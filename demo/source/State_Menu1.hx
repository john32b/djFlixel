/**
== FlxMenu Demo 1
   
   - Basic setup
   - Basic callback handling
 
***************************************/
   
package;

import common.InfoBox;
import djFlixel.D;
import djFlixel.gfx.pal.Pal_DB32;
import djFlixel.other.DelayCall;
import djFlixel.other.StepLoop;
import djFlixel.ui.FlxMenu;
import djFlixel.ui.FlxToast;
import djFlixel.ui.menu.MPageData;
import flash.display.StageQuality;
import flash.media.Sound;
import flixel.FlxG;
import flixel.FlxState;
import game1.State_Game1;
import haxe.display.Position.Range;
import haxe.ds.List;

class State_Menu1 extends FlxState
{
	
	var CHEATS_ENABLED = false;
	
	override public function create():Void
	{
		super.create();
		
		//- Add some graphics	
		Main.bg_scroller(1, [0xff2F2F2F, 0xff212121]);
		Main.add_footer_01();
		
		//====================================================;
		
		var str = 
		"$FlxMenu$ is a multipaged menu system that is easy to setup and interact with."+
		" In addition to providing #links#, it supports menu items such as #lists#, #toggles# and #number selectors#."+
		" Everything is handled by a simple callback system. Here is a simple demo of a game menu.\n" +
		"Supports : $Gamepad$ / $Mouse$ / $Keyboard$ (Arrows,K,J)";
	
		var box = new InfoBox(str, { width:300, colBG:0xf0f0f0, text:{c:0xff535359, bc:0xffcbdbfc}});
		
		// Add and align to the center of the bottom of the screen, bring 36 pixels more to the top
		add(D.align.screen(box, "c", "b", 36 ));
		
		new DelayCall(1.0, box.open.bind()); // Open the box after 1 second
		
		//====================================================;

		// - Create a simple menu and style it a bit
		// - Position at (x,y) 0 for autowidth and make it display 8 items 
		// - If the "slots" is lower, then the items will scroll
		var m = new FlxMenu(32, 32, 0, 8);
		
		m.PAR.start_button_fire = true;
		add(m);

		// ---
		// - Create some menu pages
		// - By calling m.createPage() it will automatically store the PageData inside FlxMenu
		// - This is a unique encoded string decleration method. 
		//   For more info on how to structure a string, check <MItemData.hx>
		m.createPage("main","Main Menu").add(
			"-|New Game     | link   | l_game
			 -|Difficulty   | list   | id_diff | easy,medium,hard | c=1
			 -|Start Level  | range  | id_range | 1,100 
			 -|God Mode	    | toggle | id_god | c=false | D 
			 -|Options      | link   | @options 
			 -|Next FlxMenu | link   | l_next
			 -|Quit 		| link   | id_quit | ?pop=Really?:Yes:No");
		
		// NOTE: On the "Enable Cheats" item
		// - The "D" in the declaration means disabled
		// - To change an item's properties use the function FlxMenu.item_update()
		// - Look in the `onItemEvent` function below for an example
		
		
		// -----
		// - Add another page with id "options"
		//   Will be automatically called from the "@options" link itam
		m.createPage("options","Options").add(
			"-|Enable Cheats | link | id_cheats | ?fs=Enabling cheats will disable achievements:OK do it:NO!
			 -|Graphic Options | label |.|U
			 -|Quality | list | id_qual | low,medium,high | c=1
			 -|Antialiasing | toggle | id_aa 
			 -|Sound Options | label |.|U
			 -|Volume | range | id_musvol | 0,100 | step=5
			 -|Back		|link  | @back ");
		
			// ^ IMPORTANT NOTE:
			// Notice the "U" declaration. It means make the item unselectable
			// But since the third field is the ID, I have to give it a random string
			// like "." for the label's ID and then put "U" so it can register it..
			 
		
		// - FlxMenu deals with events with simple callback functions
		// - These two are the only ones you can listen 
		// - This sends menu related events, like {open,focus}
		m.onMenuEvent = (mev, str)->{
			Main.handle_menu_sound(mev);	// custom function to handle sounds based on events
			trace("Menu Event", mev, str);
		};
		
		// This sends item related events,
		// Like an item was pressed, or changed value
		m.onItemEvent = (a, item)->{
			Main.handle_menu_sound(a);	// custom function to handle sounds based on events
			trace("Item Event ", a, item);
		
			if (a == fire) {
				switch (item.ID){
					
					case "id_cheats":
						
						CHEATS_ENABLED = !CHEATS_ENABLED;
						
						if (CHEATS_ENABLED)
							FlxToast.FIRE("Cheats $enabled$");
						else
							FlxToast.FIRE("Cheats #disabled#");
						
						// This is how to alter a property of a menu item and have it reflect on the menu
						// Ask FlxMenu to get you the item with this function
						// main is the pageID where the item is in
						// id_god is the itemID
						// Callback function with the itemdata itself, check <MItemData>
						// Make changes to it, you can change the label/disabled state 
						//  or data properties if it was a toggle/range/list
						m.item_update('main', 'id_god', (it)->{
							it.disabled = !CHEATS_ENABLED;
							if (it.disabled) {
								it.set(false);	// Make the TOGGLE to OFF if it is disabled
							}
						});

						// Now alter the 'id_cheats' Link
						m.item_update('options', 'id_cheats', (it)->{
							if (CHEATS_ENABLED) {
								it.label = "Disable Cheats";
								// OK this is a bit ADVANCED:
								// the P.ltype property of a link is its type
								// 1 means normal link, don't ask for anything
								it.P.ltype = 1;
							}else{
								it.label = "Enable Cheats";
								it.P.ltype = 3;	// (3) is full screen confirmation type
							}
						});
						
						// I need to call this so it can exit the full screen confirmation page
						m.goBack();	
							
					// This link has a confirmation attached to it
					// and will only be fired when user said YES
					case "id_quit":
						Main.goto_state(State_Menu,"let");
					
					case "id_qual":
						FlxToast.FIRE('Graphics set to: #${item.get()}#', {bg:0xFF868690, screen:"top:right"});
					
					case "id_aa":
						var a = item.get()?"Enabled":"Disabled";
						FlxToast.FIRE('Antialiasing #$a#', {bg:0xFF868690, screen:"top:right"});

					case "l_game":
						// Prevent inputs
						m.unfocus();
						Main.create_add_8bitLoader(0.5, State_Game1);
							
					case "l_next":
						// Prevent inputs
						m.close();
						// - Switch with a custom effect
						new common.SubState_Letters(".-\\|/-.",
						Main.goto_state.bind(State_Menu2),
						{
							text:{ c:0xFFDDDDDD },
							bg:0xFF090909, 
							snd:"hihat", 
							tPre:0.4, 
							tPost:0.3,
							tWait:0.02,
							tLetter:0.09
						});
				
					default:
				}
			}	
		};
		
		
		// The menu has pages stored in it, but it shows nothing
		// You need to tell it to goto a page from the ones you stored earlier
		// This will also give the menu keyboard focus
		m.goto("main");
		
		// That's it
		//
		// FlxMenu handles keys on its own.
		// There are more things you can do with it, like unfocus(), close() etc
		// More examples later
		
	}//---------------------------------------------------;
	
}// --