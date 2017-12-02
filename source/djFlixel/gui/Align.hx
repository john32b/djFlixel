package djFlixel.gui;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

/**
 * STATIC CLASS HELPER
 * Quick and Easy align sprites
 * ...
 */
class Align
{
	/**
	 * 
	 * @param	X left,center,right,none
	 * @param	Y top,center,bottom,none
	 * @param   padding Apply this much padding in pixels
	 */
	public static function screen(obj:FlxObject, X:String = "center", Y:String = "center", padding:Int = 0):FlxObject
	{
		switch(X)
		{
			case "left" : obj.x = 0 + padding;
			case "right" : obj.x = obj.camera.width - obj.width - padding;
			case "center" : obj.x = (obj.camera.width / 2) - (obj.width / 2);
			case "none" : 
			default:
		}
		
		switch(Y)
		{
			case "top" : obj.y = 0 + padding;
			case "bottom" : obj.y = obj.camera.height - obj.height - padding;
			case "center" : obj.y = (obj.camera.height / 2) - (obj.height / 2);
			case "none":
			default: 
		}
		
		return obj; // for chaining
	}//---------------------------------------------------;
	
	
	/**
	 * Place an object NEXT to another object
	 * 
	 * @param	source The object to change coords
	 * @param	of The object being a reference
	 * @param	adjX Adjust the X pos for a custom fitting
	 * @param	adjY Adjust the Y pos for a custom fitting
	 * @return
	 */
	public static function nextTo(source:FlxObject, of:FlxObject, adjX:Int = 0, adjY:Int = 0):FlxObject
	{
		source.x = of.x + of.width + adjX;
		source.y = of.y + adjY;
		return source;
	}//---------------------------------------------------;
	
	/** 
	 * Place an object LEFT to another object
	 */
	public static function prevTo(source:FlxObject, of:FlxObject, adjX:Int = 0, adjY:Int = 0):FlxObject
	{
		source.x = of.x - source.width + adjX;
		source.y = of.y + adjY;
		return source;
	}//---------------------------------------------------;
	
	/**
	 * Place an object below another object and center the middle point to match the source object
	 */
	public static function downCenter(source:FlxObject, of:FlxObject, paddingY:Int = 0):FlxObject
	{
		source.x = of.x + ((of.width - source.width) / 2);
		source.y = of.y + of.height + paddingY;
		return source;
	}//---------------------------------------------------;
	
	/**
	 * Place an array of objects below another object and center the middle point to match the source object
	 */
	@:deprecated("Use inLineCenterBelow()")
	public static function downCenterM(source:Array<FlxObject>, of:FlxObject, paddingY:Int = 0, paddingEl:Int = 0)
	{
		var tot:Float = 0;
		for (i in source) {
			tot += i.width;
			i.y = of.y + of.height + paddingY;
		}
		source[0].x = of.x + ((of.width - tot) / 2);
		for (i in 1...source.length) {
			source[i].x = source[i - 1].x + source[i - 1].width + paddingEl;
		}
	}//---------------------------------------------------;
	
	
	/**
	 * Align a bunch of objects in a line
	 * @param	x Line start X
	 * @param	y Line start Y
	 * @param	width Width of the Line
	 * @param	elements Array of elements to align
	 * @param	align center,left,right,justify
	 * @param   pad if align="center,left,right" use padding between elements in pixels
	 */
	public static function inLine(x:Float, y:Float, width:Float, elements:Array<FlxSprite>, align:String = "center", pad:Int = 1)
	{
		var sx:Float; // start x, when placing
		var tw:Float = 0; // total Width padding included
		
		inline function getTW(){
			tw = 0;
			for (i in elements) tw += i.width;
			tw += (elements.length - 1) * pad; // Total width of all the elements with padding
		};
		
		switch(align)
		{
			case "center":
				getTW();
				sx = x + (width / 2) - (tw / 2);
				for (i in elements){ i.x = sx; sx += (i.width + pad); i.y = y; }
			case "left":
				sx = x;
				for (i in elements){ i.x = sx; sx += (i.width + pad); i.y = y; }
			case "right":
				getTW();
				sx = x + width - tw;
				for (i in elements){ i.x = sx; sx += (i.width + pad); i.y = y; }	
			case "justify":
				pad = 0; getTW(); // zero out pad beforehand because I need the exact total width
				var p = (width - tw) / (elements.length + 1); // 1 element should split the available width by 2..etc
				sx = x + p;
				for (i in elements){ i.x = sx; sx+= i.width + p; i.y = y; }	
			default:
				throw "Unsupported, check for typos";
		}
	}//---------------------------------------------------;
	
	
	/**
	 * Align a bunch of elements centered below a target sprite
	 * @param	elements Array of elements to align on the line
	 * @param	source The element to put the line below
	 * @param	padX X padding of line elements
	 * @param	padY Y padding from the source element
	 */
	public static function inLineCenterBelow(elements:Array<FlxSprite>, source:FlxSprite, padX:Int = 1, padY:Int = 1)
	{
		inLine(source.x, source.y + source.height + padY, source.width, elements, "center", padX);
	}//---------------------------------------------------;
	
	/**
	 * Align a bunch of elements vertically 
	 * @param	x Line start X
	 * @param	y Line start Y
	 * @param	height Line Height
	 * @param	elements The elements to align
	 * @param	align center,top,bottom,justify
	 * @param   pad if align="center,top,bottom" use padding between elements in pixels
	 */
	public static function inVLine(x:Float, y:Float, height:Float, elements:Array<FlxSprite>, align:String = "center", pad:Int = 1)
	{
		var sy:Float; // start x, when placing
		var th:Float = 0; // total Width padding included
		
		inline function getTH(){
			th = 0;
			for (i in elements) th += i.height;
			th += (elements.length - 1) * pad; // Total width of all the elements with padding
		};
		
		switch(align)
		{
			case "center":
				getTH();
				sy = y + (height / 2) - (th / 2);
				for (i in elements){ i.y = sy; sy += (i.height + pad); i.x = x; }
			case "top":
				sy = y;
				for (i in elements){ i.y = sy; sy += (i.height + pad); i.x = x; }
			case "bottom":
				getTH();
				sy = y + height - th;
				for (i in elements){ i.y = sy; sy += (i.height + pad); i.x = x; }
			case "justify":
				pad = 0; getTH(); // zero out pad beforehand because I need the exact total width
				var p = (height - th) / (elements.length + 1); // 1 element should split the available width by 2..etc
				sy = y + p;
				for (i in elements){ i.y = sy; sy+= i.height + p; i.x = x; }	
			default:
				throw "Unsupported, check for typos";
		}
	}//---------------------------------------------------;
	
	
}// --