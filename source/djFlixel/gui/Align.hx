package djFlixel.gui;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;

/**
 * Quick and Easy align objects
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
	public static function screen(obj:FlxObject, X:String, Y:String, padding:Int = 0):FlxObject
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
	
	// --
	// Place an object LEFT to another object
	public static function prevTo(source:FlxObject, of:FlxObject, adjX:Int = 0, adjY:Int = 0):FlxObject
	{
		source.x = of.x - source.width + adjX;
		source.y = of.y + adjY;
		return source;
	}//---------------------------------------------------;
	
	// -- 
	// Place an object below another object and center the middle point to match the source object
	public static function downCenter(source:FlxObject, of:FlxObject, paddingY:Int = 0):FlxObject
	{
		source.x = of.x + ((of.width - source.width) / 2);
		source.y = of.y + of.height + paddingY;
		return source;
	}//---------------------------------------------------;
	
	
	public static function downCenterM(source:Array<FlxObject>, of:FlxObject, paddindY:Int = 0, paddingEl:Int = 0)
	{
		var tot:Float = 0;
		for (i in source) {
			tot += i.width;
			i.y = of.y + of.height + paddindY;
		}
		source[0].x = of.x + ((of.width - tot) / 2);
		for (i in 1...source.length) {
			source[i].x = source[i - 1].x + source[i - 1].width + paddingEl;
		}
	}//---------------------------------------------------;
	
}