package djFlixel.gui;


import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;

/**
 * Static class
 * Quick item generators and tools
 * ...
 */
class Gui
{
	static inline var DEFAULT_TEXT_COLOR:Int   = 0xFFFFFFFF;
	static inline var DEFAULT_BORDER_COLOR:Int = 0xFF111111;
	
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
	public static function addFormatRule(symbol:String, color:Int, borderColor:Int, bold:Bool = false)
	{
		if (formatPairs == null) {
			formatPairs = [];
		}
		trace('- New textFormatRule | symbol:$symbol');
		var format = new FlxTextFormat(color, bold, false, borderColor);
		var pair = new FlxTextFormatMarkerPair(format, symbol);
		formatPairs.push(pair);
	}//---------------------------------------------------;
	
	/**
	 * 
	 * @param	txt  Markup : [$ , #]
	 * @param   color  The default color for non-styled 
	 * @param	X optional
	 * @param	Y optional
	 * @return
	 */
	public static function getFText( text:String, size:Int = 8, color:Int = DEFAULT_TEXT_COLOR, 
									 useBorder:Bool = true, X:Int = 0, Y:Int = 0):FlxText
	{
		var t = new FlxText(X, Y, 0, "", size);
		t.scrollFactor.set(0, 0);
		t.color = color;
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
	
	
}