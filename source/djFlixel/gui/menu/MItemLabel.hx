package djFlixel.gui.menu;

class MItemLabel extends MItemBase
{
	override function state_disabled() 
	{
		// Hack the disabled color:
		label.color = style.color_accent;	
	}//---------------------------------------------------;
	
}// --