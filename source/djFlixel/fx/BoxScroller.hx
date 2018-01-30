package djFlixel.fx;

import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets;

import openfl.Assets;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * Tiles an image inside a square, Useful for Paralax layers or fullscreen backgrounds.
 * For Performance reasons, don't use very small image sources
 * 
 * NOTE: Works like `FlxTiledSprite.hx` but this is faster since
 * 		 it's using `copyPixels()`
 * ...
 * @author John Dimi
 */ 
class BoxScroller extends FlxSprite
{
	
	// The image that is going to be tiled
	var _tIm:BitmapData;
	
	var _trect:Rectangle;
	var _tpoint:Point;
	
	// Sanitized values of actual scroll of the texture
	// these values clamp at texture width and height
	var _scX:Int = 0;
	var _scY:Int = 0;
	
	// -- Scroll values of the tiling in pixels
	public var scrollX(default, set):Float = 0;
	public var scrollY(default, set):Float = 0;
	
	public var autoScrollX:Float = 0;
	public var autoScrollY:Float = 0;
	
	// Last scroll values it was drawn with, prevend duplicate draws
	var _lastScX:Int = 0;
	var _lastScY:Int = 0;
	
	// --
	var flag_tileY:Bool;
	
	// --
	var _updateFunction:Void->Void;
	
	//====================================================;
	
	/**
	 * 
	 * @param	X World Placement
	 * @param	Y World Placement
	 * @param	W Box Width, 0 for source image Width
	 * @param	H Box Height, 0 for source image height
	 * @param   YTiling Tiles on the Y Axis also
	 * @param	source
	 */
	
	public function new(source:FlxGraphicSource, X:Float = 0, Y:Float = 0, W:Float = 0, H:Float = 0, YTiling:Bool = false) 
	{
		super(X, Y);
		
		_tIm = FlxAssets.resolveBitmapData(source);
		
		// -- Just use the X axis for tiling if no Height is set
		if (W == 0) W = _tIm.width;
		if (H == 0) H = _tIm.height;
		
		// There are cases where you don't need y tiling
		if (YTiling){
			flag_tileY = true;
			_updateFunction = _updatePixelsXY;			
		}else {
			flag_tileY = false;
			_updateFunction = _updatePixelsX;
		}
		
		makeGraphic(Std.int(W), Std.int(H), 0x00000000, true); // Transparent
		
		_trect = new Rectangle();
		_tpoint = new Point();
		_scX = 0; _scY = 0;
		
		//trace('---- new BoxScroller() :: ');
		//trace(' - box:$W,$H | image:${_tIm.width},${_tIm.height}');
		//trace(' - TilingY:$flag_tileY -');
		
		_updateFunction(); // Force an initial update.
	}//---------------------------------------------------;

	/**
	 * Load a new image and keep the same box dimensions
	 * @param	source
	 */
	public function loadNewGraphic(source:FlxGraphicSource)
	{
		_tIm = FlxAssets.resolveBitmapData(source);
		_scX = 0; _scY = 0;
	}//---------------------------------------------------;
	
	public function resize(W:Float, H:Float)
	{
		makeGraphic(Std.int(W), Std.int(H), 0x00000000, true); // Transparent
	}//---------------------------------------------------;
	
