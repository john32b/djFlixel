package;

import djFlixel.FLS;
import djFlixel.MainTemplate;

class Main extends MainTemplate
{
	override function init() 
	{
		FLS.extendedClass = Reg;
		INITIAL_STATE = State_Main;
	}
}// --