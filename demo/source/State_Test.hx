package ;
import djA.ArrayExecSync;
import djFlixel.D;
import djFlixel.core.Dcontrols.DButton;
import djFlixel.gfx.BoxScroller;
import djFlixel.gfx.PanelPop;
import djFlixel.gfx.SpriteEffects;
import djFlixel.gfx.StaticNoise;
import djFlixel.gfx.TextScroller;
import djFlixel.gfx.TextBouncer;
import djFlixel.gfx.BoxFader;
import djFlixel.gfx.FilterFader;
import djFlixel.gfx.pal.Pal_CPCBoy;
import djFlixel.gfx.statetransit.Stripes;
import djFlixel.ui.FlxToast;
import djFlixel.ui.UIButton;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import lime.system.System;
import openfl.geom.Rectangle;
import openfl.text.TextFormat;
import openfl.text.TextLineMetrics;
import djFlixel.ui.UIIndicator;


/** 
 * This state is for development-testing only
 */

class State_Test extends FlxState
{
	
	var upd:Void->Void;

	override public function create() 
	{
		super.create();
		
		bgColor = Pal_CPCBoy.COL[1];
		
		sub_stripes();
		//sub_buttons();
		//sub_toast();
		//sub_panelpop();
		//sub_infobox();
		//sub_testPixelFader();
		//sub_testLetterBounce();
		//sub_testLetterScroll();
		//sub_staticNoise();
		//sub_spriteeffects();
		//sub_slice9();
		//sub_text_metric();
		
	}//---------------------------------------------------
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (upd != null) upd();
		
	}//---------------------------------------------------;
	
	
	function sub_stripes()
	{
	
		Stripes.CREATE(()->{
			trace("STRIPES COMPLETE");
		}, {
			mode:"off,left",color:0xFFFFFFFF
		});
		
	}//---------------------------------------------------;
	
	function sub_toast()
	{
		// HACK. access does not work? make it public
		FlxG.watch.add(FlxTween.globalManager._tweens, "length", "Global Tweens");
		
		var t = FlxToast.FIRE("PRESS $ESC$ TO EXIT");
		
		upd = ()->{
			if (D.ctrl.justPressed(DButton.Y))
			{
				t.destroy();
			}else
			if (D.ctrl.justPressed(DButton.A))
			{
				t = FlxToast.FIRE("ANOTHER $ONE NEW$ and #FRESH#" + Math.random() * 10);
			}else
			
			if (D.ctrl.justPressed(DButton.START))
			{
				trace("NEW STATE BY SWITCH");
				Main.goto_state(State_Test);
				// Ok resets FlxTweens
			}
		}
	}//---------------------------------------------------;
	
	function sub_infobox()
	{
		var b = new common.InfoBox("Hello world this is a test\nMultiline $also$. Will this work? I don't #know#\nThree lines. Does this work? #YES#");
		add(D.align.screen(b));
		
		b.open(true);
	}//---------------------------------------------------;
	
	
	function sub_text_metric()
	{
		// HTML5 Text metrics test
		// Conclusion. When building from HaxeDevelop it breaks
		// Build from command line `lime build project.xml html5`
		
		function ADJ(T:FlxText, lead:Int)
		{
			var f = T.textField.getTextFormat();
			f.leading += lead;
			T.textField.setTextFormat(f);
		}
		
		var T1 = D.text.get("TEST 01", {f:"fnt/mozart.ttf", s:16});
		add(T1);
		#if (html5) 
		ADJ(T1, -6);
		#end
		T1.text = ".height:" + T1.height + "   .textField.textHeight:" + T1.textField.textHeight;
		
		var T2 = D.text.get("", {f:"fnt/mozart.ttf", s:16});
		add(D.align.down(T2, T1));
		
		T2.fieldWidth = 300;
		T2.text = "TEXT THAT WILL WRAP TO\nNEW LINE --\nAnother one\nagain.\nAnd another one --";
		trace("TEXT HEIGHT is ", T2.textField.textHeight);
		
		// FLASH : Textheight is 65
		// HTML5 : Textheight is 94.96 !!!

		function LS(n:Int)
		{
			var tm:TextLineMetrics = T2.textField.getLineMetrics(n);
			trace('h:' + tm.height, 'a:' + tm.ascent, 'desc:' + tm.descent, 'lead:' + tm.leading);
			var lh = tm.height;
			var O = new FlxSprite( T2.x + 2 , T2.y + 2 + (lh * n) );
				O.makeGraphic(cast tm.width, cast lh, 0x3300FF33);
				add(O);
		}

		for (i in 0...(T2.textField.numLines))
		{
			LS(i);
		}
		
	}//---------------------------------------------------;
	
	
	function sub_buttons()
	{
		var b = new UIButton("djFlixel button with text");
		add(D.align.screen(b));
		
		var c = new UIButton(D.ui.getIcon(12, 'heart'), {col1:[0x8C0B0E, 0xF0484D, 0]});
		add(D.align.right(c, b));
		
		c.onPress = (_)->{
			FlxToast.FIRE("Pressed Heart Button");
		}
		
	}//---------------------------------------------------;
	
	// OK WORKS
	function sub_panelpop()
	{
		var p = new PanelPop(200, 200);
		add(D.align.screen(p));
		
		p.start(()->{trace("first panel complete"); return; });
		add(D.align.screen(new PanelPop(52, 50,{colorBG:Pal_CPCBoy.COL[9]}).start(),  'l', 'b', 32));
		add(D.align.screen(new PanelPop(42, 90,{colorBG:Pal_CPCBoy.COL[10]}).start(), 'r', 't', 32));
	}//---------------------------------------------------;
	
	// OK WORKS
	function sub_slice9()
	{
		bgColor = Pal_CPCBoy.COL[5];
		
		var t = System.getTimer();
		var spr1:BitmapData = null;
		for (i in 0...500) {
			spr1 = D.bmu.scale9(D.ui.atlas.get_bn('panel'), new Rectangle(8, 8, 8, 8), 32 * 3, 32 * 3 ,true);
			spr1.floodFill(9, 9, 0xFF554433);
		}
		// Normal : ~260
		// No Center : ~140
		// No Center + flood : ~300
		trace("TIME :: " + (System.getTimer() - t));
		add(new FlxSprite(100, 64, spr1));
	}//---------------------------------------------------;
	
	
	// OK WORKS
	function sub_spriteeffects()
	{
		var effects = ['dissolve', 'wave', 'split', 'noiseline', 'noisebox', 'mask', 'blink'];
		var c = -1;
		var sp = new SpriteEffects('im/HAXELOGO.png');
		add(sp);
		add(D.text.get('Press [SPACE] to cycle between effects', 32, 220));
		var name:FlxText = cast add(D.text.get('', 32, 180, {c:Pal_CPCBoy.COL[7]}));
		
		upd = ()->{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (++c >= effects.length) c = 0;
				sp.removeEffectID('all');
				trace("Adding effect" , effects[c]);
				name.text = effects[c];
				sp.addEffect(effects[c]);
			}
		}
	}//---------------------------------------------------;
	
	
	// OK WORKS
	function sub_staticNoise()
	{
		var st = new StaticNoise(20, 20, 90, 90);
		st.color_custom([0xFF334455, 0xFF998899, 0xFF221199]);
		add(st);
		
	}//---------------------------------------------------;

	// OK WORKS
	function sub_testLetterScroll()
	{
		var ts = new TextScroller("DJFLIXEL DEMO", 
			{f:'fnt/mozart.ttf', s:16, bc:Pal_CPCBoy.COL[2]},
			{y:100,speed:2,sHeight:8,w1:0.06,w0:4});
		add(ts);
	}//---------------------------------------------------;
	
	// OK WORKS
	function sub_testLetterBounce()
	{
		var lb = new TextBouncer("HELLO WORLD", 100, 200, {f:'fnt/mozart.ttf', s:16, bc:Pal_CPCBoy.COL[2]}, {time:2, timeL:0.5});
		add(lb);
		lb.start(()->{
			trace("Bounce complete");
			return;
		});
	}//---------------------------------------------------;
	
	// OK WORKS
	function sub_testPixelFader()
	{
		add(new FlxSprite("im/HAXELOGO.png"));
		var st = new FilterFader(false,()->{
			trace("Filter complete");
			return;
		});
	}//---------------------------------------------------;
	
}// --