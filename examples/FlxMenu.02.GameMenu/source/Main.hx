package;

import djFlixel.tool.DynAssets;
import flash.Lib;

class Main extends djFlixel.MainTemplate
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