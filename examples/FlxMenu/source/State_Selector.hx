package ;

import djFlixel.FLS;
import djFlixel.gui.Align;
import djFlixel.gui.FlxMenu;
import djFlixel.gui.menu.MItemData;
import djFlixel.gui.menu.PageData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;


/**
 * Basic State Selector using an FlxMenu
 * --
 * author: John Dimi
 */
 
class State_Selector extends FlxState
{
	// --
	override public function create():Void
	{
		super.create();
		
		// - Create the simplest menu, no styles just plain
		var m = new FlxMenu(32, 32, 180);
		
		// Change the default style a bit
		m.styleMenu.fontSize = 16;
		m.styleMenu.color_accent = 0xFFE3373C;
		m.styleHeader.textS = {fontSize : 8};
		
		// -- A Menu consists of pages, create a page with an ID of "main"
		//    Also I want to capture it to a var, so I can add elements to it
		var p:PageData = m.newPage("main");
			p.title = "FlxMenu Examples, make a selection";
			
			// -- I can put custom data in the link itself, here I am associating this 
			//    menu item with the state I want to go when it gets selected
			p.add("Simple Game menu", {sid:"state_", type:"link", state:State_GameMenu});
			p.add("Menu features demo", {sid:"state_", type:"link", state:State_MenuDemo1});
			p.add("Menu style generator", {sid:"state_", type:"link", state:State_StyleGen});
			
		// - Handle menu callbacks
		m.callbacks_item = function(id:String, item:MItemData)
		{
			if (id == "fire") // (item) was just clicked/selected
			{
				if (item.SID.indexOf("state_") == 0)
				{
					FlxG.switchState(cast Type.createInstance(item.data.state, []));
				}
			}
		}//--
		
		add(m);
		m.showPage("main");
		
		// -- Info Box
		
		var box = new InfoBox(250, 42);
			Align.screen(box, "center", "bottom", 32);
			add(box);
			
		var str = "Selection of FlxMenu examples. \n" +
			"Use WASD/Arrow Keys to choose" +
			"[K]/[X] to select\n" +
			"Or you can use the Mouse";
		
		box.open(str);
		
		// -- Footer
		new FooterText();
	}//---------------------------------------------------;

}// --