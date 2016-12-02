package;

import djFlixel.tool.DynAssets;
import flash.Lib;
import djFlixel.MainTemplate;

class Main extends MainTemplate
{
	public function new() {
		MainTemplate.framerate = 42;
		DynAssets.FILE_LOAD_LIST = [Reg.PARAMS_FILE];
		super(State_Main); 
	}//---------------------------------------------------;
	public static function main():Void {
		Lib.current.addChild(new Main());
	}//---------------------------------------------------;
}