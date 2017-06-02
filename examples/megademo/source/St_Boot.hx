package;
import djFlixel.FLS;
import djFlixel.FlxAutoText;
import djFlixel.fx.PalleteFaderFake;
import djFlixel.fx.StaticNoise;
import djFlixel.gfx.GfxTool;
import djFlixel.gfx.Palette_Arne16;
import djFlixel.gui.Gui;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxTimer;

/**
 * ...
 */
class St_Boot extends FlxState
{

	
	// Json parameters node
	var P:Dynamic;
	
	// --
	override public function create():Void 
	{
		super.create();
		P = FLS.JSON.st_boot;
		
		// -- Add a static noise background
		var st = new StaticNoise(0,0,0,0,P.noise); add(st);
		// --
		
		//Gui.d_color = 0xFF333333;
		//Gui.d_box(30, 30, 200, 64);
		
		var t = new FlxAutoText(2, 2, 230); add(t);
		
		t.style = cast { size:8, color:0xFFFFFFFF, borderColor:0xFF447722 };
		//t.sound.char = "short1";
		//t.sound.wait = "short2";
		//t.sound.end = "c_back";
		t.setCarrierSymbol(P.carrier);
		t.start(P.text, next);
		
		// --
	}//---------------------------------------------------;
	
	// --
	function next()
	{
		var p = new PalleteFaderFake(); add(p);
		p.fadeColor(Palette_Arne16.COL[FLS.JSON.st_intro.bgColor], function(){
			FlxG.switchState(new St_Intro());
		});	
	}//---------------------------------------------------;
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		FLS.debug_keys();
	}//---------------------------------------------------;
	
	
}// --