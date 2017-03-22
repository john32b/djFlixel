package djFlixel;

import flash.display.Sprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * 
 * Simple Autotext / Autotype effect FlxText
 * -------------------------------------
 * 
 * NOTES:
 * 			+ Edit textObj if you want multiline or other
 * 			+ Supports a carrier text e.g.  "_" or "."
 * 			
 * 
 * Special markup : 
 * 
 * (s0) - (s10) - speeds, 0 is fastest
 * (w1) - (w99) - waits, 0 is wait shortest amount 
 * (c1) - (c99) - characters to display per tick. Be sure to use (c1) after other tags else it's going to skip them :-(
 * (q0),(q1) 	- carret on/off
 *  
 * e.g.
 *		start( "(c4)Hello(s1)...(w1) Is this thing on?(w3)(s4)...." );
 * 
 * - You can use setCarrierSymbol("-"); To quickly add a carrier character
 * 
 * ------------
 * 
 * TODO:
 * 
 * 	. Replace times with a better customizable system
 * 
 */

 
typedef AutoTextMeta = {
	?c:Int,
	?w:Int,
	?s:Int,
	?q:Int // Special
};//------------------------------------;
 
class FlxAutoText extends FlxSpriteGroup
{
	// -- Defaults --
	
	// How many characters per update
	static inline var TIME_CPU_DEF:Int = 1;
	static inline var TIME_SPD_DEF:Float = 0.1; // New char(s) every 0.1sec
	static inline var TIME_STEP:Float = 0.1;    // This is the slowest speed, you can set multiples
	
	// Current characters per update
	var time_CPU:Int;
	// Curent update every seconds.
	var time_FREQ:Float;
	
	// Hold the last update time
	var timer:Float;
	// --
	var currentLength:Int = 0;	// Currently displayed chars in len
	var targetLength:Int = 0;	// TargetText length in chars
	var targetText:String;
	var nextCPUrestore:Int = 0;
	// is it in the process of displaying the text or not
	// var isWorking:Bool; // TO DELETE, replaced with active=true,false
	
	// Call this after the autotext ends.
	public var onComplete:Void->Void = null;
	// Called after a character is displayed
	public var onTick:Void->Void = function() { };
	
	// Store the string metadata here with key the index letter
	var mapMetaData:Map<Int,AutoTextMeta>;
	
	// -- CARRIER ::
	var useCarrier:Bool = false;
	var carrier:FlxSprite = null;
	var carrierBlinkRate:Float = 0.2;
	var carrierOffsetX:Int = 0;
	var carrierTimer:Float; // Carrier blink rate handled on the update();
	
	// -- TEXT :
	public var textObj(default, null):FlxText;
	
	//====================================================;
	// --
	public function new(X:Float = 0, Y:Float = 0,FieldWidth:Float = 0)
	{
		super(X,Y);
		
		// Create the text object
		textObj = new FlxText(0, 0, FieldWidth, null);
		// textObj.wordWrap = false;
		add(textObj);
		
		active = false;
		mapMetaData = null;
		
		// Set the default timings
		time_FREQ = TIME_SPD_DEF;
		time_CPU = TIME_CPU_DEF;
	}//---------------------------------------------------;
		
	// -- Set a symbol and activate the carrier
	public function setCarrierSymbol(symbol:String)
	{
		// Try to copy the style of the main text
		var c = new FlxText(0, 0, 0, symbol, textObj.size);
			c.font = textObj.font;
			c.color = textObj.color;
		setCarrierSprite(cast c);
	}//---------------------------------------------------;
		
	// -- Set a symbol and activate the carrier
	public function setCarrierSprite(symbol:FlxSprite, offsetX:Int = 0, offsetY:Int = 0 )
	{
		carrier = symbol;
		carrier.visible = false;
		useCarrier = true;
		carrierTimer = 0;
		add(carrier);
		carrier.y += offsetY;
		carrierOffsetX = offsetX;
	}//---------------------------------------------------;
	
	// -- 
	private function updateCarrierPos()
	{
		if (useCarrier)
		{
			carrierTimer = 0;
			carrier.visible = true;
			carrier.x = this.x + (currentLength * textObj.size) + carrierOffsetX;
		}
	}//---------------------------------------------------;
	
	/**
	 * Sometimes if you want to set custom text times
	 * @param	UpdateFreq Update Frequency, 0.04 is the default,
	 * @param	CharsPerUpdate How many chars per update, 1 is default
	 */
	public function setSpeed(UpdateFreq:Float, CharsPerUpdate:Int = 1)
	{
		timer = 0;
		time_FREQ = UpdateFreq;
		time_CPU = CharsPerUpdate;
	}//---------------------------------------------------;
	
