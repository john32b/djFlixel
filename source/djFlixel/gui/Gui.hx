package djFlixel.gui;


import djFlixel.SimpleVector;
import djFlixel.gfx.GfxTool;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
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
		if (useBorder) Styles.applyTextBorder(t, t.borderColor);
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
		if (borderC !=-1) Styles.applyTextBorder(t, t.borderColor);
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
	 * @param	next bool, if true it will place it next to the previous one, false to place it below the previous one
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
	
	// DjFlixel Default icons name prefix.
	public inline static var DEF_ICONS_PREFIX = "icons_";
	
	/**
	 * Returns a new bitmap with an icon from the GUI icon lib
	 * Use getIcon(..) for caching and shadow effects
	 * @param	type ch_on, ch_off, ar_left, ar_right, ar_up, ar_down, dot, plus
	 * @param	size Available Sizes = [8,12,16]
	 * @param	set Declare an external LIB ICON set to get the icon from there.
	 * @return Note Bitmap returned is of size 16x16
	 */
	static function getIconBasic(type:String, size:Int, ?set:String):BitmapData
	{
		var frame:Int;
		
		/** Order of Icons in the DjFlixel Icon Sets :
		 *	[left,right,up,down,checkbox_off,checkbox_on,dot,plus]
		 * 
		 * Make sure you embed the icon files on the "Project.xml" 
		 * 	with <set name="DJFLX_ICONS_XX"/>  XX=8,12,16,24
		 *  note: before loading the djFlixel lib
		 */
		
		// Arrows and other icons are singles
		// DEV: make a lookup table??
		frame = switch(type)
		{
			case "ar_left":0;
			case "ar_right":1;
			case "ar_up":2;
			case "ar_down":3;
			case "ch_off":4;
			case "ch_on":5;
			case "dot":6;
			case "plus":7;
			default:trace("ERROR: icon not defined"); 7;
		};		
		
		if (set != null)
		return GfxTool.getBitmapPortion(set, frame * size, 0, size, size);
		
		#if debug try{ #end
		
		var iconFile = "assets/" + DEF_ICONS_PREFIX + size + ".png";
		return GfxTool.getBitmapPortion(iconFile, frame * size, 0, size, size);
		
		#if debug }catch (e:Dynamic){
		throw "Error: You must delcare the icons to use in the Project.xml file ; <set name=\"DJFLX_ICONS_" + size +"\"/>";
		} #end
		
	}//---------------------------------------------------;
	
	/**
	 * Get a library icon with a border color applied to it.
	 * Also caches the result so next time the call will be faster.
	 * @param	type ch_on, ch_off , ar_left, ar_right, ar_up, ar_down, dot, plus
	 * @param	size 0-small 1-medium 2-big, (8 pixels to 16pixels)
	 * @param	set Declare an external LIB ICON set to get the icon from there
	 * @param	shadowCol If set, will apply this shadow color
	 * @param	offX Shadow offset X
	 * @param	offY Shadow offset Y
	 * @return
	 */
	public static function getIcon(type:String, size:Int, ?set:String, ?shadowCol:FlxColor, offX:Int = 2, offY:Int = 1):BitmapData
	{
		if (icons == null) icons = new Map();
		var uid = '$type$size$shadowCol$offX$offY';
		if (set != null) {
			uid += set.split("/").pop(); // Just put the filename there
		}
		var b:BitmapData;
		if (icons.exists(uid)) {
			b = icons.get(uid);
		}else{
			b = getIconBasic(type, size, set);
			if (shadowCol != null) b = GfxTool.applyShadow(b, shadowCol, offX, offY);
			icons.set(uid, b);
		}
		return b.clone(); 
		// Important to return a clone, because if it's a pointer it could be destroyed when a sprite is destroyed
	}//---------------------------------------------------;
	
	// -- 
	// Get an Approximate icon size to a number e.g. font size
	public static function getApproxIconSize(s:Int)
	{
		if (s <= 13) return 8;
		if (s <= 18) return 12;
		if (s <= 26) return 16;
		return 24;
	}//---------------------------------------------------;
	
	/**
	 * Mainly clears the icon cache
	 */
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
	public static var d_color:Int = 0x77FF4433;
	
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
			f.makeGraphic(Std.int(w), Std.int(h), d_color);
			f.scrollFactor.set(0, 0);
		FlxG.state.add(f);
	}//---------------------------------------------------;
	
	#else
	public static inline function d_lineX(x:Float, y:Float, width:Float) { }
	public static inline function d_box(x:Float, y:Float, width:Float) { }
	#end
	
	
}// --