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
	
======================================= */

package djFlixel.gfx;

import djA.DataT;
import djFlixel.other.StepLoop;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

#if flash
	import openfl.geom.Point;
	import openfl.geom.Rectangle;
#end

class StaticNoise extends FlxSprite
{
	/** Update the noise every this many seconds */
	public var TICK:Float = 0.12;
	var COLORS:Array<Int> = [];
	var col:FlxColor;
	var timer:Float = 0;
	var SEED:Int = 0;
	#if flash
	var point:Point;
	var rect:Rectangle;
	#end
	
	/**
	   @param	X
	   @param	Y
	   @param	WIDTH 0 for viewport width
	   @param	HEIGHT 0 for viewport height
	**/
	public function new(X:Float = 0, Y:Float = 0, WIDTH:Int = 0, HEIGHT:Int = 0) 
	{
		super();
		
		if (WIDTH == 0) WIDTH = FlxG.state.camera.width - Std.int(X);
		if (HEIGHT == 0) HEIGHT = FlxG.state.camera.height - Std.int(Y);
		makeGraphic(WIDTH, HEIGHT, 0xFF002200);
		setPosition(X, Y);
		centerOffsets();
		moves = false;
		#if flash
		point = new Point();
		rect = new Rectangle(0, 0, pixels.width, pixels.height);
		#end
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
	
	/** Make it grayscale, from 0 to 255 shade of black
	 *  steps will be divided evenly to that range */
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
	
	/** Make it use specific colors, you can put as many as you want */
	public function color_custom(COL:Array<Int>)
	{
		COLORS = COL;
		generate();
	}//---------------------------------------------------;
	
	// Create a noise pattern with (N) number of shades
	// Then recolorize each shade to a custom color
	function generate()
	{
		// DEV NOTES:
		//
		// pixels.noise(..) -- https://api.openfl.org/openfl/display/BitmapData.html
		// 
		// - If I wanted 2 colors, I should do low=0 and high=1. 
		//   So that I have two distinct colors in the bitmap, but this only
		//   seems to work in (flash). For native targets I need to give one more index in high)
		//   Is this a bug or am I not understanding this correctly ?
		//
		// - HTML5 OpenFL is busted:
		//		A simple : pixels.noise(SEED++, 0, 128, 7, true) fails on 'canvas' and 'webgl'
		//		I don't know why
		
		// - V0.5
		// 		Now that I look at it, openfl.bitmapdata.noise() just does it manually.
		//		so I am going to do it my way for all targets now'
		
		pixels.lock();
		
		#if flash
		
		var high = COLORS.length;
		pixels.noise(SEED++, 0 , COLORS.length - 1, 7, true); // DEV: 7 is BitmapDataChannel.RED + GREEN + BLUE
		for (i in 0...COLORS.length){
			col.setRGB(i, i, i);
			pixels.threshold(pixels, rect, point, "==", col, COLORS[i]);
		}
		#else
		// Fixes HTML5 which was broken, also native targets are faster this way
		for (y in 0...pixels.height)
		for (x in 0...pixels.width)
			pixels.setPixel32(x, y, DataT.arrayRandom(COLORS));
		#end
		
		pixels.unlock();
		dirty = true;
	}//---------------------------------------------------;
	
}// --