package flxmenudemo;

import common.Common;
import common.FooterText;
import common.InfoBox;
import djFlixel.FLS;
import djFlixel.fx.BoxScroller;
import djFlixel.gfx.Palette_DB32 as DB32;
import djFlixel.gui.Align;
import djFlixel.gui.FlxMenu;
import djFlixel.gui.Gui;
import djFlixel.gui.Styles;
import djFlixel.gui.menu.MItemData;
import djFlixel.gui.menu.PageData;
import djFlixel.tool.DataTool;
import flixel.FlxG;
import flixel.FlxState;


/**
 * FlxMenu Example : Style Parameters Generator
 * ---------------------------------------
 * 
 * - Dynamically create styles on the fly
 * - Showcase the various styling capabilities
 * 
 * @author JohnDimi
 */
 
class State_StyleGen extends FlxState
{
	// Parameters object
	var P:Dynamic;
	
	// One menu to choose the styles
	var menu1:FlxMenu;
	// One menu to apply the styles to
	var menu2:FlxMenu;
	// --
	var infoB:InfoBox;
	// --
	// Only visible on menu 1;
	var boxsc:BoxScroller;
	override public function create():Void
	{
		super.create();
		
		// Copy and translate colors for deskop targets
		P = DataTool.copyFieldsC(FLS.JSON.STATE_STYLEGEN);
		camera.bgColor = P.colorBG;
		
		var p:PageData;
		
		boxsc = Common.getBGScroller(P.boxscroller);
		add(boxsc);
		
		// Main Menu
		//====================================================;
		menu1 = new FlxMenu(P.mainmenu.x, P.mainmenu.y, -1, P.mainmenu.slots);
		menu1.applyMenuStyle(P.mainmenu.style);
		menu1.callbacks = menuCallbacks;
		add(menu1);
		
		// -- Page Main  ----------
		p = menu1.newPage("main", {title:"FlxMenu Theming Demos"});
		p.custom.styleMenu = { fontSize : 16, color_accent:0xFF64CF23 };
		p.link("Style example 01", "s_1", "Custom Colors, Font, Header, Slots, Icon Size, Elements enter/exit animation. Check '#params.json'# node $'STYLE_01'$" );
		p.link("Style example 02", "s_2", "Alignment, no cursor, text icons, etc. Check #'params.json'# node $'STYLE_02'$");
		p.link("Style example 03", "s_3", "Custom cursor , custom icons ,icon size, Scrolling indicator, Check #'params.json'# node $'STYLE_03'$");
		p.link("Create a style", "@create", 
			"$Create$ a menu style on the fly. Not all #style options# are available here, be sure to check the $source files!$");
		p.link("Return", "mainmenu", "Go back to the $FlxMenu Selector$");
		
		//-- Dynamic Style Page  ----------
		p = menu1.newPage("create", {
			title:"Interactively create a menu style",
			width:200
		});
		p.custom.styleMenu = {
			fontSize : 8, 
			color_accent:DB32.COL[29],
			alignment:"justify"
		};
		p.add("Slots", {sid:"slots", type:"slider", desc:"Number of slots", pool:[2, 10], current:8 });
		p.add("Font", {sid:"font", type:"oneof", desc:"Choose a font", pool:["Default", "Amstrad", "pixelArial"] });
		p.add("Font Size", {sid:"size", type:"oneof", desc:"Choose a fontsize", pool:["8", "12", "14", "16", "24", "32"]});
		p.add("Color", {sid:"color", type:"slider", pool:[0, 31], current:22, desc:"Text Color, #DB32# palette index"});
		p.add("Color Border", {sid:"color_border", type:"slider", pool:[0, 31], current:2, desc:"Text Border Color, #DB32# palette index"});
		p.add("Border Size", {sid:"borderSize", type:"slider", pool:[ -1, 4], current: -1, desc:"Border Size, -1 for automatic"});
		p.add("Color Focused", {sid:"color_focused", type:"slider", pool:[0, 31], current:8, desc:"Focused item color, #DB32# palette index"});
		p.add("Color Accent", {sid:"color_accent", type:"slider", pool:[0, 31], current:5, desc:"Accent Color, #DB32# palette index"});
		p.add("Color Disabled", {sid:"color_disabled", type:"slider", pool:[0, 31], current:25, desc:"Disabled Color, #DB32# palette index"});
		p.add("Color Disabled Focused", {sid:"color_disabled_f", type:"slider", pool:[0, 31], current:26, desc:"Disabled focused Color, #DB32# palette index"});
		p.add("El Scroll Time", {sid:"el_scroll_time", type:"slider", pool:[0, 2], inc:0.1, current:0.2, desc:"How fast to scroll elements in and out, 0 for instant scroll"});
		p.add("Alignment", {sid:"alignment", type:"oneof", pool:["left", "right", "center", "justify"], desc:"Menu Items alignment"});
		p.add("Focus Nudge", {sid:"focus_nudge", type:"slider", pool:[0, 16], current:4, desc:"How many pixels to the right to animate the highlighted element"});
		p.add("Loop at edges", {sid:"loop_edge", type:"toggle", desc:"Loop at edges when going up or down"});
		p.add("Disable Cursor", {sid:"cursorDisable", type:"toggle", desc:"Disable a cursor symbol"});
		p.link("CREATE -->", "create", "$Create$ a menu with the #above settings#");
		p.link("info", "info", "There are #MORE# styling options available, checkout the $source code and comments$, file #`Styles.hx`#");
		p.addBack();
		
		
		// -- InfoBox, prints out descriptions for options
		//====================================================;
		// --
		infoB = new InfoBox("", P.infoBox);
		// --
		new FooterText(P.footer);
		
		// --
		showMenuOne("main");
	}//---------------------------------------------------;
	
	
	
