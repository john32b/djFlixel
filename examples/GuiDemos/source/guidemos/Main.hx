package guidemos;

import djFlixel.FLS;
import guidemos.states.State_Main;
import djFlixel.MainTemplate;

class Main extends MainTemplate
{
	override function init() 
	{
		INITIAL_STATE = State_Main;
	}
}// --