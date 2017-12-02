package ;

import djFlixel.FLS;
import djFlixel.gui.Align;
import djFlixel.gui.FlxMenu;
import djFlixel.gui.PanelPop;
import djFlixel.gui.menu.MItemData;
import djFlixel.gui.menu.PageData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxGradient;


/**
 * FlxMenu Example : Functionalities Demo
 * ---------------------------------------
 *
 * - Focus/Unfocus
 * - Close/Open
 * - Force Highlight an item
 * - Force Change an item's data
 * - Confirmations
 * - Override a page style
 * - ..
 * 
 * @author JohnDimi
 */
 
class State_MenuDemo1 extends FlxState
{
	// -
	var menu:FlxMenu;
	
	// Description Text on item highlight
	var desc:FlxText;
	
	// Box with background and text
	var box:InfoBox;
	
	
	// Help text that goes in the info box
	// Note: Very crude way to set a help text, but it works for now :-/
	var description = [
			"-- Press a key --\n\n"+
			"[1] - Toggle Focus \n"+
			"[2] - Open/Close \n"+
			"[3] - Highlight an element\n"+
			"[4] - Modify on the 1st item\n"+
			"[5] - Toggle Checkbox\n"+
			"[6] - Go Home\n" +
			"---\n" +
			"Keys: WASD J/K | Arrows Z/X " +
			"",
			
			"Confirmation functionality Demos\n"+
			"---\n" +
			"Keys: WASD J/K | Arrows Z/X ",
			
			
			"FlxMenu supports scrolling and handling many items\n" +
			"It uses pooling for bringing in items so even if you have a very large set of items\n" +
			"They are not all created as sprites\n" +
			"---\n" +
			"Keys: WASD J/K | Arrows Z/X \n"+
			"PRESS J or Z to go back"
			
		];
		
