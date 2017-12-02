package ;

import djFlixel.FLS;
import djFlixel.SND;
import djFlixel.fx.StarfieldSimple;
import djFlixel.gui.Align;
import djFlixel.gui.FlxMenu;
import djFlixel.gui.menu.MItemData;
import djFlixel.gui.menu.PageData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;


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
	
	// One menu to choose the styles
	var menu1:FlxMenu;
	// One menu to apply the styles to
	var menu2:FlxMenu;
	// --
	override public function create():Void
	{
		super.create();
		// Simple black-ish BG
		camera.bgColor = 0xFF442226;
		// -
		var P = FLS.JSON.STATE_STYLEGEN;
		
		
		var p:PageData;
		// -- Left Menu
		menu1 = new FlxMenu(P.m1.x, P.m1.y, P.m1.width, P.m1.slots);
		menu1.callbacks_item = menuCallbackItem;
		p = menu1.newPage("main");
		p.title = "Style Creator";
		p.link("Predefined styles", "@predef");
		p.link("Create a style", "@create");
		p.link("Main Menu", "mainmenu");
		add(menu1);
		menu1.showPage("main");	
		
		// -- Right Menu
		menu2 = new FlxMenu(P.m2.x, P.m2.y, P.m2.width, 5);
		
		
		
		// Place a box behind the second menu
		var b = new FlxSprite(P.m2.x, 0);
			b.makeGraphic(cast FlxG.width - P.m2.x, FlxG.height, 0xFF111111);
			add(b);
			
		add(menu2);
		
		
		// --
		var box = new InfoBox(P.box.width, P.box.height, P.box.color0, P.box.color1);
			Align.screen(box, "right", "bottom", 5);
			add(box);
		box.open("Press [TAB] to swith focus between menus\n" +
			"Keys : WASD,K/J, ARROWS,Z/X");
		
		
		// --
		new FooterText();
	}//---------------------------------------------------;
	
	function menuCallbackItem(s:String, m:MItemData)	
	{
		if (s == "fire" && m.SID == "mainmenu")
		{
			FlxG.switchState(new State_Selector());
		}
	}//---------------------------------------------------;
		
	
	override public function update(elapsed:Float):Void 
	{
		FLS.debug_keys();
		super.update(elapsed);
	}//---------------------------------------------------;
}// --