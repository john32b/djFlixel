/*
 * Very simple intro, 
 * text over static -> fade off -> next state
 ================================================= */
 
package;
import djFlixel.D;
import djFlixel.gfx.FilterFader;
import djFlixel.gfx.StaticNoise;
import djFlixel.gfx.pal.Pal_DB32.COL as COL;
import djFlixel.ui.FlxAutoText;
import djA.DataT;
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
		
		var RAND_BG   = [[1,2],[2,3],[13,14],[14,15],[24,25]];
		var RAND_TEXT = [[9,14],[8,4],[29,27],[21,25]];
		FlxG.random.shuffle(RAND_BG);
		FlxG.random.shuffle(RAND_TEXT);
		var R_BG = RAND_BG.pop();
		var R_TX = RAND_TEXT.pop();
		
		// -- Add a static noise background
		var st = new StaticNoise();
			st.color_custom([COL[R_BG[0]], COL[R_BG[1]]]);
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
			c:COL[R_TX[0]],
			bc:COL[R_TX[1]]
		};
		
		t.onComplete = ()->{
			D.snd.play('bleep1');
			Main.goto_state(NEXTSTATE, "fade");
		};
		
		t.setCaret("•");
		
		// Set text and autostart
		t.setText('{w:8,c:33}djFlixel ${D.DJFLX_VER}\n{w:4}Starting Demo{c:5}....{w:5}');
		
		t.onEvent = (e:AutoTextEvent) -> {
			trace(e);
		};
	}//---------------------------------------------------;
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ESCAPE){
			Main.goto_state(State_MainMenu);
		}
	}//---------------------------------------------------;	
	
}// --
