/**
 * Very simple starfield
 * =======================
 * 
 * Use example
 * -------------
 * 
 * var stars = new StarfieldSimple(200,200);
 * 	stars.flag_widepixel = true;
 * 	stars.setColors([...]);
 * 	add(stars);
 * 
 * + Other possible calls ::
 * 
 * 	stars.setSpeed(FlxG.random.float(0.3, 1.5));
 *	stars.setDirection(FlxG.random.int(0, 360));
 *	stars.numberOfStars = FlxG.random.int(150, 900);
 *	stars.color_bg = Palette_DB32.getRandomColor();
 *	stars.color_1 = Palette_DB32.getRandomColor();
 *	stars.color_2 = Palette_DB32.getRandomColor();
 *	stars.color_3 = Palette_DB32.getRandomColor();
 * 
 * -----------------
 * 
 * + If you want to stop scrolling, use 
 * 		stars.active = false;
 * 
 *----------------------------------------------------------*/

package djFlixel.fx;

import flixel.FlxG;
import flixel.FlxSprite;
import djFlixel.SimpleVector;

class StarfieldSimple extends FlxSprite
{
	// -- Default Values if not user customized ---
	static inline var DEF_COLOR_1:Int = 0xFF999999;		// Back star
	static inline var DEF_COLOR_2:Int = 0xFF505296; 	// Medium star
	static inline var DEF_COLOR_3:Int = 0xFFEFEE77; 	// Close Fast star
	static inline var DEF_COLOR_BG:Int = 0xFF000000; 	// Black BG by default
	static inline var DEF_STARS_MAX:Int = 200;
	static inline var DEF_TRAVEL_ANGLE:Int = -180;
	static inline var DEF_TRAVEL_SPEED:Float = 0.5;
	
	// ----
	static inline var LAYER_1_SPEED:Float = 0.4;		// Speed modifiers from the base speed
	static inline var LAYER_2_SPEED:Float = 1;	
	static inline var LAYER_3_SPEED:Float = 2.4;
	
	
	// Every star should have a x,y float position
	// Stars are categorized in layers
	// FG stars move a bit faster and are brighter
	// BG start move a bit slower and are darker
	// Extra stars are another layer of stars that are extra bright
	var ar_stars_fg:Array<SimpleVector>;
	var ar_stars_bg:Array<SimpleVector>;
	var ar_start_extra:Array<SimpleVector>;	
		
	// FX+
	// Apply a bit of a random speed variation to the fg layer stars
	var ar_fg_speedVariation:Array<Float>;
	
	// --------------------
	// # Currently unused #
	// Update the star layer every X time, to save some CPU
	// var updateFrequency:Float = 0.3; 
	// var timeCur:Float = 0;
	// ---------------------
	
	// Dynamic render function for each star
	var renderStarFN:Int->Int->Int->Void = null;
	
	// The angle which the stars are traveling in degrees
	var currentAngle:Float;
	var currentSpeed:Float;
	
	// Calculated Vector for traveling of the stars
	var dirX:Float;
	var dirY:Float;
	
	// == USER SET ===========================
	// --
	// Whether or not to render with widepixels (2x1 normal pixels)
	public var flag_widepixel(default, set):Bool;
	// This will re-initialize the arrays, so avoid calling multiple times
	public var numberOfStars(default, set):Int;
	
	// The actual colors of the stars
	// You can also call setColors(...);
	public var color_1:Int; // You can change colors1-3 in realtime
	public var color_2:Int;
	public var color_3:Int;
	public var color_bg(default, set):Int;
	//---------------------------------------------------;

	public function new(Width:Int = 0, Height:Int = 0)
	{	
		super();
		
		width = Width != 0 ? Width: FlxG.width;
		height = Height != 0 ? Height: FlxG.height;
		solid = false;
		
		// Set the default paramers
		color_1 = DEF_COLOR_1;
		color_2 = DEF_COLOR_2;
		color_3 = DEF_COLOR_3;
		
		setDirection(DEF_TRAVEL_ANGLE);
		setSpeed(DEF_TRAVEL_SPEED);
		
		// These also call the setter functions:
		flag_widepixel = false;
		numberOfStars = DEF_STARS_MAX;
		color_bg = DEF_COLOR_BG;	// This will create the graphic
	}//---------------------------------------------------;

	/**
	 * Set the starfield colors in an array, 
	 * @param cols an Array with 4 colors, from DARKEST to BRIGHTEST
	 */
	public function setColors(cols:Array<Int>, reverse:Bool = false)
	{
		if (reverse) cols.reverse();
		color_bg = cols[0];
		color_1 = cols[1];
		color_2 = cols[2];
		color_3 = cols[3];
	}//---------------------------------------------------;
	
	/**
	 * Set the direction of the scrolling and the base speed modifier
	 * @param	angl Angle in degrees
	 * @param	spd  Speed modifier
	 */
	public function setDirection(angl:Float)
	{
		currentAngle = angl;
		
		var toRads:Float = Math.PI / 180;
		
		dirX = Math.cos(currentAngle * toRads);
		dirY = Math.sin(currentAngle * toRads);
	
	}//---------------------------------------------------;

