package djFlixel.gfx;

import flixel.FlxSprite;
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
		
	/**
	 * Return an animated flxSprite loaded with the "img" tilesheet
	 * stopped to frame Frame. The 
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

	
	
}// -- end --//