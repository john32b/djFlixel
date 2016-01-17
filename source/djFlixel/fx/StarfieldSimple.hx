/**
 * Very simple starfield
 * =======================
 * 
 * Example
 * -----------
 * var stars = new StarfieldSimple(200,200);
 * 	stars.flag_widepixel = true;
 * 	stars.setColors([...]);
 * 	stars.initialize();
 * 	add(stars);
 * -----------------
 * + That's it, the stars will automatically scroll now.
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
	
	// Update the star layer every X time, to save some CPU
	var updateFrequency:Float = 0.3; // Currently unused
	var timeCur:Float = 0;
	
	// Dynamic render function for each star
	var renderStarFN:Int->Int->Int->Void;	// This MUST be set later
	
	// The angle which the stars are traveling in degrees
	var currentAngle:Float;
	var currentSpeed:Float;
	
	// Calculated Vector for traveling of the stars
	var dirX:Float;
	var dirY:Float;
	
	// == USER SET ===========================
	// --
	// Whether or not to render with widepixels (2x1 normal pixels)
	public var flag_widepixel:Bool = false;
	
	public var stars_max:Int;
	// The actual colors of the stars
	// You can also call setColors(...);
	public var color_1:Int;
	public var color_2:Int;
	public var color_3:Int;
	public var color_bg:Int;
	//---------------------------------------------------;

	public function new(_width:Int,_height:Int)
	{	
		super();
		
		width = _width;
		height = _height;
		
		// Create the arrays to store the stars
		ar_stars_bg = [];
		ar_stars_fg = [];
		ar_start_extra = [];
		ar_fg_speedVariation = [];
		
		// Set the default paramers
		stars_max = DEF_STARS_MAX;
		color_1 = DEF_COLOR_1;
		color_2 = DEF_COLOR_2;
		color_3 = DEF_COLOR_3;
		color_bg = DEF_COLOR_BG;
		
		
		setDirection(DEF_TRAVEL_ANGLE);
		setSpeed(0.5);
		
	}//---------------------------------------------------;

	/**
	 * Set the starfield colors in an array, 
	 * @param cols an Array with 4 colors, from DARKEST to BRIGHTEST
	 */
	public function setColors(cols:Array<Int>, reverse:Bool)
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
	
	// --
	public function setSpeed(spd:Float)
	{
		if (spd > 64) spd = 64;
		if (spd < 0) spd = 0;
		
		currentSpeed = spd;
	}//---------------------------------------------------;
	
	// --
	// Call this after creating the object, and after
	// setting the custom parameters
	public function initialize()
	{
		var intWidth:Int = Std.int(width);
		var intHeight:Int = Std.int(height);
		
		if (graphic != null) graphic.destroy();
		
		makeGraphic(intWidth, intHeight, color_bg);
		
		var numOfFgStars = Math.floor(stars_max * 0.65);
		var r:SimpleVector;
		
		// -- Push the stars in the arrays
		
		for (i in 0...stars_max)
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
		
		// Create some unique extra bright stars?
		var numberOfExtraStars:Int = Std.int(stars_max * 0.05);
		for (i in 0...numberOfExtraStars)
		{
			r = new SimpleVector(FlxG.random.int(0, intWidth), FlxG.random.int(8, intHeight - 8));
			ar_start_extra.push(r);
		}
		
		// -- 
		
		if (flag_widepixel)
		{
			renderStarFN = renderStar_widepixel;
		}else
		{
			renderStarFN = renderStar_normal;
		}
		
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	
		//timeCur -= FlxG.elapsed;
		//if (timeCur < 0) {
			pixels.lock();
			
			updateStarArray(ar_stars_bg, LAYER_1_SPEED * currentSpeed, color_1);
			updateStarArrayFG(ar_stars_fg, LAYER_2_SPEED * currentSpeed, color_2);
			updateStarArray(ar_start_extra, LAYER_3_SPEED * currentSpeed, color_3);
			
			
			pixels.unlock();
			dirty = true;
		//timeCur = updateFrequency;
		//}
			
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
	// Hacky way to add variation to the stars
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
	}//---------------------------------------------------;
	
	
}// -- end --//