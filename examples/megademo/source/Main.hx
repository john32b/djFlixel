package;

import djFlixel.FLS;
import flash.Lib;

class Main extends djFlixel.MainTemplate
{
	public function new()
	{
		FLS.extendedClass = Reg;
		super(StateTest);
	}//---------------------------------------------------;
	// --
	public static function main():Void
	{	
		Lib.current.addChild(new Main());
	}//---------------------------------------------------;
}// --