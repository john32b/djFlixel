/**
  ++ FlxAutoText
  
  - Autotype Effect with a simple in-string tag system.
  
  TAGS::
  
  - Put tags in curly brackets, like so {key:value}
  - Supports multiple keys in brackets {key1:val, key2:val}
  
  - Codes {
  
  		c:INT		: set Characters Per Second
  		w:INT		: Wait for (100*INT Seconds). So w:10 waits for one second
 		wm:INT		: Enable word mode. Writes a word at current CPS and Waits for (INT*100 Seconds). 0 to DISABLE
  		call:String	: Calls onEvent(call(customcall)) when encountered
  		np			: Force a new page -- DON'T COMBINE WITH SP on the same {} . No Parameter, you can even write {np} 
  		sp:INT		: Special Codes ::
						0,1 Turn Caret on/off
	}
  
  DEV NOTES ::
	- The {np} tag is stored in the .sp field on the metadata as (100)
	- In case the height is not reporting  I can just call `autotext.textObj.height` to force an flxtext regen ??
	
	
  EXAMPLE ::
  
	var AT = new FlxAutoText(0, 0, 300);
		AT.style = { f:"fonts/pixel.ttf", s:16, c:0xFFFF00};
		AT.onComplete = ()->{ trace("Text complete"); };
		AT.setCaret('-', 0.15);
		AT.setText( '{c:10,sp:0}HELLO WORLD{w:10,sp:1,c:4}!!!!{w:3}' );
		add(AT);
 **/

package djFlixel.ui;

import djA.DataT;
import djFlixel.core.Dtext.DTextStyle;
import flash.text.TextLineMetrics;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;


enum AutoTextEvent {
	pause;		// The flow is currently paused, requires a resume(); call to resume
	resume; 	// resume() was just called
	complete; 	// Text has finished
	newline;	// A new line has been written
	newpage;	// New page due to overflow 
	call(msg:String); // Custom callbacks
}

class FlxAutoText extends FlxSpriteGroup
{	
	// :: Some defaults
	static inline var DEFAULT_CPS = 30;
	static inline var DEFAULT_CARET_TICK = 0.24;
	static inline var DEFAULT_CARET_SMB = "_";

	// Invisible Character
	static var INV_CHAR='‎';
	
	// :: The markup tags
	inline static var TAG_CPS= 		'c';	// cps
	inline static var TAG_WAIT= 	'w';	// wait
	inline static var TAG_WORD= 	'wm';	// word mode
	inline static var TAG_SP= 		'sp'; 	// special
	inline static var TAG_NP= 		'np'; 	// newpage (stored in the SP int)
	inline static var TAG_CALL = 	'call';
	
	// Limit text update to this time as the lowest value
	public static var MIN_TICK = 0.10;

	var TAGS:Array<AutoTextMeta>; // Hold ALL the MetaData objs
	var nextTagIndex:Int;
	
	var cps:Int; 			// current CPS, use setCPS()
	var lastTW:Float;		// if >0 then it's waiting, after waiting, restore (tw) to this value
	var timer:Float;		// Hold the last update time
	var tc:Int;				// Characters to push at next time update
	var tw:Float;			// Current time wait time until next char update
	var wordWait:Int;		// if >0 then word mode is enabled and value is the wait time after each word
	var wordNextSpace:Int;  // hold the index of the next space, used if wordWait is enabled
	
	var lineBreaks:Array<Int>;	// Store the indexes of all line breaks
	var linesMax:Int;			// If the textbox has a max number of lines. SET in constructor
	var lineCurrent:Int;		// The line index (starting at 1) that the text is being drawn at
	
	var textStart:Int;			// Start drawing from this character. This is to manage multiple lines and newpages
	var textIndex:Int;			// Up to which index characters are to be rendered (0 means none)
	
	var newpageFlag:Bool;		// If true it will cut the text to currentIndex at the next update cycle, newpage
	
	// -- Caret
	var caretEnabled:Bool = false;
	var caret:FlxSprite = null;		// The caret sprite
	var caretBlinkRate:Float;		// Current blink rate
	var caretOffsets:Array<Int>;	// X,Y offset of caret position
	var caretTimer:Float; 			// Caret blink rate handled in update();
	
	// The actual flxText object
	public var textObj(default, null):FlxText;
	
	// If set then this textstyle will be applied to the text
	public var style(default, set):DTextStyle;

	/** Is it currently Paused */
	public var isPaused(default, null):Bool;
	
	/* Is it currently done displaying all text */
	public var isComplete(default, null):Bool;

