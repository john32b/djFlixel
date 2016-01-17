package djFlixel;
import flixel.FlxSprite;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.geom.Point;

/**
 * Various general purpose tools
 * for use in my haxe flixel projects
 * ...
 * Static class
 */
class MyTools
{
	/**
	 * Create a 2D array
	 * @param	width 
	 * @param	height
	 * @return
	 */
	public static function create2DArray(width:Int, height:Int):Array<Array<Int>>
	{
		var r:Array<Array<Int>> = [];
		
		for (y in 0...height)
		{
			r[y] = [];
		}
		
		return r;
	}//---------------------------------------------------;
	
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
	 * Apply a function to a string of CSV.
	 * @param	csv The string to parse for data. e.g. "color:blue,speed:100,level:4"
	 * @param	fn The function to apply, takes 2 arguments, field:String and value:String.
	 */
	public static function applyToCSVParams(?csv:String, fn:String->String->Void):Void
	{
		if (csv == null) return;
		
		var pairs:Array<String> = csv.split(',');
		
		var d:Array<String>;
		
		for (p in pairs)
		{
			d = p.split(':');
			fn(d[0], d[1]);
		}
		
	}//---------------------------------------------------;

	
	public static function CSVGetQuick(?csv:String, field:String):String
	{
		if (csv == null) return null;
		var pairs:Array<String> = csv.split(',');
		var d:Array<String>;
		for (p in pairs) {
			d = p.split(':');
			if (d[0] == field) return d[1];
		}
		return null;
	}//---------------------------------------------------;
		
	/**
	 * Return an animated flxSprite loaded with the "img" tilesheet
	 * stopped to frame Frame. The Width and height are of the frames
	 **/
	public static function getSpriteFrame(img:String, frame:Int, width:Int, height:Int):FlxSprite
	{
		var s = new FlxSprite(0, 0);
		s.loadGraphic(img, true, width, height);
		s.animation.frameIndex = frame;
		return s;
		
		// DEV
	}//---------------------------------------------------;
	
	
	
	// Creates and return a union of 2 arrays.
	// --
	// !! USE WITH CAUTION !!
	// IMPORTANT !!: Depending on the structure, the arrays might be pointers and not 1:1 copies!!!
	// It is safe for basic types such as strings, ints, bools and floats
	public static function arrayUnion<T>(ar1:Array<T>, ar2:Array<T>):Array<T>
	{
		var n = ar1.copy();
		for (i in ar2)
		{
			if (n.indexOf(i) < 0) n.push(i);
		}
		return n;
	}//---------------------------------------------------;
	
}// -- end --//