	// --
	override public function create():Void
	{
		// DJFlixel loads and parses "params.json" file into a global object in (FLS)
		// Quickly alter variables without having to recompile, 
		// Just press F12 to reload the file and reset the state
		// Very useful to quickly tweak positioning and colors etc.
		// --> (Create a pointer so I don't have to write the full var all the time)
		var P = FLS.JSON.STATE_DEMO_VARS;
		
		
		// -- A Gradient bg for style
		var bg = new FlxSprite(0, 0, 
			FlxGradient.createGradientBitmapData(FlxG.width, FlxG.height, cast P.gradient, 16));
		add(bg);
			
		
		// -- The menu
		menu = new FlxMenu(P.menu.x, P.menu.y, P.menu.width, 12);
		menu.styleHeader.textS = {fontSize:16, color:0xFF00FF40};
		menu.callbacks_item = menuCallbackItem;
		menu.callbacks_menu = menuCallbacksMenu;
		add(menu);
		
		
		// --- Build the main page ---------------
		
		var p:PageData = menu.newPage("main", {title:"Menu Demo", desc:description[0]});
		
		// This item label can be changed dynamically [4] 
		p.link("-- This does nothing --", "rand");
		
		// -- Links to other pages ::
		p.label("Pages :"); 
		
		// "@" at the very start of the SID means GOTO, so selecting this the menu will
		// go to the "confirm" page ( declared later )
		p.link("Confirmations Page Demo", "@confirm");
		p.link("Overflow", "@overflow");
		
		// -- Create some interactibe menu items ::
		
		// Label :: ( not interactive it is unselectable by default )
		p.label("Funcional Item Types :");	
	
		// Toggle ::
		// - I can set the starting data of an element with the "current" field
		p.add("Toggle", {type:"toggle", sid:"it_1", current:true,
			desc:"Something that can toggle between two states (checkboxes)"
		});
		// Oneof ::
		// This menu item type has a "pool" field with all the available data to select from
		p.add("OneOf", {type:"oneof", sid:"it_2", pool:["sub item 1", "other", "test", "sub item n"],
			current:3,	// current field on a "oneof" item denotes the index of the "pool" that is selected
			desc:"Selects one of an array of strings"
		});
		
		// Slider ::
		// It's like a "oneof" but selects a value between a range of integers
		// Set the range in the "pool" field 
		p.add("Slider", {type:"slider", sid:"it_3", pool:[50, 100],
			current:70, // current holds the actual value
			desc:"Selects a number between a range"
		});
		
		// Create a disabled menu item ( can be enabled later )
		p.add("Disabled", {type:"link", sid:"it_4", disabled:true,
			desc:"This is disabled and cannot be fired."
		});
	
		p.link("Exit", "#exit");
	
		// -- Done creating the main page ^^ ---------------------------
		
		
		
		
		// -- Confirmation Functionality Page Test -----------
		//
		
		// Inserting a [!] or a [#] at the start of link SIDs will cause the "fire" 
		// actions to be confirmed. The captured SID does not include the prefix
		// e.g. "#test" -> will confirm and fire "test"
		
		p = menu.newPage("confirm", {title:"Confirmations", desc:description[1]});
		
		p.link("New page Confirmation", "!test");

		// Inserting a [#] will do the confirmation on a very basic popup window
		p.link("Popout Confiration", "#test2");
		
		// --
		// Capture the menu item data to alter it.
		var item:MItemData;
		
		// -
		item = p.link("Custom new Page Confirmation", "!test3");
			// You can customize the question and anwsers if you don't want the defaults:
			item.data.conf_question = "Are you sure?";
			item.data.conf_options = ["Definitely.", "Um, no."];
			// Also you can customize this page style
			item.data.conf_p_style = {fontSize:16, stw_el_EnterOffs:[ -10, 0], el_padding:4};
			
		item = p.link("Custom Popout Confirmation", "#test4");
		// You can customize the Yes/No labels
			item.data.conf_options = ["Maybe", "I am not sure"];
			item.data.conf_question = "Do you really?";
		p.addBack("Return");
		
		// --- done creating page ^^^ --------------------------
		
		
		
		
		
		// --- Dynamic Pages Test ----
	
		p = menu.newPage("overflow", {title:"Overflow Demo", desc:description[2]});
		p.custom.slots = 6; // Force 6 slots instead of what was declared for the FlxMenu
		p.custom.cursorStart = "back"; // Always point to the this element when going in
									   // Default is to remember position
	
		// Add a bunch of items
		p.addBack();
		for (i in 0...40){
		p.link('Dummy Link - $i', '_$i');
		}
		
		// --- done creating page ^^^ --------------------------
		

		// Current selection description
		desc = new FlxText(P.desc.x, P.desc.y, P.desc.width);
		desc.color = P.desc.color;
		add(desc);
		
		// Help box
		box = new InfoBox(P.info.width, P.info.height, P.info.color0, P.info.color1);
			Align.screen(box, "right", "bottom", 6);
		add(box);
		
		// - Footer
		new FooterText();
		
		// --
		menu.showPage("main");
		super.create();
	}//---------------------------------------------------;

	
	// Menu callbacks
	function menuCallbacksMenu(s:String, page:String)
	{
		
		// Page with SID=page just entered 
		if (s == "pageOn")
		{
			// Since current page HAS to be the one firing the callback
			if (menu.currentPage.description != null)
			box.open(menu.currentPage.description);
		}// --
		
		if (s == "pageOff")
		{
			// box.close();
		}// --
		
		// The back button was pressed while on the main menu
		else if (s == "rootback")
		{
			// Go back to the main state
			FlxG.switchState(new State_Selector());
		}
		
		
	}//---------------------------------------------------;
	
	
	// - Menu Item Callbacks
	function menuCallbackItem(s:String, m:MItemData)
	{
		// (m) was just fired, button press or mouse click
		if (s == "fire")
		{
			if (m.SID == "exit")
			{
				FlxG.switchState(new State_Selector());
			}
		}
		
		// (m) was just focused
		// ! Have it work for the first page only 
		else if (s == "focus" && menu.currentPage.SID == "main")
		{
			desc.text = (m.description != null)?m.description:"";
		}
	}//---------------------------------------------------;
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		FLS.debug_keys();
		
		// -- Toggle Focus
		if (FlxG.keys.justPressed.ONE)
		{
			if (menu.isFocused) menu.unfocus(); else menu.focus();
		}
		
		// -- Toggle Open/Closed
		else if (FlxG.keys.justPressed.TWO)
		{
			if (menu.visible) menu.close(); else menu.showPage("main");
		}
		
		// -- Highlight an element at random
		else if (FlxG.keys.justPressed.THREE)
		{
			var max = menu.currentPage.collection.length;
			var sidToFocus = menu.currentPage.collection[Std.random(max)].SID;
			menu.item_highlight(sidToFocus);
		}
		
		// -- Write a random string on the first element
		//    you can change any field of the menu item's data
		else if (FlxG.keys.justPressed.FOUR)
		{
			var rnd = ["Random Text 01", "Just changed", "0000011111", "What", "Hi"];
			menu.item_updateData("main", "rand", {
				label:rnd[Std.random(rnd.length)]
			});
		}
		
		// -- Get an items item data, alter it and write it back
		else if(FlxG.keys.justPressed.FIVE)
		{
			// Get the entire DATA portion of a menu item
			var cb = menu.item_get("main", "it_1");
			// "data" node stores the functional state of the menu item
			// - depending on the item type the field is different or can store other types of data
			// - for a toggle, the current state is stored in "data.current" as a Bool
			var state:Bool = cb.data.current;
			// Write it back
			menu.item_updateData("main", "it_1", {current: !state});
		}
		
		// -- Go back to the first page in the menu history
		else if (FlxG.keys.justPressed.SIX)
		{
			menu.goHome();
		}
		
	
	}//---------------------------------------------------;
	
	
}// --