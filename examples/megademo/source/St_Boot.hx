package;
import djFlixel.FLS;
import djFlixel.FlxAutoText;
import djFlixel.fx.PalleteFaderFake;
import djFlixel.fx.StaticNoise;
import djFlixel.gfx.Palette_Arne16;
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
		
		camera.bgColor = Palette_Arne16.COL[P.bgColor];
		
		var st = new StaticNoise(0,0,0,0,P.noise);
		add(st);
		
		var t = new FlxAutoText(0, 0, 320);
		add(t);
		t.start(P.text,next);
	}//---------------------------------------------------;
	
	function next()
	{
		var p = new PalleteFaderFake();
			add(p);
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