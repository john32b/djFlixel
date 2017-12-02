package;

import djFlixel.FLS;
import djFlixel.MainTemplate;
import flash.Lib;



/**
 * FlxMenu Example
 * ---------------
 * I hope this selection of examples helps you understand how to use it
 * - This class is mainly empty since the initialization is streamlined in the parent class
 */
class Main extends MainTemplate
{
	public function new()
	{
		// 0,0 Defaults to 320x240
		super(State_StyleGen, 0, 0, 60);
		//super(State_Selector, 0, 0, 60);
	}//---------------------------------------------------;
	// --
	public static function main():Void
	{	
		Lib.current.addChild(new Main());
	}//---------------------------------------------------;
}// --