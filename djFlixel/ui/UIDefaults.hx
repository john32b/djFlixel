/**
  Provides some Defaults for some UI Objects

************************/ 

package djFlixel.ui;
import djFlixel.ui.VList.VListStyle;
import djFlixel.ui.menu.MItem.MItemStyle;
import djFlixel.ui.menu.MPage.MPageStyle;
import flixel.tweens.FlxEase;


@:dce
class UIDefaults 
{

	/** Default Style for all Menu Items */
	public static var MITEM:MItemStyle = {
		
		text:{	
			bt:1	// Border Type 1:SHADOW  
		},
		
		// Text Color at different focus states
		col_t:{
			idle:0xFFF4F4F4, 
			focus:0xFFFFFF00, 
			accent:0xFFFF8000, 
			dis:0xFF5C5C5C, 
			dis_f:0xFF909090
		},
		
		// Border Color at different focus states
		col_b:{
			idle:0xFF222222		// You can only set a color for (idle) and it will be shared
								// to the rest of the FocusStates?
		},
		
		box_txt: [ "( )", "(X)" ],
		ar_txt : [ "<", ">" ],
		ar_anim : "1,2,0.33",	// Type 1 Repeat | 2 Steps | 0.33 Tick Time
		part2_pad : 10			// X pixel padding between Label and Other part| Volume ....... <30> |
	}//---------------------------------------------------;
	

	// -- This is Shared with <VListStyle>
	public static var MPAGE:MPageStyle = 
	{
		// <VListStyle> Fields ::
		align:"left",
		loop:false,
		item_pad: -2,			// You can use negative values here
		
		focus_anim:{
			x:4, y:0, inEase:FlxEase.quadOut, inTime:0.2, outEase:FlxEase.linear, outTime:0.1
		},
		
		scroll_pad:1,				// Initiate scroll when cursor is at an offset from the edge.
		scroll_time:0.125,
		
		lerp:0.08,					// Bigger values > faster

		// : View Tweens
		vt_IN:"0:-10|0.12:0.08",	// x:y|speed:delay
		vt_OUT:"12:2|0.08:0.04",	// x:y|speed:delay
		vt_in_ease:"quadOut",
		vt_out_ease:"quadOut",
		
		// : Scroll Indicator
		sind_size:8,			// (Make sure you have initialized the icon size with D.ui.initIcons(..)
		sind_anim:"2,3,0.2",	// 2=Type Loop, 3 Steps, 0.2 millisecs for each step
		sind_color:0xFFE0E0E0,
		sind_offx:0,
		// ---------------------------------
		
		item : MITEM,	// Here I am using a pointer to that object above, but you can inline the object
		
		cursor : 
		{
			text:'>',
			tween:{
				time:0.15,
				x0: -12, x1:0,
				a0:0.4, a1:1,
				ease:"bounceOut"
			}
		}
		
		#if (html5)
		,item_height_fix:0
		#end
		
	}//---------------------------------------------------;
	
	
}// -- end -- //