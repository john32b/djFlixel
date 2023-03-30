/****************************************************************
 * Some general use helpers/tools for OpenFL Bitmaps
 * 
 ****************************************************************/

package djfl.util;

import flash.display.IBitmapDrawable;
import flash.geom.ColorTransform;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;


@:dce
class BitmapUtil
{
	// General purpose MATRIX
	var m0:Matrix;
	
	public function new()
	{
		m0 = new Matrix();
	}//---------------------------------------------------;
	
	/**
	   Flip a bitmapdata, returns a new bitmapdata
	   @param	b The bitmapdata to flip
	   @param	flipX BOOL X axis Flip
	   @param	flipY BOOL Y axis Flip
	**/
	public function getFlip(b:BitmapData, flipX:Bool = false, flipY:Bool = false):BitmapData
	{
		var s = new BitmapData(b.width, b.height, true, 0x00000000);
		m0.identity();
		if (flipX)
		{
			m0.scale( -1, 1);
			m0.translate(b.width, 0);
		}
		if (flipY)
		{
			m0.scale(1, -1);
			m0.translate(0, b.height);
		}
		s.draw(b, m0);
		return s;
	}//---------------------------------------------------;
	
	
	/**
	   Draw a bitmap onto another bitmap
	   @param	src Source Bitmap
	   @param	dest Destination
	   @param	x Point on Destination
	   @param	y Point on Destination
	   @param	targetWidth Stretch the source to this width.  0 for no scale
	   @param	targetWidth Stretch the source to this height. 0 for no scale
	**/
	public function drawOn(src:BitmapData, dest:BitmapData, x:Float = 0, y:Float = 0, targetWidth:Float = 0, targetHeight:Float = 0):Void
	{
		m0.identity();
		m0.translate(x, y);
		
		// https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/geom/Matrix.html
		// a c tx | sx  0 0 SCALE | cos(q) -sin(q) 0 ROTATE
		// b d ty |  0 sy 0       | sin(q)  cos(q) 0
		// u v w  |  0  0 1       |      0       0 1
		
		if (targetWidth > 0)
		{
			m0.a = targetWidth / src.width;
		}
		
		if (targetHeight > 0)
		{
			m0.d = targetHeight / src.height;
		}
		
		dest.draw(src, m0);
	}//---------------------------------------------------;
	
	
	/**
	   Draw anything drawable
	   @param	src IBitmapDrawable, Shapes, or Sprites, etc
	**/
	public function drawOn_(src:IBitmapDrawable, dest:BitmapData, x:Int = 0, y:Int = 0)
	{
		m0.identity();
		m0.translate(x, y);
		dest.draw(src, m0);
	}//---------------------------------------------------;
	
	/**
	 * Draws an entire bitmap onto another bitmap at coordinates. 
	 * NOTE: The bitmap is copied, so alphas are overwritten.
	 */
	public function copyOn(src:BitmapData, dest:BitmapData, x:Int = 0, y:Int = 0)
	{
		var rect = new Rectangle(0, 0, src.width, src.height );
		var point = new Point(x, y);
		dest.copyPixels(src, rect, point);
	}//---------------------------------------------------;
	
	
	public function get_alpha(v:Int):Int
	{
		return (v >> 24) & 0xff;
	}
	public function get_red(v:Int):Int
	{
		return (v >> 16) & 0xff;
	}
	public function get_green(v:Int):Int
	{
		return (v >> 8) & 0xff;
	}
	public function get_blue(v:Int):Int
	{
		return v & 0xff;
	}

	/**
	   Draw a map onto a bitmap and return it. Gets source bitmap from ATLAS
	   @param	atlas 	The Atlas object
	   @param	seq Atlas Tile Sequence Name.e.g. "bg_tiles"
	   @param	mapdata Single dimension Array
	   @param	mapw  Map Width in tiles
	**/
	public function createBitmapFromMapData(atlas:Atlas, seq:String, mapdata:Array<Int>, mapw:Int):BitmapData
	{
		var inds = atlas.get_indexes(seq);
		
		// -- Get the tile size from the Atlas
		//    get the first tile, since all the tiles should be of the same size
		var r0 = atlas.tiles[inds[0]];
		
		var bit = new BitmapData(mapw * r0.w, Std.int(mapdata.length / mapw) * r0.h, true, 0x00000000);
		
		for (i in 0...mapdata.length)
		{
			var tile = mapdata[i];
			if (tile == 0) continue;
			atlas.drawAt( inds[tile-1], bit, (i % mapw) * r0.w , Std.int(i / mapw) * r0.h);
		}
		
		return bit;	
	}//---------------------------------------------------;
	

