/**
 
 Very simple starfield
 ---------------------
 
 Example:
 --------
	 stars = new StarfieldSimple();
	 stars.WIDE_PIXEL = true;
	 stars.STAR_SPEED = 1.9;
	 stars.STAR_ANGLE = 90;
	 add(stars);
 
======================================== */

package djFlixel.gfx;

import djFlixel.gfx.pal.Pal_DB32;
import flixel.FlxG;
import flixel.FlxSprite;
import djA.types.SimpleVector;
import flixel.util.FlxSpriteUtil;

class StarfieldSimple extends FlxSprite
{
	// -- Some Defaults
	static inline var DEF_STARS_MAX:Int = 212;
	static inline var DEF_TRAVEL_ANGLE:Int = -180;
	static inline var DEF_TRAVEL_SPEED:Float = 0.5;
	
	// -- Star Layer Speed Multipliers to STAR_SPEED
	static inline var LAYER_1_SPEED:Float = 0.3;
	static inline var LAYER_2_SPEED:Float = 1;
	static inline var LAYER_3_SPEED:Float = 2.4;
	
	// -- Quantity Ratio based on <NUMBER_OF_STARS>
	static inline var BG_STARS_RATIO:Float = 0.14;
	static inline var FG_STARS_RATIO:Float = 0.05;

	// Stars are categorized in layers
	var ar_stars_bg:Array<SimpleVector>;
	var ar_stars_main:Array<SimpleVector>;
	var ar_stars_fg:Array<SimpleVector>;	
		
	// FX+
	// Apply a bit of a random speed variation to the fg layer stars
	var ar_stars_main_speed_var:Array<Float>;

	// Star move vector, auto-calculated from <STAR_ANGLE>
	var starVector = new SimpleVector();
	
	// The angle which the stars are traveling in DEGREES (0-360)
	public var STAR_ANGLE(default, set):Float;
	
	// The speed multiplier stars travel
	public var STAR_SPEED:Float;
	
	// Whether or not to render with widepixels (2x1 normal pixels)
	public var WIDE_PIXEL(default, set):Bool;
	
	// This will re-initialize the arrays, so avoid calling multiple times
	public var NUMBER_OF_STARS(default, set):Int;
	
	// Normal stars use this to draw
	// When wide pixel is set, this points to a different function
	var drawFunction:Int->Int->Int->Void;
	
	/** Colors for background and 3 stars, you can set it at anytime
	 * If you want to change the background in realtime call setBGCOLOR()
	 * Star colors can change in realtime OK
	**/
	public var COLORS:Array<Int> = [
			0xFF000000,			// Background color
			Pal_DB32.COL[2],	// Blinking Stars
			Pal_DB32.COL[17],	// Normal Main Stars
			Pal_DB32.COL[8]		// Faster Foreground Stars
		];
	//---------------------------------------------------;

	/**
	   Creates a starfield in a square area
	   @param	Width 0 for FlxG.Width
	   @param	Height 0 for FlxG.Height
	   @param	COL Star Colors, Array[4] [ background, blinkingstars, mainstars, foreground stars ]
	   @param	NumberOfStars
	**/
	public function new(Width:Int = 0, Height:Int = 0, ?COL:Array<Int>, NumberOfStars:Int = DEF_STARS_MAX)
	{	
		super();
		
		if (COL != null) COLORS = COL;
		
		width = Width > 0 ? Width: FlxG.width;
		height = Height > 0 ? Height: FlxG.height;
		moves = false;
		
		scrollFactor.set(0, 0);
		
		// DEV: Non Unique graphics that share the same dimensions, share the same bitmap data
		makeGraphic(cast width, cast height, COLORS[0], true);

		STAR_ANGLE = DEF_TRAVEL_ANGLE;
		STAR_SPEED = DEF_TRAVEL_SPEED;
		WIDE_PIXEL = false;	// < will also paint the background to the correct color
		
		NUMBER_OF_STARS = NumberOfStars;	// < this will actually initialize the stars
		
	}//---------------------------------------------------;

	/**
	 * If you directly set COLORS[0], the buffer will not clear
	 * Call this to set the bg color and clear the buffer.
	 * @param	col New background color
	 */
	public function setBGCOLOR(col:Int)
	{
		COLORS[0] = col;
		FlxSpriteUtil.drawRect(this, 0, 0, width, height, col);
	}//---------------------------------------------------;

