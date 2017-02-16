package djFlixel.gui;
import djFlixel.SimpleCoords;
import flixel.FlxSprite;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;
import openfl.geom.Rectangle;


/**
 * A solid background that pops up with an animation
 * 
 * - Use
 * -------
 * 
 * 	new BGPOP(100,100,black);
 *  bg.start(callback);
 * 
 * 	// prior to starting it's transparent
 * 
 */
class BGPop extends FlxSprite
{
	static var FREQ:Float = 0.08;
	//---------------------------------------------------;
	var timer:FlxTimer;
	// Helper store the drawing rect
	var rect:Rectangle; 
	// Current step in the tables
	var step:Int = 0; 
	// Offset from origin
	var heightSteps:Array<Float>;
	// Offset from origin
	var widthSteps:Array<Float>;
	// --
	var bgColor:Int;
	// --
	public var onComplete:Void->Void = null;
	//---------------------------------------------------;
	// --
	public function new(width:Int, height:Int, color:Int = 0xFF000000)
	{
		super();
		bgColor = color;
		// Make the graphic transparent
		makeGraphic(width, height, 0x00000000);
		// Both tables MUST HAVE THE SAME LENGTH.
		widthSteps = [0.20, 0.7, 1, 1]; 
		heightSteps = [0.25, 0.5, 0.8, 1];
		
		scrollFactor.set(0, 0);
	}//---------------------------------------------------;
	
	// --
	function onTick(t:FlxTimer)
	{
		pixels.lock();
		var ww:Int = Std.int(widthSteps[step] * width);
		var hh:Int = Std.int(heightSteps[step] * height);
		var xx:Int = Std.int((width - ww) / 2); 
		var yy:Int = Std.int((height - hh) / 2);
		pixels.fillRect(new Rectangle(xx, yy, ww, hh), bgColor);
		pixels.unlock();
		dirty = true;
		step++;
		if (step == widthSteps.length) {
			timer.cancel();
			timer = null;
			if (onComplete != null) onComplete();
		}
	}//---------------------------------------------------;
	
	// --
	public function start(?ONCOMPLETE:Void->Void)
	{
		onComplete = ONCOMPLETE;
		timer = new FlxTimer().start(FREQ, onTick, 0);
	}//---------------------------------------------------;
	
	// --
	override public function destroy():Void 
	{
		super.destroy();
		timer = FlxDestroyUtil.destroy(timer);
	}//---------------------------------------------------;
	
}// --