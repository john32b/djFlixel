package;

import djFlixel.FLS;
import djFlixel.MainTemplate;
import flash.Lib;

class Main extends MainTemplate
{
	public function new()
	{
		FLS.extendedClass = Reg;
		super(St_Boot, 0, 0, 60); // 60fps?
		//super(St_Boot);
	}//---------------------------------------------------;
	// --
	public static function main():Void
	{	
		Lib.current.addChild(new Main());
	}//---------------------------------------------------;
}// --