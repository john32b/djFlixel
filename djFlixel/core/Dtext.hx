/**
 == Text generation Helpers
 ------------------------------------ */
 
package djFlixel.core;

import djA.DataT;
import flixel.text.FlxText;


typedef DTextStyle = {
	?f:String,	// FONT
	?s:Int,		// SIZE
	?c:Int,		// COLOR
	// --
	?bc:Int,	// BORDER COLOR. | TIP, if you just set the color, the BorderType will auto set to (1)
	?bt:Int,	// BORDER TYPE | (0-3) [0:NONE. 1:SHADOW, 2:OUTLINE, 3:OUTLINE_FAST] | Default is 1 if bc is set
	?bs:Int,	// BORDER SIZE | Default is 1. For shadow style just use (so) shadow offset
	?so:Array<Int>,	// SHADOW OFFSET | Default is (1,1) is multiplied by bordersize. e.g. [1,0] or [0,1]
	
	
	// --
	?x:Float,	// X
	?y:Float,	// Y
	?w:Int,		// WIDTH fieldwidth
	?a:String	// ALIGNMENT | left,right,center,justify

}// --



class Dtext 
{
	// Table (Int to border style) for quick lookup
	var __borderStyles:Array<FlxTextBorderStyle>;
	
	/** Store custom textstyles for quick reference by id anywhere.
	 *  -- Manually add the styles here -- */
	public var styles:Map<String,DTextStyle>;
	
	// Style to be applied to all new generated text
	@:noCompletion
	public var _fixStyle(default,null):DTextStyle = null;
	
	// Global use textformats
	var textFormats:Array<FlxTextFormatMarkerPair>;
	
	public function new() 
	{
		__borderStyles = [
			FlxTextBorderStyle.NONE,
			FlxTextBorderStyle.SHADOW,
			FlxTextBorderStyle.OUTLINE,
			FlxTextBorderStyle.OUTLINE_FAST
		];
		
		styles = [];
		
		textFormats = [];
	}//---------------------------------------------------;
	
	
	/** Clear all defined text formats */
	public function formatClear()
	{
		textFormats = [];
	}//---------------------------------------------------;
	
	/** Add a text format to be used in .getF() 
	 * symbols can be tags like <g> or <r> but also symbols like $,@
	 * <tags> are the most compatible?
	 * */
	public function formatAdd(symbol:String, TextColor:Int, ?BorderColor:Int)
	{
		var format = new FlxTextFormat(TextColor, false, false, BorderColor);
		textFormats.push(new FlxTextFormatMarkerPair(format, symbol));
	}//---------------------------------------------------;
	
	
	/**
	   Get a new FlxText with an applied custom style. Multiply style sources can be applied. Meaning you can 
	   use a predefined style by id, and append fields to it with an object.
	   @param	str Text String
	   @param	o Check `dui.hx` for the DTextStyle definition. Will always apply last
	   @param	id Style ID, will only get applied when fixedStyle is null
	**/
	public function get(str:String, ?X:Float = 0, ?Y:Float = 0, ?o:DTextStyle = null, ?id:String = null):FlxText
	{
		var T = new FlxText(X, Y, 0, str);
		
		//T.textField.antiAliasType = cast 0;
		//T.textField.sharpness = 400;
		
		var s:DTextStyle = null;	// Style to apply
		
		if (_fixStyle != null) {
			s = Reflect.copy(_fixStyle);
		}else{
			if (id != null) {
				s = Reflect.copy(styles.get(id));
			}
		}
		if (o != null) {
			s = DataT.copyFields(o, s);
		}
		
		if (s != null){
			applyStyle(T, s);
		}
		return T;
	}//---------------------------------------------------;

	
	/**
	   Use a predefined format (declared with formatAdd).
	   e.g. "red text <r>here<r> and this is <b>blue<b>"
	**/
	public function getF(str:String, ?X:Float = 0, ?Y:Float = 0, ?o:DTextStyle = null, ?id:String = null):FlxText
	{
		var t = get("", X, Y, o, id);
		t.applyMarkup(str, textFormats);
		return t;
	}//---------------------------------------------------;
	
	
	/**
	   Fix a TextStyle to be applied to all following GenText calls
	   !! VERY IMPORTANT !! To disable this after you are done call it again with no params
	   You can either fix from ID or a new TextStyle 
	   Call with no params to clear.
	   @param	id a styleID that you have previously set
	**/
	public function fix(?id:String, ?st:DTextStyle)
	{
		if (id == null) {
			_fixStyle = st;
		}else {
			_fixStyle = styles.get(id);
		}
		
		// note: if both are null, then then _fixstyle will be set to null
	}//---------------------------------------------------;

	
	public function applyMarkup(t:FlxText, str:String):FlxText
	{
		return t.applyMarkup(str, textFormats);
	}//---------------------------------------------------;
	
	
	/** 
	  Apply any TextStyle fields that are set 
	  - WARNING, could modify the STYLE and write {s.bt=1}
	 **/
	public function applyStyle(T:FlxText, s:DTextStyle)
	{
		if (s.f != null) T.font = s.f;
		if (s.s != null) T.size = s.s;
		if (s.c != null) T.color = s.c;
		
		if (s.x != null) T.x = s.x;
		if (s.y != null) T.y = s.y;
		if (s.w != null) T.fieldWidth = s.w;
		if (s.a != null) T.alignment = s.a;
		
		if (s.bc != null) {
			T.borderColor = s.bc;
			if (s.bt == null) s.bt = 1;	// Default [SHADOW]
		}
		
		if (s.bt != null) T.borderStyle = __borderStyles[s.bt];
		if (s.bs != null) T.borderSize = s.bs;
		
		if (s.so != null){
			T.shadowOffset.set(s.so[0], s.so[1]);
		}
	}//---------------------------------------------------;
	
	
		
}// --