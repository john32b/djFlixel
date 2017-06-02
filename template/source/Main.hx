package;

import djFlixel.FLS;
import djFlixel.tool.DynAssets;
import djFlixel.MainTemplate;
import flash.Lib;

class Main extends MainTemplate
{
	public function new()
	{
		FLS.extendedClass = Reg;
		super(State_Main);
	}//---------------------------------------------------;
	// --
	public static function main():Void
	{	
		Lib.current.addChild(new Main());
	}//---------------------------------------------------;
}// --