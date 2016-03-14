package ;

import djFlixel.gui.FlxMenu;
import djFlixel.gui.OptionData;
import djFlixel.gui.PageData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

/**
 * Simplest application of an FlxMenu
 * ...
 */
class State_Main extends FlxState
{
	
	// --
	override public function create():Void
	{
		super.create();
		
		// Create a menu at x:20, y:20, autoWidth, with 4 slots of options 
		// The menu will use the default style for menus
		var menu = new FlxMenu(20, 20, 0, 7);
	
		// Create some pages for the menu:
		// A page is a collection of options, ( links to other pages , sliders, buttons )
		
		// A pageData is an object holding all the child options and other parameters for the page
		// I am creating a pointer to a pageData object, to get the autocompletion
		var p:PageData;
	
		// This is a quick way to get a page and add it to the menu with one call
		// "main" is the unique name of the page
		p = menu.newPage("main");
	
		// ^ It is the same as this:
		//   p = new PageData("main");
		//   menu.addPage(p);
	
		// + I have created a page but it's empty, Fill it with some data

		// . A page holds options
		// . An option can have one of the following types:
		// 		"link", "slider", "oneof", "toggle", "label"
		// . Every option has a label
		
		// parameter 1 is the label
		// parameter 2 is a dyn object for parameters like ( sid, desc, selectable, disabled )
		//    check OptionData.hx for more info
	
		// A simple label, labels are unselectable by default.
		p.add("Label", { type:"label" } );
		// A link to another page of custom user function.
		// Needs to have an SID ( string ID )
		p.add("Option 1, Link", { type:"link", sid:"opt1" } );
		// Another way to quickly add a link 
		p.link("Option 2, link", "opt2");
		
		// Add more stuff --
		
		// TYPE:toggle,
		p.add("Toggle Switch", { type:"toggle" } );
		
		// TYPE:OneOf , options go into the field called "pool"
		p.add("OneOf Option", { type:"oneof", pool:["one", "two", "three"] } );
		
		// Or unselectabled, can't even be selected
		p.add("This is unselectable!", { type:"oneof", selectable:false, pool:["one", "two", "three"] } );
		
		// TYPE:slider , Min and Max go to the pool field.
		p.add("Numbers", { type: "slider", pool:[1, 20] } );
		
		// You can have options that are disabled, that can be selected but not triggered 
		p.add("Link Disabled", { type:"link", disabled:true } );
		
		// ------
		// I have added some options to the page, now to set up the feedback.
		// There are 2 callbacks that push data to the user
		
		// Callbacks_menu pushes Status Messages related to the menu
		// Like a new page going in, or going back etc.
		menu.callbacks_menu = function(type:String, data:String) {
			// Worry about it at a later demo
		};
		
		// callbacks_option, pushes info related to options
		// Like an option was selected, changed or Focused.
		menu.callbacks_option = function(type:String, opt:OptionData) {
			// data:optionData holds the entire data portion of the related option
			// Like sid,uid,label,data, everything I need.
			// the ONLY 3 types that could fire are:
			switch(type)
			{
				// This option was just focused by the cursor
				case "optFocus":  
					trace('Option (${opt.label}) focused');
					
				// The value of this option was just changed by the user
				case "optChange": 		
					trace('Option (${opt.label}) data changed');
					// How to get the data is opt.data.current, but save for later example
					
				// This option has just been selected, link, or button.
				case "optFire": 
					trace('Option (${opt.label}) Selected');
			}
		};
		
		// Add the menu object to the state
		add(menu);
		// And just tell it to show the page you just created
		menu.showPage("main");
		// And give it focus, so that it is controllable
		menu.focus();
		// ^ or you could just do:
		// menu.showPage("main", true);
		
		// That's it!
		// FlxMenu is responsible for the controls, it uses the Controls.hx Class
		// Also supports game controllers by default
		
		// For more advanced features check the next (upcoming) samples
		// Cheers
	}//---------------------------------------------------;
	
}// --