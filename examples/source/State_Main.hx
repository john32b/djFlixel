package;

import djFlixel.FlxAutoText;
import djFlixel.fx.RainbowBorder;
import djFlixel.fx.StarfieldSimple;
import djFlixel.gfx.Palette_DB32;
import djFlixel.gui.FlxMenu;
import djFlixel.gui.OptionData;
import djFlixel.gui.PageData;
import djFlixel.gui.Styles;
import djFlixel.gui.Styles.OptionStyle;
import djFlixel.gui.Toast;
import djFlixel.SND;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;


/**
 * djFlixel Tools examples
 * -----------------------
 * Main Menu
 * 
 */
class State_Main extends FlxState
{
	// Animated backgrounds
	var bg:FlxBackdrop;
	var rainb:RainbowBorder;
	var starf:StarfieldSimple;
	
	// -
	var menu:FlxMenu;	
	// Change the name!
	var toast:Toast;
	
	// * Pointer to the list of background tiles, set on params.json
	var tileBG_Files:Array<String>;
	// Current index in tileBG_Files
	var tileBG_Current:Int = 0;
	
	// Every menu page is associated to an object background
	var mapToBG:Map<String,FlxSprite>;
	// * Pointer to the current active background
	var BgObjCurrent:FlxSprite = null;
	
	var toastDemoText:Array<String>;
	
	var toastCurrent:Int = 0;
	
	// Know if this is the first time showing this state
	// Whenever a state goes back to this, skip showing the instructions
	static var firstTimeShowing:Bool = true;

