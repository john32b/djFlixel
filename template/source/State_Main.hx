package ;

import djFlixel.FLS;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

class State_Main extends FlxState
{
	// --
	override public function create():Void
	{
		super.create();
		add(new FlxText(32, 32, 0, "djFlixel " + FLS.VERSION, 16));
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// On keypress "f12" reload JSON parameters and reset game
		// So I can quickly make changes to the json file and see them in action
		FLS.debug_keys();
	
	}//---------------------------------------------------;
	
}// --