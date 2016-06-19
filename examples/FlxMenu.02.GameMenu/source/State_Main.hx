package ;

import djFlixel.SND;
import djFlixel.fx.StarfieldSimple;
import djFlixel.gui.FlxMenu;
import djFlixel.gui.OptionData;
import djFlixel.gui.PageData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;

/**
 * FlxMenu, Example 02, More advanced use of a menu.
 * Check the previous example if "FlxMenu.01" if you haven't already
 * -----
 * + Multiple pages
 * + Handling Option callbacks
 * + Conditional Options
 * + starfield FX
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
class State_Main extends FlxState
{
	
	// Dummy variable for use in the conditional option later.
	static var HAS_SAVE_DATA:Bool = false;
	
	//---------------------------------------------------;
	// --
	override public function create():Void
	{
		super.create();
		
		// -- Add a basic default starfield FX ::
		var stars = new StarfieldSimple();
		add(stars);
		// --
		
		// -- Create the info box It will display some info about the selected option
		// NOTE: some parameters are stored in "params.json" file
		var box = new FlxSprite(0, 220);
			box.makeGraphic(320, 20, Reg.JSON.box.bg);
		var infoText = new FlxText(box.x + 8, box.y + 4, box.width - 16, "Test info box text");
			infoText.color = Reg.JSON.box.textColor;
		add(box);
		add(infoText);
		// --
		
		// Create the main menu object
		var menu = new FlxMenu(50, 50, 0, 7);
		
		// This menu will be a main menu for a video game.
		var p:PageData;
		
		// The main page
		p = menu.newPage("main");
		
		// NEW ::
		// You can set a title for each page
		p.header = "Main Menu";
		
		// The new game is going to be a simple link button
		p.link("New game", "newgame", "Start a new game!");
		
		
		// VER 0.3. Removed conditionals from FlxMenu.
		// 			I can still have conditionals, but are going to be hand-checked.
		p.add("Resume", { type:"link", sid:"resume", desc:"Resume from where you left off" });
		
		// NEW ::
		// If a link starts with a "@", it will call the menu page with 
		// that ID ( without the @ )
		// The following link, will call the menu page with id=="options"
		p.link("Options", "@options", "Go to the options menu");
		
		// NEW ::
		// Adding a "!" before the sid, will ask the user for a confirmation
		p.link("Quit", "!quit", "Quit to OS");
	
		// - Done creating the main menu

		
		// + Create the options menu
		p = menu.newPage("options");
		p.header = "Options";
		
		// Add some generic options.
		p.add("Antialiasing", { type:"toggle", sid:"aa", desc:"Change the antialiasing" } );
		p.add("Music" , { type:"toggle", sid:"music", desc:"Music on/off" } );
		p.add("Volume", { type:"slider", pool:[0, 10], sid:"vol", desc:"Master volume, 0-10" } );
		p.add("Quality", { type:"oneof", pool:["low", "medium", "high"], sid:"quality", desc:"Quality affects speed" } );
		p.link("Create or Delete a Save Game", "@rstate");

		// NEW::
		// Quickly add a back button,
		// This will go back to the previous page of the menu
		p.addBack();
		
		// - Done creating the options menu
		
		
		// + Create a page that will enable or disable a simulated save game
		//   for demonstrating the "resume game" conditional option
		p = menu.newPage("rstate");
		p.label("Test out the conditional resume option : " );
		p.link("- Save Exists", "sg_yes");
		p.link("- Save Missing", "sg_no");
		
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
				// THIS IS NOT THE PLACE TO HANDLE THE OPTION DATA!
				// Option Callbacks are handled in FlxMenu.callbacks_option;
				// ---
				case "tick" :	   // An option was focused, The cursor moved.
					SND.play("c_tick");
				case "tick_change":// An option value has changed.
					SND.play("c_sel");
				case "tick_fire":  // An option was selected. ( button )
					SND.play("c_sel");
				case "tick_error": // An option that cant be selected or changed
					SND.play("c_err");
			}
		};
		
		// Create Callbacks for the options
		menu.callbacks_option = function(type:String, opt:OptionData) {
			switch(type)
			{
				case "optFocus":
					// An option was just focused.
					// Now it's a good time to update any external info boxes
					// With any help info, Like give a description to what this option does, etc.
					
					infoText.text = (opt.description != null)?opt.description:"";
					
				case "optChange":
					// An option has changed value
					// Possible options that I need to check are
					// Antialiazing, Music, Volume, Quality
					// The opt.SID is the sid I set earlier
					// ! There might be a better way, but I wanted to have everything in one 
					//   function for easiser code maintenance and readability.
					switch(opt.SID) {
						
						// Depending on the type of the option
						// the data needs to be checked accordingly
						
						case "aa":
							// For toggles:
							// (opt.data.current) is the toggled state, true or false
				
							// Just set the AA to the new value;
							Reg.ANTIALIASING = cast opt.data.current;
							
							infoText.text = "Antialiasing " + ((opt.data.current)?"ON":"OFF");
							
						case "music":
							// -- Handle music on/off..
							// ....
							infoText.text = "Music " + ((opt.data.current)?"ON":"OFF");
							
						case "vol":
							// For sliders:
							// (opt.data.current) is the actual value
							// Handle volume ....
							infoText.text = 'Current Volume ${opt.data.current}';
							
						case "quality":
							// For "oneof":
							// (opt.data.current) is the current INDEX of 
							// opt.data.pool[]
							infoText.text = 'Quality set to ${opt.data.pool[opt.data.current]}';
					}
					
				case "optFire":
					// An  option was fired. So far, only links can fire this.
					// I should check for "new game", "resume" and "quit"
					// Again check the opt.SID
					
					switch(opt.SID) {
							case "newgame":
								// .. handle a new game
								// switch to a state, whatever
								infoText.text = "New game";
							case "resume":
								// .. Handle a resume game request
								infoText.text = "Resuming game";
							case "quit":	// NOTE: it's not "!quit", the confirmation ! is removed
								// .. whatever.
								infoText.text = "Quitting";
								
							// -- These will fire from the save game simulation menu:
							case "sg_yes":
								HAS_SAVE_DATA = true;
								menu.option_updateData("main", "resume", { disabled: !HAS_SAVE_DATA } );
								menu.goHome();
								
							case "sg_no":
								HAS_SAVE_DATA = false;
								menu.option_updateData("main", "resume", { disabled: !HAS_SAVE_DATA } );
								menu.goHome();
								
					}
			}//- end switch(type);
		};//--end function
		
		add(menu);
		
		// Show the first page, it will be auto-focused.
		menu.showPage("main");
		
		// -- Check for any conditional options, BEFORE opening the page
		// You can call it everywhere you like
		menu.option_updateData("main", "resume", { disabled: !HAS_SAVE_DATA } );
		
	}//---------------------------------------------------;
	
}// --