	/**
	 * Start animating the FlxText to a target String.
	 * # USES MARKUP FOR TEXT SPEED #
	 * @param Text The text to animate to. USES MARKUP for speed settings.
	 * @param onComplete Void callback called on completion.
	 */
	public function start(_text:String, ?_onComplete:Void->Void)
	{
		textObj.text = "";
		currentLength = 0;
		timer = 0;
		active = true;
		onComplete = _onComplete;
		
		/* Capture (s1) for speeds
		 * Capture (w1) for waits
		 * Capture (c1) for chars per tick
		 */
		var regSpeeds:EReg = ~/(\([s|w|c|q]\d+\))/g;
	
		if (regSpeeds.match(_text))
		{
			// trace("+ Reg Exp found.");
			mapMetaData = new Map();
			var indAcc = 0;
			
			_text = regSpeeds.map(_text, function(reg:EReg) {
				var match = reg.matched(0);
				var trueIndex = reg.matchedPos().pos - indAcc;
				// trace(' + REG MATCH $match at $trueIndex');
				// trace("Index Accumulator", indAcc);
				
				var data:AutoTextMeta;
				if (mapMetaData.exists(trueIndex)) {
					data = mapMetaData.get(trueIndex);
				}else {
					data = { };
				}
				
				var number:Int = Std.parseInt(match.substr(2, reg.matchedPos().len - 3));
				// trace(' Number GOT $number');
				switch(match.charAt(1))
				{
					case "s" : data.s = number;
					case "w" : data.w = number;
					case "c" : data.c = number;
					case "q" : data.q = number;
					default : trace("Error: Parse Error");
				}
				
				mapMetaData.set(trueIndex, data);
				// trace('Setting DATA at $trueIndex with data', data);
				indAcc += reg.matchedPos().len;
				return "";
				// Note: It all works OK, I checked.
			});
		}

		targetText = _text;
		targetLength = targetText.length;
		
		// Check for any times set at the first index.
		checkAndSetTime();
	}//---------------------------------------------------;
	
	// Text has been updated, check the next times
	private function checkAndSetTime()
	{
		if (mapMetaData != null && mapMetaData.exists(currentLength))
		{
			// I need to apply new variables
			var data = mapMetaData.get(currentLength);
			if (data.s != null) time_FREQ = data.s * TIME_STEP; // What about slower?
			if (data.w != null) timer -= data.w * TIME_STEP;
			if (data.q != null) useCarrier = data.q == 1;
			if (data.c != null) {
				time_CPU = data.c;
				if (time_CPU > 1) checknextCPUrestore(currentLength + 1);
			}
			
			//trace("Setting new vars to ", data);
		}

		updateCarrierPos();
	}//---------------------------------------------------;
	

	
	// Call this when setting the CPU over 1,
	// I need to know where the next CPU change occurs so
	// I can stop the text before going over another change!
	private function checknextCPUrestore(startIndex:Int)
	{
		for (i in startIndex...targetLength)
		{
			if (mapMetaData.exists(i) && mapMetaData.get(i).c != null) {
				nextCPUrestore = i;
				// trace("NEXT CPU CHANGE INDEX AT", nextCPUrestore);
				return;
			}
		}
		nextCPUrestore = 0;
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// -- Update Carrier
		if (useCarrier)
		{
			carrierTimer += FlxG.elapsed;
			if (carrierTimer >= carrierBlinkRate) {
				carrierTimer = 0;
				carrier.visible = !carrier.visible;
			}
		}
		
		// -- Update Character
		timer += elapsed;
		if (timer >= time_FREQ)
		{
			timer = 0;
			currentLength += time_CPU;
			
			// It is going to be>0 only when 2CPU and up
			if (nextCPUrestore > 0 && currentLength > nextCPUrestore)
			{
				currentLength = nextCPUrestore;
				nextCPUrestore = 0;
			}
			
			if (currentLength >= targetLength)
			{
				stop(true);
				
				if (onComplete != null) {
					onComplete();
				}
				
			}else {	
				textObj.text = targetText.substr(0, currentLength);
				checkAndSetTime();
				onTick();
			}
		}
		

	}//---------------------------------------------------;
	// --
	public function stop(showFinal:Bool = false)
	{
		if (showFinal && targetText != null)
		{
			currentLength = targetLength;
			textObj.text = targetText;
			if (useCarrier) carrier.visible = false;
		}
		
		timer = 0;
		active = false;
	}//---------------------------------------------------;
	// --
	override public function destroy():Void 
	{
		super.destroy();
		mapMetaData = null;
	}//---------------------------------------------------;	
	
}// -- end -- //