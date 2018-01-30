package guidemos.states;

import djFlixel.CTRL;
import djFlixel.FLS;
import djFlixel.SND;
import djFlixel.gfx.Palette_DB32 as DB32;
import djFlixel.gui.Gui;
import guidemos.ListItem;
import djFlixel.gui.list.VListBase;


/**
 * Simple VListBase use example
 */
class State_VListBase extends State_Demo
{
	
	var list:VListBase<ListItem,String>;
	
	// --
	override public function create():Void 
	{
		super.create();
		
		// Create the list
		list = new VListBase<ListItem,String>(ListItem, 112, 42, 160);
		add(list);
		
		list.setDataSource(["One", "Two", "Three", "Four", "Five", "Six"]);
		list.onScreen();
		
		// --
		add(Gui.getQText("Vertical List Base", 8, 0xFF00FFFF, -1, list.x, list.y - 10));

	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (CTRL.justPressed(CTRL.DOWN))
		{
			if (list.scrollDownOne()) SND.play('c_sel');
		}
		else if (CTRL.justPressed(CTRL.UP))
		{
			if (list.scrollUpOne()) SND.play('c_sel');
		}
	}//---------------------------------------------------;

}// --
