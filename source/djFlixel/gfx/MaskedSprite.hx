package djFlixel.gfx;

import flash.geom.Point;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import djFlixel.gfx.GfxTool;

/**
 * Load an image and apply masking
 * ...
 */
class MaskedSprite extends FlxSprite
{

	/**
	 * 
	 * @param	im Warning, if a tilesheet ,make sure it is a SINGLE ROW
	 * @param	type  [ hole | invert ]
	 * @param	color_ Color to apply on effects
	 * @param	sheet { .tw .th .frame } Set these if you want a portion of a tilesheet
	 */
	public function new(im:FlxGraphicAsset, ?sheet:Dynamic, type:String = "hole", color_:Int = 0xFFFFFFFF )
	{
		super();
		
		if (sheet != null)
		{
			pixels = GfxTool.getBitmapPortion(im, Std.int(sheet.tw * sheet.frame), 0, sheet.tw, sheet.th);
		}else{
			loadGraphic(im, false, 0, 0);
		}
					
		var process:Int->Int;
		
		if (type == "hole") 
		{
			process = function(i:Int){
				return i == color_?0x00000000:i;
			}
		}
		else if (type == "invert")
		{
			process = function(i:Int){
				return i == 0x00000000?color_:0x00000000;
			}
		}else{
			throw "Unsupported";
		}
		
		// Note: I could do this with pixels.threshold()
		pixels.lock();
		for (xx in 0...pixels.width)
		for (yy in 0...pixels.height)
		pixels.setPixel32(xx, yy, process(pixels.getPixel32(xx, yy)));
		pixels.unlock();
	}//---------------------------------------------------;
	
	
	override public function destroy():Void 
	{
		super.destroy();
	}//---------------------------------------------------;
	/**
	 * Change the canvas size of the mask outwards in with a color if bigger
	 * @param	w_ New Width
	 * @param	h_ New Height
	 * @param	c_ The color of new pixels created
	 */
	public function expand(w_:Int, h_:Int, c_:Int = 0xFF000000)
	{
		var oldPix = pixels.clone();
		
		var r = new Rectangle(0, 0, oldPix.width, oldPix.height);
		var p = new Point( Std.int((w_ / 2) - (oldPix.width / 2)),
						   Std.int((h_ / 2) - (oldPix.height / 2)));
		
		pixels = new BitmapData(w_, h_, true, c_);
		pixels.copyPixels(oldPix, r, p);
		oldPix.dispose();
	}//---------------------------------------------------;
		
}// --