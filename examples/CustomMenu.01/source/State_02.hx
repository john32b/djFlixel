package ;

import djFlixel.Controls;
import djFlixel.fx.StarfieldSimple;
import djFlixel.gui.FlxMenuPages;
import djFlixel.gui.OptionData;
import djFlixel.gui.PageData;
import djFlixel.gui.Styles;
import djFlixel.gui.list.VListBase;
import djFlixel.gui.list.VListMenu;
import djFlixel.gui.list.VListNav;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;

/**
 * Creating a Custom Menu using the VList system
 * ...
 */
class State_02 extends FlxState
{
	// --
	override public function create():Void
	{
		super.create();

		// --
		var page:PageData = new PageData("main");
		page.link("One", "one");
		page.link("Two ....", "two");
		page.link("Three ....", "three");
		page.link("444444 ....", "three");
		
		// --
		var menu:VListMenu = new VListMenu(20, 20, 0, 10);
			menu.styleOption = Styles.newStyle_Option(Reg.JSON.FlxMenuStyle1.option);
			menu.styleBase = Styles.newStyle_Base(Reg.JSON.FlxMenuStyle1.base);
			
		menu.setPageData(page);	
		add(menu);
		menu.onScreen();
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.F1) {
			FlxG.switchState(new State_Main());
		}
		#if debug
			Reg.debug_keys();
		#end
	}//---------------------------------------------------;
	
}// --