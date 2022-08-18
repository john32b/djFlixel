package djFlixel.ui;

import djFlixel.ui.FlxMenu;
import flixel.system.debug.FlxDebugger.GraphicCloseButton;


/**
   Menu Plugin - Audio
   
   Example:
   --------
   
	menu.plug(new MPlug_Audio({
		pageCall:'cursor_high',
		back:'cursor_low',
		it_fire:'cursor_high',
		it_focus:'cursor_tick',
		it_invalid:'cursor_error'
	}));
	
**/

class MPlug_Audio implements IFlxMenuPlug
{
	var m:FlxMenu;
		
	// Hold MenuItemEvent + SoundID
	var SND:Map<MenuEvent,String> = [];
	
	/**
	   Create this object and call `FlxMenu.plug( plugin )` to enable it
	   @param	PAR Object with { menuevent:soundID } e.g. { it_fire:"sound_one" }
	**/
	public function new(S:Dynamic)
	{
		for (f in Reflect.fields(S))
		{
			SND.set(MenuEvent.createByName(f), Reflect.field(S, f));
		}
	}//---------------------------------------------------;
	
	// -- INTERFACE
	@:allow(djFlixel.ui.FlxMenu)
	function attach(m:FlxMenu)
	{
		this.m = m;
	}//---------------------------------------------------;
	
	// -- INTERFACE
	function onMEvent(ev:MenuEvent, pid:String)
	{
		if (SND.exists(ev))
		{
			D.snd.playV(SND.get(ev));
		}
	}//---------------------------------------------------;

	//-- INTERFACE
	public function destroy()
	{
		// GC will take care of pointers
	}
	
}// --

