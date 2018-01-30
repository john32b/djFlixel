package guidemos.states;

import djFlixel.CTRL;
import djFlixel.FLS;
import djFlixel.SND;
import djFlixel.gfx.Palette_DB32 as DB32;
import djFlixel.gui.Gui;
import djFlixel.gui.list.VListNav;
import flixel.FlxSprite;


/**
 * Simple VListNav use example, 
 * A VLIstNAv adds item navigation and interaction.
 * 
 */
class State_VListNav extends State_Demo
{
	var list:VListNav<ListItem,String>;
	
	// --
	override public function create():Void 
	{
		super.create();
		
		// Create the list
		list = new VListNav<ListItem,String>(ListItem, 112, 42, 160);
		add(list);
		// HACK: Since this is a simple demo, set the pooling mode to not destroy elements 
		// 		 when they scroll out of view, so that they keep their CHANGED state
		// 		 In real world application DONT store actual data inside the items
		//		 But rather in the datatype like `VListMenu` does.
		
		list.setPoolingMode("reuse", 10);
		list.setDataSource(["One", "Two", "Three", "Four", "Five", "Six"]);
		list.onScreen();
		
		// Listen to callbacks
		list.callbacks = function(a, b)
		{
			if (a == "tick")
			{
				SND.play('c_tick');
			}
		}//--
	
		// - Add a simple cursor from a bitmap from the default icon lib
		var icon = Gui.getIcon("right", 12);
		var crs = new FlxSprite(0, 0, icon);
		// Note: I am manually adjusting the cursor position
		//		 The list will try to center the cursor but if it's not right
		//		 I can manually add offsets like so:
		list.cursor_setSprite(crs, [ 4, -4]);
		
		// --
		add(Gui.getQText("Vertical List Navigable", 8, 0xFF00FFFF, -1, list.x, list.y - 10));
		
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// NOTE:
		// VListNav, autohandles controls so there is no need to check for controls here
		
	}//---------------------------------------------------;

}// --
