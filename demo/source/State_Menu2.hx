/**
== FlxMenu Demo 2
   
   - Custom Styles
 
***************************************/
   
package;

import common.InfoBox;
import djFlixel.D;
import djFlixel.gfx.BoxScroller;
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
import flixel.tweens.FlxEase;
import flixel.util.FlxStringUtil.LabelValuePair;
import haxe.display.Display.GotoDefinitionResult;

class State_Menu2 extends FlxState
{
	
	// Custom user update
	var u:Void->Void = ()->{}; 
	
	// For calling Main.bg_scroller;
	var scrollCombo = [ 
		[3, 0xff3a4466, 0xff262b44],
		[6, 0xff4b1d52, 0xff692464],
		[5, 0xff2f5753, 0xff3b7d4f]
	];
	
	override public function create():Void
	{
		super.create();
		
		// --
		Main.bg_scroller(scrollCombo[0][0], [scrollCombo[0][1], scrollCombo[0][2]]);
		Main.add_footer_01();
		
		// --
		var t1 = D.text.get("PRESS [ENTER]/[CLICK] TO OPEN THE MENU", {f:'fnt/LycheeSoda.ttf',s:16, c:0xFFEF4B50, bc:0xFF850C0F});
		add(D.align.screen(t1));
		t1.visible = false;
		
		// --
		var str = 
		"FlxMenu has many customizable properties. From $Text Style$ and how items animate and out" +
		", to custom $icons$ and $animated cursors$. Also each #page# on the menu can be #customized#" +
		" to override the global menu style.";
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
		m.STP.align = "center";		// [left,center,justify]
		m.STP.focus_anim.x = 0;		// X target when focused | I am changing this because the default has a value
		m.STP.scroll_time = 0.1;	// Time to scroll when elements come in from the top/bottom
		m.STP.item_pad = 2;			// Padding between items
		m.STP.background = { color:0xFF222230, padding:[0, 0, 0, 0] };
		// -- vt (ViewTweens) when the menu comes in/out
		m.STP.vt_IN = "-22:0|0.25:0.04";	// When coming in start from (-10,0) | 0.2 duration 0.1 wait
		m.STP.vt_OUT = "22:0|0.25:0.04";	// The same for going out, but end in (10,0) offset
		m.STP.vt_in_ease = "bounceOut";		// Ease in function name from FlxEase
		
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
			offset : [ -2, 2],				// required field
			tween:{
				time:0.5,			// Time to complete the animation tween
				x0: -32, 			// Start at -32 pixels from the baseline
				x1:0,				// End at +0 pixels from the baseline
				a0:0.4, a1:1,		// Start alpha 0.4 | End alpha 1.0
				ease:"bounceOut"	// name of the function in FlxEase
			}
		};
		//
	
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
			
		// -- Create a page with a bunch of menu items
		//    trying to demo a range of functionalities
		
		m.createPage("main", "Main Menu").add("
			 -| Return to Main | link | id_main | ?pop=:YES:NO
			 -| Goto Page 2 | link | @page2
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
		
		
		
		// --
		// More examples in functionality
		var p2 = m.createPage("page2", "page two (2)").add("
			-| Goto Page 3| link | @page3
			-| Dynamic Label (x) | label | id_ch1
			-| Change Above ^ | range |id_ch2| 10,200 | c=50 | step=12
			-| This page can loop | label | U
			-| Back | link | @back
		");
		
		
		// - You can override page specific styles with this
		// - It will overlay attributes on top of the global FlxMenu style
		// - NOTE: Best used for small changes; this is just to show that you can change many stuff
		p2.STPo = {
			vt_IN:"0:-24|0.5:0.15",
			vt_OUT:"0:-24|0.3:0.08",
			vt_in_ease:"elasticOut",
			vt_out_ease:"elasticIn",
			loop:true,
			align:"left",
			background:{
				color:0x77FFFFFF,
				padding:[2, 2, 2, 2]
			},
			item:{
				text:{
					f:"fnt/mozart.ttf",
					s:16,
					bt:2,
					bc:0xFF112233
				}
			},
			cursor:{
				anim:null,
				bitmap:null,
				text:">",
				color:{c:0xFFEEE209},
				tween:{
					time:0.2,
					x0:-4,
					x1:0,
					ease:"linear"
				}
			}
		};

		
		// --
		var p3 = m.createPage("page3", "page three (3)").add("
			-| Less Menu Slots Here | label | .
			-| Scroll Down | label | .
			-| One | link | .
			-| Two | link | .
			-| Three | link | .
			-| Four | link | .
			-| Five | link | .
			-| Six | link | .
			-| more| list | . | djFlixel v0.5.4,added,smooth animations,for centered,dynamic sized,items,like this one | loop=true
			-| Go to Root | link | id_root
			-| Go Back | link | @back
		");
		
		p3.PAR.slots = 3;
		p3.STPo = {
			background: {
				color:0xFF443344,
				padding:[2,32,2,32]
			},
			item:{
				text:{
					bt:1,
					bc:0xFF112211,
					bs:3
				},
				col_t:{
					idle:0xdef0f0,
					focus:0xc8d45d,
					accent:0xcc3f7b
				},
			}	
		};
		
		// :: NEW
		// - FlxMenu Header Title
		// - It is an FlxAutoText object that displays the Page Title of pages
		// - You can set the properties of the Text like this, for undeclared fields
		//   it will copy over the properties from the MItem style of the current page
		// - It used to be built in on FlxMenu, not you have to attach it
		
		m.plug(new MPlug_Header({
			text:{a:"center"},
			lineHeight:2
		}));
		
		
		// -- Global way to add sounds
		Main.menu_attach_sounds(m);

		// -----------------------------------------
		
		m.onItemEvent = (a, item)->{
		
			if (a == fire) switch (item.ID) {
					
					case "id_close":
						m.close();
					
					case "id_main":
						m.unfocus();
						Main.goto_state(State_MainMenu, "fade");
						
					case "id_root":
						m.goHome();
						
					case "id_ch2":
						var value = item.get();
						// Put the range value on the label
						m.item_update(null, "id_ch1", (it)->{
							it.label = 'Dynamic Label (${value})';
						});
				
					default:
			}
			
		};
		
		// --
		m.onMenuEvent = (ev, id)->{
			switch (ev){
				
				case page:
					switch (id) {
						case "main":
							Main.bg_scroller(scrollCombo[0][0], [scrollCombo[0][1], scrollCombo[0][2]]);
						case "page2":
							Main.bg_scroller(scrollCombo[1][0], [scrollCombo[1][1], scrollCombo[1][2]]);
						default:	// page 3
							Main.bg_scroller(scrollCombo[2][0], [scrollCombo[2][1], scrollCombo[2][2]]);
					}
				
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