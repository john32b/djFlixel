package djFlixel.gui.listoption;

import djFlixel.gfx.GfxTool;
import djFlixel.gfx.Palette_DB32;
import djFlixel.gui.Styles.OptionStyle;
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
	public function new(_style:OptionStyle)
	{
		super(_style);
		
		box = GfxTool.getSpriteFrame(MenuOptionBase.GFX_ICONS, 8, 16, 16);


		box.scale.set((style.size/12), (style.size/12));
		box.updateHitbox();
		box.offset.add(-3*box.scale.x, -3*box.scale.y);
		frameStart = 8;

		
		add(box);	
	}//---------------------------------------------------;
	
	
	// --
	// Position the checkbox.
	override function initElements() 
	{
		super.initElements();
				
		box.y = y + 1 + (label.height / 2) - box.height / 2;
		box.x = x + label.fieldWidth + PADDING_FROM_LABEL;
		
		updateOptionData();
		
	}//---------------------------------------------------;
	
	// --
	override function handleInput(inputName:String) 
	{
		switch(inputName){
			case "fire" | "click":
				opt.data.current = !opt.data.current;
				updateOptionData();
				cb("optChange");
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