	// -- Generate a style object from the style generator page
	//    ready to be passed to the showMenuWithStyle() function
	function getStyleFromPage()
	{
		// Since this is called from the menu, currentPage is guarenteed to be the one I want
		var page = menu1.currentPage;
		var fnt:String = 
		switch(page.get("font").get()) { default: null;
			case "Mozart": "fonts/mozart";
			case "PixelArial" : "fonts/pixelarial";
		};
		
		var s = {
			x:60, y:40, slots: page.get("slots").get(),
			menu:{
				font : fnt,
				fontSize: Std.parseInt(page.get("size").get()),
				border_size: page.get("borderSize").get(),
				color: DB32.COL[page.get("color").get()],
				color_border: DB32.COL[page.get("color_border").get()],
				color_focused: DB32.COL[page.get("color_focused").get()],
				color_accent: DB32.COL[page.get("color_accent").get()],
				color_disabled: DB32.COL[page.get("color_disabled").get()],
				color_disabled_f: DB32.COL[page.get("color_disabled_f").get()],
				
				el_scroll_time: page.get("el_scroll_time").get(),
				alignment: page.get("alignment").get(),
				focus_nudge: page.get("focus_nudge").get(),
				loop_edge: page.get("loop_edge").get(),
				
				cursor:{
					disable: page.get("cursorDisable").get()
				}
			}
		};
		
		return s;
	}//---------------------------------------------------;
	
	
	// -- Menu item Callbacks for the first menu
	function menuCallbacks(s:String, d:String, m:MItemData)
	{
		
		if (s == "fire") switch(m.SID){ default:
			case "mainmenu": GO_BACK();
			case "s_1": showMenuWithStyle(P.STYLE_01);
			case "s_2": showMenuWithStyle(P.STYLE_02);
			case "s_3": showMenuWithStyle(P.STYLE_03);
			case "create": showMenuWithStyle(getStyleFromPage());
		}
		
		else if (s == "focus") // Update the infoB
		{
			if (m.description != null) {
				infoB.setText(m.description);
			}else{
				infoB.setText("");
			}
		}
		
		else if (s == "rootback") GO_BACK();
			
		Common.handleMenuSounds(s);
	}//---------------------------------------------------;
		
	
	/**
	 * Create a page, style it and show it on menu 2
	 * @param	style
	 */
	function showMenuWithStyle(style:Dynamic,?headerStyle:Dynamic)
	{
		
		menu1.close(true);
		infoB.visible = false;
		
		boxsc.active = false;
		boxsc.visible = false;
		
		
		if (menu2 != null) {
			menu2.destroy();
		}
		
		menu2 = new FlxMenu(style.x, style.y, -1, style.slots);
		menu2.applyMenuStyle(style.menu, style.header);
		menu2.callbacks = function(a, b, c){
			if (a == "rootback") GO_BACK(); 
			else if (a == "focus" && c.description != null) {
				infoB.setText(c.description);
			}			
		}
		// --
		var p:PageData;
			p = menu2.newPage("main", {title:"Demo Style"});
			p.label("Unselectable");
			p.link("Function Link");
			p.link("Goto page", "@page2");
			p.add("Toggle", {type:"toggle"});
			p.add("Disabled", {type:"toggle",disabled:true});
			p.add("Slider", {type:"slider", pool:[0, 10]});
			p.add("Selector", {type:"oneof", pool:["One", "Two", "Three", "etc"]});
			p.addBack();// Auto fires "rootback" because there is no history
			
		//--
		p = menu2.newPage("page2");
			p.label("Second Page");
			p.link("Function Link 2");
			p.add("Toggle 1", {type:"toggle"});
			p.add("Toggle 2", {type:"toggle"});
			p.addBack();
		
		add(menu2);
		menu2.open("main");
	}//---------------------------------------------------;
	
	// -- Called when closing the styled menu
	function showMenuOne(page:String = null)
	{
		infoB.open();
		menu1.open(page);
		boxsc.active = true;
		boxsc.visible = true;
	}//---------------------------------------------------;

	
	// --
	function GO_BACK()
	{
		if (menu1.visible)
		{
			FlxG.switchState(new State_Main());
		}	
		else if (menu2 != null && menu2.visible)
		{
			remove(menu2);
			showMenuOne();
		}
		
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		FLS.debug_keys();
		
		super.update(elapsed);
		
		// Return to the megademo menu on esc key
		if (FlxG.keys.justPressed.ESCAPE) 
		{
			GO_BACK();
		}
		
	}//---------------------------------------------------;
}// --