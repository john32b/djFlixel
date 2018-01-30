package;

import common.Common;
import djFlixel.FLS;
import djFlixel.MainTemplate;

class Main extends MainTemplate
{
	override function init() 
	{
		INITIAL_STATE = St_Boot;

		Common.demo_return_state = St_Menu;
		
		// 
		FLS.extendedClass = Reg;
	
		// Note, These are ASSET ID's, can't load externally. 
		// 		 hacky way to load external projects and use the same 'params.json'
		//		 file, by giving ID's to it in `project.xml`
		// 		 Then,before loading the states, I set FLS.JSON to point to the appropriate one
		FLS.assets.add("guidemo.json");
		FLS.assets.add("fxdemo.json");
		FLS.assets.add("flxmenu.json");
	}//---------------------------------------------------;
}// --