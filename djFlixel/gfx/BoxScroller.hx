/*
 BoxScroller.hx
 ---------------
 - timles an image inside a square
 - Useful for Paralax layers or fullscreen backgrounds.
 - For Performance reasons, don't use very small image sources
 - NEW: Updated code, much shorter and more efficient
 
 NOTE: Works like `FlxtimledSprite.hx` but this is faster since
 		 it's using `copyPixels()`
		 
 EXAMPLE:
 -------
 		var BS = new BoxScroller("images/pattern.png", 0, 0, 200, 200);
		BS.autoScrollX = 2;	// will auto scroll 2 pixels per update
		add(BS);
============================================= */ 
 
package djFlixel.gfx;

import flash.display.BitmapData;
import flash.display.PixelSnapping;

import openfl.Assets;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets;


class BoxScroller extends FlxSprite
{
	// The image that is going to be timled
	var tim:BitmapData;
	var tr:Rectangle;
	var dp:Point;
	
	// Sanitimzed values of actual scroll of the texture
	// these values clamp at texture width and height
	var _scX:Int = 0;
	var _scY:Int = 0;
	
	// -- Scroll values of the timling in pixels
	public var scrollX(default, set):Float = 0;
	public var scrollY(default, set):Float = 0;
	
	public var autoScrollX:Float = 0;
	public var autoScrollY:Float = 0;
	
	// Last scroll values it was drawn with, prevend duplicate draws
	var _lastScX:Int = 0;
	var _lastScY:Int = 0;
	
	/**
	 * 
	 * @param	X World Placement
	 * @param	Y World Placement
	 * @param	W Box Width, 0 for source image Width
	 * @param	H Box Height, 0 for source image height
	 * @param   Ytimling timles on the Y Axis also
	 * @param	source
	 */
	
	public function new(source:FlxGraphicSource, X:Float = 0, Y:Float = 0, W:Float = 0, H:Float = 0) 
	{
		super(X, Y);
		
		tr = new Rectangle();
		dp = new Point();
		
		loadNewGraphic(source, W, H);
	}//---------------------------------------------------;

	/**
	 * Load a new image and keep the same box dimensions
	 * @param	source
	 */
	public function loadNewGraphic(source:FlxGraphicSource, W:Float = 0, H:Float = 0)
	{
		tim = FlxAssets.resolveBitmapData(source);
		_scX = 0; _scY = 0;
		if (W == 0) W = tim.width;
		if (H == 0) H = tim.height;
		if (pixels == null)	resize(W, H);
		update(FlxG.elapsed);	// force an update to the graphic
	}//---------------------------------------------------;
	
	public function resize(W:Float, H:Float)
	{
		makeGraphic(cast W, cast H, 0x00000000, true); // Transparent
	}//---------------------------------------------------;
	
	/**
	   @param	yAxis Randomize Y Scroll Also
	**/
	public function randomOffset(yAxis:Bool = false)
	{
		scrollX = FlxG.random.int(0, tim.width);
		if (yAxis) scrollY = FlxG.random.int(0, tim.height);
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		scrollX += autoScrollX;
		scrollY += autoScrollY;
		
		// Don't redraw for no reason
		if (_lastScX == _scX && _lastScY == _scY) return;
		
		pixels.lock();
		
		var J:Int = 0; // height pixels drawn
		if (_scY > 0) {
			_drawStripe(tim.height - _scY, _scY, 0);
			J = _scY;
		}
		while (J < pixels.height) {
			_drawStripe(0, tim.height, J);
			J += tim.height;
		}
		pixels.unlock();
		_lastScX = _scX; _lastScY = _scY;
		dirty = true;
	}//---------------------------------------------------;
		
	
	/**
	 * Draws a horizontal timled stripe of the source image
	 * @param	sourceY Y on the source image
	 * @param	sourceHeight Height on the source image
	 * @param	destY Draw to this (y) on buffer
	 */
	function _drawStripe(sourceY:Int, sourceHeight:Int, destY:Int)
	{
		dp.y = destY;
		tr.y = sourceY;
		tr.height = sourceHeight;
		var J:Int = 0; // length drawn, 0 to max pixels.width
		if (_scX > 0)
		{
			tr.x = tim.width - _scX;
			tr.width = _scX;
			dp.x = 0;
			pixels.copyPixels(tim, tr, dp);
			J = _scX;
		}
		while (J < pixels.width)
		{
			tr.x = 0;
			tr.width = tim.width;
			dp.x = J;
			pixels.copyPixels(tim, tr, dp);
			J += tim.width;
			// NOTE: There are cases where copypixels will overshoot a draw but it is not costly
			//       happens at the last loop, but I want to save a check
		}
	}//---------------------------------------------------;

	
	//====================================================;
	// GETTERS, SETTERS
	//====================================================;
	
	// --
	function set_scrollX(value:Float):Float
	{
		scrollX = value;
		_scX = Std.int(scrollX % tim.width);
		if (_scX < 0) _scX += tim.width;
		return scrollX;
	}//---------------------------------------------------;
	
	// --
	function set_scrollY(value:Float):Float
	{
		scrollY = value;
		_scY = Std.int(scrollY % tim.height);
		if (_scY < 0) _scY += tim.height;
		return scrollY;
	}//---------------------------------------------------;
	
}// --
