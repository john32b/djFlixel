package djFlixel;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

/**
 * 
 * Simple Autotext / Autotype effect FlxText
 * -------------------------------------
 * 
 * Special markup:
 * 
 * (s0) default speed
 * (s1) very slow
 * (s2) slow
 * (s3) faster
 * (s4) fastest
 * 
 * (w1) wait short
 * (w2) wait a bit
 * (w3) wait long
 * 
 * e.g.
 *		setDialog( "Hello(s1)...(w1) Is this thing on?(w3)(s4)...." );
 * 
 */
class FlxAutoText extends FlxText
{
	// -- Defaults --
	
	// How many characters per update
	static inline var TIME_CPU_DEF:Int = 1;
	
	// Interval for character updates
	// These apply for the markup times.
	static inline var TIME_SPEED_S0:Float = 0.08;	// Default
	static inline var TIME_SPEED_S1:Float = 0.28;   // Slower
	static inline var TIME_SPEED_S2:Float = 0.14;   // Slow
	static inline var TIME_SPEED_S3:Float = 0.08;   // Fast, 2 CPU
	static inline var TIME_SPEED_S4:Float = 0.04;   // Faster. 2 CPU

	// Current characters per update
	var time_CPU:Int;
	// Curent update every seconds.
	var time_FREQ:Float;
	// Hold the last update time
	var timer:Float;
	// --
	var currentLength:Int = 0;
	var targetLength:Int = 0;
	var targetText:String;
	
	// is it in the process of displaying the text or not
	var isWorking:Bool;
	
	// Call this after the autotext ends.
	var onComplete:Void->Void;
	
	// Store the times if present
	// (index => speed)
	var mapTimes:Map<Int,Int>;
	var mapTimesTotal:Int;
	
	//====================================================;
	// --
	public function new(X:Float, Y:Float, FieldWidth:Float = 0, Size:Int = 8)
	{
		super(X, Y, FieldWidth, null, Size);
		wordWrap = false;	
		isWorking = false;
		mapTimes = null;
		mapTimesTotal = 0;
	}//---------------------------------------------------;
	
	// -- USER SET --
	// Trigger a user call whenever a character is displayed
	// Useful to set audio effects.
	dynamic public function onCharacter():Void
	{
		// Empty for now
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
		text = "";
		currentLength = 0;
		timer = 0;
		isWorking = true;
		onComplete = _onComplete;
		
		// Set the default timings because the autotext might restart from old values
		time_FREQ = TIME_SPEED_S0;
		time_CPU = TIME_CPU_DEF;

		// Check the markup of the _text
		// Match (s0)..(s9)
		var regSpeeds:EReg = ~/(\(s\d\))/g;
		if (regSpeeds.match(_text)) 
		{
			// trace("+ Reg Exp found.");
			// Init the map and start counting total times found
			mapTimes = new Map();
			mapTimesTotal = 0;
			_text = regSpeeds.map(_text, function(reg:EReg) {
				var m:String = reg.matched(0);
				var spd:Int = Std.parseInt(m.substr(2, 1));
				// Compensate for the added length of the (s1) markup
				var ind:Int = (reg.matchedPos().pos) - 4 * mapTimesTotal;
				mapTimes.set(ind, spd);
				// Increment after adjusting index
				mapTimesTotal++;
				// trace('+ Speed ($spd) at index ($ind)');
				// remove the markup by returning empty string
				return "";
			});
		}
			
		targetText = _text;
		targetLength = targetText.length;
		
		// Check for any times set at the first index.
		checkAndSetTime();
	}//---------------------------------------------------;
	
	function checkAndSetTime()
	{
		if (mapTimesTotal > 0 && mapTimes.exists(currentLength)) {
			time_FREQ = switch(mapTimes.get(currentLength)) {
				case 1: time_CPU = 1; TIME_SPEED_S1;
				case 2: time_CPU = 1; TIME_SPEED_S2;
				case 3: time_CPU = 2; TIME_SPEED_S3;
				case 4: time_CPU = 3; TIME_SPEED_S4;
				case 0: time_CPU = 1; TIME_SPEED_S0;
				default: TIME_SPEED_S0;
			};
			trace('-- Setting speed from map = $time_FREQ');
			trace('-- Setting CHARS from map = $time_CPU');
		}
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (!isWorking) return;
	
		timer += FlxG.elapsed;
		if (timer >= time_FREQ)
		{
			timer = 0;
			currentLength += time_CPU;
			
			if (currentLength >= targetLength)
			{
				stop(true);
				
				if (onComplete != null) {
					onComplete();
				}
				
			}else {	
				text = targetText.substr(0, currentLength);
				checkAndSetTime();
				onCharacter();
			}
		}
	}//---------------------------------------------------;
	// --
	public function stop(showFinal:Bool = false)
	{
		if (showFinal && targetText != null)
		{
			currentLength = targetLength;
			text = targetText;
		}
		
		timer = 0;
		isWorking = false;
	}//---------------------------------------------------;
	// --
	override public function destroy():Void 
	{
		super.destroy();
	}//---------------------------------------------------;	
	
}// -- end -- //