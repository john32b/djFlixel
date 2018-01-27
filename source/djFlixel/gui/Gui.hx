package djFlixel.gui;


import djFlixel.SimpleVector;
import djFlixel.gfx.GfxTool;
import djFlixel.gui.Styles.TextStyle;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.tweens.misc.VarTween;

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
	
	// -- Once per program execution
	public static function initOnce()
	{
		// Add a basic text style:
		Gui.addTextStyle("default", {
				fontSize:8, 
				color:Styles.DEF_TEXT_COLOR,
				color_border:Styles.DEF_BORDER_COLOR
		});
		
		// Autoplacer init:
		AP = {x:0, y:0, width:FlxG.width, enabled:false, align:"left", pad:0};
		
	}//---------------------------------------------------;
	
	// -- Reset some things every time a state has switched
	public static function stateSwitch()
	{
		// -- TODO ?
	}//---------------------------------------------------;
	
	
	//====================================================;
	// Tween help 
	//====================================================;
	
	// Keep track of object to Tweens
	@:allow(djFlixel.FLS.onStateSwitch)
	static var mapTweens:Map<FlxSprite,VarTween>;

	/**
	 * Add and store tween using the object as a key, if you try to add a new tween with the same object
	 * the old tween will be deleted. Call tween(sprite) to cancel any tweens
	 * @return
	 */
	public static function tween(sprite:FlxSprite, ?Values:Dynamic, Duration:Float = 1, ?Options:TweenOptions)
	{
		var tw = mapTweens.get(sprite);
		if (tw != null) {
			tw.cancel();
			tw.destroy();
		}
		if (Values == null) return;
		mapTweens.set(sprite, FlxTween.tween(sprite, Values, Duration, {
			onComplete:function(_){
				mapTweens.remove(sprite);
			}
		}));
	}//---------------------------------------------------;
	
	//====================================================;
	// Custom Global Text Formatting
	//====================================================;
	
	// --
	// General use GLOBAL formatPairs
	public static var formatPairs:Array<FlxTextFormatMarkerPair>;
	
	/**
	 * Add custom styles, usually once per program.
	 * 
	 * @param	symbol Mark up symbol, like "#" or "$"
	 * @param	color
	 * @param	borderColor
	 * @param	bold
	 */
	public static function addFormatRule(symbol:String, TextColor:FlxColor, ?BorderColor:FlxColor)
	{
		if (formatPairs == null) {
			formatPairs = [];
		}
		
		formatPairs.push(getFormatRule(symbol,TextColor,BorderColor));
	}//---------------------------------------------------;
	
	/**
	 * Quickly create and get an FlxFormatPair object
	 * @param	symbol e.g. "$"
	 * @param	TextColor Text Color
	 * @param	BorderColor Border Color, optional
	 */
	public static function getFormatRule(symbol:String, TextColor:FlxColor, ?BorderColor:FlxColor)
	{
		var format = new FlxTextFormat(TextColor, false, false, BorderColor);
		return new FlxTextFormatMarkerPair(format, symbol);
	}//---------------------------------------------------;
	
	//====================================================;
	// Text Styles and Text Objects
	//====================================================;
	
	// --
	public static var textStyles(default, null):Map<String,TextStyle>;
	
	/**
	 * Add a textStyle for use in the Gui quick text functions
	 * @param	id Set a Unique ID for the textstyle, e.g. "h1"
	 * @param	style A textstyle
	 */
	public static function addTextStyle(id:String, style:TextStyle)
	{
		if (textStyles == null) textStyles = new Map();
		textStyles.set(id, style);
	}//---------------------------------------------------;
	
	
	/**
	 * Get formatted text, add formats with addFormatRule();
	 * @param	txt  Markup : [$ , #]
	 * @param	textCol Text Color -1 for default color
	 * @param	borderCol Needs the color to be in 0xAARRGGBB format, -1 for no border
	 * @param	X if AutoPlacer this will behave like an offset
	 * @param	Y if AutoPlacer this will behave like an offset
	 * @return
	 */
	public static function getFText(text:String, size:Int = 8, textCol:Int = -1, borderCol:Int = -1, X:Float = 0, Y:Float = 0):FlxText
	{
		var t = new FlxText(X, Y, 0, text, size);
			t.scrollFactor.set(0, 0);
		if (textCol !=-1) t.color = textCol; else t.color = Styles.DEF_TEXT_COLOR;
		if (borderCol !=-1) Styles.applyTextBorder(t, borderCol);
			t.applyMarkup(text, formatPairs);
		if (AP.enabled) place(t, X, Y);
		return t;
	}//---------------------------------------------------;
	
	
	/**
	 * Get a quick text object with color and border color. NO TEXT MARKUP!!
	 * @param	text
	 * @param	size Text size
	 * @param	textCol Text Color -1 for default color
	 * @param	borderCol Needs the color to be in 0xAARRGGBB format, -1 for no border
	 * @param	X if AutoPlacer this will behave like an offset
	 * @param	Y if AutoPlacer this will behave like an offset
	 * @return
	 */
	public static function getQText(text:String, size:Int = 8, textCol:Int = -1, borderCol:Int = -1, X:Float = 0, Y:Float = 0, WIDTH:Float = 0):FlxText
	{
		var t = new FlxText(X, Y, WIDTH, text, size);
			t.scrollFactor.set(0, 0);
		if (textCol !=-1) t.color = textCol; else t.color = Styles.DEF_TEXT_COLOR;
		if (borderCol !=-1) Styles.applyTextBorder(t, borderCol);
		if (AP.enabled) place(t, X, Y);
		return t;
	}//---------------------------------------------------;
	
	
	
	/**
	 * Get a quick text object styled with a predefined text style
	 * @param	text 
	 * @param	style A style you have added before with addTextStyle(..)
	 * @param	X if AutoPlacer this will behave like an offset
	 * @param	Y if AutoPlacer this will behave like an offset
	 * @return
	 */
	public static function getSText(text:String, style:String = "default", X:Float = 0, Y:Float = 0):FlxText
	{
		var t = new FlxText(X, Y, 0, text);
			t.scrollFactor.set(0, 0);
		Styles.applyTextStyle(t, textStyles.get(style));
		if (AP.enabled) place(t, X, Y);
		return t;
	}//---------------------------------------------------;
	
	
	//====================================================;
	
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
	public static function getFButton(  _str:String, color:Int, borderCol:Int =-1,
										callback:Void->Void, X:Int = 0, Y:Int = 0):FlxButton
	{
		var t = new FlxButton(X, Y, null, callback);
		var text = getFText(_str, 8, color, borderCol);
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
	@:deprecated("Use Autoplacer")
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
	@:deprecated("Use Autoplacer")
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
	// AUTO PLACER
	//====================================================;
	// - Utility to quickly align text and items
	// - If you enable autoplacer, text Getters will use it (getQText,getSText,getFText)
	// - Item placers will use the default autoplacer method, unless overriden
	
	// Autoplacer parameters
	static var AP:{
		x:Float, y:Float, width:Float, enabled:Bool, align:String, pad:Float
	};
	// Last object placed with autoplacer.
	static var APlast:FlxObject;
	

	/**
	 * Enable the autoplacer for the textGetters and .place() function
	 * @param	x
	 * @param	y
	 * @param	width 0 to use remaining width, -1 to use the mirror distance
	 * @param	align center, left, right, grid
	 * @param	pad
	 */
	public static function autoplace(x:Float = 0, y:Float = 0, width:Float = 0, align:String = "left", padding:Float = 2)
	{
		if (width == 0) width = FlxG.width;
		if (width < 0) width = FlxG.width - (x * 2);
		AP.enabled = true;
		AP.x = x;  AP.y = y;
		AP.width = width;
		AP.align = align;
		AP.pad = padding;
		APlast = null;
	}//---------------------------------------------------;
	// --
	public static function autoplaceOff()
	{
		AP.enabled = false;
	}//---------------------------------------------------;
	
	/**
	 * 
	 * @param	obj The object to place
	 * @param	align Override global alignment,
	 * 		up	 : On top of the previous
	 * 		next : place the item next to the previous one
	 * 		grid : place the item next to the previous one, auto new line if width overflows (default)
	 * 		prev : place the item left of the previous one
	 * 		down : place exaclty below the previous one.
	 * 		downC : Down and Center of the previous
	 * 		left : New Line, aligns at the left of the autoplace line
	 * 		right : New Line, aligns at the right of the autoplace line
	 * 		center : New Line, aligns at the center of the autoplace line
	 */
	public static function place(obj:FlxSprite, ?align:String, offX:Float = 0, offY:Float = 0):FlxSprite
	{
		if (align == null) align = AP.align;
		
		// Offset is not padding but it's safe for most operations
		// Only "left","up" operations needs adjustment
		
		if (APlast == null)
		{
			// Cases where the object needs to be aligned despite being the first
			if (align == "center" || align == "right") {
				Align.inLine(AP.x, AP.y, AP.width, [obj], align);
			}else{
				obj.setPosition(AP.x + offX, AP.y + offY);
			}
			APlast = obj;
			return obj;
		}
		
		switch(align)
		{
			case "up":
				Align.up(obj, APlast, offX, offY - AP.pad);
			case "next":
				Align.right(obj, APlast, offX + AP.pad, offY);
			case "grid": // same as next, but checks for overflow
				Align.right(obj, APlast, offX + AP.pad, offY);
				if (obj.x + obj.width > AP.x + AP.width) {
					obj.x = AP.x;
					obj.y = APlast.y + APlast.height + AP.pad;
				}
			case "prev":
				Align.left(obj, APlast, offX - AP.pad, offY);
			case "down":
				Align.down(obj, APlast, offX, offY + AP.pad);
			case "downC":
				Align.downCenter(obj, APlast, offY + AP.pad);
				
			default:
				// It has got to be either [left, right, center]
				// Move the object below the last one, it's for all 3 cases
				obj.y = APlast.y + APlast.height + AP.pad + offY;
				
				switch(align){
				case "left":
					obj.x = AP.x + offX;
				case "right":
					obj.x = AP.x + AP.width - obj.width + offX;
				case "center":
					obj.x = AP.x + offX + (AP.width - obj.width) / 2;
				default:
					trace("Error: Invalid alignment type, typo?");
				}
		}// -
		APlast = obj;
		return obj;
	}//---------------------------------------------------;
	
	//====================================================;
	// #ICONS
	//====================================================;
	// DjFlixel comes with a standard icon library with 
	// some common graphics (e.g. minus sign, plus sign, home, etc)
	// - To include the icon asset to your project, you MUST set a parameter in the 
	// - `Project.xml` file. Just add the following line before including the djFlixel Lib :
	// 		- <set name="DJFLX_ICONS_8"/>  includes the 8x8 pixel icons, or
	// 		- <set name="DJFLX_ICONS_12"/>  includes the 12x12 pixel icons
	// 		- and so on, for 16 and 24 pixels.
	// - Once the icon assets are declared ok, you are ready to use the icon functions
	
	// FEATURES :
	// + Customizable border color
	// + Pooling with unique IDs
	// + Available sizes: (8,12,16,24) squared pixels
	
	
	// The names of the icons as the are on the assets.
	// All icon sizes must support these.
	static var ICON_INDEX:Array<String> = [
		"ar_left", "ar_right", "ar_up", "ar_down",
		"ch_off", "ch_on", "dot", "cross",
		"reset", "left", "right", "exit",
		"params", "o", "x", "v", "X",
		"home", "options", "heart",
		"star", "minus", "plus"
		];
		
	
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
		
		frame = ICON_INDEX.indexOf(type);

		#if debug
			if (frame < 0){
				trace('ERROR: Could not get icon [$type], typo?');
				frame = 14; // X
			}
		#end
		
		if (set != null)
		return GfxTool.getBitmapPortion(set, frame * size, 0, size, size);
		
		#if debug 
		try {
		#end
		return GfxTool.getBitmapPortion(getIconAsset(size), frame * size, 0, size, size);
		#if debug 
		} catch (e:Dynamic) {
		throw "Error: You must declare the icons to use in the Project.xml file ; <set name=\"DJFLX_ICONS_" + size +"\"/>"; } 
		#end
		
	}//---------------------------------------------------;
	
	/**
	 * Get the asset file of the standard icons with a set size
	 * @param	size
	 * @return
	 */
	public inline static function getIconAsset(size:Int = 16):String
	{
		return "assets/" + DEF_ICONS_PREFIX + size + ".png";
	}//---------------------------------------------------;
	
	/**
	 * Get a library icon with a border color applied to it.
	 * Also caches the result so next time the call will be faster.
	 * @param	type ch_on, ch_off , ar_left, ar_right, ar_up, ar_down, dot, plus
	 * @param	size Available sizes from default lib [8,12,16,24]
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
	
	#if (debug)
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
	public static inline function d_box(x:Float, y:Float, width:Float, h:Float) { }
	#end
	
	
}// --