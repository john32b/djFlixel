package guidemos.states;

import djFlixel.CTRL;
import djFlixel.gfx.Palette_DB32 as DB32;
import djFlixel.gui.Align;
import djFlixel.gui.FlxAutoText;
import djFlixel.gui.Gui;
import flixel.FlxG;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;




/**
 * Simple FlxAutotext example,
 * Be sure to check "params.json"
 */
class State_FlxAutoText extends State_Demo
{
	var t:FlxAutoText;
	var prompt:FlxText;
	
	// --
	override public function create():Void 
	{
		super.create();
		
		// --
		t = new FlxAutoText(P.x, P.y, P.width, P.maxLines); add(t);
		t.style = P.style;
		t.onEvent = onFlxTextEvents; 
		t.setCarrierSymbol(P.carrier);
		t.sound.char = "short1";
		t.sound.wait = "short2";
		t.sound.end = "c_back";
		t.start(P.text, function(){ FlxG.resetState(); });
		
		// --
		prompt = Gui.getQText("", 8, DB32.COL[23],DB32.COL[1]);
		prompt.applyMarkup(P.contText, [
			Gui.getFormatRule("#", DB32.COL[28], DB32.COL[27])
		]);
		add(prompt);
		Align.XAxis(prompt, t, "center");
		Align.YAxis(prompt, t, "top", -32);
		prompt.visible = false;
		
	}//---------------------------------------------------;
	
	// --
	function onFlxTextEvents(s:String)
	{
		if (s == "pause")
		{
			FlxFlicker.flicker(prompt, 0, 0.2);
			
		}
		
		else if (s == "resume")
		{
			FlxFlicker.stopFlickering(prompt);
			prompt.visible = false;
		}
		
		else if (s == "newline") 
		{
			trace("Line No : " + t.lineCurrent);
		}
		
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (CTRL.justPressed(CTRL.A) || FlxG.mouse.justPressed )
		{
			t.resume();
		}	
	}//---------------------------------------------------;
	
}// --