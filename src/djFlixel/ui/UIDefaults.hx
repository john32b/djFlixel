/**
  Provides some Defaults for some UI Objects

************************/ 

package djFlixel.ui;
import djFlixel.ui.VList.VListStyle;
import djFlixel.ui.menu.MItem.MItemStyle;
import djFlixel.ui.menu.MPage.MPageStyle;


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
		part2_pad : 10			// X pixel padding between Label and Other part| Volume ....... <30> |
	}//---------------------------------------------------;
	

	// -- This is Shared with <VListStyle>
	public static var MPAGE:MPageStyle = 
	{
		// <VListStyle> Fields ::
		align:"left",
		loop:false,
		item_pad:-2,				// You can use negative values here
		focus_nudge:4,				// Push elements 4 pixels when they are focused
		scroll_pad:1,				// Initiate scroll when cursor is at an offset from the edge.
		scroll_time:0.125,
		// : View Tweens
		vt_IN:"0:-10|0.12:0.08",	// x:y|speed:delay
		vt_OUT:"12:2|0.08:0.04",	// x:y|speed:delay
		vt_in_ease:"quadOut",
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
			offset:[3, 0],
			tmult:0.9	// 0 for instant tween, Other float to tweak tween time
		}
	}//---------------------------------------------------;
	
	
}// -- end -- //