/**
   Static Noise Box
   ---------------
   - Creates an animated simple noise box
   - Customizable Colors
   - You can use as little as 2 colors for the noise
   - Starts animating automatically
   
   - set colors with color_custom() or color_gray() (default)
   - set Update time directly with <StaticNoise.TICK>
   
   == Example :
   	var st = new StaticNoise(20, 20, 160, 160);
	st.TICK = 0.4;	// increase tick, make it slower
	st.color_custom([0xFF333344,0xFF998855]);	// custom colors
	add(st);
	
	
!! DOES NOT WORK ON HTML !!
	
======================================= */

package djFlixel.gfx;

import djFlixel.other.StepLoop;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class StaticNoise extends FlxSprite
{
	/** Update the noise every this many seconds */
	public var TICK:Float = 0.12;
	var COLORS:Array<Int> = [];
	var col:FlxColor;
	var point:Point;	
	var rect:Rectangle;
	var timer:Float = 0;
	var SEED:Int = 0;
	
	public function new(X:Float = 0, Y:Float = 0, WIDTH:Int = 0, HEIGHT:Int = 0) 
	{
		super();
		if (WIDTH == 0) WIDTH = FlxG.state.camera.width - Std.int(X);
		if (HEIGHT == 0) HEIGHT = FlxG.state.camera.height - Std.int(Y);
		makeGraphic(WIDTH, HEIGHT, 0xFF002200);
		setPosition(X, Y);
		centerOffsets();
		moves = false;
		rect = new Rectangle(0, 0, pixels.width, pixels.height);
		point = new Point();
		color_gray();
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		if ((timer += elapsed) >= TICK) {
			timer = 0;
			generate();
		}
		super.update(elapsed);
	}//---------------------------------------------------;
	
	public function color_gray(steps:Int = 4)
	{
		var st = Math.floor(255 / steps);
		COLORS = [];
		for (i in 0...steps)  {
			col.setRGB(i * st, i * st, i * st);
			COLORS[i] = col;
		}
		generate();
	}//---------------------------------------------------;
	
	public function color_custom(COL:Array<Int>)
	{
		COLORS = COL;
		generate();
	}//---------------------------------------------------;
	
	// Create a noise pattern with (N) number of shades
	// Then recolorize each shade to a custom color
	function generate()
	{
		pixels.lock();
		#if (hl)
		// I don't know why. It should work with (-1)?
		pixels.noise(SEED++, 0 , COLORS.length, 7, true);
		#else
		pixels.noise(SEED++, 0 , COLORS.length - 1, 7, true);
		#end
		for (i in 0...COLORS.length){
			col.setRGB(i, i, i);
			pixels.threshold(pixels, rect, point, "==", col, COLORS[i]);
		}
		pixels.unlock();
		dirty = true;
	}//---------------------------------------------------;
	
}// --