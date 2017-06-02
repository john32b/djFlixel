package;

import djFlixel.FLS;
import djFlixel.MainTemplate;
import flash.Lib;

class Main extends MainTemplate
{
	public function new()
	{
		super(State_Main);
	}//---------------------------------------------------;
	// --
	public static function main():Void
	{	
		Lib.current.addChild(new Main());
	}//---------------------------------------------------;
}// --