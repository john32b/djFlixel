package djFlixel.gfx;

import flash.display.Bitmap;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets;
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
	 * Draws a map as an image to a BitmapData based on 2D array MapData
	 * 
	 * @param	source BitmapTiles to draw tiles from
	 * @param	tw Tile Width
	 * @param	th Tile Height
	 * @param	mapdata 2D Array of Mapdata
	 * @return  Composited Image
	 */
	public static function drawTilesToBitmap(source:FlxGraphicAsset, tw:Int, th:Int, mapdata:Array<Array<Int>>):BitmapData
	{
		var bsrc = resolveBitmapData(source);
		var mapwidth:Int = mapdata[0].length;
		var mapheight:Int = mapdata.length;
		var bit = new BitmapData(mapwidth * tw, mapheight * th, true, 0);
		var rect:Rectangle = new Rectangle();
		var point:Point = new Point();
		var sTilesInW = Std.int(bsrc.width / tw);
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
				bit.copyPixels(bsrc, rect, point);
			}
		}
		
		bit.unlock();
		return bit;
	}//---------------------------------------------------;
	
	
	/**
	 * Adds a simple shadow effect to target Bitmap and returns new bitmap
	 * @param	im The bitmap to apply shadow to, needs to be transparent!
	 * @param	color The color of the shadow
	 * @param	offx offset X of the shadow 
	 * @param	offy offset Y of the shadow
	 * @return
	 */
	public static function applyShadow(im:BitmapData, color:Int = 0xFF111111, offx:Int = 1, offy:Int = 1):BitmapData
	{
		var _tr = new Rectangle(0, 0, im.width, im.height);
		var _tc = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
		var _ma = new Matrix();
		var _tp = new Point();
		var n = new BitmapData(im.width, im.height, true, 0x00000000);

		_ma.tx = offx; _ma.ty = offy;  _tc.color = color;
		n.draw(im, _ma, _tc); // The shadow
		_ma.identity();
		n.draw(im, _ma); // Overlay, normal
		
		return n;
	}//---------------------------------------------------;
		
	/**
	 * Returns a rectangular portion of a bitmap
	 * @param	source
	 * @param	x
	 * @param	y
	 * @param	width
	 * @param	height
	 * @return
	 */
	public static function getBitmapPortion(source:FlxGraphicAsset, x:Int, y:Int, width:Int, height:Int):BitmapData
	{
		var r = new BitmapData(width, height);
		var rect:Rectangle = new Rectangle(x, y, width, height);
		var point:Point = new Point(0, 0);
		var sourceData:BitmapData;
		
		sourceData = resolveBitmapData(source);
		
		r.copyPixels(sourceData, rect, point);

		return r;
	}//---------------------------------------------------;
	
	
	/**
	 * Flixel offers FlxAssets.resolveBitmapData(FlxGraphicSource) but not with FlxGraphicAsset
	 * @param	Graphic 
	 * @return
	 */
	public static function resolveBitmapData(Graphic:FlxGraphicAsset):BitmapData
	{
		if (Std.is(Graphic, BitmapData)) {
			return cast Graphic;
		}
		else if (Std.is(Graphic, FlxGraphic)) {
			return cast (Graphic, FlxGraphic).bitmap;
		}
		else if (Std.is(Graphic, String)) {
			return FlxAssets.getBitmapData(Graphic);
		}
		return null;
	}//---------------------------------------------------;
	
	
	/**
	 * Draws an entire bitmap onto another bitmap at coordinates
	 * @param	bit The bitmap to be drawn
	 * @param	dest The bitmap to be drawn to
	 * @param	x
	 * @param	y
	 */
	public static function drawBitmapOn(bit:BitmapData, dest:BitmapData, x:Int = 0, y:Int = 0)
	{
		var rect:Rectangle = new Rectangle(0, 0, bit.width, bit.height );
		var point:Point = new Point(x, y);
		dest.copyPixels(bit, rect, point);
	}//---------------------------------------------------;
	
	
	/**
	 * Takes a bunch of bitmaps and stiches them to a long stripe
	 * @param	ar Array of bitmaps NOTE: They must be of the same size!
	 * @return
	 */
	public static function stitchBitmaps(ar:Array<BitmapData>):BitmapData
	{
		var final:BitmapData = new BitmapData((ar.length * ar[0].width), ar[0].height, true, 0x00000000);
		var rect = new Rectangle(0, 0, ar[0].width, ar[0].height);
		var p = new Point(0, 0);
		for (i in 0...ar.length) {
			final.copyPixels(ar[i], rect, p);
			p.x += ar[i].width;
		}
		return final;
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
	
	
	//====================================================;
	// Bitmap Generator
	//====================================================;
	
	/**
	 * Generate a bitmap with
	 * @param	colors An array with the colors to draw
	 * @param	width Width of the final bitmapdata
	 * @param	height Height of the final bitapdata
	 * @return
	 */
	static public function rainbowStripes(colors:Array<Int>, width:Int = 20, height:Int = 100 ):BitmapData
	{
		var b = new BitmapData(width, height, false);
		var ch:Int = Std.int(height / colors.length);
		var tr:Rectangle = new Rectangle();
		b.lock();
		for (i in 0...colors.length)
		{
			tr.setTo(0, i * ch, width, ch);
			b.fillRect(tr, colors[i]);
		}
		b.unlock();
		return b;
	}//---------------------------------------------------;
	
	
	//====================================================;
	// QUICK PALLETE
	//====================================================;
	
	
	/**
	 * Return a palette color based on a string
	 * Supported :
	 * 
	 * 	A16[0-15]  -> Arne 16
	 *  DB32[0-31] -> DB32
	 *  AMS[0-26]  -> Amstrad
	 * 
	 * e.g.
	 * 
	 * 	palCol("A16[3]") == 0xFFBE2633
	 * 
	 * @param	str A16[] | DB32[] | AMS[]
	 * @return The Color
	 */
	static public function palCol(str:String):Int
	{
		var exp = ~/(.+)\[(\d+)\]/;
		exp.match(str);
		if (exp.matched(1) != null){
			switch(exp.matched(1)){
				case "A16" : return Palette_Arne16.COL[Std.parseInt(exp.matched(2))];
				case "DB32" : return Palette_DB32.COL[Std.parseInt(exp.matched(2))];
				case "AMS" :return Palette_Amstrad.COL[Std.parseInt(exp.matched(2))];
				default : trace("ERROR - Unsupported pallete code", exp.matched(1)); return 0;
			}
		}
		trace("ERROR - Error parsing Pallete String", str); return 0;
	}//---------------------------------------------------;
	
}// -- end --//