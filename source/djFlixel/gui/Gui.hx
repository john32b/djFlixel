package djFlixel.gui;


import djFlixel.SimpleVector;
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
	public static var DEFAULT_TEXT_COLOR:FlxColor   = 0xFFEEEEEE;
	public static var DEFAULT_BORDER_COLOR:FlxColor = 0xFF111111;
	
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
		if (textC !=-1) t.color = textC; else t.color = DEFAULT_TEXT_COLOR;
		if(useBorder) {
			t.borderStyle = FlxTextBorderStyle.SHADOW;
			t.borderSize = Math.ceil(size / 8);
			t.borderColor = DEFAULT_BORDER_COLOR;
			t.borderQuality = 1;
		}
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
		if (textC !=-1) t.color = textC; else t.color = DEFAULT_TEXT_COLOR;
		if (borderC !=-1) {
			t.borderStyle = FlxTextBorderStyle.SHADOW;
			t.borderSize = Math.ceil(size / 8);
			t.borderColor = borderC;
			t.borderQuality = 1;
		}
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
	
}// --