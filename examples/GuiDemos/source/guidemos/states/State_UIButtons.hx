package guidemos.states;

import djFlixel.FLS;
import djFlixel.SND;
import djFlixel.gfx.Palette_DB32 as DB32;
import djFlixel.gui.Align;
import djFlixel.gui.Gui;
import djFlixel.gui.Toast;
import djFlixel.gui.UIButton;
import flixel.FlxG;


/**
 * UI Buttons Test
 */
class State_UIButtons extends State_Demo
{
	// --
	override public function create():Void 
	{
		super.create();

		// -- Add a toast to get quick infos
		var t = new Toast();
		add(t);
		
		var buttons:Array<UIButton> = [];
		
		// No style options on a UIBUTTON
		buttons.push(new UIButton("0"));
		
		// Icons with style options in the param.json file ::
		buttons.push(new UIButton("1", P.buttonStyle1));
		buttons.push(new UIButton("2", P.buttonStyle2));
		buttons.push(new UIButton("3", P.buttonStyle3));
		// Bigger graphic (32pixel) button style
		buttons.push(new UIButton("4", P.buttonStyle4));
		
		// Aligns all the elements at the center of the screen
		Align.inLine(0, 64, FlxG.width, cast buttons, "center", 16);

		for (b in buttons)
		{
			add(b);
			b.onPress = function(id) {
				SND.play("c_sel");
				t.fire("Pressed button with ID=" + id);
			}
		}
		
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	}//---------------------------------------------------;

}// --