	/**
	 * Adds a simple shadow effect to target Bitmap and returns new bitmap
	 * ! Does not mofify the source bitmap. Since the new bitmap size differs
	 * @param	im The bitmap to apply shadow to, needs to be transparent!
	 * @param	color The color of the shadow
	 * @param	offx offset X of the shadow 
	 * @param	offy offset Y of the shadow
	 * @return	A new bitmap, Note, it is now bigger in size
	 */
	public function applyShadow(im:BitmapData, color:Int = 0xFF111111, offx:Int = 1, offy:Int = 1):BitmapData
	{
		var _tr = new Rectangle(0, 0, im.width, im.height);
		var _tc = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
		var _tp = new Point();
		var n = new BitmapData(cast im.width + Math.abs(offx), cast im.height + Math.abs(offy), true, 0x00000000);
		
		_tc.color = color;
		m0.identity();
		
		if (offx < 0){
			m0.tx = 0;
		}else{
			m0.tx = offx;
		}
		if (offy < 0){
			m0.ty = 0;
		}else{
			m0.ty = offy;
		}
		n.draw(im, m0, _tc); // The shadow
		
		m0.tx -= offx;
		m0.ty -= offy;
		n.draw(im, m0); 	// Overlay, normal
		
		return n;
	}//---------------------------------------------------;
	
	
	/**
	 * Replace a color on a bitmap using the built-in Threshold function
	 * ! Modifies the source bitmapdata
	 * It's faster than `FlxBitmapDataUtil.replaceColor()`
	 * @param	source The source bitmap
	 * @param	color0 Color to be replaced
	 * @param	color1 Replace with this color
	 * @return  The new bitmap for chaining
	 */
	public function replaceColor(source:BitmapData, COL0:Int, COL1:Int):BitmapData
	{
		var rect:Rectangle = new Rectangle(0, 0, source.width, source.height);
		var point:Point = new Point();
		source.threshold(source, rect, point, "==", COL0, COL1);
		return source;
	}//---------------------------------------------------;
	
	
	
	/**
	 * Replace a set of colors in a bitmap with another set of colors
	 * This is kinda slow as it does this pixel-by-pixel
	 * ! Modifies the source bitmapdata
	 * @param	src The bitmap to read
	 * @param	COL0 Source Array of colors [black,red]
	 * @param	COL1 Destination array of colors [targetcol, targetcol]
	 * @return  The new bitmap for chaining
	 */
	public function replaceColors(src:BitmapData, COL0:Array<Int>, COL1:Array<Int>):BitmapData
	{
		// Check to see if the source and dest are the same length
		#if debug
		if (COL0.length != COL1.length) throw "Source and Destination color mappings are different sized";
		if (src == null) throw "Bitmap is null";
		#end
		src.lock();
		var col:Int;
		var ind:Int;
		for (y in 0...src.height)
		for (x in 0...src.width) {
			col = src.getPixel32(x, y);
			if (col == 0) continue;
			ind = COL0.indexOf(col);
			if (ind >= 0) { // Write the mapped color
				src.setPixel32(x, y, COL1[ind]);
			}
		}// --
		src.unlock();
		return src;
	}//---------------------------------------------------;
	
	
	/**
	 * Takes a bunch of bitmaps and stitches them together to a long stripe
	 * !NOTE! The bitmaps must be of the same size
	 */
	public function combineBitmaps(ar:Array<BitmapData>):BitmapData
	{
		var f:BitmapData = new BitmapData((ar.length * ar[0].width), ar[0].height, true, 0x00000000);
		var rect = new Rectangle(0, 0, ar[0].width, ar[0].height);
		var p = new Point(0, 0);
		for (i in 0...ar.length) {
			f.copyPixels(ar[i], rect, p);
			p.x += ar[i].width;
		}
		return f;
	}//---------------------------------------------------;
	
	
	/**
	 * Returns a rectangular portion of a bitmap
	 */
	public function getBitmapSquare(source:BitmapData, x:Int, y:Int, width:Int, height:Int):BitmapData
	{
		var r = new BitmapData(width, height);
		var rect = new Rectangle(x, y, width, height);
		var point = new Point(0, 0);
		r.copyPixels(source, rect, point);
		return r;
	}//---------------------------------------------------;

	/**
	   Scale a bitmap using Slice9 method.
	   This method TILES the inner portions, does not use scaling.
	   @param	sb Source Bitmap
	   @param	sr Slices Rect (x,y,width,height) for the middle square (on an imaginary 3x3 grid)
	   @param	width Final Bitmap Width
	   @param	height Final Bitmap Height
	   @param	borderOnly true to skip drawing the middle parts. I don't know if this is useful or not.
	   @return
	**/
	public function scale9(sb:BitmapData, sr:Rectangle, width:Int, height:Int, borderOnly:Bool = false):BitmapData
	{
		var d = new BitmapData(width, height, true, 0x00000000); // destination bitmap
		var r = new Rectangle();	// Rect area from the Source bitmap to draw
		var p = new Point();		// Target point on Destination to draw
		var slx = sb.width - (sr.x + sr.width);	  // End slice width
		var sly = sb.height - (sr.y + sr.height); // End slice height
		
		// Set Source Rect and Destination P.Y before calling
		function dline() {
			var l:Float = sr.x;
			while (l < width - slx) {
				p.x = l;
				d.copyPixels(sb, r, p);
				l += sr.width;
			}
		};
		inline function dSides() {
			r.x = 0; r.width = sr.x; p.x = 0;
			d.copyPixels(sb, r, p);
			r.x = sr.x + sr.width; r.width = slx; p.x = width - slx;
			d.copyPixels(sb, r, p);
		};
		
		// -- TOP ::
		d.lock();
		p.y = 0;
		r.setTo(sr.x, 0, sr.width, sr.y);
		dline(); dSides();
		// -- MIDDLE ::
		// Start drawing line by line until the end
		var t = sr.y; // Start from here, I drew the previous line
		r.y = sr.y; r.height = sr.height; // These are going to stay the same for all operations
		while (t < height - sly) {
			p.y = t;
			r.x = sr.x; r.width = sr.width;
			if (!borderOnly) dline();
			dSides();
			t += sr.height;
		}
		// -- BOTTOM ::
		p.y = height - sly;
		r.setTo(sr.x, sr.y + sr.height, sr.width, sly);
		dline(); dSides();
		// -
		d.unlock();
		return d;
	}//---------------------------------------------------;
	
}// --