	// --
	override public function destroy():Void 
	{
		if (_tIm != null) { _tIm.dispose(); _tIm = null; }
		super.destroy();
	}//---------------------------------------------------;
	
	
	/**
	 * Update the X axis only, I am separating the two functions to save some CPU if possible
	 */
	function _updatePixelsX()
	{
		pixels.lock();
		_drawStripe(0, _tIm.height, 0);
		_lastScX = _scX; _lastScY = _scY;
		pixels.unlock();
		dirty = true;
	}//---------------------------------------------------;
		
	
	/**
	 * Update both the X and Y axis
	 */
	function _updatePixelsXY()
	{
		pixels.lock();
	
		// -- Draw stripes from top to bottom
		
		if (_scY <= pixels.height)
		{
			// last portion of source needs to be drawn first
			// draw the rest normally and repeat until pixel.height is full
			_drawStripe(_tIm.height - _scY, _scY, 0);
			
			var lastYY:Int = _scY;
			
			// Start drawing full sources from 0,0 --> variable height
			while (lastYY < pixels.height)
			{
				if (lastYY +_tIm.height > pixels.height)
				{
					// -- Last short draw
					_drawStripe(0, pixels.height - lastYY, lastYY);
					lastYY = pixels.height;
				}else{
					// -- Repeat until full
					_drawStripe(0, _tIm.height, lastYY);
					lastYY += _tIm.height;
				}
			}
			
		}else
		{
			// no repeat needed, just draw the visible portion
			_drawStripe(_tIm.height - _scY, pixels.height, 0);
		}
		
		_lastScX = _scX; _lastScY = _scY;
		pixels.unlock();
		dirty = true;
	}//---------------------------------------------------;
	
	/**
	 * Draws a horizontal tiled stripe of the source image
	 * @param	sourceY Y on the source image
	 * @param	sourceHeight Height on the source image
	 * @param	destY Destination Y on the final buffer
	 */
	function _drawStripe(sourceY:Int, sourceHeight:Int, destY:Int)
	{
		if (_scX <= pixels.width)
		{
			// last portion of source needs to be drawn first
			// draw the rest normally and repeat until pixel.width is full
			_trect.setTo(_tIm.width - _scX, sourceY, _scX, sourceHeight);
			_tpoint.setTo(0, destY);
			pixels.copyPixels(_tIm, _trect, _tpoint);
			
			var lastXX:Int = _scX;
			
			// Start drawing full sources from 0,0 --> variable width
			while (lastXX < pixels.width)
			{
				if (lastXX +_tIm.width > pixels.width)
				{
					// -- Last short draw,
					_trect.setTo(0, sourceY, pixels.width - lastXX, sourceHeight);
					_tpoint.setTo(lastXX, destY);
					pixels.copyPixels(_tIm, _trect, _tpoint);
					lastXX = pixels.width;
				}else{
					// -- Repeat until full
					_trect.setTo(0, sourceY, _tIm.width, sourceHeight);
					_tpoint.setTo(lastXX, destY);
					pixels.copyPixels(_tIm, _trect, _tpoint);
					lastXX+= _tIm.width;
				}
			}
			
		}else
		{
			// no repeat needed, just draw the visible portion
			_trect.setTo(_tIm.width - _scX, sourceY, pixels.width, sourceHeight);
			_tpoint.setTo(0, destY);
			pixels.copyPixels(_tIm, _trect, _tpoint);
		}
	}//---------------------------------------------------;

	// --
	public function randomOffset()
	{
		scrollX = FlxG.random.int(0, _tIm.width);
		scrollY = FlxG.random.int(0, _tIm.height);
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (autoScrollX != 0) scrollX += autoScrollX;
		if (autoScrollY != 0) scrollY += autoScrollY;
		
		// Don't redraw for no reason
		if (_lastScX != _scX || _lastScY != _scY)
		{
			_updateFunction();
		}
		
	}//---------------------------------------------------;
	
	//====================================================;
	// GETTERS, SETTERS
	//====================================================;
	
	// --
	function set_scrollX(value:Float):Float
	{
		scrollX = value;
		_scX = Std.int(scrollX % _tIm.width);
		if (_scX < 0) _scX += _tIm.width;
		return scrollX;
	}//---------------------------------------------------;
	
	// --
	function set_scrollY(value:Float):Float
	{
		scrollY = value;
		_scY = Std.int(scrollY % _tIm.height);
		if (_scY < 0) _scY += _tIm.height;
		return scrollY;
	}//---------------------------------------------------;
	
}// --
