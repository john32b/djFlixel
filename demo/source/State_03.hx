/*****************************
 FlxAutotext Demo
******************************/

package ;
import djA.DataT;
import djFlixel.D;
import djFlixel.gfx.BoxScroller;
import djFlixel.gfx.StarfieldSimple;
import djFlixel.gfx.pal.Pal_DB32;
import djFlixel.gfx.statetransit.Stripes;
import djFlixel.other.DelayCall;
import djFlixel.other.FlxSequencer;
import djFlixel.ui.FlxAutoText;
import djFlixel.ui.FlxMenu;
import djFlixel.ui.FlxSlides;
import djFlixel.ui.UIIndicator;
import djFlixel.ui.menu.MPageData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.text.FlxText;


class State_03 extends FlxState
{
	var AT:FlxAutoText;

	override public function create() 
	{
		super.create();
		
		bgColor = 0xFF040408;
		
		// -- Scroller
		var b = new BoxScroller("im/stripe_01.png", 0, -20, FlxG.width);
			b.color = 0xFF313548;
			b.autoScrollX = 1;
			b.randomOffset();
			add(b);
		var b1 = new BoxScroller("im/stripe_01.png", 0, FlxG.height - 20, FlxG.width);
			b1.color = 0xFF313548;
			b1.autoScrollX = 1;
			b1.randomOffset();
			add(b1);
				
		// -- Next Symbol
		var ns = new UIIndicator('12:ar_right');
		D.align.screen(ns, 'r', 'b', 12);
		ns.lockPos();	//<- important, do this after setting the final position of the UI Indicator
		ns.applyFX({c:0xFFB1ACF0});
		ns.setAnim(1, {axis:'x'});
		add(ns);
		
		// -- Autotext
		AT = new FlxAutoText(18, 0, 280, 0);
		AT.sound.pause = "cursor_low";
		D.align.screen(AT, 'c', 't', 32); // centerx, 64 from top
		AT.style = {f:"fnt/mozart.ttf", s:16, c:0xFFFFFFFF,bc:0xFF2B2B24};
		AT.setCarrier('-', 0.15);
		AT.onComplete = textComplete;
		AT.onEvent = (e)->{
			if (e == pause || e==complete) {
				ns.setEnabled(true);
			}else
			if (e == resume) {
				ns.setEnabled(false);
			}
		};
		
		AT.setText(
			'{c:30}FLXAUTOTEXT ::{w:5}\n' + 
			'{w:1}Provides a simple way to create and control auto-typing text with custom tags like {wm:3,c:100}changing the characters per second on the fly.{w:10,c:60}Waiting custom times, etc.\n' +
			'{w:10,wm:0,c:40}The carrier symbol is optional and you can turn it off even in a tag like so{sp:0}. Also linebreaks are autocalculated from beforehand so no weird text jumping when the text reaches the end of the area.\n' +
			'- Press [J,V] or CLICK for next page -'+
			'{w:0,np}Can also be used as a bare-bones dialog box, as it supports some preliminary dialog box functions like <newpage> and <pausing>.\n' +
			'- Press [J,V] or CLICK to return -'
		);
		
		add(AT);
		
	}//---------------------------------------------------;

	
	function textComplete()
	{
		trace("Text Complete");
		// This is redundant, I have already set onEvent()
	}//---------------------------------------------------;
	
	var t = 0;
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (FlxG.mouse.justPressed || D.ctrl.justPressed(A))
		{
			if (AT.isPaused) AT.resume(); else
			if (AT.isComplete) 
			{
				if (t == 1) return;
				t = 1;
				Main.create_add_8bitLoader(0.6, State_01);
			}
		}
			
	}//---------------------------------------------------;
	
	
}// --