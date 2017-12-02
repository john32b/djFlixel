package ;

import djFlixel.FLS;
import djFlixel.SND;
import djFlixel.fx.StarfieldSimple;
import djFlixel.gui.FlxMenu;
import djFlixel.gui.menu.MItemData;
import djFlixel.gui.menu.PageData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;


/**
 * FlxMenu Example : Simple Game Menu
 * 
 * -----
 * 
 * + Multiple pages
 * + Handling MenuItem callbacks
 * + Conditional MenuItems
 * + Starfield FX on the background
 * 
 * ------
 * 
 * This example will create a simple game menu
 * The structure of the menu:
 *  
 *	- new game 
 *  - resume (conditional)
 *  - option -
 *           |- antialiasing (toggle)
 *           |- music (toggle)
 *           |- volume (1-10)
 *           |- quality (low,medium,high)
 *           |- back
 *  - quit
 */

 
class State_GameMenu extends FlxState
{
	// Dummy variable for use in the conditional menuItem later.
	static var HAS_SAVE_DATA:Bool = false;
	
	//---------------------------------------------------;
	// --
	override public function create():Void
	{
		super.create();
			
		// -- Add a basic default starfield FX for eye candy
		var stars = new StarfieldSimple();
			add(stars);
		
		// -- Create the info box It will display some info about the selected menuItem
		var box = new FlxSprite(0, 220);
			box.makeGraphic(320, 20, 0xFFFFFFFF);
			add(box);
			
		// -- 
		var infoText = new FlxText(box.x + 8, box.y + 4, box.width - 16, "Test info box text");
			infoText.color = 0xFFAAAAAA;
			add(infoText);
		
		
		// --
		// Create the main menu
		// 7 Slots means that 7 item slots are going to be visible at all times with no scrolling
		var menu = new FlxMenu(50, 64, 200, 7);
		
		// -- Override some menu style parameters
			menu.styleHeader.deco_line = 3;			// Make the deco line thicker
			menu.styleHeader.textS = {fontSize:16};	// Make the title bigger, Note I need to create the object.
			
		
		// A pointer to quickly capture the pagedata and work with it
		var p:PageData;
		
		// Create, The main page, returns the pagedata object
		p = menu.newPage("main");
		
		// You can set a title for each page
		p.title = "Main Menu";
		// The new game is going to be a simple link button
		p.add("New game", { type:"link", sid:"newgame", desc:"Start a new game!" } );
		// This menuItem will be checked later and set to disabled/enabled depending on save data 
		p.add("Resume", { type:"link", sid:"resume", desc:"Resume from where you left off" });
		// If a link starts with a "@", it will call the menu page with that ID ( without the @ )
		// The following link, will call the menu page with id=="options"
		p.add("Options", { type:"link", sid:"@options", desc:"Go to the options menu" } );
		// Adding a "!" before the sid, will ask the user for a confirmation
		p.add("Quit", { type:"link", sid:"!quit", desc:"Quit to OS" } );
		// - Done creating the main menu --------^
		
		// + Create the options menu
		p = menu.newPage("options");
		p.title = "Options";
		// Add some generic Menu Items
		p.add("Antialiasing", { type:"toggle", sid:"aa", desc:"Change the antialiasing" } );
		p.add("Music" , { type:"toggle", sid:"music", desc:"Music on/off" } );
		p.add("Volume", { type:"slider", pool:[0, 10], sid:"vol", desc:"Master volume, 0-10" } );
		p.add("Quality", { type:"oneof", pool:["low", "medium", "high"], sid:"quality", desc:"Quality affects speed" } );
		p.link("Create or Delete a Save Game", "@rstate");

		// Quickly add a back button, This will go back to the previous page of the menu
		p.addBack();
		
		
		// + Create a page that will enable or disable a simulated save game
		//   for demonstrating the "resume game" conditional menu item
		p = menu.newPage("rstate");
		p.label("Test out the conditional resume item : " );
		p.link("- Save Exists", "sg_yes");
		p.link("- Save Missing", "sg_no");
		
		// - Done creating the menu ---- ^
				
		// + Add callbacks to the menu
		
		// You can customize the flxMenu further by adding custom code
		// to generic events:
		menu.callbacks_menu = function(type:String, data:String) {
			switch(type)
			{
				case "back":
					// The menu went back a page
					// ...
					
					// NOTE:
					// SND.play("xx"); will play a sound that was autoloaded before
					// The xx is the ID of the sound
					// Sounds are declared on "params.json".
					SND.play("c_back");
					
				case "rootback":
					// The menu wants to go back from the root page
					// You could go back to a title screen or exit alltogether, etc
				case "open":
					// The menu was just opened
				case "close":
					// The menu was just closed
				case "pageOn":
					// The page with SID == data just entered
					SND.play("c_sel");
				case "pageOff":
					// The page with SID == data just left
				
				// -- 
				// The following types are mainly for sound effects:
				// Item Callbacks are handled in FlxMenu.callbacks_item;
				// ---
				case "tick" :	   // An item was focused, The cursor moved.
					SND.play("c_tick");
				case "tick_change":// An item value has changed.
					SND.play("c_sel");
				case "tick_fire":  // An item was selected. ( button )
					// SND.play("c_sel");
				case "tick_error": // An item that cant be selected or changed
					SND.play("c_err");
			}
		};
		
		// Create Callbacks for menu items
		menu.callbacks_item = function(type:String, item:MItemData) {
			switch(type)
			{
				case "focus":
					// A menu item was just focused.
					// Now it's a good time to update any external info boxes
					// With any help info, Like give a description to what this menu item does, etc.
					
					infoText.text = (item.description != null)?item.description:"";
					
				case "change":
					// A menu item has changed value
					// Possible menu items that I need to check are
					// Antialiazing, Music, Volume, Quality
					// The item.SID is the sid I set earlier
					// ! There might be a better way, but I wanted to have everything in one 
					//   function for easiser code maintenance and readability.
					switch(item.SID) {
						
						// Depending on the type of the item
						// the data needs to be checked accordingly
						
						case "aa":
							// For toggles:
							// (item.data.current) is the toggled state, true or false
				
							// Just set the AA to the new value;
							FLS.ANTIALIASING = cast item.data.current;
							
							infoText.text = "Antialiasing " + ((item.data.current)?"ON":"OFF");
							
						case "music":
							// -- Handle music on/off..
							// ....
							infoText.text = "Music " + ((item.data.current)?"ON":"OFF");
							
						case "vol":
							// For sliders:
							// (item.data.current) is the actual value
							// Handle volume ....
							infoText.text = 'Current Volume ${item.data.current}';
							
						case "quality":
							// For "oneof":
							// (item.data.current) is the current INDEX of 
							// item.data.pool[]
							infoText.text = 'Quality set to ${item.data.pool[item.data.current]}';
					}
					
				case "fire":
					// An menu item was fired. So far, only links can fire this.
					// I should check for "new game", "resume" and "quit"
					// Again check the item.SID
					
					switch(item.SID) {
							case "newgame":
								// .. handle a new game
								// switch to a state, whatever
								infoText.text = "New game";
							case "resume":
								// .. Handle a resume game request
								infoText.text = "Resuming game";
							case "quit":	
								// NOTE: it's not "!quit", the confirmation ! is removed
								infoText.text = "Quitting";
								FlxG.switchState(new State_Selector());
								
							// -- These will fire from the save game simulation menu:
							case "sg_yes":
								HAS_SAVE_DATA = true;
								menu.item_updateData("main", "resume", { disabled: !HAS_SAVE_DATA } );
								menu.goHome();
								
							case "sg_no":
								HAS_SAVE_DATA = false;
								menu.item_updateData("main", "resume", { disabled: !HAS_SAVE_DATA } );
								menu.goHome();
								
					}
			}//- end switch(type);
		};//--end function
		
		add(menu);
		
		// Show the first page, it will be auto-focused.
		menu.showPage("main");
		
		// -- Check for any conditional menu items, BEFORE opening the page
		// You can call it everywhere you like
		menu.item_updateData("main", "resume", { disabled: !HAS_SAVE_DATA } );
		
	}//---------------------------------------------------;
	
}// --