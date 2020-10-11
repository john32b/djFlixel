/*
 * Very simple intro, 
 * text over static -> fade off -> next state
 ================================================= */
 
package;
import djFlixel.D;
import djFlixel.gfx.FilterFader;
import djFlixel.gfx.StaticNoise;
import djFlixel.gfx.pal.Pal_DB32;
import djFlixel.ui.FlxAutoText;
import flixel.FlxG;
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
		var t = new FlxAutoText(4, 4);
			add(t);
		t.sound.char = "bleep0";
		t.setCarrier("_");
		t.style = {
			f:'fnt/mozart.ttf',
			s:16,
			c:Pal_DB32.COL[9],
			bc:Pal_DB32.COL[14]
		};
		t.onComplete = ()->{
			D.snd.play('bleep1');
			new FilterFader(()->{Main.goto_state(NEXTSTATE);});
		};
		t.setText('{w:8,c:32}djFlixel ' + D.DJFLX_VER + '\n{w:4}Starting Demo{c:4}....{w:10}');
		
	}//---------------------------------------------------;
}// --