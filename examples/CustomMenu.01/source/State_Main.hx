package ;

import djFlixel.Controls;
import djFlixel.fx.StarfieldSimple;
import djFlixel.gui.OptionData;
import djFlixel.gui.list.VListBase;
import djFlixel.gui.list.VListNav;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;

/**
 * Creating a Custom Menu using the VList system
 * ...
 */
class State_Main extends FlxState
{
	var menu:VListNav<SaveSlotGfx,SaveSlotData>;
	// --
	override public function create():Void
	{
		super.create();

		// Create some test data
		var savesData:Array<SaveSlotData> = [];
		var datalen:Int = Reg.JSON.menu.testDataLen;
		for (i in 0...datalen) {
			savesData.push(new SaveSlotData(i));
		}
			
		var stars:StarfieldSimple = new StarfieldSimple();
			add(stars);
			
		menu = new VListNav(SaveSlotGfx, 46, 46, 200, Reg.JSON.menu.slots);
		menu.setDataSource(savesData);
		menu.cursor_setSprite(new FlxText(0, 0, 0, Reg.JSON.menu.cursorText, 16));
		menu.onScreen();
		add(menu);
	
	
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		#if debug
			Reg.debug_keys();
		#end
		
		if (FlxG.keys.justPressed.L)
		{
			if (menu.isFocused) menu.unfocus(); else menu.focus();
		}
	}//---------------------------------------------------;
	
	
}// --