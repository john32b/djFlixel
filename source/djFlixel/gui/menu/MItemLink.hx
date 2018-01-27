package djFlixel.gui.menu;

import djFlixel.gui.Styles.StyleVLMenu;
import flixel.FlxG;
import flixel.text.FlxText;

class MItemLink extends MItemBase
{
	// Optional decorative symbol for use when the link goes to another page
	// Animated dots . ..
	var deco:FlxText;
	var hasDeco:Bool;
	// -----
	var dTimer:Float; // timer
	var dCounter:Int; // place in the array
	var dArr:Array<String> = [" ", ".", ".."]; // loop through these
	//====================================================;
	// --
	public function new(_s:StyleVLMenu, _w:Int)
	{
		super(_s, _w);
		
		deco = new FlxText(0, 0, 0);
		Styles.applyTextStyle(deco, style);
		deco.color = style.color_focused;
		add(deco);
		
		hasDeco = false;
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		if (hasDeco && deco.visible)
		{
			dTimer -= FlxG.elapsed;
			if (dTimer < 0) {
				dTimer = 0.25;
				deco.text = dArr[dCounter];
				dCounter++;
				if (dCounter > 2) dCounter = 0;	// Hardcoded instead of array.length
			}
		}
		super.update(elapsed);
	}//---------------------------------------------------;
	
	// --
	override function handleInput(inputName:String) 
	{
		if (inputName == "fire" || inputName.indexOf("c|") == 0)
		{
			cb("fire");
		}
	}//---------------------------------------------------;
	// --
	override function state_disabled() 
	{
		super.state_disabled();
		deco.visible = false;
	}//---------------------------------------------------;
	// --
	override function state_default() 
	{
		super.state_default();
		deco.visible = false;
	}//---------------------------------------------------;
	// --
	override function state_focused() 
	{
		super.state_focused();
		if (hasDeco) {
			deco.visible = true;
			dTimer = 0;
			dCounter = 1;
		}
	}//---------------------------------------------------;
	// --
	override function initElements() 
	{
		super.initElements();
		
		if (opt.data.fn == "call" || opt.SID == "back")
		{	
			hasDeco = false;
		}else if(opt.data.fn == "page")
		{
			 // Show the decorative animated dots only when this 
			 // is a link to another page.
			 switch(style.alignment)
			 {
				case "right":
					deco.x = label.x - EL_PADDING - style.fontSize; // Hack: nudge it a bit to the left.
				case "justify":
					deco.x = label.x + parentWidth - style.fontSize - EL_PADDING;
				default:
					deco.x = label.x + label.fieldWidth + EL_PADDING;
			 }
			hasDeco = true;
		}
	}//---------------------------------------------------;
	
}// -- end -- 