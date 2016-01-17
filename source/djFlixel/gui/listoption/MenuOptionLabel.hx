package djFlixel.gui.listoption;
import djFlixel.gui.list.VListMenu;

class MenuOptionLabel extends MenuOptionBase
{
	override function state_disabled() 
	{
		// Hack the disabled color:
		label.color = style.color_accent;	
	}//---------------------------------------------------;
	
}// --