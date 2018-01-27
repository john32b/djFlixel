package ;

import djFlixel.FLS;
import flixel.FlxState;

class State_Main extends FlxState
{
	// --
	override public function create():Void
	{
		super.create();
		
		// Delete this line:
		add(djFlixel.gui.Gui.getQText("DJFLIXEL v" + FLS.DJFLX_VERSION, 8, 0xff65F062, 0xff38741F, 32, 32));
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		FLS.debug_keys();
	}//---------------------------------------------------;
	
}// --