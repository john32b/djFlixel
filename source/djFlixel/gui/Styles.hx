package djFlixel.gui;

import djFlixel.gfx.Palette_DB32;
import flixel.text.FlxText;
import flixel.util.FlxColor;


/**
 * Styling functions for FlxTexts and FlxMenu MenuOptions
 * -------------------------------------------------------
 */


//====================================================;
// Parameters for a <VListBase>
//====================================================;

	typedef VBaseStyle = {
		// Time it takes to scroll the elements in and out of the list.
		var element_scroll_time:Float;
		
		// Use a tween to scroll elements or make them appear instantly
		var instantScroll:Bool;
		
		// Padding between elements in pixels.
		var element_padding:Int;

		// ==----------------------------------==
		// -- Animation for onScreen,offScreen --
		
		// How much time between elements to activate an on/off tween
		// -1: auto calculate
		//  0: everything at the same time
		//  x: another time between elements
		var anim_time_between_elements:Float;
		// Total time to animate all the slots ignoring time_between_elements
		//   e.g. if there are 10 elements, and this is 1 seconds,
		//		  tween time would be 1 / 10 = 0.1seconds for each element
		var anim_total_time:Float;
		
		// When animating onScreen(), start from this offset,
		// - in relation to an element's starting position
		var anim_start_x:Int;
		var anim_start_y:Int;
		
		// When animating offScreen(), go to this offset
		var anim_end_x:Int;
		var anim_end_y:Int;
		
		// Page in and out transition type:
		// "sequential", "parallel", "none"
		// sequential, parallel BUG when hiding cursor
		var anim_style:String;
		
		// Easy type of the elements:
		// "bounce", "elastic", "linear", "back", "circ"
		var anim_tween_ease:String;
		
	}// :: -- ::
	 

//====================================================;
//  Parameters for a <VListMenu>.
//====================================================;

	typedef VListStyle = {	 
		 // Start scrolling the view before reaching the edges by this much.
		 var scrollPad:Int;
		 // How many pixels to the right to animate the highlighted element
		 var focus_nudge:Int;
		 // Apply a custom cursor offset [x,y]
		 var cursor_offset:Array<Int>;
		 // If set then the cursor will be a sprite with this image asset.
		 var cursor_image:String;
		 // Loop at edges
		 var loop_edge:Bool;
	 }// :: -- ::
 
	 
	 
//====================================================;
// Parameters for a <FlxText> that goes inside Lists
//====================================================;
 
	typedef OptionStyle = {		
		var font:String; 		// Custom embedded font, null for flixel default
		var size:Int;     		// Font Size
		var alignment:String;	// left | center | right | justify
		var color_default:Int;
		var color_focused:Int;
		var color_accent:Int;		// Special Accent color, used in labels and icons
		var color_disabled:Int;		// Color for all disabled elements, (excluding labels)
		var color_disabled_f:Int;	// Focused color of disabled element
		@:optional var borderColor:Int;	// If set, then it will apply a border of this color
	}// :: -- ::
	 
	
	
//====================================================;
// Parameters for a <FlxText>
//====================================================;

	typedef TextStyle = {
		// Custom embedded font, null for flixel default
		var size:Int;
		var color:Int;
		@:optional var font:String;
		@:optional var borderColor:Int;
	}// :: -- ::

	
//====================================================;
// Styling helpers for gui.lists and flxTexts
//====================================================;

class Styles
{

	// --
	public inline static var DEF_TEXT_COLOR:FlxColor   = 0xFFEEEEEE;
	public inline static var DEF_BORDER_COLOR:FlxColor = 0xFF111111;
	
	// -- Default FlxMenu styles::
	
	public static var default_ListStyle(default, never):VListStyle = {
		focus_nudge : 5,
		scrollPad : 1,
		cursor_offset : null,
		cursor_image : null,
		loop_edge : false
	}; // --
		
