package djFlixel.ui.menu;
import djFlixel.ui.menu.MItem.FocusState;

/**
 */
class MItemLabel extends MItem
{
	override function state_set(id:FocusState) 
	{
		_ctext('accent'); // Force this color
	}//---------------------------------------------------;
	
}// --