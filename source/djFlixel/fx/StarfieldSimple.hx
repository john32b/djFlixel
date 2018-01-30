/**
 * Very simple starfield
 * =======================
 * 
 * + If you want to stop scrolling, use 
 * 		stars.active = false;
 * 
 *----------------------------------------------------------*/

package djFlixel.fx;

import djFlixel.gfx.Palette_DB32;
import flixel.FlxG;
import flixel.FlxSprite;
import djFlixel.SimpleVector;
import flixel.util.FlxSpriteUtil;

class StarfieldSimple extends FlxSprite
{
	// -- Some Defaults
	static inline var DEF_STARS_MAX:Int = 200;
	static inline var DEF_TRAVEL_ANGLE:Int = -180;
	static inline var DEF_TRAVEL_SPEED:Float = 0.5;
	
	// -- Star Layer Multipliers to STAR_SPEED
	static inline var LAYER_1_SPEED:Float = 0.3;
	static inline var LAYER_2_SPEED:Float = 1;
	static inline var LAYER_3_SPEED:Float = 2.4;

	// Every star should have a x,y float position
	// Stars are categorized in layers
	// FG stars move a bit faster and are brighter
	// BG start move a bit slower and are darker
	// Extra stars are another layer of stars that are extra bright
	
	var ar_stars_bg:Array<SimpleVector>;
	var ar_stars_middle:Array<SimpleVector>;
	var ar_stars_fg:Array<SimpleVector>;	
		
	// FX+
	// Apply a bit of a random speed variation to the fg layer stars
	var ar_fg_speedVariation:Array<Float>;
	
	// Dynamic render function for each star
	var renderStarFN:Float->Float->Int->Void = null;
	
	// Calculated Vector for traveling of the stars
	var dirX:Float;
	var dirY:Float;
	// Helper counter
	var c:Int;
	
	// The angle which the stars are traveling in DEGREES (0-360)
	public var STAR_ANGLE(default, set):Float;
	
	// The speed multiplier stars travel
	public var STAR_SPEED(default, set):Float;
	
	// Whether or not to render with widepixels (2x1 normal pixels)
	public var WIDE_PIXEL(default, set):Bool;
	
	// This will re-initialize the arrays, so avoid calling multiple times
	public var NUMBER_OF_STARS(default, set):Int;
	
	// Colors for background and 3 stars, you can set it at anytime
	public var COLORS(default, default):Array<Int>;
	
	
	//---------------------------------------------------;

	public function new(Width:Int = 0, Height:Int = 0, NumberOfStars:Int = DEF_STARS_MAX)
	{	
		super();
		
		COLORS = [
			0xFF000000,
			Palette_DB32.COL[2],
			Palette_DB32.COL[17],
			Palette_DB32.COL[8]
		];
		
		width = Width > 0 ? Width: FlxG.width;
		height = Height > 0 ? Height: FlxG.height;
		moves = false;
		
		// --
		makeGraphic(cast width, cast height, COLORS[0]);
		// Init speeds and angles
		STAR_ANGLE = DEF_TRAVEL_ANGLE;
		// --
		STAR_SPEED = DEF_TRAVEL_SPEED;
		// These also call the setter functions:
		WIDE_PIXEL = false;
		// This will init the star objects as well
		NUMBER_OF_STARS = NumberOfStars;
	}//---------------------------------------------------;

