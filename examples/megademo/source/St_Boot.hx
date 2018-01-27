package;
import common.Common;
import djFlixel.FLS;
import djFlixel.gui.FlxAutoText;
import djFlixel.fx.BoxFader;
import djFlixel.fx.StaticNoise;
import djFlixel.gui.Gui;
import djFlixel.tool.DataTool;
import flixel.FlxG;
import flixel.FlxState;

/**
 * First state`
 * ...
 */
class St_Boot extends FlxState
{
	// --
	var P:Dynamic;

	// --
	override public function create():Void
	{
		super.create();

		Common.setPixelPerfect();
		
		P = DataTool.copyFieldsC(FLS.JSON.St_Boot);
		
		// -- Add a static noise background
		var st = new StaticNoise(0, 0, 0, 0, P.noise); add(st);

		// --
		var t = new FlxAutoText(2, 2, 230); add(t);
		t.style = P.textStyle;

		t.sound.char = "short2";
		t.setCarrierSymbol(P.carrier);
		t.start(P.text, next);
		
	}//---------------------------------------------------;

	// --
	function next()
	{
		var p = new BoxFader(); add(p);
		p.fadeColor(P.colorBG, {
			callback:function() {
				FlxG.switchState(new St_Intro());
			}
		});
	}//---------------------------------------------------;
	// --
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		FLS.debug_keys();
	}//---------------------------------------------------;

}// --