	//====================================================; 
	// --
	override public function create():Void
	{
				
		super.create();
	
		// - Create the animated backgrounds
		tileBG_Files = Reg.JSON.tilesBG;
		bg = new FlxBackdrop(tileBG_Files[tileBG_Current]);
		bg.velocity.set(-8, 12.2);	// random speed
		add(bg);

		rainb = new RainbowBorder();
		rainb.setPredefined(0);
		add(rainb);
		
		starf = new StarfieldSimple();
		starf.setDirection(45);
		add(starf);
		
		// Map menuPageSID to background objects
		// Every time the menu displays a page
		// the associated object is displayed.
		mapToBG = [
			"main" => bg,
			"rainbow" => rainb,
			"starfield" => starf,
			"settings" => bg
		];
		
		// Initialize the objects
		for (i in mapToBG) {
			add(i);
			i.visible = false;
			i.active = false;
		}
		
		// -- Create the main menu
		menu = new FlxMenu(20, 40, 0, 5);
		
		// These parameters are going to be applied to all the pages
		// unless overrided by a page.
		menu.callbacks_menu = callbacks_menu;
		menu.callbacks_option = callbacks_option;
		menu.styleOption.fontSize = 8;
		menu.styleOption.border_color = Palette_DB32.COL[3];
		menu.styleOption.color_default = Palette_DB32.COL[21];
		menu.styleOption.color_accent = Palette_DB32.COL[29];
		menu.styleOption.color_disabled = Palette_DB32.COL[4];
		menu.styleHeader.color_default = Palette_DB32.COL[18];
		
		// Temp pointer to the current page that is being edited;
		var p:PageData;
		
		// == Menu Main Page
		// ------------------------------------------
		
		// This creates a new page with SID="main", 
		// adds it to the menu and returns the object.
		p = menu.newPage("main");
		// Optional parameter, This is the page's title header text.
		p.header = '${Reg.NAME} - ${Reg.VERSION}';
		p.link("Rainbow Border", "@rainbow", "Rainbow Demo");
		p.link("Starfield", "@starfield", "Starfield Demo");
		p.link("Menu Demo", "@menudemo", "FlxMenu Demo");
		p.link("Notification Demo", "toast", "Fire a random toast notification");
		p.add("Grid navigation Demo (soon)", { type:"link", sid:"grid", disabled:true,
						desc:"Fully Customizable grid system navigation for inventories"} );
		p.link("Dialog box Demo", "dialog", "Dialog box that is fully customizable");
		p.link("Settings", "@settings", "Settings menu");
		// --
		p = menu.newPage("rainbow");
		p.header = "Rainbow Example";
		p.add("Predefined style", { sid:"rslider", type:"slider", pool:[0, 3], desc:"Cycle through the predefined styles" } );
		p.addBack(); // Quick way to add a "back" button to the page.
		// --
		p = menu.newPage("starfield");
		p.header = "Starfield Example";
		p.link("Randomize", "star_random", "Randomize colors and WidePixel");
		p.addBack();
		// --
		p = menu.newPage("settings");
		p.header = "Settings";
		p.add("Antialiasing", { type:"toggle", current:Reg.ANTIALIASING, sid:"aa" } );
		p.add("BG Texture", { sid:"bg", type:"slider", desc:"Change the background tile image",
							  pool:[0, tileBG_Files.length - 1], current:tileBG_Current } );
		p.addBack();
			
		
		// == Menu Demo Page
		// --------------------------------
		
		p = menu.newPage("menudemo");
		// This page will be displayed using 10 slots, to avoid scrolling
		p.custom.slots = 10;
		p.header = "FlxMenu Demo";
		// Add a custom callback handler for this page only
		p.custom.callbacks_option = callbacks_menudemo;
		// This option will start UNCHECKED, (current:false)
		p.add("Toggle Option", { type:"toggle", current:false, sid:"tog1" } );
		// Labels are unselectable by default
		p.add("Text Label", { type:"label" } );
		// This option will start CHECKED, { current:true }
		p.add("A disabled element", { type:"toggle", current:true, sid:"tog2", disabled:true } );
		p.add("OneOf Option", { type:"oneof", pool:["red", "green", "blue"], sid:"oneof1" } );
		p.add("Number Ranger", { type:"slider", pool:[50, 60], current:55, sid:"slider1" } );
		// the @ tells the menu to go to the page with SID=="menupage2"
		p.link("MenuPage with custom style", "@menupage2");
		p.add("Dynamically selectable", { type:"toggle", selectable:false, sid:"stog1" } );
		p.add("Toggle selectable ^", { type:"toggle", sid:"stog", current:false } );
		p.addBack();
			
		
		// == Menu Style Demo Page
		// --------------------------------------
		
		// - Create a new page with different styling
		p = menu.newPage("menupage2");
		p.header = "Custom Styling";
		// Add a custom option callback function
		p.custom.callbacks_option = function(s:String, o:OptionData) {
			if (s == "optFire") {
				toast.fire(o.label);
			}
		};

		// -- You can modify the style of a menu page
		//    like the colors, fonts, and even some animation parameters.
		//    Check Styles.hx for more info
		
		// I am creating the style objects so that I can
		// get autocompletion on the objects.
		var os:OptionStyle = Styles.newStyle_Option();
			os.font = "assets/pixelarial.ttf";
			os.fontSize = 16;
			os.color_focused = Palette_DB32.COL_10;
			os.color_default = Palette_DB32.COL_30;
			os.useBorder = false;
		var ls:VListStyle = Styles.newStyle_List();
			ls.cursorSymbol = "+";
			ls.scrollPad = 1;
		var bs:VBaseStyle = Styles.newStyle_Base();
			bs.anim_start_x = 60;
			bs.anim_end_x = 0;
			bs.anim_start_y = 0;
			bs.anim_end_y = 0;
			bs.anim_time_between_elements = 0.12;
			bs.anim_style = "parallel";
			
		// Then I assign the styles I created to the page.custom dynamic var
		// You could create the styles directly to page.custom
		// but you'd lose the autocompletion.
		
		p.custom.styleOption = os;
		p.custom.styleList = ls;
		p.custom.styleBase = bs;
		p.custom.slots = 3;
		
		// Just add a few call buttons.
		p.link("Link one", "fn1");
		p.link("Link two", "fn2");
		p.link("Link three", "fn3");
		p.link("Link four", "fn4");
		p.add("Toggle test", { type:"toggle" } );
		p.add("Selection test", { type:"oneof", pool:["opt 1", "opt 2", "opt 3"] } );
		p.addBack(); 

		// - Done creating menus, add it to the stage.
		add(menu);
		
		// - This will animate the menu in and focus it.
		menu.showPage("main");
		
		// - Extra display info
		create_footer_box();
		
		// == Creates a notification toast, for displaying quick info
		// ------------------------------------
		toastDemoText = Reg.JSON.toastdemo;
		toast = new Toast(100, "top", "right");
		add(toast);
				
		if (firstTimeShowing) {
			toast.fire("#WASD# - move\n#K# - select\n#J# - cancel", 16, "bottom", "right");
			firstTimeShowing = false;
		}
	}//---------------------------------------------------;
	
