package djFlixel.gui;


import djFlixel.SimpleVector;
import djFlixel.gfx.GfxTool;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.FlxPointer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

/**
 * Static class
 * Quick item generators and tools
 * ...
 * 
 * 	Notes: 	Be sure to add text formal rules with addFormatRule(), 
 * 			before calling getFText() ot getFButton
 */
class Gui
{

	public inline static var DEF_GUI_ICONS:String = "assets/hud_icons.png";
	
	//====================================================;
	// Custom Global Text Formatting
	//====================================================;
	
	// --
	public static var formatPairs(default, null):Array<FlxTextFormatMarkerPair>;
	
	/**
	 * Add custom styles, usually once per program.
	 * 
	 * @param	symbol Mark up symbol, like "#" or "$"
	 * @param	color
	 * @param	borderColor
	 * @param	bold
	 */
	public static function addFormatRule(symbol:String, textC:Int, borderC:Int, bold:Bool = false)
	{
		if (formatPairs == null) {
			formatPairs = [];
		}
		trace('- New textFormatRule | symbol:$symbol');
		var format = new FlxTextFormat(textC, bold, false, borderC);
		var pair = new FlxTextFormatMarkerPair(format, symbol);
		formatPairs.push(pair);
	}//---------------------------------------------------;
	
	/**
	 * Get formatted text, add formats with addFormatRule();
	 * @param	txt  Markup : [$ , #]
	 * @param   color  The default color for non-styled 
	 * @param	X optional
	 * @param	Y optional
	 * @return
	 */
	public static function getFText(text:String, size:Int = 8, textC:Int = -1, useBorder:Bool = false, X:Float = 0, Y:Float = 0):FlxText
	{
		var t = new FlxText(X, Y, 0, "", size);
		t.scrollFactor.set(0, 0);
		if (textC !=-1) t.color = textC; else t.color = Styles.DEF_TEXT_COLOR;
		if (useBorder) Styles.quickTextBorder(t, t.borderColor);
		t.applyMarkup(text, formatPairs);
		return t;
	}//---------------------------------------------------;
	
	/**
	 * Get a quick text object with color and border color. NO TEXT MARKUP!!
	 * @param	text
	 * @param	size
	 * @param	color
	 * @param	border Needs the color to be in 0xAARRGGBB format
	 * @param	X
	 * @param	Y
	 * @return
	 */
	public static function getQText(text:String, size:Int = 8, textC:Int = -1, borderC:Int = -1, X:Float = 0, Y:Float = 0):FlxText
	{
		var t = new FlxText(X, Y, 0, text, size);
		t.scrollFactor.set(0, 0);
		if (textC !=-1) t.color = textC; else t.color = Styles.DEF_TEXT_COLOR;
		if (borderC !=-1) Styles.quickTextBorder(t, t.borderColor);
		return t;
	}//---------------------------------------------------;
	
	/**
	 * Quickly get a text button that can be clicked to a void callback
	 * 
	 * @param	txt 
	 * @param	color
	 * @param	useBorder
	 * @param	callback
	 * @param	X
	 * @param	Y
	 * @return
	 */
	public static function getFButton(  _str:String, color:Int, useBorder:Bool = true, 
										callback:Void->Void, X:Int = 0, Y:Int = 0):FlxButton
	{
		var t = new FlxButton(X, Y, null, callback);
		var text = getFText(_str, 8, color, useBorder);
		t.makeGraphic(Std.int(text.width), Std.int(text.height), 0x00000000);
		t.scrollFactor.set(0, 0);
		t.label = text;
		return t;
	}//---------------------------------------------------;
	
	
	// --
	// WARNING: Will add to the current active state! Be careful with substates.
	public static function addAndTween(obj:FlxSprite, startX:Int = 0, startY:Int = 0, noAdd:Bool = false):FlxSprite
	{
		var endX = obj.x;
		var endY = obj.y;
		obj.alpha = 0;
		obj.setPosition(endX + startX, endY + startY);
		if (!noAdd) FlxG.state.add(obj);
		FlxTween.tween(obj, { x:endX, y:endY, alpha:1 }, 0.2, { ease:FlxEase.quadOut } );
		return obj;
	}//---------------------------------------------------;
	
	
	
	// NEW for 3.0
	//====================================================;
	// QUICK PANEL
	// useful for quickly putting and aligning text
	//====================================================;
	
	// Quick Box Start
	static var qBoxS:SimpleVector;
	// Quick Box Last
	static var qBoxL:SimpleVector;
	
	/**
	 * Set the quick area to put qText on
	 */
	public static function qBox(X:Float, Y:Float)
	{
		qBoxS = new SimpleVector(X, Y);
		qBoxL = new SimpleVector(X, Y);
	}//---------------------------------------------------;
	
