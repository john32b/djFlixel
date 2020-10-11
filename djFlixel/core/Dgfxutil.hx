/**
 * Bitmap Utilities
 * ================
 * 
 * - Bitmap Utilities for use in FLIXEL
 * - More bitmap utilities at <D.bmu>
 */

 
package djFlixel.core;

import djFlixel.gfx.pal.*;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import openfl.display.BitmapData;


@:dce
class Dgfxutil
{
	// Prefix for when parsing a color string
	static inline var PREFIX_PALETTE:String = "@";
	
	public function new() 
	{
	}//---------------------------------------------------;
	
	
	/**
	 * Return an animated flxSprite loaded with the "img" tilesheet
	 * stopped to target frame.
	 * @param img Path of the image
	 * @param frame number the frame to stop
	 * @param width Frame Width
	 * @param height Frame height
	 **/
	public function getSpriteFrame(img:String, frame:Int, width:Int, height:Int):FlxSprite
	{
		var s = new FlxSprite(0, 0);
		s.loadGraphic(img, true, width, height);
		s.animation.frameIndex = frame;
		return s;
	}//---------------------------------------------------;
	
	/**
	   Make sure the bitmap is WHITE 0xFFFFFFFF, and alpha masked
	   Operates on source, so use .clone() if you must
	**/
	public function colorizeBitmapWithTextStyle(src:BitmapData, st:djFlixel.core.Dtext.DTextStyle):BitmapData
	{
		var res:BitmapData = src;
		if (st == null) return res;
		if (st.c != null) {
			res = D.bmu.replaceColor(src, 0xFFFFFFFF, st.c);
		}
		if (st.bc != null) {
			var ox = 1; var oy = 1;
			if (st.so != null) { ox = st.so[0]; oy = st.so[1]; }
			var s = 1;
			if (st.s != null) s = st.s;
			res = D.bmu.applyShadow(res, st.bc, ox * s, oy * s);
		}
		return res;
	}//---------------------------------------------------;
	
	
	
	/**
	 * Parse a custom color string, useful when reading color data from INI/JSON files
	 * Will check the string for PaletteColors "check palCol()" and then pass it to FlxColor.fromString()
	 * @param	s The Coded String. e.g. "@A16[34]", "@DB32[23]", "blue", "#0000FF" "0x00FF00"
	 */
	public function sCol(s:String):Int
	{
		if (s.indexOf(PREFIX_PALETTE) == 0) {
			return palCol(s.substr(1)); // It's a Palette Color
		}else{
			return FlxColor.fromString(s);
		}
	}//---------------------------------------------------;
	
	
	/**
	 * Return a palette color based on a string code
	 * Supported :: (check djFlixel.gfx.palette.*)
	 * 
	 * 	A16[]  	-> Arne 16
	 *  DB16[]  -> DB16
	 *  DB32[] 	-> DB32
	 *  CPC[]	-> Amstrad CPC
	 *  CPCBOY[] -> CPC Boy
	 * 
	 * e.g.
	 * 
	 * 	palCol("A16[3]") == 0xFFBE2633 ; the 4th color of the palette
	 * 
	 * @param str A16[0-15] | DB32[0-31] | AMS[0-26]
	 */
	static public function palCol(str:String):Int
	{
		var exp = ~/(.+)\[(\d+)\]/;
		exp.match(str);
		if (exp.matched(1) != null){
			var ind = Std.parseInt(exp.matched(2));
			switch(exp.matched(1)){
				case "A16" : return Pal_Arne16.COL[ind];
				case "DB16" : return Pal_DB16.COL[ind];
				case "DB32" : return Pal_DB32.COL[ind];
				case "CPC" : return Pal_CPC.COL[ind];
				case "CPCBOY" : return Pal_CPCBoy.COL[ind];
				case _ :
			}
		}
		trace("ERROR - Error parsing Pallete String", str); return 0;
	}//---------------------------------------------------;
	
	
	/**
	 * Copy All Fields AND translates colors. Overwrites the target object's fields. 
	 *  
	 * - If a field starts with "color" it will automatically convert it to proper INT
	 *    e.g. "0xffffff" or "blue" => (int)0x0000FF
	 * 
	 * - Palettes : Supports Getting colors from Palettes , check GfxTool.palCol(.)
	 *		use the "@" prefix and call normally. 
	 *		e.g. "@A16[3]" => (int)0xFFBE2633 
	 * 
	 * @param	from The Source Object to copy fields from 
	 * @param	into The Destination object, if null it will be created. It is altered in place
	 * @return  The resulting object
	 */
	/// TODO:
	public static function copyFieldsC(from:Dynamic, ?into:Dynamic):Dynamic
	{
		//if (into == null) into = {};
		//if (from != null)
		//
		//for (f in Reflect.fields(from)) 
		//{	
			//var d:Dynamic = Reflect.field(from, f);
			//
			//// f is the name of the field
			//// d is the field data
			//
			//// Convert COLOR string and array of strings to INT
			//if (f.indexOf("color") == 0) {
				//
				//if (Std.is(d, Array))
				//{
					//var ar:Array<Int> = [];
					//var arS:Array<String> = d;
					//var c:Int = 0;
					//while (c < arS.length) ar.push(GfxTool.stringColor(arS[c++]));
					//Reflect.setField(into, f, ar);
					//continue;
				//}
				//else if (Std.is(d, String))
				//{
					//Reflect.setField(into, f, GfxTool.stringColor(d));
					//continue;
				//}
			//}
			//
			//// Process any object nodes
			//if (Reflect.isObject(d) && !Std.is(d, Array) && !Std.is(d, String))
			//{	
				//if (!Reflect.hasField(into, f)) Reflect.setField(into, f, {});
				//copyFieldsC(d, Reflect.field(into, f));	// Recursion ftw
				//continue;
			//}
			//
			//// Just copy everything else.
			//Reflect.setField(into, f, Reflect.field(from, f));
		//}
		//
		//return into;
		return null;
	}//---------------------------------------------------;
}// --