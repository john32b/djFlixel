package djFlixel.gui;

import djFlixel.gui.Styles;
import djFlixel.gui.Styles.TextStyle;
import flash.text.TextLineMetrics;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;


/**
 * FlxAutoText
 * Simple Autotext / Autotype effect FlxText
 * -------------------------------------
 * 
 * NOTES :
 * 		+ AutoBakes linebreaks
 * 		+ Access "textObj" if you want to manipulate aligning etc.
 * 		+ Supports a carrier text e.g.  "_" or "."
 * 		+ You can use setCarrierSymbol("-"); To quickly add a carrier character
 *		+ wordWait mode , follows the currently set CPS
 *      + You can set the maximum lines
 *
 * USAGE :
 * 		new FlxAutoText(0,0,128,3); 128 width, 3 maximum lines
 * 		.start("String With Markup tags",onComplete);
 * 
 * MARKUP TAGS:
 * 
 * 		(cN) for CPS 	   		 / 1 is the slowest you can set. 0 for instant flow
 * 		(w1...n) for waits     	 / 1 to 9 read from TABLE, 9.. is n/4
 * 		(w0) pause			  	 / Pause and await a resume() call
 * 		(mN) for wordWait		 / Enables word wait, where words fill normally and waits at " " and "-"
 * 		(p0),(p1)				 / New Page, p0 = no wait, p1 = pause
 * 		(s0),(s1)				 / s0=enable carrier, s1=disable carrier
 * 		(f=hello) for callbacks  / Will call onEvent("@hello");
 * 		
 * 			N = Number. e.g. "(c3)Hello (w4)World"
 * 
 * DEVNOTES:
 * 		+ Is a SpriteGroup, because it may include a carrier sprite.
 *		+ Waittimes are based on a table, check WAIT_TABLE, which you can change
 * 
 **/

class FlxAutoText extends FlxSpriteGroup
{	
	// -- Some defaults
	static inline var DEFAULT_CPS:Int = 15;
	static inline var DEFAULT_CARRIER_TICK:Float = 0.24;
	static inline var DEFAULT_WIDTH:Int = 128;
	
	// Minimum text update frequency
	public static var DEFAULT_MIN_TICK:Float = 0.12;
	
	// -- The markup tags
	// - The chars go inside parenthesis + integer .e.g. (c3)
	inline static var TAG_CPS:String 	= 'c';
	inline static var TAG_WAIT:String 	= 'w';
	inline static var TAG_SP:String 	= 's';
	inline static var TAG_WORD:String 	= 'm';
	inline static var TAG_NP:String 	= 'p';
	
	// Wait times, affect the (w) and (m) tags, and the waitX() function
	public static var WAIT_TABLE = [0.1, 0.3, 0.5, 0.7, 1, 1.5, 2, 3, 4, 5];	
	
	// The actual flxText object
	public var textObj(default, null):FlxText;
	
	// Current minimum tick
	public var MIN_TICK:Float;
	
	// --
	var currentLength:Int;	// Length displayed of the final string. Displays characters up until but not inclusive.
	var targetLength:Int;	// Short for targetText.length
	var targetText:String;
	var textOffset:Int;		// Used for multi-paging
	
	// --
	var TAGS:Array<AutoTextMeta>;	// Hold ALL the MetaData 
	var nextTAGIndex:Int;			// Hold the next tag's string index, so it doesn't get jumped over
	
	//--
	var timer:Float;	// Hold the last update time
	var cps:Int; 		// current CPS, use setCPS()
	var tc:Int;			// Characters to push at next time update
	var tw:Float;		// Current time wait time until next char update
	var lastTW:Float;	// if >0 then it's waiting, after waiting, restore (tw) to this value
	// --
	var wordWait:Int;	// if >0 then word mode is enabled and value is the wait time after each word
	var nextSpace:Int;  // hold the index of the next space, used if wordWait is enabled
	
	// -- LINES
	var lineBreaks:Array<Int>;	// Store the indexes of all line breaks
	var linesMax:Int;			// If the textbox has a max number of lines
	var newpageFlag:Bool;		// If true it will cut the text to currentIndex at the next update cycle, newpage
	
	public var lineCurrent(default, null):Int;	// Current line the text is being written to (1...n)
	public var lineHeight(default, null):Int;	// Line height in pixels
	