	var footerText:FlxAutoText;
	// -- Add a footer box for displaying general info
	// -- $param HEIGHT, The box is always going to be aligned 
	//	  at bottom,using this HEIGHT
	function create_footer_box(HEIGHT:Int = 16)
	{
		var startY = FlxG.height - HEIGHT;
		var textPadding = 2;	// padding from the edges
		
		var bgBox = new FlxSprite(0, startY);
		bgBox.makeGraphic(FlxG.width, HEIGHT, Palette_DB32.COL_22);
		bgBox.alpha = 0.85;
		add(bgBox);
		
		footerText = new FlxAutoText(textPadding, startY + textPadding, FlxG.width - (textPadding * 2));
		footerText.setSpeed(0.03, 2);
		footerText.color = Palette_DB32.COL_26;
		add(footerText);
	}//---------------------------------------------------;
	
	// --
	// MainMenu general callbacks
	function callbacks_menu(status:String, data:String)
	{
		switch(status) {
			case "pageOn" : 
				showBGWithID(data);
				SND.play("c_sel");
				
			// Sound Effects :
			case "tick" :
				SND.play("c_tick");
			case "tick_change" | "tick_fire":
				SND.play("c_sel");
			case "back":
				SND.play("c_back");
			case "tick_error":
				SND.play("c_err");
		}
	}//---------------------------------------------------;
	
	// --
	// MainMenu option elements callbacks
	function callbacks_option(status:String, opt:OptionData)
	{
		switch(status)
		{
			// Fired everytime an option changed values
			case "optChange":
				switch(opt.SID) {
				// Antialiasing toggle
				case "aa":	 Reg.ANTIALIASING = !Reg.ANTIALIASING;
				// Background selector
				case "bg":	 bg.loadGraphic(tileBG_Files[cast opt.data.current]);
				}
				
			// Fired everytime an option is focused
			case "optFocus":
				footerText.start(opt.description != null? opt.description : "");
				
			// Fired when an option is selected.
			case "optFire":
				switch(opt.SID) {
				// Randomize stars
				case "star_random":
					starf.setSpeed(FlxG.random.float(0.3, 1.5));
					starf.setDirection(FlxG.random.int(0, 360));
					starf.numberOfStars = FlxG.random.int(150, 900);
					starf.flag_widepixel = FlxG.random.bool();
					starf.color_bg = Palette_DB32.getRandomColor();
					starf.color_1 = Palette_DB32.getRandomColor();
					starf.color_2 = Palette_DB32.getRandomColor();
					starf.color_3 = Palette_DB32.getRandomColor();
				// Change background image
				case "rslider":
					rainb.setPredefined(cast opt.data.current);
				
				// Fire a toast notification
				case "toast":
					toast.fire(toastDemoText[toastCurrent]);
					toastCurrent++;
					if (toastCurrent >= toastDemoText.length) {
						toastCurrent = 0;
					}	
				
				// Go to the dialog demo State
				case "dialog":
					FlxG.switchState(new State_Dialog());
				}
		}// end switch
		
	}//---------------------------------------------------;
	
	// --
	// Custom callbacks for the menudemo pages.
	function callbacks_menudemo(status:String, opt:OptionData)
	{
		footerText.start(opt.data.current != null?("Data set to : " + opt.data.current) : "");
		
		if (opt.SID == "stog" && status == "optChange")
		{
			menu.option_setEnabled("stog1", opt.data.current);
		}
	}//---------------------------------------------------;
	// --
	// Show the background object associated with bgID,
	// Auto hides the previous one.
	function showBGWithID(bgID:String)
	{
		if (mapToBG.exists(bgID)) 
		{
			var s:FlxSprite = mapToBG.get(bgID);
			
			if (BgObjCurrent != null && BgObjCurrent != s)
			{
				BgObjCurrent.visible = false;
				BgObjCurrent.active = false;
			}
			
			s.visible = true;
			s.active = true;
			
			BgObjCurrent = s;
		}
	}//---------------------------------------------------;
	
}// --