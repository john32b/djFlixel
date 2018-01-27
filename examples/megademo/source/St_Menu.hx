package;
import common.Common;
import common.FooterText;
import common.InfoBox;
import common.SubState_Letters;
import djFlixel.FLS;
import djFlixel.fx.BoxScroller;
import djFlixel.gfx.GfxTool;
import djFlixel.gui.Align;
import djFlixel.gui.FlxMenu;
import djFlixel.gui.Gui;
import djFlixel.gui.Styles;
import djFlixel.gui.menu.MItemData;
import djFlixel.tool.DataTool;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import djFlixel.gui.UIButton;
import flixel.text.FlxText;
import djFlixel.gfx.Palette_DB32 as DB32;


/**
 * Megademo Main Menu state
 * ...
 */
class St_Menu extends FlxState
{
	// --
	var P:Dynamic;
	
	// Popup text over the cursor on some elements
	var cursorHelp:FlxText;
	// helper
	var cursorHW2:Float;
	// Sometimes hover and out calls are being overwritten, 
	// Keeping track and counting to fix this
	var btnhover:Int;

	// The main menu
	var menu:FlxMenu;
	
	// --
	override public function create():Void
	{
		super.create();
		
		// Since this state is called from the siblin demos
		// I need to reset the FLS.JSON since it was changed
		FLS.JSON = FLS.assets.json.get(FLS.PARAMS_ASSET);
		
		// --
		P = DataTool.copyFieldsC(FLS.JSON.St_Menu);
		camera.bgColor = P.colorBG;
		//---------------------------------------------------;
		
		Common.setPixelPerfect();
		
		// Buttons
		//====================================================;
		
		createButtons();
		
		// Decorative stripe at the top
		//====================================================;
		
		// Note: No Y tiling
		var stripe_im = GfxTool.resolveBitmapData('assets/stripe_01.png');
		var stripe = new BoxScroller(
			GfxTool.replaceColor(stripe_im, 0xFFFFFFFF, P.stripe.color, true),
			0, 0, FlxG.width, 0, false);
		stripe.y = P.stripe.y;
		stripe.autoScrollX = P.stripe.speed;
		add(stripe);
		
		// MAIN MENU 
		//====================================================;
		
		menu = new FlxMenu(P.menu.x, P.menu.y, P.menu.width);
		menu.callbacks = menuCallbacks;
		menu.applyMenuStyle(P.menu.style, P.menu.header);
		// -- Create the page
		var p = menu.newPage("main", {title:"djFlixel 0.3"});
		
		p.link("FlxMenu Demos", "flxm");
		p.link("Gui Package Demos", "gui");
		p.link("FX Package Demos", "fx");
		p.link("Reset", "reset");
		p.add("Smoothing", {type:"toggle", sid:"AA", current:FLS.ANTIALIASING});
		
		add(menu);
		menu.open("main");
	//====================================================;
	
	// Infobox: Gets added automatically
	var info = new InfoBox(P.infoboxText, P.infoboxStyle);
	info.open();
		
	// Footer, Gets added automaticaly
	new FooterText(P.footer);
	
	}//---------------------------------------------------;

	// --
	function menuCallbacks(a:String, b:String, c:MItemData)
	{
		Common.handleMenuSounds(a);
		
		if (a == "fire") {
			switch(b){default:
			
			case "gui":
				// Some serious hacking going on here:
				// Place the global settings of the demo there, 
				// and then don't forget to switch back!
				FLS.JSON = FLS.assets.json.get("guidemo.json");
				gotoStateFX(new guidemos.states.State_Main());
			case "flxm":
				FLS.JSON = FLS.assets.json.get("flxmenu.json");
				gotoStateFX(new flxmenudemo.State_Main());
			case "fx":
				FLS.JSON = FLS.assets.json.get("fxdemo.json");
				gotoStateFX(new fxdemos.states.State_Main());
				
			case "reset":
					// gotoStateFX(cast Type.createInstance(c.data.state, []));
					gotoStateFX(new St_Intro());
				
			}
		}else
		
		
		if (a == "change")
		{
			if (b == "AA")
			{
				Reg.setAA(c.get());
			}
		}
		
	
	}//---------------------------------------------------;
	
	
	
	// --
	// WARNING! Do not place and FLS.JSON calls here
	// 
	function gotoStateFX(stateToGo:FlxState)
	{
		menu.close();
		
		// -- LETTERS FX --
		
		var col1:Int, col2:Int;
		do{
			col1 = DB32.random();
			col2 = DB32.random();
		}while (col1 == col2);
		
		var s = new SubState_Letters("FLIXEL", function(){
				FlxG.switchState(stateToGo);
			}, {
			font:"fonts/blocktopia",
			fontSize:256,
			color:col1,
			colorBG:col2,
			ofEnd:[0,16],
			ofStart:[
				0, 
				FlxG.random.sign() * FlxG.random.int(24, 64)
			],
			timeLetter:0.12,
			timeWait:0.015,
			timePre:0.1,
			sound:"short2"
		});
		
		openSubState(s);
	}//---------------------------------------------------;
	
	//====================================================;
	// Buttons
	//====================================================;
	
	// -- Create some buttons
	// Reads data from `params.json`
	function createButtons()
	{
		// Shorthand
		var btns:Array<String> = P.buttonNames;
		var lastbutton:UIButton = null; // pointer helper
		
		// --
		for (i in 0...btns.length)
		{
			var b = new UIButton('$i', P.buttons);
			b.setFGSprite(GfxTool.getSpriteFrame("assets/social.png", i, 24, 24));
			add(b); 
			b.onHover = buttonHover;
			b.onPress = buttonPress;
			b.onOut = buttonOut;
		
			if (i == 0) {
				// First button goes to a predefined X,Y pos
				b.setPosition(P.buttonPos[0], P.buttonPos[1]);
			}else {
				// Rest of the buttons next to the previous one
				Align.right(b, lastbutton);
			}
			
			lastbutton = b;
		}
		
		// -- TEXT POPUP, enabled on some mouse roll overs
		// --
		cursorHelp = Gui.getSText("--");
		cursorHelp.visible = false;
		add(cursorHelp);
		btnhover = 0;
		cursorHW2 = 0;		
	}//---------------------------------------------------;
	
	
	function buttonHover(id:String)
	{
		btnhover++;
		cursorHelp.text = P.buttonNames[Std.parseInt(id)];
		cursorHW2 = cursorHelp.width / 2;
		cursorHelp.visible = true;
	}//---------------------------------------------------;
	
	function buttonPress(id:String)
	{
		FlxG.openURL(P.buttonLinks[Std.parseInt(id)]);
	}//---------------------------------------------------;	
	
	function buttonOut(id:String)
	{
		btnhover--;
		if (btnhover == 0) cursorHelp.visible = false;
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		FLS.debug_keys();
		
		if (cursorHelp.visible)
		{
			cursorHelp.x = FlxG.mouse.x - cursorHW2;
			cursorHelp.y = FlxG.mouse.y - 12;
		}
	}//---------------------------------------------------;

}// --