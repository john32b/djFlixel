/*
 * Very simple intro, 
 * text over static -> fade off -> next state
 ================================================= */
 
package;
import djFlixel.D;
import djFlixel.core.Ddest;
import djFlixel.gfx.FilterFader;
import djFlixel.gfx.StaticNoise;
import djFlixel.gfx.pal.Pal_DB32;
import djFlixel.ui.FlxAutoText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class State_Boot extends FlxState
{
	var NEXTSTATE = State_Logos;
	// --
	override public function create():Void
	{
		super.create();
		
		// -- Add a static noise background
		var st = new StaticNoise();
			st.color_custom([Pal_DB32.COL[1], Pal_DB32.COL[2]]);
			add(st);

		// -- Some text
		var t = new FlxAutoText(4, 4, -1);
			add(t);

		// DEV REMINDER:
		// bleep0 is short asset name. Real asset name is `snd/bleep0.ogg` D.sound handles it.
		// Real Real asset path is `assets/sound_ogg/bleep0.ogg`. Renamed in project.xml
		t.sound.char = "bleep0"; 
		
		t.style = {
			f:'fnt/mozart.ttf',
			s:16,
			c:Pal_DB32.COL[9],
			bc:Pal_DB32.COL[14]
		};
		
		t.onComplete = ()->{
			D.snd.play('bleep1');
			Main.goto_state(NEXTSTATE, "fade");
		};
		
		t.setCarrier("|");	// Set the carrier after setting the text style
		
		// Set text and autostart
		t.setText('{w:8,c:33}djFlixel ${D.DJFLX_VER}\n{w:4}Starting Demo{c:5}....{w:5}');
		
		t.onEvent = (e:AutoTextEvent) -> {
			trace(e);
		};
	}//---------------------------------------------------;
}// --