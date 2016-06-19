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
	var savesData:Array<SaveSlotData>;
	var savesData2:Array<SaveSlotData>;
	// --
	override public function create():Void
	{
		super.create();

		// Create some test data
		savesData = [];
		
		var datalen:Int = Reg.JSON.menu.testDataLen;
		for (i in 0...datalen) {
			savesData.push(new SaveSlotData(i));
		}
		
		savesData2 = [];
		for (i in 0...datalen) {
			savesData2.push(new SaveSlotData(i + 100));
		}

		var stars:StarfieldSimple = new StarfieldSimple();
			add(stars);
				
		menu = new VListNav(SaveSlotGfx, 46, 46, 200, Reg.JSON.menu.slots);
		menu.setDataSource(savesData);
		menu.cursor_setSprite(new FlxText(0, 0, 0, Reg.JSON.menu.cursorText, 16));		
		add(menu);
		menu.onScreen();
	
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
		else if (FlxG.keys.justPressed.P)
		{
			menu.setDataSource(savesData2);
		}
	}//---------------------------------------------------;
	
	
}// --