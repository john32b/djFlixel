package guidemos.states;

import djFlixel.CTRL;
import djFlixel.SND;
import djFlixel.gfx.Palette_DB32 as DB32;
import djFlixel.gui.Gui;
import djFlixel.gui.Toast;
import flixel.FlxG;
import flixel.FlxState;


/**
 * Simple Toast example.
 */

class State_ToastTest extends State_Demo
{
	// - The Toast object
	var toast:Toast;
	// - Loop through messages
	var MSG_MAX:Int;
	var MSG_CURRENT:Int;
	// --
	override public function create():Void 
	{
		super.create();
		
		// --
		MSG_MAX = P.MSG.length;
		MSG_CURRENT = 0;
		// -- Create the notification box
		toast = new Toast({
			width:120,
			color : P.colorText,
			colorBG : P.colorBack,
			alignX:"right"
		});
		add(toast);
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (CTRL.justPressed(CTRL.A) || FlxG.mouse.justPressed)
		{
			var extra:Dynamic = null;
			if (MSG_CURRENT == 4) // Special Case, hard coded
			{
				extra = {
					alignX:"left",
					timeTween:1,
					easeIn:"bounceOut",
					width:180
				}
			}
			toast.fire(P.MSG[MSG_CURRENT], extra);
			SND.play('c_err');
			if (++MSG_CURRENT == MSG_MAX) MSG_CURRENT = 0;
		}
	}//---------------------------------------------------;
	
}// --