package djFlixel.ui.menu;
import djFlixel.ui.IListItem.ListItemInput;
import flixel.text.FlxText;
import djFlixel.ui.menu.MItem.FocusState;

class MItemLink extends MItem
{
	static inline var DECO_TICK = 0.25;
	// Optional decorative symbol for use when the link goes to another page
	// Animated dots . ..
	var deco:FlxText;
	var hasDeco:Bool = false;
	// -----
	var dTimer:Float; // timer
	var dCounter:Int; // place in the array
	var dArr:Array<String> = [" ", ".", ".."]; // loop through these
	//====================================================;
	
	// --
	override function on_newdata() 
	{
		super.on_newdata();
		
		if (data.P.type == 0 && data.P.link != "back")
		{
			deco_enable();
			switch(mp.STP.align) {
				case "justify": 
					deco.x = label.x + mp.menu_width - deco.width;
				default: 
					deco.x = label.x + label.width + st.part2_pad;
			}
		}else {
			deco_enable(false);
		}
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		if (hasDeco && deco.visible)
		{
			if ((dTimer -= elapsed) < 0) {
				dTimer = DECO_TICK;
				if (++dCounter >= dArr.length) dCounter = 0;
				deco.text = dArr[dCounter];
			}
		}
		super.update(elapsed);
	}//---------------------------------------------------;
	// --
	override function handleInput(inp:ListItemInput) 
	{
		switch(inp) {
			case click(_) | fire:
				callback(fire);
			case _:
		}
	}//---------------------------------------------------;
	
	// --
	override function state_set(id:FocusState) 
	{
		super.state_set(id);
		if (!hasDeco) return;
		
		if (id == FocusState.focus)
		{
			deco.visible = true;
			dTimer = 0;
			dCounter = 0;
		}else{
			deco.visible = false;
		}
	}//---------------------------------------------------;	
	/**
	   Enable/Disable the decorative element for this link
	   ~ Not for hiding , this is to know whether this link should have a deco element when focused */
	function deco_enable(en:Bool = true)
	{
		if (hasDeco = en)
		{
			if (deco == null) {
				deco = D.text.get(dArr[dArr.length - 1], st.text);
				_ctext('focus', deco);	// Will stay to that color forever
				add(deco);
			}
			deco.active = deco.visible = true;
		}else{
			if(deco!=null)
				deco.active = deco.visible = false;
		}
	}//---------------------------------------------------;
	
	override function get_width():Float 
	{
		return label.width;
	}//---------------------------------------------------;
	
}// --