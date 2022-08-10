/**
== FlxMenu Demo 2
   
   - Custom Styles
 
***************************************/
   
package menu1;

import common.InfoBox;
import djFlixel.D;
import djFlixel.gfx.pal.Pal_DB32;
import djFlixel.other.DelayCall;
import djFlixel.ui.FlxMenu;
import djFlixel.ui.menu.MItemToggle;
import djFlixel.ui.menu.MPageData;
import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets;
import djFlixel.gfx.FilterFader;
import djFlixel.ui.MPlug_Header;

class State_Menu2 extends FlxState
{
	
	//static var AA = 
	// Kapel
	// Custom user update
	var u:Void->Void = ()->{}; 
	
	override public function create():Void
	{
		super.create();
		
		// --
		Main.bg_scroller(3, [0xff3a4466, 0xff262b44]);
		Main.add_footer_01();
		
		// --
		var t1 = D.text.get("PRESS [ENTER]/[CLICK] TO OPEN THE MENU", {f:'fnt/LycheeSoda.ttf',s:16, c:0xFFEF4B50, bc:0xFF850C0F});
		add(D.align.screen(t1));
		t1.visible = false;
		
		// --
		var str = "";
		var box = new InfoBox(str, { width:240, colBG:0xf0f0f0, text:{c:0xff535359, bc:0xffcbdbfc}});
		add(D.align.screen(box, "c", "b", 30 ));
		new DelayCall(1.0, box.open.bind());
		
		//====================================================;
		
		
		// -1 means make the width reach the end of the screen minus 32pixels
		// 5 slots, so it will scroll
		var m = new FlxMenu(42, 32, -1, 5);
		
		m.PAR.start_button_fire = true;
		add(m);
		
		// - Customizing the style of an FlxMenu ::		
		
		// STP is the object that holds all the style options of the pages and menu items
		// When an FlxMenu is created {STP} is filled with a default style (defined in "UIDefaults.hx")
		// You can modify current fields or you can completelt replace it a new Style Object
		// For a complete rundown on what it can do, refer to <MPageStyle> defined in "Mpage.hx"
		
		//m.STP.loop = true;
		m.STP.focus_nudge = 0;
		m.STP.scroll_time = 0.1;
		m.STP.vt_IN = "-22:0|0.25:0.04";	// When coming in start from (-10,0) | 0.2 duration 0.1 wait
		m.STP.vt_OUT = "22:0|0.25:0.04";	// The same for going out, but end in (10,0) offset
		m.STP.item_pad = 2;				// Padding between items
		m.STP.vt_in_ease = "bounceOut";	// Customize the easing function
		m.STP.background = 0xFF222230;
		m.STP.align = "center";		// left,justify
		
		// HTML5 is wonky with some fonts metrics
		#if (html5)
			m.STP.item_height_fix = 3;
			m.STP.item_pad = 0;
		#end
			
		// Text font and style	
		m.STP.item.text = {
			f:'fnt/LycheeSoda.ttf',
			s:16,
			bt:0,	// No border
		};
		
		// - Set the menu items State colors
		m.STP.item.col_t = {
			idle:0xFF3e8948,
			focus:0xFF2ce8f5,	
			accent:0xFFff0044,
			dis:0xFF595959,
			dis_f:0xFF787878	
		};
		
		// - Set the border color for each State
		// - In this case, I can set the IDLE state only and it will be shared to the other states
		m.STP.item.col_b = {
			idle:0xFF2F202C
		};
			
		
		// -- Add a custom cursor graphic, Follow the <MCursorStyle> typedef
		m.STP.cursor = {
			bitmap : FlxAssets.getBitmapData('im/menu_style.png'),
			anim  : "16,10,0,1,2,3,4,5,6",	// 16 size, 10 fps, 0,1,2,3,4,5,6 frames to loop
			tmult : 0.9,					// required field
			offset : [-2,2]					// required field
		};
		
	
		// - Set custom checkbox bitmaps
		var bit = FlxAssets.getBitmapData('im/menu_style.png');
		// {box_bm} Requires an array of 2 bitmaps, off and on
		// This is a crude way to do this. There are other ways of course like using an Atlas
		m.STP.item.box_bm = [
			D.bmu.getBitmapSquare(bit, 112, 0, 16, 16),
			D.bmu.getBitmapSquare(bit, 128, 0, 16, 16)
		];
		
		// - Use custom graphics for the < > symbols for the range/list item
		// Also change the animation properties
		m.STP.item.ar_anim = "2,3,0.20";
		m.STP.item.ar_bm = [
			D.bmu.getBitmapSquare(bit, 144, 0, 16, 16),
			D.bmu.getBitmapSquare(bit, 160, 0, 16, 16)
		];
	
		
		// - You can also customize the little ^ indicators at the top and bottom of the VLIST
		//   These indicate that there are more items to scroll to
		
		m.STP.sind_size = 12;			// Default is 8
		m.STP.sind_anim = "1,2,0.2";	// 1:Type repeat | 2 steps | 0.2 tick time
		m.STP.sind_color = m.STP.item.col_t.accent;

		
		// -- Done creating a style 
		// -------------------------------------
			
		m.createPage("main", "Main Menu").add("
			 -| Return to Main | link | id_main | ?pop=:YES:NO
			 -| New Page Demo| link | @page2
			 -| Close The Menu | link | id_close
			 -| Label (unselectable) | label|.|U
			 -| Selectable Label |label
			 -| Toggle | toggle | .
			 -| Forbidden item | toggle | . | D
			 -| Range Int| range | . | 0,1000 | step=100 | c=500
			 -| Range Float| range | . | 0,2 | step=0.33 | c=1
			 -| List Test | list | . | haxe,c++,js,rust,lua
			 -| List Looped  | list |.| red,green,blue | c=2 | loop=true
		");
		
		
		
		// - FlxMenu Header Title
		// - It is an FlxAutoText object that displays the Page Title of pages
		// - You can set the properties of the Text like this, for declared fields
		//   it will copy over the properties from the MItem style of the current page
		
		m.plug(new MPlug_Header({
			text:{a:"right"},lineHeight:2
		}));
		
		
		// -----------------------------------------
		
		m.onItemEvent = (a, item)->{
			Main.handle_menu_sound(a);	// custom function to handle sounds based on events
		
			if (a == fire) {
				switch (item.ID){
					
					case "id_close":
						m.close();
					
					case "id_main":
						m.unfocus();
						new FilterFader( Main.goto_state.bind(State_Menu));
				
					default:
				}
			}	
		};
		
		// --
		m.onMenuEvent = (ev, id)->{
			Main.handle_menu_sound(ev);	// custom function to handle sounds based on events
			switch (ev){
				
				case close:
					
					// Show the text to open the menu
					// Handle input to open it
					new DelayCall(()->{
						t1.visible = true;
						u = () -> {
							if (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed) {
								m.open();
							}
						}
					});
					
				case open:
					// close the info text
					t1.visible = false;
					u = ()-> {};
					
				default:
			}
		};
		
		m.goto("main");
		
	}//---------------------------------------------------;
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed); u();
	}//---------------------------------------------------;
	
}// --