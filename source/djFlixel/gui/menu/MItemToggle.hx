package djFlixel.gui.menu;

import djFlixel.gfx.GfxTool;
import djFlixel.gui.Styles.StyleVLMenu;
import djFlixel.gui.menu.MItemData;
import djFlixel.tool.DataTool;
import flash.display.BitmapData;
import flixel.FlxSprite;
import flixel.text.FlxText;

/**
 * [Label + Checkbox], something that toggles on/off
 * ------------------------
 * Checkbox can either have an animation or be 2 separate bitmaps and swap them
 */
class MItemToggle extends MItemBase
{
	// The Color of the default Icon that will be replaced in box states, (white as the icons in the ICONLIB)
	inline static var KEY:Int = 0xFFFFFFFF; 
	
	var box:FlxSprite;			// Checkbox sprite
	var frm:Array<Int>;			// [offFrame,onFrame]
	var bit:Array<BitmapData>;	// [offBitmap,onBitmap]
		
	// Keep the current color the box is supposed to be in
	var currentColor:Int;
	
	// True if using a custom sprite
	var flag_sprite:Bool = false;
	// True if using text labels
	var flag_text:Bool = false;
	// The text object, same as box but casted as FlxText
	var text:FlxText;
	//---------------------------------------------------;
	
	public function new(_s:StyleVLMenu,_w:Int)
	{
		super(_s, _w);
		
		currentColor = style.color_accent;
		
		// If a custom icon has not been set, get graphic from the default LIB
		// else load the default icon
		
		if (style.custom_icons != null) // :: Use a custom checkbox image
		{
			flag_sprite = true;
			box = GfxTool.getSpriteFrame(style.custom_icons.image, 0, style.custom_icons.size, style.custom_icons.size);
			frm = style.custom_icons.checkbox;
		}
		else
		{
			flag_sprite = false;
			
			var c = DataTool.copyFields(style.icons, {
				image:null,
				size:0,
				checkboxText:null
			});
			
			// Text Checkbox ::
			if (c.checkboxText != null)
			{
				flag_text = true;
				text = new FlxText();
				text.text = c.checkboxText[0];
				Styles.applyTextStyle(text, style);
				box = cast text;
			}else{
				
			// Icon BOX ::
			bit = [];
			var forceSize:Bool = c.size > 0;
			var ics = forceSize?c.size:Gui.getApproxIconSize(style.fontSize);
			var ss:Int = cast label.borderSize;	// Because border could be auto-generated from the style
			var shadowCol:Int = style.color_icon_shadow != null?style.color_icon_shadow:style.color_border;
			bit[0] = Gui.getIcon("ch_off", ics, c.image, shadowCol, ss, ss);
			bit[1] = Gui.getIcon("ch_on",  ics, c.image, shadowCol, ss, ss);
			box = new FlxSprite();
			box.makeGraphic(bit[0].width, bit[0].height, 0x00000000, true); // Unique is important!
			box.setSize(ics - 1, ics - 1);
			if (style.fontSize > 38 && !forceSize) {
				// NOTE : Anything bigger, will scale up the 24x24 sprite
				//		: If you are using AntiAliasing, the box will be overly blurred
				// 		: with arbitrary size ratio to make it a bit smaller than the fontsize
				trace("Warning: Font size too big, Resizing the checkbox, add a custom IconSet to avoid AA blur");
				box.scale.set((style.fontSize / 30), (style.fontSize / 30));
				box.updateHitbox();
			}
			}// end if
		}// endif
		
		add(box);
	}//---------------------------------------------------;
	
	
	// The data state has changed update the visual
	function updateItemData()
	{
		if (flag_sprite) {
			box.animation.frameIndex = frm[opt.data.current?1:0];
		}
		else{
			boxUpdateAndColor(currentColor); // Draws the current state with target color
		}
	}//---------------------------------------------------;
	
	
	// Position the checkbox
	override function initElements() 
	{
		super.initElements();
		
		box.y = label.y + (label.height / 2) - (box.height / 2);
		
		switch(style.alignment)
		{
			case "right":
				box.x = label.x - EL_PADDING - box.width;
			case "justify":
				box.x = x + parentWidth - box.width - EL_PADDING; //<- test
			default:
				box.x = label.x + label.fieldWidth + EL_PADDING;
				self_width += box.width;
		}
		
		updateItemData();
		
	}//---------------------------------------------------;
	
	// --
	override function handleInput(inputName:String) 
	{
		if (inputName == "fire" || inputName.indexOf("c|") == 0)
		{
			opt.data.current = !opt.data.current;
			updateItemData();
			cb("change");
		}
	}//---------------------------------------------------;

	override function state_default() 
	{
		super.state_default();
		if (flag_sprite) return;

		if (opt.disabled)
			boxUpdateAndColor(style.color_disabled);
		else
			boxUpdateAndColor(style.color_accent);
	}//---------------------------------------------------;
	
	override function state_focused() 
	{
		super.state_focused();
		if (flag_sprite) return;
		boxUpdateAndColor(label.color);
	}//---------------------------------------------------;
	
	override function state_disabled() 
	{
		super.state_disabled();
		if (flag_sprite) return;
		boxUpdateAndColor(style.color_disabled);
	}//---------------------------------------------------;
	
	/**
	 * Replace the color of the KEY color, in order to keep the shadow color the same.
	 * 
	 */
	function boxUpdateAndColor(col:Int)
	{
		if (flag_text){
			text.text = style.icons.checkboxText[opt.data.current?1:0];
			text.color = col;
		}else{
			GfxTool.drawBitmapOn(
				GfxTool.replaceColor(bit[opt.data.current?1:0], KEY, col), 
				box.pixels);
			box.dirty = true;
		}
		currentColor = col;
	}//---------------------------------------------------;
}// --