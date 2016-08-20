package djFlixel.gfx;

import flash.display.Bitmap;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxSpriteUtil;
import openfl.Assets;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.geom.Point;

/**
 * Various general purpose Graphic Tools
 * for use in my haxe flixel projects
 * ...
 * Static class
 */
class GfxTool
{
	
	/**
	 * Draws a map as an image to a BitmapData based from 2D array MapData
	 * 
	 * @param	source BitmapTiles to draw tiles from
	 * @param	tw Tile Width
	 * @param	th Tile Height
	 * @param	mapdata 2D Array of Mapdata
	 * @return  Composited Image
	 */
	public static function drawTilesToBitmap(source:BitmapData, tw:Int, th:Int, mapdata:Array<Array<Int>>):BitmapData
	{
		var mapwidth:Int = mapdata[0].length;
		var mapheight:Int = mapdata.length;
		var bit = new BitmapData(mapwidth * tw, mapheight * th, true, 0);
		var rect:Rectangle = new Rectangle();
		var point:Point = new Point();
		var sTilesInW = Std.int(source.width / tw);
		var tile:Int;
		
		bit.lock();
		
		for (yy in 0...mapheight)
		for (xx in 0...mapwidth)
		{
			tile = mapdata[yy][xx] - 1;
			
			if (tile >= 0)
			{
				rect.setTo( (tile % sTilesInW) * tw, 
							Std.int(tile / sTilesInW) * th, tw, th);
				point.setTo(xx * tw, yy * th);
				bit.copyPixels(source, rect, point);
			}
		}
		
		bit.unlock();
		return bit;
	}//---------------------------------------------------;
	
		
	
	public static function getBitmapPortion(source:FlxGraphicAsset, x:Int, y:Int, width:Int, height:Int):BitmapData
	{
		var r = new BitmapData(width, height);
		var rect:Rectangle = new Rectangle(x, y, width, height);
		var point:Point = new Point(0, 0);
		var sourceData:BitmapData;
		
		if (Std.is(source, BitmapData))
		{
			sourceData = cast source;
		}else if (Std.is(source, String))
		{
			sourceData = Assets.getBitmapData(cast source);
		}else {
			sourceData = cast(source, FlxGraphic).bitmap;
		}
		
		r.copyPixels(sourceData, rect, point);

		return r;
	}//---------------------------------------------------;
	
	
	/**
	 * Draws an entire bitmap onto another bitmap at coordinates
	 * @param	bit The bitmap to be drawn
	 * @param	dest The bitmap to be drawn to
	 * @param	x
	 * @param	y
	 */
	public static function drawBitmapOn(bit:BitmapData, dest:BitmapData, x:Int, y:Int)
	{
		var rect:Rectangle = new Rectangle(0, 0, bit.width, bit.height );
		var point:Point = new Point(x, y);
		dest.copyPixels(bit, rect, point);
	}//---------------------------------------------------;
	
	
		
	/**
	 * Return an animated flxSprite loaded with the "img" tilesheet
	 * stopped to target frame.
	 * @param img Path of the image
	 * @param frame number the frame to stop
	 * @param width Frame Width
	 * @param height Frame height
	 **/
	public static function getSpriteFrame(img:String, frame:Int, width:Int, height:Int):FlxSprite
	{
		var s = new FlxSprite(0, 0);
		s.loadGraphic(img, true, width, height);
		s.animation.frameIndex = frame;
		return s;
	}//---------------------------------------------------;
	
	
	
	/**
	 * Replace a set of colors in a bitmap with another set of colors
	 * Creates a new bitmap, does not modify the original one.
	 * #NOTE: You should declare "persist==true" if you want to keep it after state change
	 * @param	b The bitmap to read
	 * @param	source Source Array of colors [black,red]
	 * @param	dest Destination array of colors [targetcol, targetcol]
	 * @return
	 */
	public static function getGraphicColorReplace(b:BitmapData, source:Array<Int>, dest:Array<Int>):FlxGraphic
	{
		var gfx:FlxGraphic = FlxG.bitmap.create(b.width, b.height, 0x00000000, true);
			
		// gfx.persist = true;
		
		// Check to see if the source and dest are the same length
		#if debug
		if (source.length != dest.length) {
			trace("Error: Source and Destination color mappings are different sized");
			return null;
		}
		#end
		
		gfx.bitmap.lock();
		
		var col:Int;
		var ind:Int;
		
		for (y in 0...b.height)
		for (x in 0...b.width)
		{
			col = b.getPixel32(x, y);
			if (col == 0) continue;
			
			ind = source.indexOf(col);
			if (ind >= 0) {
				// Write the mapped color
				gfx.bitmap.setPixel32(x, y, dest[ind]);
			}else {
				// Write the same color with no change
				gfx.bitmap.setPixel32(x, y, col);
			}
		}
			
		gfx.bitmap.unlock();
	
		return gfx;
	
	}//---------------------------------------------------;
	
	static inline public function extractRed(c:Int):Int 
	{
		return (( c >> 16 ) & 0xFF);
	}//---------------------------------------------------;
	static inline public function extractGreen(c:Int):Int 
	{
		return ( (c >> 8) & 0xFF );
	}//---------------------------------------------------;
	static inline public function extractBlue(c:Int):Int 
	{
		return ( c & 0xFF );
	}//---------------------------------------------------;
	
	/**
	 * Snaps to color
	 * @param	a COLOR 
	 * @param	div snap value(1-255)
	 * @return
	 */
	static inline public function snapToLowerBitRepr(a:Int,div:Int = 64):Int
	{
		return Math.floor(a / div) * div;
	}//---------------------------------------------------;
	
	
}// -- end --//