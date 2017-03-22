package;

import djFlixel.Controls;
import djFlixel.FlxAutoText;
import djFlixel.fx.StarfieldSimple;
import djFlixel.gfx.Palette_DB32;
import djFlixel.gui.DialogBox;
import flixel.FlxG;
import flixel.FlxState;

/**
 * Demo state, demoing the dialog system
 * ...
 */
class State_Dialog extends FlxState
{

	// The main dialog box object
	var dialogBox:DialogBox;
	
	//--
	override public function create():Void 
	{
		super.create();
		
		// --
		var stars = new StarfieldSimple();
		stars.setDirection(45);
		stars.flag_widepixel = true;
		stars.setColors([
			Palette_DB32.COL[5],
			Palette_DB32.COL[6],
			Palette_DB32.COL[17],
			Palette_DB32.COL[8]]);
		add(stars);
		
		// --
		dialogBox = new DialogBox(3, 16);
		add(dialogBox);
		dialogBox.y = FlxG.height - dialogBox.HEIGHT - 2;

		// This sets and starts the dialog
		dialogBox.setDialog(Reg.JSON.dialog);

	}//---------------------------------------------------;
		
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (Controls.CURSOR_CANCEL()) {
			FlxG.switchState(new State_Main());
		}
	}//---------------------------------------------------;
	
}// -- end -- 