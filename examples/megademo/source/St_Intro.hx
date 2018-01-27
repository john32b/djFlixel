package;
import common.Common;
import djFlixel.CTRL;
import djFlixel.FLS;
import djFlixel.SND;
import djFlixel.fx.TextBouncer;
import djFlixel.fx.RainbowStripes;
import djFlixel.fx.SpriteEffects;
import djFlixel.fx.substate.Stripes;
import djFlixel.gfx.GfxTool;
import djFlixel.gfx.MaskedSprite;
import djFlixel.gfx.Palette_Arne16;
import djFlixel.gui.Align;
import djFlixel.gui.Toast;
import djFlixel.tool.DataTool;
import djFlixel.tool.Sequencer;
import flixel.FlxG;
import flixel.FlxState;

/**
 * Intro State
 * Logos
 * ...
 */
class St_Intro extends FlxState
{
	// -- Helpers
	var logoWidth = 200; // Size of the image logo, some objects need to know this
	var logoHeight = 160;
	
	// --
	var seq:Sequencer;
	
	// Point to the JSON node parameters for quick accessing
	var P:Dynamic;
	
	var upd:Void->Void = null;
		
	// --
	override public function create():Void 
	{
		super.create();
		
		Common.setPixelPerfect();
		
		P = DataTool.copyFieldsC(FLS.JSON.St_intro);
		
		camera.bgColor = P.colorBG;
		
		// Rainbow
		var rb = new RainbowStripes(logoWidth, logoHeight);
			rb.COLORS = Palette_Arne16.COL.copy();
			rb.COLORS.splice(0, 1); // Remove the first black
			Align.screen(rb);
			
		// --
		var logo1 = new SpriteEffects("assets/DJLOGO.png", {tw:logoWidth, th:logoHeight, frame:1});
		Align.screen(logo1);
		
		// -- TOAST ::
		var t = new Toast(P.toast);
		add(t);
		
		// --
		seq = new Sequencer(function(step:Int){
		switch(step){
			case 1:
				add(rb);
				rb.setPredefined(2);
				logo1.addEffect("blink", P.l1_blink, seq.nextF);
				logo1.addEffect("wave", P.l1_wave);
				//#if (!neko) ! IT IS SLOW ON NEKO !
				logo1.addEffect("mask", {id:"mask", colorBG:P.colorBG}); 
				//#end
				add(logo1);
				
				t.fire("Music : $Deep Horizons$, by #DvD#");
			case 2:
				rb.setPredefined(0);
				seq.next(0.4);
			case 3:
				SND.playFile("fx1",0.8);
				rb.setPredefined(3);
				logo1.removeEffectID("wave");
				logo1.addEffect("noiseline", P.l1_line);
				seq.next(0.5);
				// -- 
			case 4:
				remove(rb);
				remove(logo1);
				camera.bgColor = P.colorBG2;
				logo1 = new SpriteEffects("assets/DJLOGO.png", {tw:logoWidth, th:logoHeight, frame:0});
				logo1.addEffect("noiseline", P.l1_line);
				Align.screen(logo1);
				add(logo1);
				camera.flash(0xFFFFFFFF, 0.2);
				seq.next(0.5);
				
				upd = function(){
					if (CTRL.CURSOR_START() || FlxG.keys.justPressed.ESCAPE  || FlxG.mouse.justPressed)
					{
						seq.forceTo(11);
						upd = null;
					}
				};
				
			case 5:
				logo1.removeEffectID("line");
				logo1.addEffect("split", {id:"split", color1:Palette_Arne16.COL[4], color2:Palette_Arne16.COL[14], width:4, ease:"", time:0.8 });
				logo1.addEffect("noisebox", P.l2_box);
				seq.next(1);
				// Shorter Time:
				t.fire("Press #ESC# to skip", {easeOut:"quadOut", timeTween:0.15});
			case 6:
				logo1.removeEffectID("nbox");
				logo1.addEffect("noiseline", P.l2_line, seq.nextF);
			case 7:
				SND.playFile("fx3",0.5);
				logo1.addEffect("dissolve", P.l2_diss, seq.nextF);
			case 8:
				camera.flash(0xFFFFFFFF, 0.14);
				remove(logo1);
				seq.next(0.2);
			//====================================================; -- Haxe Logo
			case 9:
				var hl = new SpriteEffects("assets/HAXELOGO.png");
				Align.screen(hl); add(hl);
				hl.addEffect("blink", {open:true}, seq.nextF);
				hl.addEffect("wave", P.l3_wave);
				SND.playFile("fx4",0.5);
			case 10:
				var tb = new TextBouncer("HAXEFLIXEL", 0, 0, {
						startY: -32,
						time:1.5,
						timeLetter:0.4,
						ease:"elasticOut",
						snd:"short2"
				});
				Align.screen(tb);
				tb.y += 40;
				add(tb);
				tb.start();
				seq.next(4);
			case 11:
				seq.cancel();	// make sure nothing calls seq.next() or whatever
				persistentUpdate = true;
				openSubState(new Stripes(
					"on-right", 
					NextState, {
					color:0xFFFFFFFF, soundID:"short2"
				}));
			default:
		}
		});
		
		seq.next(P.delay1);
		
		// If the music is already playing it will reset it.
		SND.playMusic("track1");
	}//---------------------------------------------------;
	

	// -- The sequence is complete, go to the next state
	function NextState()
	{
		FlxG.switchState(new St_Intro2());
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		FLS.debug_keys();
		
		if (upd != null) upd();
		
	}//---------------------------------------------------;
	
}//-- 