	public static var default_BaseStyle(default, never):VBaseStyle = {
		element_scroll_time:0.18,
		instantScroll:false,
		element_padding:2,
		anim_time_between_elements:0,
		anim_total_time: 0.4,
		anim_start_x:0,
		anim_start_y:-12,
		anim_end_x:16,
		anim_end_y:2,
		anim_tween_ease:"linear",
		anim_style:"none"
	}; // --
	
	public static var default_OptionStyle(default, never):OptionStyle = {
		font:null,
		size:8,
		alignment:"left",
		color_default:Palette_DB32.COL_21,
		color_focused:Palette_DB32.COL_09,
		color_accent:Palette_DB32.COL_06,
		color_disabled:Palette_DB32.COL_26,
		color_disabled_f:Palette_DB32.COL_24,
		borderColor:Palette_DB32.COL_02
	}; // --
	
	
	//====================================================;
	// FUNCTIONS
	//====================================================;

	
	// NEW STYLES
	// ----------
	// If you want to quickly create a newstyle based on the default,
	// use these functions.
	
	// --
	public static function newStyle_Base(?styleNode:Dynamic):VBaseStyle
	{
		return applyStyleNodeTo(styleNode, Reflect.copy(default_BaseStyle));
	}//---------------------------------------------------;
	// --
	public static function newStyle_Option(?styleNode:Dynamic):OptionStyle
	{
		return applyStyleNodeTo(styleNode, Reflect.copy(default_OptionStyle));
	}//---------------------------------------------------;
	// --
	public static function newStyle_List(?styleNode:Dynamic):VListStyle
	{
		return applyStyleNodeTo(styleNode, Reflect.copy(default_ListStyle));
	}//---------------------------------------------------;
	
	/**
	 * Applies a Dynamic Object with styles to a style target
	 * It will convert colors from "0xffffff" or "blue" to proper INT
	 * @param	node The object with the styles.
	 * @param	target Must exist
	 */
	public static function applyStyleNodeTo(node:Dynamic, target:Dynamic):Dynamic
	{
		if (node != null)
		for (i in Reflect.fields(node)) {
			// Convert COLOR string to INT
			if (Std.is(i, String) && i.indexOf("color_") == 0) {
				Reflect.setField(target, i, FlxColor.fromString(Reflect.field(node, i)));
				continue;
			}
	
			// Just copy everything else.
			Reflect.setField(target, i, Reflect.field(node, i));
		}
		
		return target;
	}//---------------------------------------------------;
	
	
	/**
	 * Quickly apply border to an FlxText object
	 */
	public static function quickTextBorder(t:FlxText, c:Int = DEF_BORDER_COLOR):FlxText
	{
		t.borderStyle = FlxTextBorderStyle.SHADOW;
		t.borderSize = Math.ceil(t.size / 8);
		t.borderColor = c;
		t.borderQuality = 2;
		return t; // for chaining
	}//---------------------------------------------------;
	
	
	/**
	 * Quickly add a predefined style to an FlxText
	 * @param	t The flxText
	 * @param	style the style, check the TextStyle typedef
	 * @return
	 */
	public static function applyTextStyle(t:FlxText, style:TextStyle):FlxText
	{
		if (style == null) style = {
			font:null,
			size:8,
			color:DEF_TEXT_COLOR
		};
		if (t.font != null) t.font = style.font;
		if (style.borderColor != null) quickTextBorder(t, style.borderColor);
		t.size = style.size;
		t.color = style.color;
		return t; // for chaining
	}//---------------------------------------------------;
	
	
	/**
	 * Style FlxTexts that are used in FlxMenus.
	 */
	public static function styleOptionText(t:FlxText, style:OptionStyle)
	{
		if (style.font != null) t.font = style.font;
		if (style.borderColor != null) quickTextBorder(t, style.borderColor);
		t.size = style.size;
		t.alignment = style.alignment;
		t.wordWrap = false;
	}//---------------------------------------------------;
	
}// -- 