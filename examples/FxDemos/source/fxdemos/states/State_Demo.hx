package fxdemos.states;

import common.Common;
import common.FooterText;
import common.InfoBox;
import djFlixel.CTRL;
import djFlixel.FLS;
import djFlixel.gui.Align;
import djFlixel.gui.FlxMenu;
import djFlixel.gui.Gui;
import djFlixel.gui.Styles;
import djFlixel.gui.Toast;
import djFlixel.gui.menu.MItemData;
import djFlixel.tool.DataTool;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

/**
 * General class for the demos, Provides some common functionality
 * ...
 */
class State_Demo extends FlxState 
{
	// Variables,gets the node with the same class name from "params.json"
	public var P:Dynamic;
	// A box at the bottom of the screen displaying some info
	public var INFO:InfoBox;
	// General use flxMenu
	public var menu:FlxMenu;
	// Generic toast
	public var toast:Toast;
	// -- Generic group, place things here so they appear behind the menu
	var group:FlxGroup;	
	// -- Special Occasion, main menu sets this to avoid some functions
	var flag_main_menu:Bool = false;
	var flag_hide_msg:Bool = false;
	// --
	public function new() 
	{
		super();
		var name:String = Type.getClassName(Type.getClass(this)).split('.').pop();
		P = DataTool.copyFieldsC(Reflect.field(FLS.JSON, name));
	}//---------------------------------------------------;
	
	// --
	override public function create():Void 
	{
		super.create();
		
		if (P.colorBG != null) 
		{
			camera.bgColor = P.colorBG;
		}
		else if (P.scroller != null)
		{
			add(Common.getBGScroller(P.scroller));
		}
		
		// -- 
		group = new FlxGroup();
		add(group);
		
		// --
		var IB:Dynamic = Reflect.copy(FLS.JSON.COMMON.infoBox);
		if (P.infoHeight != null)  {
			IB.height = P.infoHeight;
		}
		INFO = new InfoBox(P.infoText, IB);
		INFO.open();
		
		// --
		new FooterText(FLS.JSON.COMMON.footer);
		
		// -- Skip these inits when main menu state
		if (flag_main_menu) return;
		
		//-- Create a small menu that controls the FX Demos
		var G = DataTool.copyFieldsC(FLS.JSON.COMMON.subMenu);
		menu = new FlxMenu(G.x, G.y, G.width, G.slots);
		menu.applyMenuStyle(G.style, G.header);
		menu.callbacks = function(a, b, c) {
			Common.handleMenuSounds(a);
			if (a == "rootback") EXIT();
			if (a == "focus" && c.description != null){
				INFO.setText(c.description);
			}
		}// ------
		add(menu);
		
		// -- Add a background to the menu
		var bg = new FlxSprite(G.x - G.bgpad, G.y - G.bgpad - 16);
		bg.makeGraphic(Std.int(G.width + (G.bgpad * 2)), Std.int(G.height + (G.bgpad * 2)), G.colorBG);
		menu.insert(0, bg); // Add to the back
		
		// --
		if (flag_hide_msg)
		{
			toast = new Toast({alignY:"top", alignX:"right", colorBG:0xFFF2F2F2, color:0xFF4F4F4F});
			add(toast);
			toast.fire("press $[TAB]$ to toggle the menu", {timeOn:1.5, timeTween:0.7});
		}
		
	}//---------------------------------------------------;
	// --
	function EXIT()
	{
		FlxG.switchState(new State_Main());
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		FLS.debug_keys();
		
		if (FlxG.keys.justPressed.ESCAPE || CTRL.justPressed(CTRL.START))
		{
			EXIT();
		}
		
		if (flag_main_menu) return;
	
		if (FlxG.keys.justPressed.TAB || (CTRL.justPressed(CTRL.B)))
		{
			if (menu.visible) {
				menu.close(true);  
				INFO.visible = false;
			}else {
				menu.open();
				INFO.visible = true;
			}
		}
	}//---------------------------------------------------;

	
	// --
	// Add the haxelogo along with some text
	// Called from the demos.
	function addDecoAndText(TEXT:String)
	{
		// --
		var im = new FlxSprite(0, 0, "assets/HAXELOGO.png");
		Align.inLine(menu.x + menu.width, menu.y + 16, 0, [im], "center");
		group.add(im);
		
		// --
		var txt = new FlxText(0, 0, 140, TEXT);
		Styles.applyTextStyle(txt, Gui.textStyles.get("default"));
		group.add(Align.downCenter(txt, im, 4));	
	}//---------------------------------------------------;	
}// --