	/** Final text to be displayed (with no tags, they are processed and stored elsewhere) */
	public var text(default, null):String;
	
	/** Broadcast Events, usually set by a dialogBox */
	public var onEvent:AutoTextEvent->Void;
	
	/** Called when the entire string is displayed | same as onEvent(complete); */
	public var onComplete:Void->Void;
	
	/** If set, then it will automatically play the soundID */
	public var sound = {
		char:null,	// On character being typed
		wait:null,	// On a Wait
		pause:null  // On a Pause
	};
	
	/** When the text flow reaches end of a page, wait this amount of time 
	 *  to go to the next page. Set 0 to WAIT. Value is *100ms, so 9 is 900ms */
	public var newpageWait:Int = 9;
	
	// True to enable verbose logging
	public static var _dlog:Bool = false;

	//====================================================;
	
	/**
		Create an FlxAutoText, a textbox that will autotype text. Check file header for info.
	   @param	X Screen Pos
	   @param	Y Screen Pos
	   @param	FieldWidth 0 For Single Line | -1 For rest of the view area, mirrored x margin amount
	   @param	Lines How many lines to use 0 for infinite -- New page only on command
	**/
	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, Lines:Int = 0)
	{
		super(X, Y);
		linesMax = Lines;
		if (FieldWidth ==-1) FieldWidth = FlxG.width - (x * 2);
		textObj = new FlxText(0, 0, FieldWidth, null); // DEV setting 0 to FieldWidth makes wordwrap=false
		add(textObj);
		moves = active = false;
		setCPS(DEFAULT_CPS);
	}//---------------------------------------------------;
	
	override function get_width():Float 
	{
		return textObj.width;
	}//---------------------------------------------------;
	
	// --
	override public function destroy()
	{
		super.destroy();
		TAGS = null;
		lineBreaks = null;
	}//---------------------------------------------------;	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// -- Blink Caret
		if (caretEnabled && ((caretTimer += elapsed) >= caretBlinkRate)) {
			caret.visible = !caret.visible;
			caretTimer = 0;
		}
		
		// -- Update Text
		if ( !isPaused && (timer += elapsed) >= tw)
		{
			// First thing first, check for linecuts
			if (newpageFlag)
			{	
				// New page from a {np} tag
				// Remove the linebreak from the checks, so it doesn't
				// TODO: WARNING: No new line event will be sent, should it?
				if(lineBreaks[0]==textIndex) {
					lineBreaks.shift();
				}
				
				// do not print the \n at the tag position since I am clearing manually
				// occurs on auto and custom page skips
				if (["\n", "\r"].indexOf(text.charAt(textIndex)) >= 0) {
					textIndex++;
				}

				newpageFlag = false;
				lineCurrent = 1;
				textStart = textIndex;
				event_c(newpage);
			}
			
			timer = 0;
			textIndex += tc;
			
			// :: Waiting in effect and just stopped waiting
			if (lastTW > 0)
			{
				tw = lastTW;
				lastTW = 0;
			}
			
			// :: WordMode is enabled
			if (wordWait > 0) // dev: Assumes that nextSpace is checked
			{
				if (wordNextSpace > -1 && textIndex >= wordNextSpace) // Reached or just passed a space.
				{
					textIndex = wordNextSpace + 1;
					calcNextWordSpace();
					wait(wordWait);
				}
			}
			
			// :: Check for TAGS and stop if jumped
			if (nextTagIndex >-1 && textIndex > nextTagIndex)
			{
				textIndex = nextTagIndex;
			}
				
			// :: Check for linebreaks
			if (lineBreaks.length > 0)
			{
				while (textIndex > lineBreaks[0]) // Doing while loop, In case it jumps more than one line break
				{
					var breakIndex = lineBreaks.shift();
					if (linesMax > 0 && lineCurrent >= linesMax) // -- overflow --
					{
						textIndex = breakIndex;	// Go back to the line cut
						newpageFlag = true;
						// DEV: using a flag to do the newpage at the next update, because it might pause or wait here
						wait(newpageWait);
						break;
					}else{
						lineCurrent++;
						event_c(newline);
					}
					if (lineBreaks.length == 0) break;
				}
			}

				
			// :: Check for Text End	
			if (textIndex >= text.length)
			{
				textIndex = text.length;
				// DEV: The text passed the ending mark and there are no tags to process
				//      I can end the animation safely. Else if there are tags, continue 
				//      so they can be processed
				// DEV: Even if 'newpageFlag' I can end now, it doesn't make any sense to newpage
				//      when the text is going to end
				if (TAGS.length == 0){
					caret_state(false);
					textObj.text = text.substr(textStart, textIndex - textStart);
					active = false;
					//if (sound.char != null) D.snd.playV(sound.char);
					isComplete = true;
					if (onComplete != null) onComplete();
					event_c(complete);
					return;
				}
			}
			
			// :: RE-Check for tags at current
			tags_check_and_apply();

			// :: Render
			textObj.text = text.substr(textStart, textIndex - textStart);	// substr is by length

			// == OPENFL/FLIXEL BUG
			// Immediately after a new line the textmetrics are not being updated right away
			// In FLASH it works ok but everything else has this problem
			// == FIX
			if(textObj.text.charAt(textObj.text.length-1) == '\n')
				textObj.text += INV_CHAR;

			if (sound.char != null) D.snd.playV(sound.char);
			
			if (caretEnabled)
			{
				caret_update();
				caretTimer = 0;			// Reset the time, wait a full (TICK) again
				caret.visible = true;	// This is for effect, show the caret right when text appears
			}
		}
	}//---------------------------------------------------;
	
	
	/**
	   Prepare a string to be AutoTexted
	   - Resets already going text
	   @param	source Text, supports tags - *Check this doc header for more info*
	   @param	start Auto start , else do active=true to start
	**/
	public function setText(source:String, start:Bool = true)
	{
		text = tags_parse(source); // Will also set TAG[] to new data
		
		// Init vars
		isPaused = isComplete = false;
		textIndex = textStart = 0;
		lineCurrent = 1;
		timer = 0;
		lastTW = 0;
		wordWait = 0;
		wordNextSpace = 0;
		
		// -- Fix Line Brakes
		textObj.visible = false;
		textObj.text = text; // text is without any tags now.
		
		// -- Prebake linebreakes
		text = getBakedLineBrakes();
		
		textObj.text = INV_CHAR; // this is to give an initial height to the object
		textObj.visible = true;
		
		// -- Calculate linebreaks
		lineBreaks = [];
		for (i in 0...text.length){
			var c = text.charAt(i);
			if (c == "\r" || c == "\n"){
				lineBreaks.push(i);
			}
		}

		#if debug
			if (lineBreaks.length > 0 && !textObj.wordWrap)
				FlxG.log.error("FlxAutoText with fieldwidth 0 is only for single line texts");
			if(_dlog) {
				var str = StringTools.replace(text,'\n','|nl|\n');
				trace('== Text (starts in next line) Symbols: |nl| |end| :\n${str}|end|');
				trace('== Tags : ');
				for(t in TAGS) trace('  ' ,t);
				trace('== Linebreaks : ', lineBreaks);
			}
		#end
		
		// -- Applying the First TAGS right now
		tags_calc_next();
		tags_check_and_apply();

		if (start) active = true;
	}//---------------------------------------------------;
	
	
	/**
	   Set a caret, you can either set a CHARACTER or a custom SPRITE not both
	   e.g.
			setCaret('_',0.2);
			setCaret(new FlxSprite(...));
	 @param offsets [x,y] offsets in Array
	 @param tick Override Blinking Time Interval
	**/
	public function setCaret(?symbol:String = DEFAULT_CARET_SMB, ?spr:FlxSprite = null, 
							offsets:Array<Int> = null, tick:Float = DEFAULT_CARET_TICK)
	{
		var C:FlxSprite;
		if (spr == null) {
			C = cast D.text.get(symbol, style);	
		}else{
			C = spr;
			C.moves = false;
		}
		if (offsets == null) offsets = [0, 0];	// DEV: I can't put it as default function argument.
		add(caret = C);
		caretEnabled = true;
		caretBlinkRate = tick;
		caretTimer = 0;
		caret.visible = false;
		caretOffsets = offsets;
	}//---------------------------------------------------;	

	// Set Carrier? wtf was I thinking. Caret is the correct term.
	@:deprecated("Use setCaret()")
	public function setCarrier(?a:String = DEFAULT_CARET_SMB, ?b:FlxSprite = null, 
		c:Array<Int> = null, d:Float = DEFAULT_CARET_TICK) { setCaret(a,b,c,d); }
	
	/**
	 * Set the Characters Per Second
	 * @param	cps 1 Is the slowest speed, 0 for instant
	 */
	public function setCPS(v:Int)
	{		
		cps = v;
		timer = 0; // Reset the timer, so next update will happen in (tw) seconds
		if (cps == 0) { // Try to push a bunch of characters at once.
			tc = 9999;
			tw = 0;   
			return;
		}
		
		var R = 1 / MIN_TICK; 	// How many ticks per seconds ( e.g. 8.3 )
		var TC = cps / R; 		// This many updates of (MIN_TICK) to push all cps in a second
		
		if (TC >= 1) { // So, if >1, then I can complete CPS in (MIN_TIC) updates of (TC) len chars
			tc = Std.int(TC);
			tw = MIN_TICK;
		} else { // if <1 then the CPS is slow enough to be a able to push a character at minimum ticks + offset time
			tc = 1;
			tw = MIN_TICK * (1 / TC);
		}
		#if debug
		if(_dlog) trace('Set | cps=$cps | tc=$tc | tw=$tw');
		#end
	}//---------------------------------------------------;
	
	/** Pause the flow, await a resume() */
	public function pause()
	{
		wait(0);
	}//---------------------------------------------------;
	
	/** Resume the flow if paused */
	public function resume()
	{
		if (!isPaused) return;
			isPaused = false;
		if (wordWait>0) calcNextWordSpace();
		timer = tw; // Force next update now
		event_c(AutoTextEvent.resume);
	}//---------------------------------------------------;
	
	/**
	  Hold the flow for a predefined set of time.
	  In 100 Milliseconds. 1 is 100ms, 2 is 200ms, 10 is 1sec, 20 is 2seconds, 100 is 10 seconds. etc
	  Set 0 to WAIT, resume with resume()
	 */
	public function wait(value:Int = 5)
	{
		if (value == 0)
		{	
			if (isPaused) return;
				isPaused = true;
			if (sound.pause != null) D.snd.playV(sound.pause);
			event_c(AutoTextEvent.pause);
			return;
		}
		
		if (lastTW == 0) lastTW = tw; // tw will be restored to this after done counting down
		tw = value * 0.1;
		if (sound.wait != null) D.snd.playV(sound.wait);
	}//---------------------------------------------------;
	
	/** Stop the text, and optionally reveal the full thing */
	public function stop(showFull:Bool = false)
	{
		/// TODO : Calculate the final-final text, accounting for linebreaks/newpages that are stored in METADATA?
		if (showFull && text != null)
		{
			textIndex = text.length;
			textObj.text = text.substr(textStart, textIndex - textStart);
		}
	
		caret_state(false);
		timer = 0;
		active = false;
	}//---------------------------------------------------;
	
	
	// Find where the next space occurs
	// :: Called when word mode is actived
	//    stops flow at the index of the next space
	function calcNextWordSpace()
	{
		for (i in (textIndex + 1)...text.length)
		{
			if (text.charAt(i) == " ")
			{
				wordNextSpace = i;
				return;
			}
		}
		// Didn't find any space
		wordNextSpace = -1;
	}//---------------------------------------------------;
	

	/**
	   - Fills the TAGS[] array with the tag data from the string
	   - Returns a clean string without the tags
	**/
	function tags_parse(source:String):String
	{
		var REG:EReg = ~/{([^}]+)}/g;
		TAGS = [];
		
		if (REG.match(source))
		{
			var indAcc = 0;	// Index Accumulator
			
			// DEV: I am going to check for each Captured Group, and replace it with "" on the source string
			source = REG.map(source, (r:EReg)->{
				var m = r.matched(1);
				
				var data:AutoTextMeta = {
					index:r.matchedPos().pos - indAcc
				};
				
				// Get the CSV string into a MAP and process each key in the MAP
				for (k => v in DataT.getCSVTable(m)) {
					switch(k) {
						case TAG_CPS:  data.cps = DataT.intOrZeroFromStr(v);
						case TAG_CALL: data.call = v;
						case TAG_WAIT: data.wait = DataT.intOrZeroFromStr(v);
						case TAG_WORD: data.word = DataT.intOrZeroFromStr(v);
						case TAG_SP:   data.sp = DataT.intOrZeroFromStr(v);
						case TAG_NP:   data.sp = 100;
						default: data = null;
								 trace('Error Parsing `$m` at ', r.matchedPos());
					}
				}
				
				// Check for null because on parse error I don't want it
				if (data != null) TAGS.push(data); 
				
				indAcc += r.matchedPos().len;
				return "";
			});
		}
		
		return source;
	}//---------------------------------------------------;
	
	/** Check if current textIndex has a TAG and applies
	 */
	function tags_check_and_apply()
	{
		if (textIndex != nextTagIndex) return;
		var t:AutoTextMeta = TAGS.shift();	// This is guaranteed to have elements

		#if debug
		if(_dlog) {
			trace('Applying tags', t);
			trace('LineText (before update): |' + textObj.textField.getLineText(textObj.textField.numLines - 1) + '|');
			trace('TextIndex: ${textIndex} | TextStart:${textStart}'); }
		#end
		
		if (t.call != null) {
			event_c(call(t.call));
		}
		if (t.cps != null) {
			setCPS(t.cps);
		}
		if (t.sp != null) {
			switch(t.sp) {
				case 0: caret_state(false);
				case 1: caret_state(true);
				case 100: newpageFlag = true;
				default:
			}
		}
		if (t.wait != null) {
			if (t.wait == 0) pause(); else wait(t.wait);
		}
		if (t.word != null) {
			wordWait = t.word;
			calcNextWordSpace();
		}
		
		tags_calc_next();
	}//---------------------------------------------------;

	
	/**
	   Checks to see the upcoming TAG and fills `nextTagIndex`
	**/
	function tags_calc_next()
	{
		if (TAGS.length == 0)
			nextTagIndex = -1; 
		else
			nextTagIndex = TAGS[0].index;
	}//---------------------------------------------------;
	
	/**
	 * - Called on update(); updates caret pos
	 */
	function caret_update()
	{
		var numLines = textObj.textField.numLines;
		// Text Metrics for the LAST line
		var tm:TextLineMetrics = textObj.textField.getLineMetrics(numLines - 1);

		caret.y = this.y + caretOffsets[1] + ((numLines - 1) * (tm.height));
		caret.x = this.x + tm.width + caretOffsets[0];

		// trace("CARET UPDATE >>>>");
		// trace('NumLines(tbox):',numLines);
		// trace('LineCurrent:', lineCurrent);
		// trace('Text:|' + textObj.textField.getLineText(numLines - 1)+'|');
		// trace('Metrics | w:${tm.width} h:${tm.height}');
		// trace("-------\n");
	}//---------------------------------------------------;
	
	/**
	   Set caret on or off
	**/
	function caret_state(enabled:Bool)
	{
		#if debug
		if(_dlog)trace("= Caret state :" + enabled);
		#end
		if (caret == null) return;
		caret.visible = enabled;
		caretEnabled = enabled;
		caretTimer = 0;
		//if(enabled) caret_update(); // NO: when it is called from a TAG, the position will be updated on the same function later
	}//---------------------------------------------------;
	
	
	/** Quickly callback an event */
	inline function event_c(e:AutoTextEvent)
	{
		#if debug
		if(_dlog) trace('= Event :' , e);
		#end
		if (onEvent != null) onEvent(e);
	}//---------------------------------------------------;
	
	
	/**
	 * Reads the textfield, bakes the linebreaks and returns a string with linebreaks (\n) in it.
	 * PRE: TextField MUST be set to the final text
	 * NOTE: Also shifts the TAGS indexes
	 * This is really useful to not have words jump on the line below if they get out of area width.
	 * ----
	 * http://troyworks.com/blog/2011/06/09/flash-as3-detect-undesired-line-break-in-textfield-wordwrap-is-true/
	 */
	function getBakedLineBrakes():String
	{
		var t = ""; // Final String with linebreaks
		var lii:Int = 0;
		var lcc = "";
		for (ci in 0...textObj.textField.length)
		{ 
			var cc:String = textObj.textField.text.charAt(ci); 
			var li:Int = textObj.textField.getLineIndexOfChar(ci); 
			if (li != lii) { // NEW LINE
				if (lcc != "\r" && lcc != "\n") {
					t += "\n"; // BROKEN WORD
					// - Shift the tags from index (ci) because I just added '\n' to the final string
					for (tg in TAGS) {
						if (tg.index >= ci) tg.index++;
					}
				}
			}
			t +=  cc;
			lii = li;
			lcc = cc;
		}
		return t;
	}//---------------------------------------------------;

	
	// SETTER -
	function set_style(val:DTextStyle):DTextStyle
	{
		style = val;
		D.text.applyStyle(textObj, style);
		return val;
	}//---------------------------------------------------;
	
}// -- end -- //




// -- Stores a text MARKUP tag
typedef AutoTextMeta = {
	?cps:Int,		// Characters per second
	?wait:Int, 		// Wait Time
	?word:Int, 		// Word mode, store the wait time after each word
	?sp:Int, 		// Special codes, like buttonpress,erase,blink,etc
	?call:String,	// User String attached, Currently used for callbacks
	index:Int   	// The index of the TAG in the finalstring
};//------------------------------------;

