/**--------------------------------------------------------
 * RainbowBorder.hx
 * @author: johndimi, <johndimi@outlook.com> @jondmt
 * --------------------------------------------------------
 * @Description
 * -------
 * Amstrad like animated Colorful borders
 * 
 * @Notes
 * ------
 * 02-2015. rewritten from AS3
 * 
 *********************************************************/
package djFlixel.fx;

import djFlixel.gfx.Palette_Amstrad;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import haxe.Timer;


/**
 * User Example:
 * -------------
 * 	var R = new RainbowBorder();
 * 	R.setPredefined(1);
 * 	add(R);
 * 
 */

class RainbowBorder extends FlxSprite
{
	// defaults:
	private static inline var DEFAULT_MAX__rect_HEIGHT:Int = 30;
	private static inline var DEFAULT_MIN__rect_HEIGHT:Int = DEFAULT_MAX__rect_HEIGHT - 4;
	private static inline var DEFAULT_SPEED:Int = 40;
	
	// * Pointer to the active color array
	private static var COLORS:Array<Int>;
			
	// Parameters, the max and min height of a border color.
	private var param_max_height:Int;
	private var param_min_height:Int;
	private var param_speed:Float;		// Update rate of the borders, in seconds
	private var timer:Float;
	
	// A zoom value of 2+ is recommended to improve speed, as quality doesn't drop
	private var zoom:Int;
	
	// helpers 
	private var __rect:Rectangle;
	private var _ch:Int = 0;
	private var _arlength:Int; // Set the length of the COLORS array to save CPU
	
	//---------------------------------------------------;
	// --
	public function new(_width:Int = 0, _height:Int = 0, inZoom:Int = 2)
	{
		super();
		
		width = _width != 0 ? _width: FlxG.width;
		height = _height != 0 ? _height: FlxG.height;
		zoom = inZoom;
		
		solid = false;
		
		// This will initialize a bitmapData and store it in the cache
		pixels = new BitmapData(Std.int(width / zoom), Std.int(height / zoom), false, 0xFFFFFFFF);
		
		// Note, scaling in flash is a bit slow.
		scale.x = zoom;
		scale.y = zoom;
		origin.set(0, 0);
		
		__rect = new Rectangle();
		__rect.x = 0;
		__rect.width = pixels.width;
		
		COLORS = Palette_Amstrad.COL;	// FUTURE: Set custom colors
		_arlength = COLORS.length;
		
		setPredefined(3);
		
	}//---------------------------------------------------;
	
	// --
	override public function destroy():Void 
	{
		super.destroy();
		__rect = null;
	}//---------------------------------------------------;
	
	/**
	 * Set a predefined mode to run this.
	 * @param	mode [0-3] 0-one color border, 1-big borders, 2-smaller 3-smallest
	 * @return
	 */
	public function setPredefined(mode:Int)
	{
		if (mode > 3) mode = 3;
		if (mode < 0) mode = 0;
		
		var i:Int;
		switch(mode)
		{
			case 0:
				i = Math.ceil(pixels.height * 0.8);
				setBorderSize(i, Math.ceil(i/3));
				setSpeed(0.24);
			case 1:	
				i = Math.ceil(pixels.height / 3);
				setBorderSize(i, Math.ceil(i / 4));
				setSpeed(0.13);
			case 2:	
				i = Math.ceil(pixels.height / 6);
				setBorderSize(i, Math.ceil(i / 2));
				setSpeed(0.1);
			case 3:	
				i = Math.ceil(pixels.height / 16);
				setBorderSize(i, Math.ceil(i / 2));
				setSpeed(0.08);
		}
		
	}//---------------------------------------------------;
	// --
	public function setSolidBg(colorIndex:Int)
	{
		throw "IS THIS BEING USED?";
		
		_ch = 0;
		while (_ch < pixels.height)
		{
			__rect.y = _ch;
			__rect.height = pixels.height;
			_ch += Std.int(__rect.height);
			
			pixels.fillRect(__rect,COLORS[colorIndex]);
		}
	}//---------------------------------------------------;
	// --
	public function setBorderSize(maxH:Int, minH:Int = 0)
	{
		if (minH == 0) minH = Std.int(maxH / 3);
		
		param_max_height = maxH;
		param_min_height = minH;
	}//---------------------------------------------------;
	// --
	public function setSpeed(sp:Float)
	{
		if (param_speed != sp) {
			param_speed = sp;
			timer = 0;
		}
	}//---------------------------------------------------;

	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		
		// DON'T FORGET:
		// -------------
		// This will be called even if visible=false;
		// Use this.active = false to prevent this from updating.
		// ---------------
		
		timer -= FlxG.elapsed;
		
		if (timer < 0)
		{
			// Render a new frame
			timer = param_speed;
			
			_ch = 0;

			pixels.lock();
			
			while (_ch < pixels.height)
			{
				__rect.y = _ch;
				__rect.height = Math.ceil( param_max_height - (Math.random() * param_min_height)) / zoom;
				_ch += Std.int(__rect.height);
				
				pixels.fillRect(__rect, COLORS[Math.floor( Math.random() * _arlength)]);
			}
			
			pixels.unlock();
			dirty = true;
			
		}
	}//---------------------------------------------------;
	

}//-- end class --//