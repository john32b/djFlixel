package djFlixel.fx;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxTimer;
import openfl.display.BitmapData;

/**
 * Palette fader
 * 
 * HOW TO USE:
 * -----------
 * 
 * !!! Don't forget to call draw() at every state draw call !!!
 */
class PaletteFader
{
	// -
	var isFading:Bool = false;
	// How many colors in the color array
	var colors_total:Int;
	// Hold the timer for the fade offset
	var offset_timer:Float = 0;
	// The current index in the array that is going to be faded to
	var offset_current:Int = 0;
	// Sometimes the fade will require other ending targets
	var offset_target:Int = 0;
	// Speed increment of the offset, +1 or -1
	var offset_dir:Int = 0;
	// pointer to the camera to apply the fade
	var pixels:BitmapData;
	//-
	var width:Int;
	// -
	var height:Int;
	// - Hold pixels at a solid color
	public var isOpaque(default,null):Bool = false;
	// Stores the callback for when ending a fade
	var callback_complete:Void->Void = null;

	// -- Helpers
	var xx:Int; var yy:Int; var r1:Int; var r2:Int; var p:Int;
	
	// ==  USER SET ========= 
	
	// Array holding all the colors of the active screen palette,
	// Can be as long as it needs
	public var COLORS(default, set):Array<Int>;
	
	// Fade a step every this seconds
	public var step_frequency:Float = 0.12;
	
	//---------------------------------------------------;

	// --
	public function new(_width:Float,_height:Float,?camera:FlxCamera) 
	{
		width = Std.int(_width);
		height = Std.int(_height);
		
		if (camera != null)
		{
			pixels = camera.buffer;
		}else
		{
			// Get the default camera
			pixels = FlxG.camera.buffer;
		}
	}//---------------------------------------------------;
	
	
	
	public function fadeLeft(?callback:Void->Void)
	{
		fade( -1, true, callback);
	}//---------------------------------------------------;
	
	public function fadeRight(?callback:Void->Void)
	{
		fade(1, true, callback);
	}//---------------------------------------------------;
	

	//--
	// Call this after a solid to fade into view
	public function restore(?callback:Void->Void)
	{
		if (isOpaque == false)
		{
			isFading = false;
			trace("Info: Can't restore from a not solid state");
			if (callback != null) callback();
			return;
		}
		
		if (offset_dir == 1)
		{
			fade( -1, false, callback);	// redo some initialization
			offset_target = 0;
			offset_current = colors_total - 2;
		}else
		{
			fade(1, false, callback);
			offset_target = 0;
			offset_current = -colors_total + 2;
		}
	}//---------------------------------------------------;
	
	
	// --
	function fade(direction:Int = 1, waitOnEnd:Bool = false,  ?callback:Void->Void)
	{
		isOpaque = false;
		isFading = true;
		
		offset_timer = 0;
		offset_dir = direction;
		offset_current = 0;

		// Safequard, Sanitize
		if (offset_dir < 0) 
		{
			offset_dir = -1; 
			offset_target = -colors_total;
		}
		else
		{
			
			offset_dir = 1;
			offset_target = colors_total;
		}
			
		offset_current += offset_dir;
		
		// If wait, set to the solid color, call the callback and wait for a restore 
		if (waitOnEnd == true)
		{
			callback_complete = function() {
				solid(offset_dir);
				if(callback!=null) callback();
			}
		}else
		{
			callback_complete = callback;
		}
		
	}//---------------------------------------------------;
	
	//-- Force the screen to go to one end of the COLORS array, 
	// use direction -1 for the first or 1 for the last color on the array
	public function solid(direction:Int = 1, ?autoRestoreTime:Float, ?callback:Void->Void)
	{
		offset_dir = direction;
		// Safequard, Sanitize
		if (offset_dir < 0) 
		{
			offset_current = 0;	// This is the color index to render
		}
		else
		{
			offset_current = colors_total - 1; // This is the color index to render
		}		
		
		isFading = true;
		isOpaque = true;
		
		// Autorestore to normal after x seconds
		if (autoRestoreTime != null)
		{
			new FlxTimer().start(autoRestoreTime, function(_) {
				restore(callback);
			});
		}
		
	}//---------------------------------------------------;
	
	
	//--
	// Call this on the draw() of the state
	public function draw()
	{
		if (!isFading) return;
	
		if (isOpaque)
		{
			// --
			pixels.lock();
			for (xx in 0...width)
			for (yy in 0...height) 
			{
				pixels.setPixel32(xx, yy, COLORS[offset_current]);
			}
			pixels.unlock();
			return;
		}
		
		// Normal Fading --


		// --
		pixels.lock();
		for (xx in 0...width)
		for (yy in 0...height) {
			p = pixels.getPixel32(xx, yy);
			pixels.setPixel32(xx, yy, getAdjColor(p, offset_current));
		}
		pixels.unlock();
		
		
		offset_timer += FlxG.elapsed;
		if (offset_timer > step_frequency) {
			offset_timer = 0;
			offset_current += offset_dir;
			// The offset_target is OFF BY ONE on purpose (from above setters)
			//, so that is has some time to render the color
			if (offset_current == offset_target) 
			{
				isFading = false;
				if (callback_complete != null) callback_complete();
				callback_complete = null;
			}
		}
		
	}//---------------------------------------------------;
		
	
	
	// Get the next color on the color array based on the direction
	// set on this class #fadeDirection
	function getAdjColor(col:Int, offset:Int):Int
	{ 
		for (r1 in 0...colors_total) 
		{
			if (col == COLORS[r1]) 
			{
				r2 = r1;
				break;
			}
		}
		
		// r2 is the index the color was found
		r2 += offset;
		
		if (r2 > colors_total - 1) 
			r2 = colors_total - 1; 
		else
			if (r2 < 0) r2 = 0;

		return COLORS[r2];
	}//---------------------------------------------------;	
	
	// --
	public function set_COLORS(val:Array<Int>):Array<Int>
	{
		COLORS = val;
		colors_total = COLORS.length;
		return COLORS;
	}//---------------------------------------------------;
	
}//-- end --//