	/**
	 * Puts text on the current state, automatically aligns it to the previous text put with qText
	 * @param	text String of text
	 * @param	next bool, if true it will place it next to the previous one
	 */
	public static function qText(txt:String="", next:Bool = false):FlxText
	{
		var t:FlxText = getQText(txt, 8, -1, -1);
		// Info: All text should have the same height
		if (next) {
			t.setPosition(qBoxL.x, qBoxL.y);
		}else {
			t.setPosition(qBoxS.x, qBoxL.y + t.textField.height);
		}
		qBoxL.x = t.x + t.fieldWidth;
		qBoxL.y = t.y; 
		return cast(FlxG.state.add(t));
	}//---------------------------------------------------;
	
	//====================================================;
	// ICONS
	//====================================================;
	// Provide some dynamic icon generation
	// + Customizable border color
	// + Customizable size on some
	// + Pooling with unique IDs
	
	// - Store the generated icons
	static var icons:Map<String,BitmapData>;
	
	/**
	 * Returns a new bitmap with an icon from the default gui lib
	 * @param	type check, ar_left, ar_right, ar_top, ar_bottom, dot, plus
	 * @param	size 0-small 1-medium 2-big, (8 pixels to 16pixels)
	 * @return Note Bitmap returned is of size 16x16
	 */
	static function getLibIcon(type:String, size:Int = 0):BitmapData
	{
		var frame:Int;
		
		// Checkbox is the only icon that will return a strip of 2 consecutive frames, open/close
		if (type == "check")
		{
			if (size == 0) frame = 12; else
			if (size == 1) frame = 14; else frame = 16;
			return GfxTool.getBitmapPortion(DEF_GUI_ICONS, frame * 16, 0, 32, 16);
		}
		
		// Arrows and other icons are singles
		frame = switch(type)
		{
			case "ar_left": 
				if (size == 0) 0; else
				if (size == 1) 2; else 4;
			case "ar_right":
				if (size == 0) 1; else
				if (size == 1) 3; else 5;
			case "ar_up":
				if (size == 0) 6; else
				if (size == 1) 8; else 10;
			case "ar_down":
				if (size == 0) 7; else
				if (size == 1) 9; else 11;
			case "dot":  18;
			case "plus": 19;
			default: 19;
		};		
		
		return GfxTool.getBitmapPortion(DEF_GUI_ICONS, frame * 16, 0, 16, 16);
	}//---------------------------------------------------;
	
	/**
	 * Get a library icon with a border color applied to it
	 * @param	type check , ar_left, ar_right, ar_top, ar_bottom, dot, plus
	 * @param	size 0-small 1-medium 2-big, (8 pixels to 16pixels)
	 * @param	shadowCol If set, will apply this shadow color at a default 1 pixel offset at bottom right
	 * @param	offX Shadow offset X
	 * @param	offY Shadow offset Y
	 * @return
	 */
	public static function getIcon(type:String, size:Int = 0, ?shadowCol:FlxColor, offX:Int = 2, offY:Int = 1):BitmapData
	{
		if (icons == null) icons = new Map();
		var uid = 'type$size$shadowCol$offX$offY';
		var b:BitmapData;
		if (icons.exists(uid)) {
			b = icons.get(uid);
		}else{
			b = getLibIcon(type, size);
			if (shadowCol != null) b = GfxTool.applyShadow(b, shadowCol, offX, offY);
			icons.set(uid, b);
		}
		return b.clone(); 
		// Important to return a clone, because if it's a pointer it could be destroyed when a sprite is destroyed
	}//---------------------------------------------------;
	
	
	// --
	public static function destroy()
	{
		for (i in icons){
			i.dispose();
		}
		icons = null;
	}//---------------------------------------------------;
		
	
	//====================================================;
	// Debugging
	//====================================================;
	// Color for some debug shapes
	public static var d_color:Int = 0xFFFF9933;
	
	#if debug
	/**
	 * Draw a quick line on the camera
	 */
	inline public static function d_lineX(x:Float, y:Float, width:Int)
	{
		d_box(x, y, width, 2);
	}//---------------------------------------------------;
	
	
	public static function d_box(x:Float, y:Float, w:Float, h:Float)
	{
		var f = new FlxSprite(x, y);
			f.makeGraphic(Std.int(w),Std.int(h), d_color);
			f.scrollFactor.set(0, 0);
		FlxG.state.add(f);
	}//---------------------------------------------------;
	
	#else
	public static inline function d_lineX(x:Float, y:Float, width:Float) { }
	public static inline function d_box(x:Float, y:Float, width:Float) { }
	#end
	
	
}// --