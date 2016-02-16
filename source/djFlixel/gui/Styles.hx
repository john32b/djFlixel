package djFlixel.gui;

import djFlixel.gfx.Palette_DB32;
import djFlixel.gui.Styles.VBaseStyle;
import flixel.text.FlxText;



/**
 * Various objects that hold styles for gui elements
 * =================================================
 * - BaseMenu
 * - ListMenu
 * - MenuOption
 */


//====================================================;
// Visual parameters for a <VListBase>
//====================================================;

	typedef VBaseStyle = {
		// Time it takes to scroll the elements in and out of the list.
		var element_scroll_time:Float;
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
//  Visual parameters for a <VListMenu>.
//====================================================;

	typedef VListStyle = {	 
		 // Start scrolling the view before reaching the edges by this much.
		 var scrollPad:Int;
		 // How many pixels to the right to animate the highlighted element
		 var focus_nudge:Int;
		 // If set then a cursor will be created as an FlxText
		 var cursorSymbol:String; 
		 
		 // TODO: It doesn't work.
		 // TODO: parameterize the sprite and frame etc
		 // var cursorSprite:Bool;
		 
	 }// :: -- ::
 
//====================================================;
// Visual parameters for a <MenuOptionBase>
//====================================================;
 
	typedef OptionStyle = {
		
		// Custom embedded font, null for flixel default
		var font:String; 
		var fontSize:Int;
		var color_default:Int;
		var color_focused:Int;
		var color_accent:Int;
		var color_disabled:Int;		// Note: Labels will not be of this color, but a diff one
		var color_disabled_f:Int;	// Focused color for a disabled element
		var useBorder:Bool;
		var border_color:Int;	
	}// :: -- ::
	 
	
//====================================================;
// Various MenuStyle Helpers
//====================================================;

class Styles
{

	// Create the default styles here,
	// those can be overriden.
	
	public static var default_ListStyle:VListStyle = {
		focus_nudge:5,
		scrollPad:1,
		cursorSymbol:">"
	}; // --
		
	public static var default_BaseStyle:VBaseStyle = {
		element_scroll_time:0.18,
		element_padding:2,
		anim_time_between_elements:0,
		anim_total_time: 0.7,
		anim_start_x:0,
		anim_start_y:-12,
		anim_end_x:32,
		anim_end_y:2,
		anim_tween_ease:"linear",
		anim_style:"none"
	}; // --
	
	public static var default_OptionStyle:OptionStyle = {
		font:null,
		fontSize:8,
		color_default:Palette_DB32.COL_21,
		color_focused:Palette_DB32.COL_09,
		color_accent:Palette_DB32.COL_06,
		color_disabled:Palette_DB32.COL_26,
		color_disabled_f:Palette_DB32.COL_24,
		useBorder:true,
		border_color:Palette_DB32.COL_02
	}; // --
	
	
	//====================================================;
	// FUNCTIONS
	//====================================================;

	// Convert a text objet style to this style
	public static function styleOptionText(t:FlxText,style:OptionStyle)
	{
		t.size = style.fontSize;
		t.wordWrap = false;
		if (style.font != null) 
			t.font = style.font;
		if (style.useBorder) {
			t.borderSize = Math.ceil(style.fontSize / 8);
			t.borderColor = style.border_color;
			t.borderQuality = 2;
			t.borderStyle = FlxTextBorderStyle.SHADOW;
		}
		
	}//---------------------------------------------------;
	
	// NEW STYLES
	// ----------
	// If you want to quickly create a newstyle based on the default,
	// use these functions.
	
	// --
	public static function newStyle_Base():VBaseStyle
	{
		return Reflect.copy(default_BaseStyle);
	}//---------------------------------------------------;
	// --
	public static function newStyle_Option():OptionStyle
	{
		return Reflect.copy(default_OptionStyle);
	}//---------------------------------------------------;
	// --
	public static function newStyle_List():VListStyle
	{
		return Reflect.copy(default_ListStyle);
	}//---------------------------------------------------;
	
}// -- 