	/**
	 * Set the speed ratio of all star layers.
	 * @param	spd A value from 0 to 64. ( 64 is too fast!, 1-3 is OK)
	 */
	public function setSpeed(spd:Float)
	{
		currentSpeed = spd;
	}//---------------------------------------------------;

	// --
	function set_color_bg(Value:Int):Int
	{
		// I am skipping same color check, because I might want to
		// clear the screen.
		// if (color_bg == Value) return Value;
		
		trace('Setting BG color to ($Value)');
		
		color_bg = Value;
		makeGraphic(cast width, cast height, color_bg);
		
		return Value;
	}//---------------------------------------------------;
	
	// --
	// Call this after creating the object, and after
	// setting the custom parameters
	function set_numberOfStars(Value:Int):Int
	{
		if (numberOfStars == Value) return Value;
		
		trace('Setting number of stars to [$Value]');
		numberOfStars = Value;
		
		// Helpers, don't calculate ints every time
		var intWidth:Int = Std.int(width);
		var intHeight:Int = Std.int(height);
		
		// Create the arrays to store the stars
		ar_stars_bg = [];
		ar_stars_fg = [];
		ar_start_extra = [];
		ar_fg_speedVariation = [];
		
		// Turns out, the graphics don't need to be clears, it's done automatically
		// if (graphic != null) graphic.destroy();
		// if (pixels != null) pixels.dispose();
		
		var numOfFgStars = Math.floor(numberOfStars * 0.65);
		var r:SimpleVector;
		
		// -- Push the stars in the arrays
		for (i in 0...numberOfStars)
		{
			r = new SimpleVector(FlxG.random.int(0, intWidth), FlxG.random.int(0, intHeight));
			
			if (i < numOfFgStars)
			{
				ar_stars_fg.push(r);
				ar_fg_speedVariation.push(FlxG.random.float(0.75, 1.25));
			}else
			{
				ar_stars_bg.push(r);
			}
		}
		
		// Create some unique extra bright stars
		var numberOfExtraStars:Int = Std.int(numberOfStars * 0.05);
		for (i in 0...numberOfExtraStars)
		{
			r = new SimpleVector(FlxG.random.int(0, intWidth), FlxG.random.int(8, intHeight - 8));
			ar_start_extra.push(r);
		}
		
		return Value;
	}//---------------------------------------------------;
	
	
	// --
	function set_flag_widepixel(val:Bool):Bool
	{
		flag_widepixel = val;
		
		if (flag_widepixel)
		{
			renderStarFN = renderStar_widepixel;
		}else
		{
			renderStarFN = renderStar_normal;
		}
		
		return val;
	}//---------------------------------------------------;
	
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
			
		pixels.lock();
		
		updateStarArray(ar_stars_bg, LAYER_1_SPEED * currentSpeed, color_1);
		updateStarArrayFG(ar_stars_fg, LAYER_2_SPEED * currentSpeed, color_2);
		updateStarArray(ar_start_extra, LAYER_3_SPEED * currentSpeed, color_3);
		
		pixels.unlock();
		dirty = true;
			
	}//---------------------------------------------------;
	
	// --
	// Avoid redudancy
	inline function updateStarArray(ar:Array<SimpleVector>, speedMult:Float, color:Int)
	{
		for (c in 0...ar.length)
		{
			// draw over the old position
			renderStarFN(Math.round(ar[c].x), Math.round(ar[c].y), color_bg);
			ar[c].x += dirX * speedMult;
			ar[c].y += dirY * speedMult;
			checkbounds(ar[c]);
			renderStarFN(Math.round(ar[c].x), Math.round(ar[c].y) , color);
		}
	}//---------------------------------------------------;	
	
	// --
	// It's a bit faster to have a separate function for rendering with speed variation
	inline function updateStarArrayFG(ar:Array<SimpleVector>, speedMult:Float, color:Int)
	{
		for (c in 0...ar.length)
		{
			// draw over the old position
			renderStarFN(Math.round(ar[c].x), Math.round(ar[c].y), color_bg);
			ar[c].x += dirX * speedMult * ar_fg_speedVariation[c];
			ar[c].y += dirY * speedMult * ar_fg_speedVariation[c];
			checkbounds(ar[c]);
			renderStarFN(Math.round(ar[c].x), Math.round(ar[c].y) , color);
		}
	}//---------------------------------------------------;
	
	inline function checkbounds(star:SimpleVector)
	{
		if (star.x < 0) star.x = width;
		if (star.y < 0) star.y = height;
		if (star.x > width) star.x = 0;
		if (star.y > height) star.y = 0;
	}//---------------------------------------------------;
	
	// # Speed up calls with virtual functions
	// -- Call this when pixels are locked.
	inline function renderStar_widepixel(x:Int, y:Int, col:Int)
	{
		pixels.setPixel32(x, y, col);
		pixels.setPixel32(x + 1, y, col);
	}//---------------------------------------------------;
	// --
	inline function renderStar_normal(x:Int, y:Int, col:Int)
	{
		pixels.setPixel32(x, y, col);
	}//---------------------------------------------------;	
	// --
	inline function renderStar_Big(x:Int, y:Int, col:Int)
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
		ar_stars_fg = null;
		ar_start_extra = null;
		ar_fg_speedVariation = null;
	}//---------------------------------------------------;
	
	
}// -- end --//