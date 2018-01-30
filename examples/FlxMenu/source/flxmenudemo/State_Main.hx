package flxmenudemo;

import common.Common;
import common.FooterText;
import common.InfoBox;
import djFlixel.FLS;
import djFlixel.SND;
import djFlixel.fx.BoxScroller;
import djFlixel.gui.Align;
import djFlixel.gui.FlxMenu;
import djFlixel.gui.menu.MItemData;
import djFlixel.gui.menu.PageData;
import flixel.FlxG;
import flixel.FlxState;


/**
 * Basic State Selector using an FlxMenu
 * --
 * author: John Dimi
 */
 
class State_Main extends FlxState
{
	// --
	override public function create():Void
	{
		super.create();
		
		camera.bgColor = 0xFF000000;
		
		Common.setPixelPerfect();
		
		// --
		var b = Common.getBGScroller({colorA:0xFF060606, colorB:0xFF45283C, x: -0.2, y:0.2, bg:3});
		add(b);
		
		// - Create the simplest menu, no styles just plain
		var m = new FlxMenu(32, 32, 180);
		
		// Change the default style a bit
		m.styleMenu.fontSize = 16;
		m.styleMenu.color_accent = 0xFFE3373C;
		m.styleHeader.textS = {fontSize : 8};
		
		// -- A Menu consists of pages, create a page with an ID of "main"
		//    Also I want to capture it to a var, so I can add elements to it
		var p:PageData = m.newPage("main");
			p.title = "FlxMenu Examples";
			
			// -- I can put custom data in the link itself, here I am associating this 
			//    menu item with the state I want to go when it gets selected
			p.add("Simple Game menu", {sid:"state_", type:"link", state:State_GameMenu});
			p.add("Menu features demo", {sid:"state_", type:"link", state:State_MenuDemo1});
			p.add("Menu styles demo", {sid:"state_", type:"link", state:State_StyleGen});
			
			#if (MEGADEMO)
			p.addBack();
			#end
			
		// - Handle menu callbacks
		// --
		m.callbacks = function(id:String, data:String, item:MItemData)
		{
			Common.handleMenuSounds(id);
			
			if (id == "fire") // (item) was just clicked/selected
			{
				if (item.SID.indexOf("state_") == 0)
				{
					FlxG.switchState(cast Type.createInstance(item.data.state, []));
				}
			}
			#if (MEGADEMO)
			else if (id == "rootback") EXIT();
			#end
		}//--
		
		add(m);
		m.open(); // With no parameters, will open the first static page
		
		// -- Info Box
		
		var str =   "Selection of $FlxMenu examples$. \n" +
					"Use #WASD/Arrow Keys# to choose, " +
					"#[K]/[X]# to select, #[ESC]# to go back. " +
					"You can also use the #mouse# , $wheel$ to scroll, $click$ to select.\n" +
					"Be sure to check the $source code$ of the examples.";
					
		var box = new InfoBox(str, { width:260, padOut:24 });
		box.open();
		
		// -- Footer
		new FooterText({align:"right-bottom", pad: -2});
	}//---------------------------------------------------;
	
	
	#if (MEGADEMO)
	// --
	function EXIT()
	{
		Common.GOTO_MEGADEMO();
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.ESCAPE)
		{
			EXIT();
		}
	}//---------------------------------------------------;
	
	#end
	
}// --