	// -- CARRIER 
	var carrierEnabled:Bool = false;
	var carrier:FlxSprite = null;
	var carrierBlinkRate:Float;
	var carrierOffsetX:Int;
	var carrierOffsetY:Int;
	var carrierTimer:Float; // Carrier blink rate handled on the update();
	
	// - Is it currently paused
	public var isPaused(default, null):Bool;
	
	// -- USERSET --
	// If set, then it will automatically play the soundID
	public var sound:Dynamic = {
		char:null,	// On character being typed
		wait:null,	// On a Wait
		pause:null  // On a pause
	};

	
	// If the lines reach MaxLines, how to behave
	// "pause" - Pause the flow and await a resume()
	// "waitx" - Wait for a bit,then auto resume. wait0.....wait9 according to the WAIT_TABLE
	public var overflowRule:String = "pause";
	
	// If set then this textstyle will be applied to the text
	public var style(default, set):TextStyle;
	
	// Get the number of lines that the final state will be at
	public var numberOfLines(default, null):Int;
	
	//  - Called when the entire string is displayed
	//  - same as onEvent("complete");
	public var onComplete:Void->Void;
	
	// - Broadcast Events, usually set by a dialogBox
	// pause 	- The flow is currently paused, requires a resume(); call to resume
	// resume 	- resume() was just called
	// complete - Text has finished
	// newline 	- A new line has been written
	// newpage  - New page due to overflow 
	// @......  - Custom callbacks
	public var onEvent:String->Void;
	//====================================================;
	/**
	 * 
	 * @param	X Screen X
	 * @param	Y Screen Y
	 * @param	FieldWidth 
	 * @param	maxLines 0 for infinite lines
	 */
	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = DEFAULT_WIDTH, maxLines:Int = 0)
	{
		super(X, Y);
		// Create the text object
		textObj = new FlxText(0, 0, FieldWidth, null);
		textObj.wordWrap = true;
		linesMax = maxLines;
		add(textObj);
		active = false;
		lineHeight = 10; // precalculated value if default text style is used.
		MIN_TICK = DEFAULT_MIN_TICK;
		setCPS(DEFAULT_CPS); // default
	}//---------------------------------------------------;
	// --
	override public function destroy():Void 
	{
		super.destroy();
		TAGS = null; lineBreaks = null;
	}//---------------------------------------------------;	
		
	/**
	 * Set the Characters Per Second
	 * @param	cps 1 Is the slowest speed, 0 for instant
	 */
	public function setCPS(v:Int)
	{		
		cps = v;
		timer = 0; // Reset the timer, so next update will happen in (tw) seconds
		
		if (cps == 0) // Special case,
		{
			tc = 9999; // I think it's big enough?
			tw = 0; // No wait
			return;
		}
		
		var R = 1 / MIN_TICK; // How many ticks per seconds
		var TC = cps / R; // TEMP, same as tc but FLOAT. What is the spread of characters per tick in a second
		
		if (TC >= 1) // More than 1 CharsPerTick
		{
			tc = Std.int(TC);
			tw = MIN_TICK;
		}
		else
		{
			tc = 1;
			tw = MIN_TICK * (1 / TC);
		}
		
		//trace('SetCPS, cps=$cps | tc=$tc | tw=$tw');
	}//---------------------------------------------------;
	
		
	/**
	 * Use a symbol for a carrier, e.g. "_"
	 * NOTE: Set this after setting a style
	 * @param	symbol
	 */
	public function setCarrierSymbol(symbol:String)
	{
		// Try to copy the style of the main text
		var c = new FlxText(0, 0, 0, symbol, textObj.size);
			c.font = textObj.font;
			c.color = textObj.color;
		if (style != null) Styles.applyTextStyle(c, style);
		setCarrierSprite(cast c);
	}//---------------------------------------------------;
		
	/**
	 * Use an FlxSprite as a carrier. AutoActivates the carrier
	 * @param	symbol Any FlxSprite
	 * @param	offsetX Custom offset the carrier X position, useful to tweaking 
	 * @param	offsetY Custom offset the carrier Y position, useful to tweaking
	 */
	public function setCarrierSprite(symbol:FlxSprite, offsetX:Int = 0, offsetY:Int = 0 )
	{
		carrierBlinkRate = DEFAULT_CARRIER_TICK;
		carrier = symbol;
		carrierTimer = 0;
		add(carrier);
		carrierOffsetX = offsetX; carrierOffsetY = offsetY;
		carrierEnabled = true;
		carrierUpdatePos();
		carrier.visible = false; // Start off as not visible so it only start updating after the first start();
	}//---------------------------------------------------;
	

	/**
	 * Update Position of the carrier sprite if any
	 */
	function carrierUpdatePos()
	{
		if (!carrierEnabled) return;
		var tm:TextLineMetrics = textObj.textField.getLineMetrics(textObj.textField.numLines - 1);
		// Update Position
		carrier.visible = true;
		carrier.x = this.x + tm.width + carrierOffsetX;
		carrier.y = this.y + carrierOffsetY + (textObj.textField.numLines - 1) * (tm.height + tm.leading);
		if (carrier.x >= this.x + textObj.width) {
			carrier.x = this.x;
			carrier.y += (tm.height + tm.leading);
		}
		carrierTimer = 0;
	}//---------------------------------------------------;
	
	// -- Quickly turn the carrier off
	function carrierOff()
	{
		if (carrier == null) return;
		carrier.visible = false;
		carrierEnabled = false;
	}//---------------------------------------------------;
	
	
	// -- Useful when you want to hide the text for a bit, before feeding new data to it.
	public function clearAndWait()
	{
		active = false;
		textObj.text = "";
	}//---------------------------------------------------;
	
	
	/**
	 * Start animating the FlxText to a target String.
	 * @param Text The text to animate to. USES MARKUP for speed settings.
	 * @param onComplete Void callback called on completion.
	 */
	public function start(_text:String, ?_onComplete:Void->Void)
	{
		currentLength = 0;
		textOffset = 0;
		timer = 0;
		lastTW = 0;
		nextSpace = 0;
		wordWait = 0;
		lineCurrent = 1;
		TAGS = [];
		onComplete = _onComplete;
		active = true;
		isPaused = false;
		
		// ::: READ TAGS :::
		
		// Capture all the possible tags at once
		// reg =  \(([c|w|s|m]\d+|f=\w+)\)
		var reg = new EReg('\\((\\w\\d+|f=\\w+)\\)', 'g');
		
		// -- Store the processed INDEX of each TAG into the hash
		if (reg.match(_text))
		{
			var indAcc:Int = 0;
			
			_text = reg.map(_text, function(reg:EReg) {
				var match = reg.matched(0);
				var trueIndex = reg.matchedPos().pos - indAcc;
				 //trace(' + REG MATCH $match at $trueIndex');
				 //trace('  Index Accumulator = $indAcc');
				
				var data:AutoTextMeta;
				if (TAGS.length == 0 || TAGS[TAGS.length - 1].index != trueIndex){
					data = {index:trueIndex};
					TAGS.push(data);
				}else{
					data = TAGS[TAGS.length - 1];
				}
				// 2 types of tags, (c0) or (f=hello)
				if (match.charAt(1) == "f")
				{
					data.call = match.substr(3, match.length - 4);
				}else
				{
					var number:Int = Std.parseInt(match.substr(2));
					switch(match.charAt(1)) {
						case TAG_CPS : data.cps = number;
						case TAG_WAIT : data.wait = number;
						case TAG_WORD : data.word = number;
						case TAG_SP   : data.sp = number;
						case TAG_NP   : data.np = true; if (number == 1) data.wait = 0; // (p1) will pause();
						case _: trace("Error: Unsupported TAG");
					}
				}
			
				//trace('  Setting DATA at index:$trueIndex with data', data);
				indAcc += reg.matchedPos().len;
				return "";
				// Note: It all works OK, I checked.
			});
						
		}// -- end reg matched

		// -- Fix Line Brakes
		textObj.visible = false;
		textObj.text = _text; // _text is without any tags now.
		
		// -- Prebake linebreakes
		targetText = getBakedLineBrakes();
		targetLength = targetText.length;
		textObj.text = ""; textObj.visible = true;
		
		// -- Calculate Linebreaks
		numberOfLines = 1;
		lineBreaks = [];
		for (i in 0...targetLength){
			var c = targetText.charAt(i);
			if (c == "\r" || c == "\n"){
				numberOfLines++;
				lineBreaks.push(i);
			}
		}
		
		// --
		if (TAGS.length > 0) nextTAGIndex = TAGS[0].index; else nextTAGIndex = -1;

		// Check for any times set at the first index.
		checkTagsAtCurrentLen();
	}//---------------------------------------------------;
	
	/**
	 * Checks and processes tags at current string index
	 */
	function checkTagsAtCurrentLen()
	{
		if (TAGS.length > 0 && nextTAGIndex == currentLength)
		{
			var data = TAGS.shift();
			
			if (TAGS.length > 0) nextTAGIndex = TAGS[0].index; else nextTAGIndex = -1;

			// Order is important, check for CPS first
			if (data.cps  != null) setCPS(data.cps);
			if (data.wait != null) {
				if (data.wait == 0) pause(); else waitX(data.wait);
			}
			if (data.word != null) {
				wordWait = data.word;
				searchNextSpace();
			}
			if (data.sp != null)
			{
				switch(data.sp)
				{
					case 0: // Disable Carrier
						carrierOff();
					case 1: // Enable Carrier
						carrierEnabled = true;
					default:
				}
			}
			if (data.call != null)
			{
				// Check for the first char and then use .substr(1) to get the string
				if (onEvent != null) onEvent("@" + data.call);
			}
			if (data.np != null)
			{
				// It has to be true, will never be false
				newpageFlag = true;
			}
		}
	}//---------------------------------------------------;
	

	/**
	 * Find where the next space occurs
	 * :: Called when word mode is actived
	 * 	  stops flow at the index of the next space
	 */
	function searchNextSpace()
	{
		for (i in (currentLength + 1)...targetLength)
		{
			if (targetText.charAt(i) == " ")
			{
				nextSpace = i;
				return;
			}
		}
		// Didn't find and space
		nextSpace = 0;
	}//---------------------------------------------------;
	
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// -- Blink the carrier
		if (carrierEnabled && ((carrierTimer += elapsed) >= carrierBlinkRate)) {
			carrier.visible = !carrier.visible;
			carrierTimer = 0;
		}
		
		// --Update Character
		if (!isPaused && (timer += elapsed) >= tw)
		{
			
			// First thing first, check for linecuts
			if (newpageFlag)
			{	
				if (["\n", "\r"].indexOf(targetText.charAt(currentLength)) >= 0) {
					currentLength++;
					// DEV: Skip newlines, I check because it might be a custom newpage and not from a newline
				}
				newpageFlag = false;
				lineCurrent = 1;
				textOffset = currentLength;
				if (onEvent != null) onEvent("newpage");
			}
			
			// ::
			
			timer = 0;
			currentLength += tc;
			
			if (lastTW > 0) // Done Waiting
			{
				tw = lastTW;
				lastTW = 0;
			}
			
			// WordMode is enabled
			if (wordWait > 0) // devnote: Assumes that nextSpace is checked
			{
				if (nextSpace > 0 && currentLength >= nextSpace) // Reached or just passed a space.
				{
					currentLength = nextSpace + 1;
					searchNextSpace();
					waitX(wordWait);
				}
			}
			
			if (nextTAGIndex > 0 && currentLength > nextTAGIndex)
			{
				// Stop here so that next check will check for the current tag;
				currentLength = nextTAGIndex;
			}			
			
			// :: LineCheck
			if (lineBreaks.length > 0)
			{
				while (currentLength >= lineBreaks[0]) // In case it jumps more than one LINE
				{
					var lineindex = lineBreaks.shift();

					if (linesMax > 0 && lineCurrent >= linesMax) //-- OVERFLOW --
					{
						currentLength = lineindex; // Go back to the line cut
						newpageFlag = true;
						// :: OVERFLOW CHECK
						if (overflowRule.substr(0, 4) == "wait"){
							waitX(Std.parseInt(overflowRule.substr(4))); // get the number portion of "waitx"
						}else{ // It's going to be pause or other
							pause(); 
						}
						
						break;
					}else{
						lineCurrent++;
						if (onEvent != null) onEvent("newline");
					}
					
					if (lineBreaks.length == 0) break;
				}
			}
			
			
			// :: Keep this check for the end
			if (currentLength >= targetLength && TAGS.length == 0)
			{
				stop(true);
				if (onComplete != null) onComplete();
				if (onEvent != null) onEvent("complete");
			}
			else 
			{	
				textObj.text = targetText.substr(textOffset, currentLength - textOffset);
				carrierUpdatePos();
				if (sound.char != null) SND.play(sound.char);
				checkTagsAtCurrentLen();
			}
			
		}// -- end timer
		
	}//---------------------------------------------------;
	
	
	/**
	 * Hold the flow for a predefined set of time.
	 * @param	value 1-9 Check the WAIT_TABLES var, 
	 */
	public function waitX(value:Int)
	{
		#if debug if(value==0) {trace("ERROR: Can't use 0 for a wait"); value=1;} #end
		if (lastTW == 0) lastTW = tw; // tw will be restored to this after done counting down
		if (sound.wait != null) SND.play(sound.wait);
		if (value > 0 && value < 11)
			tw = WAIT_TABLE[value-1]; // index 0...9
		else
			tw = value / 4; // 0.25 increments
	}//---------------------------------------------------;
	
	/**
	 * Stop the text build up.
	 * @param	showFinal If true will set to the target text
	 */
	public function stop(showFinal:Bool = false)
	{
		if (showFinal && targetText != null)
		{
			currentLength = targetLength;
			textObj.text = targetText.substr(textOffset, currentLength - textOffset);
			carrierUpdatePos(); // I don't really need this one, carrier to be turned off later
		}
		
		carrierOff();
		timer = 0;
		active = false;
	}//---------------------------------------------------;

	
	/**
	 * Pause the flow, await a resume()
	 */
	public function pause()
	{
		if (isPaused) return;
		isPaused = true;
		if (sound.pause != null) SND.play(sound.pause);
		if (onEvent != null) onEvent("pause");
	}//---------------------------------------------------;
	
	/**
	 * Resume the flow if paused
	 */
	public function resume()
	{
		if (!isPaused) return;
		isPaused = false;
		if (wordWait>0) searchNextSpace();
		timer = tw; // Force next update now
		if (onEvent != null) onEvent("resume");
		// DEV: sound on resume??
	}//---------------------------------------------------;
	
	// --
	function set_style(val:TextStyle):TextStyle
	{
		style = val;
		Styles.applyTextStyle(textObj, style);
		// -- Now it's a good time to calculate the lineHeight
		lineHeight = Std.int(textObj.textField.getLineMetrics(0).height);
		return style;
	}//---------------------------------------------------;
	
	/**
	 * Reads the textfield, bakes the linebreaks and returns a string with linebreaks (\n) in it.
	 * PRE: TextField MUST be set to the final text
	 * NOTE: Also shifts the TAGS indexes
	 * This is really useful to not have words jump on the line below if they get out of width.
	 * ----
	 * http://troyworks.com/blog/2011/06/09/flash-as3-detect-undesired-line-break-in-textfield-wordwrap-is-true/
	 */
	function getBakedLineBrakes():String
	{
		#if desktop
			trace("Warning: textfield.getLineIndexOfChar() is not supported in Desktop builds");
			return textObj.textField.text;
		#else
		
		var t = ""; // Final String with linebreaks
		var lii:Int = 0;
		var lcc = "";
		for (ci in 0...textObj.textField.length)
		{ 
			var cc:String = textObj.textField.text.charAt(ci); 
			var li:Int = textObj.textField.getLineIndexOfChar(ci); 
			if (li != lii) { // NEW LINE
				if (lcc != "\r" && lcc != "\n")
				{
					t += "\n"; // BROKEN WORD
					// - Shift the tags from index (ci) because I just added '\n' to the final string
					for (t in TAGS) {
						if (t.index >= ci) t.index++;
					}
				}
			}
			t +=  cc;
			lii = li;
			lcc = cc;
		}
		//trace(' number of lines = $numberOfLines');
		return t;
		
		#end
	}//---------------------------------------------------;

	
}// -- end -- //




// -- Stores a text MARKUP tag
typedef AutoTextMeta = {
	?cps:Int,		// Characters per second
	?wait:Int, 		// Wait Time
	?word:Int, 		// Word mode, store the wait time after each word
	?call:String,	// User String attached, Currently used for callbacks
	?sp:Int, 		// Special codes, like buttonpress,erase,blink,etc. <-- TODO
	?np:Bool,		// NewPage,
	index:Int   	// The index of the TAG in the finalstring
};//------------------------------------;

