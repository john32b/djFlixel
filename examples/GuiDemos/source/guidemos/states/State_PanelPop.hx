package guidemos.states;

import djFlixel.CTRL;
import djFlixel.SND;
import djFlixel.gfx.Palette_DB32;
import djFlixel.gui.Align;
import djFlixel.gui.PanelPop;
import flixel.FlxG;


/**
 * Simple PanelPop example,
 * Be sure to check "params.json"
 */
class State_PanelPop extends State_Demo
{
	// --
	var panel:PanelPop;
	
	// Prevent an infinite long stack of function calls	
	var flag_allowCreation:Bool = false;
	
	
	override public function create():Void 
	{
		super.create();
		flag_allowCreation = true;
	}//---------------------------------------------------;

	// --
	function openRandomPanel()
	{
		flag_allowCreation = false;
		
		if (panel != null){
			remove(panel);
			panel.destroy();
		}
		
		panel = new PanelPop(
			FlxG.random.int(P.size.w0, P.size.w1),
			FlxG.random.int(P.size.h0, P.size.h1),
			Palette_DB32.random(),
			{
				sheet:"assets/panelBorder_01.png",
				size:8, // Tilesize of the panelborder tiles
				inset:2	// Places the border 2 pixels in
			}
		);
		
		add(Align.screen(panel));
		panel.y += P.yoffset;
		panel.open(function(){flag_allowCreation = true; }, P.updateTick);
		SND.play('c_err');
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);

		if (CTRL.justPressed(CTRL.A) || FlxG.mouse.justPressed)
		{
			if (flag_allowCreation)
			{
				openRandomPanel();
			}
		}
	}//---------------------------------------------------;
	
}// --