	/**
	 * Set the direction of the Stars in Degrees
	 * @param	angl Angle in degrees
	 */
	public function set_STAR_ANGLE(value:Float)
	{
		STAR_ANGLE = value;
		
		var toRads = Math.PI / 180;
		
		starVector.set(  Math.cos(STAR_ANGLE * toRads),
						 Math.sin(STAR_ANGLE * toRads) );
		return value;
	}//---------------------------------------------------;

	
	/**
	 * Reset the number of stars
	 * @param	Value
	 * @return
	 */
	function set_NUMBER_OF_STARS(Value:Int):Int
	{
		if (NUMBER_OF_STARS == Value) return Value;
		
		NUMBER_OF_STARS = Value;
		
		ar_stars_main = [];
		ar_stars_main_speed_var = [];
		
		for (i in 0...NUMBER_OF_STARS)
		{
			ar_stars_main.push(
				new SimpleVector(
					FlxG.random.int(0, cast width), 
					FlxG.random.int(0, cast height))
			);
		}
		
		// From the stars that got created, get a portion for bg and fg stars
		ar_stars_bg = ar_stars_main.splice(0, Math.floor(NUMBER_OF_STARS * BG_STARS_RATIO));
		ar_stars_fg = ar_stars_main.splice(0, Math.floor(NUMBER_OF_STARS * FG_STARS_RATIO));
		
		// > ar_stars_main should be modified now and filled with the main stars only
		for (i in 0...ar_stars_main.length)
		{
			ar_stars_main_speed_var.push(FlxG.random.float(0.75, 1.25));
		}
		
		return Value;
	}//---------------------------------------------------;
	
	
	/**
	 * Emulate an aesthetic used in old computers like the amstrad CPC
	 * @param	val
	 */
	function set_WIDE_PIXEL(val:Bool):Bool
	{
		WIDE_PIXEL = val;
		
		setBGCOLOR(COLORS[0]); // Redraws
		
		if (WIDE_PIXEL) {
			drawFunction = renderStar_Wide;
		}else {
			drawFunction = renderStar_Normal;
		}
		
		return val;
	}//---------------------------------------------------;
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	
		pixels.lock();
		
		// DEV:
		// It used to be separate function calls to draw each layer, I put it all here now
		
		// :: Draw the background Flickering stars
		var ar:Array<SimpleVector> = ar_stars_bg;
		var c:Int = ar.length;
		var spd:Float = LAYER_1_SPEED * STAR_SPEED;
		while (c-->0){
			// draw over the old position, it's faster than clearing the buffer
			drawFunction(Math.round(ar[c].x), Math.round(ar[c].y), COLORS[0]);
			ar[c].x += starVector.x * spd;
			ar[c].y += starVector.y * spd;
			checkbounds(ar[c]);
			if (Math.random() < 0.4) // Shimmer
				drawFunction(Math.round(ar[c].x), Math.round(ar[c].y), COLORS[1]);
		}
		
		// :: Draw the main stars
		ar = ar_stars_main;
		c = ar.length;
		spd = LAYER_2_SPEED * STAR_SPEED;
		while (c-->0){
			// draw over the old position, it's faster than clearing the buffer
			drawFunction(Math.round(ar[c].x),Math.round(ar[c].y), COLORS[0]);
			ar[c].x += starVector.x * spd * ar_stars_main_speed_var[c];
			ar[c].y += starVector.y * spd * ar_stars_main_speed_var[c];
			checkbounds(ar[c]);
			drawFunction(Math.round(ar[c].x),Math.round(ar[c].y), COLORS[2]);
		}
		
		// :: Draw the foreground stars
		ar = ar_stars_fg;
		c = ar.length;
		spd = LAYER_3_SPEED * STAR_SPEED;
		while (c-->0){
			// draw over the old position, it's faster than clearing the buffer
			renderStar_Big(Math.round(ar[c].x), Math.round(ar[c].y), COLORS[0]);
			ar[c].x += starVector.x * spd;
			ar[c].y += starVector.y * spd;
			checkbounds(ar[c]);
			renderStar_Big(Math.round(ar[c].x), Math.round(ar[c].y), COLORS[3]);
		}

		// --
		pixels.unlock();
		dirty = true;
	}//---------------------------------------------------;

	
	// --
	inline function checkbounds(star:SimpleVector)
	{
		if (star.x < 0) star.x = width;
		if (star.y < 0) star.y = height;
		if (star.x > width) star.x = 0;
		if (star.y > height) star.y = 0;
	}//---------------------------------------------------;
	
	
	// # Speed up calls with virtual functions
	// -- Call this when pixels are locked.
	function renderStar_Wide(x:Int, y:Int, col:Int)
	{
		pixels.setPixel32(x, y, col);
		pixels.setPixel32(x + 1, y, col);
	}//---------------------------------------------------;
	// --
	function renderStar_Normal(x:Int, y:Int, col:Int)
	{
		pixels.setPixel32(x, y, col);
	}//---------------------------------------------------;	
	// --
	function renderStar_Big(x:Int, y:Int, col:Int)
	{
		pixels.setPixel32(x, y, col);
		pixels.setPixel32(x + 1, y, col);
		pixels.setPixel32(x, y + 1, col);
		pixels.setPixel32(x + 1, y + 1, col);
	}//---------------------------------------------------;
	
	// --
	override public function destroy():Void 
	{
		super.destroy();
		ar_stars_bg = null;
		ar_stars_main = null;
		ar_stars_fg = null;
		ar_stars_main_speed_var = null;
	}//---------------------------------------------------;
	
}// -- end --//