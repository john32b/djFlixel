package ;
import djFlixel.D;
import djFlixel.gfx.RainbowStripes;
import djFlixel.gfx.SpriteEffects;
import djFlixel.gfx.TextBouncer;
import djFlixel.gfx.pal.Pal_DB32;
import djFlixel.gfx.statetransit.Stripes;
import djFlixel.other.DelayCall;
import djFlixel.other.FlxSequencer;
import djFlixel.ui.FlxToast;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;


class State_Logos extends FlxState
{
	var NEXTSTATE = State_TextScroll;
	var logoWidth = 200;
	var logoHeight = 160;
	var COLOR_BG = Pal_DB32.COL[0];
	var COLOR_BG2 = Pal_DB32.COL[2];
	var COLOR_BG3 = Pal_DB32.COL[25];
	var rb:RainbowStripes;
	var logo:SpriteEffects;

	override public function create() 
	{
		super.create();
		
		bgColor = COLOR_BG;
		
		// -- I could break this up, but I am doing the whole thing in one go:
		
		add(new FlxSequencer((s)->{ switch(s.step) {
			case 1:
				rb = new RainbowStripes(logoWidth, logoHeight);
				rb.COLORS = Pal_DB32.COL.copy();
				rb.COLORS.splice(0, 1);	// Remove the first black color
				add(D.align.screen(rb));
				// --
				logo = new SpriteEffects('im/DJLOGO.png', {tw:logoWidth, th:logoHeight, frame:1});
				add(D.align.screen(logo));
				logo.addEffect("blink", { time:2.8, open:true }, s.nextV);
				logo.addEffect("wave",  { id:"wave", time : 1, width : 3, height : 0.5 });
				logo.addEffect("mask",  { colorBG:COLOR_BG}); 
				rb.setMode(2);
				rb.setOn();
			case 2:
				rb.setMode(0);
				s.next(0.4);
			case 3:
				D.snd.play('fx1', 0.8);
				rb.setMode(3);
				logo.removeEffectID("wave");
				logo.addEffect("noiseline", {h0 : 2, w0 : 20, time : 0 });
				s.next(0.5);
			case 4:
				remove(rb);
				remove(logo);
				bgColor = COLOR_BG2;
				logo = new SpriteEffects('im/DJLOGO.png', {tw:logoWidth, th:logoHeight, frame:0});
				logo.addEffect("noiseline", { id:"line", h0 : 2, w0 : 20, time : 0});
				add(D.align.screen(logo));
				camera.flash(0xFFFFFFFF, 0.2);
				s.next(0.5);
			case 5:
				logo.removeEffectID("line");
				logo.addEffect("split", {id:"split", color1:Pal_DB32.COL[28], color2:Pal_DB32.COL[18], width:3, ease:"", time:0.8 });
				logo.addEffect("noisebox", { id:"nbox", w:6, j1:4, time:0 });
				s.next(1);
			case 6:
				logo.removeEffectID("nbox");
				logo.addEffect("noiseline", { id:"nline2", FX2:true, time:2, w1:4, run:2 }, s.nextV);
			case 7:
				D.snd.play('fx3', 0.5);
				logo.addEffect("dissolve", { time:1, size:12 }, s.nextV);
			case 8:
				bgColor = COLOR_BG3;
				camera.flash(0xFFFFFFFF, 0.14);
				remove(logo);
				s.next(0.3);
			//====================================================; -- Haxe Logo
			case 9:
				logo = new SpriteEffects('im/HAXELOGO.png');
				logo.addEffect("wave", { time : 1.75, width : 2, height : 0.6});
				logo.addEffect("blink", {open:true, time:2}, s.nextV);
				D.snd.play('fx4', 0.5);
				// DEV: There is a bug with the wave effect. Somehow for a frame it draws the whole thing
				//      This is why I am delaying the adding a bit
				new DelayCall(0.1, ()->{
					add(D.align.screen(logo));
				});
				
			case 10:
				var tb = new TextBouncer("HAXEFLIXEL", 0, 0, {
					startY: -32,
					time:1.5,
					timeL:0.4,
					ease:"elasticOut",
					snd0:"hihat"
				});
				add(D.align.screen(tb));
				tb.y += 40;
				tb.start();
				s.next(4);
			case 11:
				// Stripes Substate
				persistentUpdate = true;
				openSubState(new Stripes( ()->{
					Main.goto_state(NEXTSTATE);
					}, {
						mode:"on-right",
						color:0xFFFFFFFF,
						snd:"hihat"
					}	
				));
				
			case _:
		}}, 0)); // 0 = Start sequencer now.
		
		D.snd.playMusic('track1');
	}//---------------------------------------------------
	
}// --