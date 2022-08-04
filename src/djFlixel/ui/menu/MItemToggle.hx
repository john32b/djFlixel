package djFlixel.ui.menu;

import djFlixel.ui.IListItem.ListItemInput;
import djFlixel.ui.menu.MPage;
import djFlixel.ui.menu.MItem;
import djFlixel.ui.menu.MItem.FocusState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import openfl.display.BitmapData;


/**
 * [Label + Checkbox], something that toggles on/off
 * ------------------------
 * A Checkbox can either have an animation or be 2 separate bitmaps and swap them
 */
class MItemToggle extends MItem
{	
	var box:FlxSprite;			// Checkbox sprite, if TEXT mode, this will be the casted Text
	var boxt:FlxText;			// If TEXT mode, this will be the text
	var lastState:String;
	var offy:Int = 1;
	//---------------------------------------------------;
	public function new(MP:MPage) 
	{
		super(MP);
		
		if (st.box_offy != null) offy = st.box_offy;
		if (st.box_bm != null)
		{
			// It is important to fill out the sprite for it to get aligned on init() later.
			// Also this bitmap will not go to waste, it will be cached
			box = new FlxSprite(0, 0, mp.iconcache.get(st.box_bm[0], 'idle').clone());
			D.align.YAxis(box, label, 'c', offy);
		}else{		
			if (st.box_txt == null) throw "Style error, you must set text or bitmap";
			boxt = D.text.get("", st.text);
			box = cast boxt;
			// No alignment when text, the box text should be the same style as labels text
		}
		add(box);
	}//---------------------------------------------------;
	
	// Apply data status to visual, No colors
	function data_refresh()
	{
		if (boxt != null) {
			boxt.text = st.box_txt[data.P.c?1:0];
			// Hack, text needs to be aligned every time it changes
			if (mp.STP.align == "justify") {
				box.x = x + mp.menu_width - box.width;
			}
		}else{
			// DEV: bitmap does not need to be refreshed, just redraw the box
			//  	For the first refresh at 'newdata' it already has a bitmap at this point 
			//      so it is going to get aligned.
		}
		
	}//---------------------------------------------------;
	
	// Position the checkbox
	override function on_newdata() 
	{
		super.on_newdata();
		
		data_refresh();
		
		switch(mp.STP.align) 
		{
			case "justify":
				box.x = x + mp.menu_width - box.width;
			default:
				box.x = label.x + label.width + st.part2_pad;
		}
	}//---------------------------------------------------;
	
	// --
	override function handleInput(inp:ListItemInput) 
	{
		switch(inp) {
			case click(_) | fire:
			data.P.c = !data.P.c;
			data_refresh();
			_setBox(lastState); // This is mainly to redraw the correct bitmap 
			callback(fire);
			case _:
		}
	}//---------------------------------------------------;

	override function state_set(id:FocusState) 
	{
		super.state_set(id);
		if (id == idle)	{
			_setBox('accent');
		}else{
			_setBox(id.getName());
		}
	}//---------------------------------------------------;
	
	// Set current state , StateColors
	// Reads and applies current state to bitmap
	// Changes COLOR of either text/box to set state from {StateColors}
	function _setBox(str:String)
	{
		lastState = str;
		if (boxt != null) {
			_ctext(str, boxt);
		}else{
			// DEV: If I don't put clone, sometimes this crashes. Very weird.
			box.pixels = mp.iconcache.get(st.box_bm[data.P.c?1:0], str).clone();
			box.dirty = true;
		}
	}//---------------------------------------------------;

}// --