package djFlixel.gui;

import djFlixel.gfx.GfxTool;
import djFlixel.gfx.Palette_DB32;
import djFlixel.tool.DataTool;
import flixel.text.FlxText;




//====================================================;
// Parameters for a <FlxText>, 
// can by set with applyTextStyle()
//====================================================;

	typedef TextStyle = {
		
		?font:String,		// Font name
		
		?fontSize:Int,		// Font size, ( I keep changing the name, I think fontSize is the best )
		
		?color:Int,			// Color
		
		?color_border:Int,	// Border Color ( note I am using color_border and not borderColor so that this
							// can be set with DataTool.copyFieldsC() and have the color translated :-)
			
		?border_size:Int,	// The depth of the shadow/border in pixels. 
							// null or -1 to autocalculate size
							
		?border_type:Int	// 0(Default) = shadow,  1 = Outline
	}

	
// -- Style/Parameters for a VListBase
// --------------------------------------

	typedef StyleVLBase = {
		
		// How fast to scroll elements in and out, 0 for instant scroll
		el_scroll_time:Float,	
		// How much padding between the elements in pixels
		el_padding:Int,
	
		// How to align the elements vertically in the List
		// [ left | right | center | justify ]
		alignment:String,
		
		// == Screen Tweens -----------------
		// 	. Behavior of the elements if they are to enter/exit the view
		// 	. Used at onScreen() and offScreen()
		
		// Time to move each element from start to end offset
		stw_el_time:Float,
		// Time to wait after starting each element to get to start animating the next one
		// 0 : everything at the same time
		stw_el_wait:Float,
		// Go from this starting (X,Y) offset to init pos when onScreen(); e.g.[0,-16] will start from 16 pixels above
		stw_el_EnterOffs:Array<Int>,
		// Go from current pos to this ending (X,Y) position when offScreen();
		stw_el_ExitOffs:Array<Int>,
		// Name of the ease function found in "FlxEase.hx"
		// e.g : bounceOut, SineIn, backInOut
		stw_el_ease:String,
		
		// == Scroll Indicators -----------------
		// . Arrows at the top and bottom of the list
		//   indicating that there are more elements to scroll to
		//	 The arrows are fetched form the GUI ICON LIB.
		?scrollInd:Dynamic
			// size:Int			; Force a icon size (8,12,16,24)
			// blinkRate:Float	; Blink every this milliseconds
			// alignment:String	; Force an alignment, else it's the same as "style.alignment"
			// color:Int		; Indicator color, else it's White
			// color_border:Int	; Border color
			// offset:Array<Int> ; [top,bottom] positioning padding
		
		// ======================================
		
	}// --
	
	
// -- Style/Parameters for a VListNav
// --------------------------------------
	typedef StyleVLNav = {>StyleVLBase,
	
		// Start scrolling the view before reaching the edges by this much.
		scrollPad:Int,
		// How many pixels to the right to animate the highlighted element at (el_scroll_time) speed
		focus_nudge:Int,
		// Loop at edges
		loop_edge:Bool

	}// --

	 
// -- Style/Parameters for a VListMenu and its menu items
// --------------------------------------------------------
 
	typedef StyleVLMenu = {
		> StyleVLNav,
		> TextStyle,
		
		color_focused:Int,		// Focused Color
		color_accent:Int,		// Special Accent color, used in labels and icons
		color_disabled:Int,		// Color for all disabled elements, (excluding labels)
		color_disabled_f:Int,	// Focused color of disabled element
	
		?color_icon_shadow:Int,	// If set, icons (checkboxes,arrows) will generate this shadow color
								// Usually same as the text "color_border"
		
		pageEnterStyle:String,	// Page in and out transition type ( used in FLXMenu )
								// [ wait | parallel | none ]

		// -- If you want to override the djFlixel icon lib
		?icons:Dynamic,
			//
			// image:String			; Asset of a new icon set, --It must follow the icon template--
			// size:Int				; Declare the size for the custom set
			//						; also FORCES the size of the default icons
			// colorize:Bool		; If false will not re-color the icons, Default to (true)  # UNUSED
			// -
			// checkboxText:Array<String>	; if set then checkbox will not use an icon and will use for off/on
			//								; text strings. e.g. ["( )" , "(X)"]
			// sliderText:Array<String>		; if set then the slider will use text symbols for left/right
			//								; e.g. ["<",">"]
			// sliderTime:Float				; Time to complete a full cursor nudge loop
						
		// -- In some special occations where you might want to use other images for icons
		// 	  that don't follow the djFlixel icon lib template
		?custom_icons:Dynamic,
			//
			// image:String			; Assetname of the tileset
			// size:Int				; Size of the tiles, must be square
			// checkbox:Array<Int>	; Two frames in an array, [off, on]
			// arrows:Array<Int>	; Frames in an array, [left,right,up,down] // UNUSED FOR NOW --
		
		// Object holding custom cursor parameters :
		// NOTE: VListMenu will use a text cursor by default
		?cursor:Dynamic
			//
			// image:String			;	The assetname of the cursor
			// size:Int				;	Required if animated, set the size of the frame, must be square
			// fps:Int				;	Required if animated, this will be the speed of the animation
			// frames:Array<Int>	;	If not NULL, will set this animation to the cursor
			// align:Bool			;	If true will Vertically Align the cursor on the menu item
			// -
			// disable:Bool			;	Don't use a cursor at all
			// offset:Array<Int>	;	Place the cursor with an offset [x,y]
			// text:String			;	If set it will use this text for the cursor. e.g. "->"
			//						;	Note it will be the same size as the label.size
			
			
		// TIP: You can use the same image for the cursor and icons
		
	}// --

	
	

	
	
