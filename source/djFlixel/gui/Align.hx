package djFlixel.gui;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

/**
 * Align Tools
 * ------------
 * Helper functions that can quickly align sprites to guides and other sprites
 * 
 */
class Align
{
	/**
	 * Align an object using the screen viewport as a guide
	 * @param	obj Object to align
	 * @param	alignX left,center,right,none
	 * @param	alignY top,center,bottom,none
	 * @param   padding Apply this much padding in pixels
	 */
	public static function screen(obj:FlxObject, alignX:String = "center", alignY:String = "center", padding:Float = 0):FlxObject
	{
		switch(alignX)
		{
			case "left" : obj.x = 0 + padding;
			case "right" : obj.x = obj.camera.width - obj.width - padding;
			case "center" : obj.x = (obj.camera.width / 2) - (obj.width / 2);
			// case "none" : 
			default:
		}
		
		switch(alignY)
		{
			case "top" : obj.y = 0 + padding;
			case "bottom" : obj.y = obj.camera.height - obj.height - padding;
			case "center" : obj.y = (obj.camera.height / 2) - (obj.height / 2);
			// case "none":
			default: 
		}
		
		return obj; // for chaining
	}//---------------------------------------------------;
	
	/**
	 * Align Horizontally an object to another object
	 * @param	o Object to Align
	 * @param	t The Guide Object
	 * @param	type center|left|right
	 * @param	offs Placement Offset
	 */
	public static function XAxis(o:FlxObject, t:FlxObject, type:String = "center", offs:Float = 0):FlxObject
	{
		switch(type){
			case "center":
				o.x = t.x + (t.width - o.width) / 2;	
			case "left":
				o.x = t.x;
			case "right":
				o.x = t.x + t.width - o.width;
			default:
		}
		o.x += offs; return o;
	}//---------------------------------------------------;
	
	/**
	 * Align Verticaly an object to another object
	 * @param	o Object to Align
	 * @param	t The Guide Object
	 * @param	type center|top|bottom
	 * @param	offs Placement Offset
	 */
	public static function YAxis(o:FlxObject, t:FlxObject, type:String = "center", offs:Float = 0):FlxObject
	{
		switch(type){
			case "center":
				o.y = t.y + (t.height - o.height) / 2;
			case "top":
				o.y = t.y;
			case "bottom":
				o.y = t.y + t.height - o.height;
			default:
		}
		o.y += offs; return o;
	}//---------------------------------------------------;
	
	/**
	 * Place an object to the RIGHT of another object
	 * @param	o Object to Align
	 * @param	t Guide Object
	 * @param	offX Offset X
	 * @param	offY Offset Y
	 * @return  Placed Object
	 */
	public static function right(o:FlxObject, t:FlxObject, offX:Float = 0, offY:Float = 0):FlxObject
	{
		o.x = t.x + t.width + offX;
		o.y = t.y + offY;
		return o;
	}//---------------------------------------------------;
	
	/** 
	 * Place an object to the LEFT of another object
	 * @param	o Object to Align
	 * @param	t Guide Object
	 * @param	offX Offset X
	 * @param	offY Offset Y
	 * @return  Placed Object
	 */
	public static function left(o:FlxObject, t:FlxObject, offX:Float = 0, offY:Float = 0):FlxObject
	{
		o.x = t.x - o.width + offX;
		o.y = t.y + offY;
		return o;
	}//---------------------------------------------------;
	
	/**
	 * Place an object on TOP of another object
	 * @param	o Object to Align
	 * @param	t Guide Object
	 * @param	offX Offset X
	 * @param	offY Offset Y
	 * @return  Placed Object
	 */
	public static function up(o:FlxObject, t:FlxObject, offX:Float = 0, offY:Float = 0):FlxObject
	{
		o.x = t.x + offX;
		o.y = t.y - o.height + offY;
		return o;
	}//---------------------------------------------------;
	
	/**
	 * Place an object BELOW another object
	 * @param	o Object to Align
	 * @param	t Guide Object
	 * @param	offX Offset X
	 * @param	offY Offset Y
	 * @return  Placed Object
	 */
	public static function down(o:FlxObject, t:FlxObject, offX:Float = 0, offY:Float = 0):FlxObject
	{
		o.x = t.x + offX;
		o.y = t.y + t.height + offY;
		return o;
	}//---------------------------------------------------;
	
	/**
	 * Places an object below another object and center it in the middle of it
	 */
	public static function downCenter(o:FlxObject, t:FlxObject, offY:Float = 0):FlxObject
	{
		o.x = t.x + ((t.width - o.width) / 2);
		o.y = t.y + t.height + offY;
		return o;
	}//---------------------------------------------------;
	
	
	/**
	 * Align a bunch of elements centered below a target sprite
	 * @param	elements Array of elements to align on the line
	 * @param	source The element to put the line below
	 * @param	padX X padding of line elements
	 * @param	padY Y padding from the source element
	 */
	public static function inLineCenterBelow(elements:Array<FlxSprite>, guide:FlxSprite, offX:Float = 1, offY:Float = 1)
	{
		inLine(guide.x, guide.y + guide.height + offY, guide.width, elements, "center", offX);
	}//---------------------------------------------------;
	
	/**
	 * Align a bunch of objects in a line
	 * @param	x Line start X
	 * @param	y Line start Y
	 * @param	width Width of the Line, 0: Rest of the screen, -1: Center of the screen mirror to X
	 * @param	elements Array of elements to align
	 * @param	align center, left, right, justify
	 * @param   pad if align="center,left,right" use padding between elements in pixels
	 */
	public static function inLine(x:Float, y:Float, width:Float, elements:Array<FlxSprite>, align:String = "center", pad:Float = 0)
	{
		var sx:Float; // start x, when placing
		var tw:Float = 0; // total Width padding included
		
		if (width == 0) width = FlxG.width - x;
		if (width < 0) width = FlxG.width - x * 2;
	
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
	 * Align a bunch of elements vertically 
	 * @param	x Line start X
	 * @param	y Line start Y
	 * @param	height Line Height 0:Rest of the screen, -1:Center of the screen mirror to Y
	 * @param	elements The elements to align
	 * @param	align center,top,bottom,justify
	 * @param   pad if align="center,top,bottom" use padding between elements in pixels
	 */
	public static function inVLine(x:Float, y:Float, height:Float, elements:Array<FlxSprite>, align:String = "center", pad:Float = 0)
	{
		var sy:Float; // start x, when placing
		var th:Float = 0; // total Width padding included
		if (height == 0) height = FlxG.height - y;
		if (height < 0 ) height = FlxG.height - y * 2;
		
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