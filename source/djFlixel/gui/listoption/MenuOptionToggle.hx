package djFlixel.gui.listoption;

import djFlixel.gfx.GfxTool;
import djFlixel.gfx.Palette_DB32;
import djFlixel.gui.list.VListMenu;
import djFlixel.gui.OptionData;
import flixel.FlxSprite;
import flixel.text.FlxText;

class MenuOptionToggle extends MenuOptionBase
{	
	// Checkbox sprite
	var box:FlxSprite;
	// Checkbox frame helper
	var frameStart:Int;
	
	//---------------------------------------------------;
	public function new(P:VListMenu) 
	{
		super(P);
		box = GfxTool.getSpriteFrame(MenuOptionBase.GFX_ICONS, 6, 16, 16);
		// Depending on the font size, set the small or big box.
		if (parent.styleOption.fontSize < 12) {
			box.setSize(8, 8);
			frameStart = 6;
		}else {
			box.setSize(12, 12);
			frameStart = 8;
		}
		
		add(box);		
	}//---------------------------------------------------;
	
	// --
	// Position the checkbox.
	override function updateElements() 
	{
		super.updateElements();
		
		box.y = 1 + (label.height / 2) - box.height / 2;
		box.x = label.fieldWidth + PADDING_FROM_LABEL;
		
		updateOptionData();
		
	}//---------------------------------------------------;
	
	// --
	override function handleInput(inputName:String) 
	{
		switch(inputName){
			case "fire":
				opt.data.current = !opt.data.current;
				updateOptionData();
				parent.callback_option("optChange");
		}
	}//---------------------------------------------------;
	
	// --
	function updateOptionData()
	{
		if (opt.data.current)
		{
			box.animation.frameIndex = frameStart + 1;
		}else
		{
			box.animation.frameIndex = frameStart;
		}
	}//---------------------------------------------------;


	override function state_default() 
	{
		super.state_default();
		if (opt.disabled)
			box.color = style.color_disabled;
		else
			box.color = style.color_accent;
	}//---------------------------------------------------;
	
	override function state_focused() 
	{
		super.state_focused();
		box.color = label.color;
	}//---------------------------------------------------;
	
	override function state_disabled() 
	{
		super.state_disabled();
		box.color = style.color_disabled;
	}//---------------------------------------------------;

	
}// --