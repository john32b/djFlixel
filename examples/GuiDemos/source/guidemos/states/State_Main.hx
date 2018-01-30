package guidemos.states;

import common.Common;
import common.FooterText;
import djFlixel.FLS;
import djFlixel.SND;
import djFlixel.gfx.GfxTool;
import djFlixel.gui.FlxMenu;
import flixel.FlxG;
import flixel.FlxState;


/**
 * Menu that selects other states.
 * It extends State_Demo which provides simple initialization methods
 */
class State_Main extends State_Demo
{
	var menu:FlxMenu;
	
	// --
	override public function create():Void
	{
		super.create();
		
		Common.setPixelPerfect();
		
		// --		
		menu = new FlxMenu(P.menu.x, P.menu.y, -1, 10);
		menu.applyMenuStyle(P.menu.style, P.menu.header);
		add(menu);
		
		// --
		var p = menu.newPage("main", {title:"Gui Demo Selection"});
		// -- Pages
		// NOTE: I don't need SID to be set, I will access the state field later
		p.add("FlxAutoText", {type:"link", state:State_FlxAutoText});
		p.add("Panel Pop", {type:"link", state:State_PanelPop});
		p.add("Toast Notifications", {type:"link", state:State_ToastTest});
		p.add("UI Buttons", {type:"link", state:State_UIButtons});
		p.add("VListBase", {type:"link", state:State_VListBase});
		p.add("VListNav", {type:"link", state:State_VListNav});
		
		#if (MEGADEMO)
		p.addBack();
		#end
		
		menu.callbacks = function(a, b, c)
		{
			Common.handleMenuSounds(a);
			
			if (a == "fire" && c.data.state != null) {
				FlxG.switchState(Type.createInstance(c.data.state, []));
			}else
			if (a == "rootback"){
				EXIT();
			}
			
		}// --
		
		// --
		menu.open("main");
	}//---------------------------------------------------;
	
	// --
	override function EXIT() 
	{
		#if (MEGADEMO)
			Common.GOTO_MEGADEMO();
		#end
	}//---------------------------------------------------;
	
}// --