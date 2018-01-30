package fxdemos;

import djFlixel.MainTemplate;
import fxdemos.states.State_Main;

class Main extends MainTemplate
{
	override function init() 
	{
		INITIAL_STATE = State_Main;
	}
}// --