	/**
	 * If you directly call COLORS[0], the buffer will not clear
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
		
		var toRads:Float = Math.PI / 180;
		
		dirX = Math.cos(STAR_ANGLE * toRads);
		dirY = Math.sin(STAR_ANGLE * toRads);
		
		return value;
	}//---------------------------------------------------;

	/**
	 * Star speed multiplier
	 * @param	value
	 */
	public function set_STAR_SPEED(value:Float)
	{
		STAR_SPEED = value;
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
		
		// Helpers, don't calculate ints every time
		var intWidth:Int = Std.int(width);
		var intHeight:Int = Std.int(height);
		
		// Create the arrays to store the stars
		ar_stars_bg = [];
		ar_stars_middle = [];
		ar_stars_fg = [];
		ar_fg_speedVariation = [];
		
		var numberOfMiddleStars = Math.floor(NUMBER_OF_STARS * 0.86);
		var r:SimpleVector;
		
		// -- Push the stars in the arrays
		for (i in 0...NUMBER_OF_STARS)
		{
			r = new SimpleVector(FlxG.random.int(0, intWidth), FlxG.random.int(0, intHeight));
			
			if (i < numberOfMiddleStars)
			{
				ar_stars_middle.push(r);
				ar_fg_speedVariation.push(FlxG.random.float(0.75, 1.25));
			}else
			{
				ar_stars_bg.push(r);
			}
		}
		
		// Create some unique extra bright stars
		var numberOfFGStars:Int = Std.int(NUMBER_OF_STARS * 0.05);
		for (i in 0...numberOfFGStars)
		{
			r = new SimpleVector(FlxG.random.int(0, intWidth), FlxG.random.int(8, intHeight - 8));
			ar_stars_fg.push(r);
		}
		
		return Value;
	}//---------------------------------------------------;
	
	
	/**
	 * Emulate an aesthetic used in old computers like the amstrad CPC
	 * @param	val
	 * @return
	 */
	function set_WIDE_PIXEL(val:Bool):Bool
	{
		WIDE_PIXEL = val;
		
		// I am clearing the buffer in case this is called in runtime
		setBGCOLOR(COLORS[0]);
		
		return val;
	}//---------------------------------------------------;
	
	
	/**
	 * Update the stars
	 * @param	elapsed
	 */
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	
		pixels.lock();
		
		// Process::
		// --
		// Draw the background stars
		// Draw the main stars in variable speeds
		// Draw the foreground stars
		
		if (WIDE_PIXEL)
		{
			updateStarArrayRand(ar_stars_bg, LAYER_1_SPEED * STAR_SPEED, COLORS[1], renderStar_Wide);
			updateStarArrayVarSpeed(ar_stars_middle, LAYER_2_SPEED * STAR_SPEED, COLORS[2], renderStar_Wide);
		}
		else
		{
			updateStarArrayRand(ar_stars_bg, LAYER_1_SPEED * STAR_SPEED, COLORS[1], renderStar_Normal);
			updateStarArrayVarSpeed(ar_stars_middle, LAYER_2_SPEED * STAR_SPEED, COLORS[2], renderStar_Normal);
		}
		
		// It's the same size for widepixel and normal pixel
		updateStarArray(ar_stars_fg, LAYER_3_SPEED * STAR_SPEED, COLORS[3], renderStar_Big);

		pixels.unlock();
		dirty = true;
	}//---------------------------------------------------;
		// --
	function updateStarArrayRand(ar:Array<SimpleVector>, spd:Float, color:Int, drawFN:Int->Int->Int->Void)
	{
		c = ar.length;
		while (c-->0){
			// draw over the old position, it's faster than clearing the buffer
			drawFN(Math.round(ar[c].x), Math.round(ar[c].y), COLORS[0]);
			ar[c].x += dirX * spd;
			ar[c].y += dirY * spd;
			checkbounds(ar[c]);
			if (Math.random() < 0.4) // Shimmer
				drawFN(Math.round(ar[c].x), Math.round(ar[c].y), color);
		}
	}//---------------------------------------------------;	
	
	// --
	function updateStarArray(ar:Array<SimpleVector>, spd:Float, color:Int, drawFN:Int->Int->Int->Void)
	{
		c = ar.length;
		while (c-->0){
			// draw over the old position, it's faster than clearing the buffer
			drawFN(Math.round(ar[c].x), Math.round(ar[c].y), COLORS[0]);
			ar[c].x += dirX * spd;
			ar[c].y += dirY * spd;
			checkbounds(ar[c]);
			drawFN(Math.round(ar[c].x), Math.round(ar[c].y), color);
		}
	}//---------------------------------------------------;	
	
	// --
	// It's a bit faster to have a separate function for rendering with speed variation
	function updateStarArrayVarSpeed(ar:Array<SimpleVector>, spd:Float, color:Int, drawFN:Int->Int->Int->Void)
	{
		c = ar.length;
		while (c-->0){
			// draw over the old position, it's faster than clearing the buffer
			drawFN(Math.round(ar[c].x),Math.round(ar[c].y), COLORS[0]);
			ar[c].x += dirX * spd * ar_fg_speedVariation[c];
			ar[c].y += dirY * spd * ar_fg_speedVariation[c];
			checkbounds(ar[c]);
			drawFN(Math.round(ar[c].x),Math.round(ar[c].y), color);
		}
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
		ar_stars_middle = null;
		ar_stars_fg = null;
		ar_fg_speedVariation = null;
	}//---------------------------------------------------;
	
	
}// -- end --//