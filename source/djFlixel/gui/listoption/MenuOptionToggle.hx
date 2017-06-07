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
		
		if (style.icons == null || style.icons.ind_checkbox == null)
		{
			// Get a checkbox from the default GUI icons
			box = GfxTool.getSpriteFrame(Gui.DEF_GUI_ICONS, 0, 16, 16);
			
			if (style.size <= 12) {
				frameStart = 6; // Small
				box.setSize(8, 8);
				box.offset.set( -1, -1); // It looks better 1 pixel further down
			}else if (style.size <= 16) {
				frameStart = 8; // Larger
				box.setSize(12, 12);
			}else{
				// NOTE : If you are using AntiAliasing, the box will appear overly blurred
				// Temp Solution.
				frameStart = 8;
				box.scale.set((style.size / 12), (style.size / 12));
				box.updateHitbox();
				box.setSize(style.size, style.size);
			}
			
		}else
		{
			box = GfxTool.getSpriteFrame(style.icons.tileSheet, 0, style.icons.tileSize, style.icons.tileSize);
			frameStart = style.icons.ind_checkbox;
		}
		
		add(box);	
	}//---------------------------------------------------;
	
	
	// --
	// Position the checkbox.
	override function initElements() 
	{
		super.initElements();
				
		box.y = y + (label.height / 2) - (box.height / 2);
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