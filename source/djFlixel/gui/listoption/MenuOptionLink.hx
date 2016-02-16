package djFlixel.gui.listoption;

import djFlixel.gui.list.VListMenu;
import flixel.FlxG;
import flixel.text.FlxText;

class MenuOptionLink extends MenuOptionBase
{
	
	// Optional decorative symbol
	// Animated dots . ..
	var deco:FlxText;
	// 
	var hasDeco:Bool;
	// -----
	var dTimer:Float; // timer
	var dCounter:Int; // place in the array
	var dArr:Array<String> = [" ", ".", ".."]; // loop through these
	
	//====================================================;
	// --
	public function new(P:VListMenu)
	{
		super(P);
		
		deco = new FlxText(0, 0, 0);
		Styles.styleOptionText(deco, style);
		deco.color = style.color_default;
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
		if (inputName == "fire")
		{
			parent.callback_option("optFire");
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
	override function updateElements() 
	{
		super.updateElements();
		
		if (opt.data.fn == "call" || opt.SID == "@back")
		{	
			hasDeco = false;
		}else if(opt.data.fn == "page")
		{
			deco.x = label.fieldWidth + PADDING_FROM_LABEL;
			hasDeco = true;
		}
	}//---------------------------------------------------;
	
}// -- end -- 