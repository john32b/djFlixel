/**
	DJFlixel Text Generation Helpers
	===================
	
	- Accessible from (D.text)
	
	- Introducing the struct of "DTextStyle" which describes the 
		style of a text object.
		
	- The most useful function is get()
		
*******************************************/
 
package djFlixel.core;

import djA.DataT;
import flixel.text.FlxText;


/* Text Style Objects are used mainly in .get(..)
 * Provides a quick way to stylize text */
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
	//?x:Float,	// X	-- Why would a style change the position? Removed V0.5
	//?y:Float,	// Y	-- Why would a style change the position? Removed V0.5
	
	?w:Int,		// WIDTH fieldwidth , >0 (wordwrap, no autoexpand) =0 (no wordwrap, autoexpand)
	?a:String	// ALIGNMENT | left,right,center,justify

}// --



class Dtext 
{
	// Table (Int to border style) for quick lookup in {DTextStyle.bt}
	var __borderStyles:Array<FlxTextBorderStyle>;
	
	/** Holds Global Styles
	 * Put things here MANUALLY | styles.set("customID", {style...});
	 * then you can use these in | .text.get("Text","customID"); */
	public var styles:Map<String, DTextStyle>;
	
	// Style to be applied to all new generated text. Set with fix()
	@:noCompletion
	public var _fixStyle(default,null):DTextStyle = null;
	
	// Global use textformats. This is the thing where it uses tags to put multiple styles on FlxText
	// .markupAdd() and .getF()
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
	
	
	
	/** Add a text format to be used in .getF() 
	 * symbols can be tags like <g> or <r> but also symbols like $,@
	 * <tags> are the most compatible?
	 * */
	public function markupAdd(symbol:String, TextColor:Int, ?BorderColor:Int)
	{
		for (t in textFormats) {
			if (t.marker == symbol) {
				trace("Warning: Duplicate Markup Symbol. Ignoring.");
				return;
			}
		}
		var format = new FlxTextFormat(TextColor, false, false, BorderColor);
		textFormats.push(new FlxTextFormatMarkerPair(format, symbol));
	}//---------------------------------------------------;
	
	
	/** Clear all defined text formats 
	 **/
	public function markupClear()
	{
		textFormats = [];
	}//---------------------------------------------------;

	
	
	/**
	   Get a new FlxText with an applied custom style. Multiple style sources can be applied. Meaning you can 
	   use a predefined style by id, and append fields to it with an object.
	   - Text Objects returned are best fitted for SINGLE-LINE use
	   - If you want multiline/wordwrap later just set the FlxText.fieldWidth to >0
	   @param	str Text String
	   @param	o   Overlay Text Style that will always apply last
	   @param	id  Style ID, will only get applied if fixedStyle is null
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
			// DEV: s is now a new copy, so I can override it
			 s = DataT.copyFields(o, s);	
		}
		
		if (s != null){
			applyStyle(T, s);
		}
		return T;
	}//---------------------------------------------------;

	
	/**
	   Get text like .get() but also apply a predefined format
	   that was previously declared with markupAdd(..)
		- This is the kind of text that supports inner tags
		  like "red text <r>here<r> and this is <b>blue<b>"
	**/
	public function getF(str:String, ?X:Float = 0, ?Y:Float = 0, ?o:DTextStyle = null, ?id:String = null):FlxText
	{
		var t = get("", X, Y, o, id);
		t.applyMarkup(str, textFormats);
		return t;
	}//---------------------------------------------------;
	
	
	/**
	   ::EXPERIMENTAL::
	   Fix a TextStyle to be applied to all following get() calls
	   !! VERY IMPORTANT !! To disable this after you are done - call this fn with no params -
	   @param	id a styleID that you have previously set
	   @param	st text style object
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
	
	
	/** 
	  Apply any TextStyle fields that are set 
	  - WARNING, could modify the STYLE and write {s.bt=1}
	 **/
	public function applyStyle(T:FlxText, s:DTextStyle)
	{
		if (s.f != null) T.font = s.f;
		if (s.s != null) T.size = s.s;
		if (s.c != null) T.color = s.c;
		
		//if (s.x != null) T.x = s.x;
		//if (s.y != null) T.y = s.y;
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
	
	
	/** Apply a markup previously declared in markupAdd() in a text object
	 */
	public function applyMarkup(t:FlxText, str:String):FlxText
	{
		return t.applyMarkup(str, textFormats);
	}//---------------------------------------------------;
		
}// --