//====================================================;
// Static class with Styling helpers 
// for VLists and FlxTexts
//====================================================;

class Styles
{
	// -- DJFLixel Defaults ::
	
	public inline static var DEF_TEXT_COLOR:Int   = 0xFFEEEEEE;
	public inline static var DEF_BORDER_COLOR:Int = 0xFF111111;	
	
	public static var DEF_STYLEVLBASE(default, never):Dynamic = {
		el_scroll_time:0.15,
		el_padding:1,
		alignment:"left",
		// --
		stw_el_time:0.10,
		stw_el_wait:0.02,
		stw_el_EnterOffs:[0,-10],	// Enter from top
		stw_el_ExitOffs:[16,2],		// Leave going right
		stw_el_ease:"easeOut"
	};
	
	public static var DEF_STYLEVLNAV(default, never):Dynamic = {
		focus_nudge:5,
		scrollPad:1,
		loop_edge:false
	};
	
	public static var DEF_STYLEVLMENU(default, never):Dynamic = {
		// TextStyle:
		font:null,
		fontSize:8,
		color:Palette_DB32.COL_21,
		color_border:Palette_DB32.COL_02,
		border_size:-1,	// auto
		// -- MenuStyle ::
		color_focused:Palette_DB32.COL_09,
		color_accent:Palette_DB32.COL_06,
		color_disabled:Palette_DB32.COL_26,
		color_disabled_f:Palette_DB32.COL_24,
		color_icon_shadow:null, //If null going to be same as 'color_border'
		pageEnterStyle:"wait"
	};
	
	//====================================================;
	
	// New Style Generators
	// ------------------
	// If you want to quickly create a newstyle based on the defaults
	// use these functions.
	
	// --
	public static function newStyleVLBase():StyleVLBase
	{
		return Reflect.copy(DEF_STYLEVLBASE);
	}//---------------------------------------------------;
	// --
	public static function newStyleVLNav():StyleVLNav
	{
		// Merge StyleVLBase + StyleVLNav
		return DataTool.copyFields(DEF_STYLEVLNAV, Reflect.copy(DEF_STYLEVLBASE));
	}//---------------------------------------------------;
	// --
	public static function newStyleVLMenu():StyleVLMenu
	{
		// Merge StyleVLBase + StyleVLNav + StyleVLMenu
		var p = DataTool.copyFields(DEF_STYLEVLNAV, Reflect.copy(DEF_STYLEVLBASE));
		return  DataTool.copyFields(DEF_STYLEVLMENU, p);
	}//---------------------------------------------------;
	
	/**
	 * Quickly apply border to an FlxText object
	 * @param	t FlxText
	 * @param	c Border Color
	 * @param	size if -1 it will generate 1 pixel for every 8 pixels of the fontSize
	 * @return
	 */
	public static function applyTextBorder(t:FlxText, c:Int = DEF_BORDER_COLOR, size:Int = -1, type:Int = 0 ):FlxText
	{
		if (size == 0) return t;
		if (type == 1) 
			t.borderStyle = FlxTextBorderStyle.OUTLINE;
		else
			t.borderStyle = FlxTextBorderStyle.SHADOW;
		t.borderSize = (size < 0)?Math.ceil(t.size / 8):size;
		t.borderColor = c;
		t.borderQuality = 1;
		return t; // for chaining
	}//---------------------------------------------------;
	
	
	/**
	 * Style an FlxText with a predefined (TextStyle) style
	 * @param	t The FlxText to apply the style to
	 * @param	s The style, check `TextStyle` typedef in this file
	 * @return
	 */
	public static function applyTextStyle(t:FlxText, s:TextStyle):FlxText
	{		
		if (s.font != null) t.font = s.font;
		if (s.fontSize != null) t.size = s.fontSize; // Size first, don't move this.
		if (s.color_border != null) {
			applyTextBorder(t, s.color_border, 
				s.border_size != null?s.border_size: -1,
				s.border_type != null?s.border_type: 0);
		}
		if (s.color != null) t.color = s.color;
		return t; // for chaining
	}//---------------------------------------------------;
	
}// -- 