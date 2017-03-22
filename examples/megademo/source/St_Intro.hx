package;
import djFlixel.FLS;
import djFlixel.SND;
import djFlixel.TextBouncer;
import djFlixel.fx.BoxScroller;
import djFlixel.fx.RainbowBorder;
import djFlixel.fx.SpriteEffects;
import djFlixel.fx.substate.Stripes;
import djFlixel.gfx.GfxTool;
import djFlixel.gfx.MaskedSprite;
import djFlixel.gfx.Palette_Arne16;
import djFlixel.gui.Align;
import djFlixel.tool.Sequencer;
import flixel.FlxG;
import flixel.FlxState;

/**
 * Intro State,
 * Show some logos
 * ...
 */
class St_Intro extends FlxState
{
	// -- Helpers
	var logoWidth = 200; // Other elements need to know this
	var logoHeight = 160;
	// --
	var seq:Sequencer;
	// Json parameters node
	var P:Dynamic;
	// --
	override public function create():Void 
	{
		super.create();
		P = FLS.JSON.st_intro;
		camera.bgColor = Palette_Arne16.COL[P.bgColor];
		
		// Rainbow
		var rb = new RainbowBorder(logoWidth, logoHeight);
			rb.COLORS = Palette_Arne16.COL.copy();
			rb.COLORS.splice(0, 1); // Remove the first black
			Align.screen(rb);
			
		// --
		var logo1 = new SpriteEffects("assets/DJLOGO.png", {tw:logoWidth, th:logoHeight, frame:1});
		Align.screen(logo1);
		
		seq = new Sequencer(function(step:Int){
		switch(step){
			case 1:
				add(rb);
				rb.setPredefined(2);
				logo1.addEffect("blink", P.l1_blink, seq.nextF);
				logo1.addEffect("wave", P.l1_wave);
				logo1.addEffect("mask", {id:"mask", colorBG:Palette_Arne16.COL[P.bgColor]});
				add(logo1);
			case 2:
				rb.setPredefined(0);
				seq.next(0.4);
			case 3:
				SND.playFile("fx1",0.8);
				rb.setPredefined(3);
				logo1.removeEffectID("wave");
				logo1.addEffect("noiseline", P.l1_line);
				seq.next(0.5);
			case 4:
				remove(rb);
				remove(logo1);
				camera.bgColor = Palette_Arne16.COL[P.bgColor2];
				logo1 = new SpriteEffects("assets/DJLOGO.png", {tw:logoWidth, th:logoHeight, frame:0});
				logo1.addEffect("noiseline", P.l1_line);
				Align.screen(logo1);
				add(logo1);
				camera.flash(0xFFFFFFFF, 0.2);
				seq.next(0.5);
			case 5:
				logo1.removeEffectID("line");
				logo1.addEffect("split", {id:"split", color1:Palette_Arne16.COL[4], color2:Palette_Arne16.COL[14], width:4, ease:"", time:0.8 });
				logo1.addEffect("noisebox", P.l2_box);
				seq.next(1);
			case 6:
				logo1.removeEffectID("nbox");
				logo1.addEffect("noiseline", P.l2_line, seq.nextF);
			case 7:
				SND.playFile("fx3",0.5);
				logo1.addEffect("dissolve", P.l2_diss, seq.nextF);
			case 8:
				remove(logo1);
				camera.flash(0xFFFFFFFF, 0.2);
				seq.next(0.2);
			//====================================================; -- Haxe Logo
			case 9:
				var hl = new SpriteEffects("assets/HAXELOGO.png");
				Align.screen(hl); add(hl);
				hl.addEffect("blink", {open:true}, seq.nextF);
				hl.addEffect("wave", P.l3_wave);
				SND.playFile("fx4",0.5);
			case 10:
				var tb = new TextBouncer("HAXEFLIXEL", 8, 0, 150, {alignX:true, height:64});
				add(tb);
				tb.start();
				seq.next(4);
			case 11:
				persistentUpdate = true;
				openSubState(new Stripes("on-right", {color:0xFFFFFFFF, soundID:"short2"},
					function(){FlxG.resetState();}));
			default:
		}
		});
		seq.next(P.delay1);
		SND.playMusic("track1");
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		FLS.debug_keys();
	}//---------------------------------------------------;
	
}//-- 