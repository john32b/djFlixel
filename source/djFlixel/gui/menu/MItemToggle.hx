package djFlixel.gui.menu;

import djFlixel.gfx.GfxTool;
import djFlixel.gui.Styles.MItemStyle;
import djFlixel.gui.menu.MItemData;
import flixel.FlxSprite;
import flixel.text.FlxText;

class MItemToggle extends MItemBase
{	
	// Checkbox sprite
	var box:FlxSprite;
	
	// Checkbox frame helper
	var frameStart:Int;
	
	// -- No need for constuctor --
	//====================================================;
	// --
	
	// Position the checkbox.
	override function initElements() 
	{
		super.initElements();
		
		// -- Reset the box, since this could be a recycled object
		if (box != null) {
			remove(box);
			box.destroy();
		}
		
		if (style.icons == null || style.icons.ind_checkbox == null)
		{
			frameStart = 0;
			
			// shortcut this call
			function ld(ss){
				box = new FlxSprite();
				box.loadGraphic(Gui.getIcon("check", ss , style.borderIcon, Std.int(label.borderSize), Std.int(label.borderSize)), true, 16, 16);
			};
			
			// I checked those hardcoded size values against the default font, and they look ok
			// Should work for other fonts just fine
			if (style.size < 12) {
				ld(0);
				box.setSize(7, 7);
			}else if (style.size < 17) {
				ld(1);
				box.setSize(10, 10);
			}else if (style.size < 26) {
				ld(2);
				box.setSize(14, 14);
			}else { 
				// Anything bigger, just in case
				// NOTE : If you are using AntiAliasing, the box will be overly blurred
				ld(2);
				box.scale.set((style.size / 15), (style.size / 15));
				box.updateHitbox();
				box.setSize(style.size, style.size);
			}
			
		}else
		{
			// :: Use a custom checkbox image
			box = GfxTool.getSpriteFrame(style.icons.tileSheet, 0, style.icons.tileSize, style.icons.tileSize);
			// TODO: Custom size in case the checkbox is smaller than the image?
			frameStart = style.icons.ind_checkbox;
		}
		
		box.y = y + (label.height / 2) - (box.height / 2);
		box.x = x + label.fieldWidth + PADDING_FROM_LABEL;
		add(box);
		
		updateItemData();
		
	}//---------------------------------------------------;
	
	// --
	override function handleInput(inputName:String) 
	{
		switch(inputName){
			case "fire" | "click":
				opt.data.current = !opt.data.current;
				updateItemData();
				cb("change");
		}
	}//---------------------------------------------------;
	
	// --
	function updateItemData()
	{
		if (opt.data.current) {
			box.animation.frameIndex = frameStart + 1;
		}else {
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