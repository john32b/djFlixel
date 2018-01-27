package;

import common.Common;
import common.SubState_Letters;
import djFlixel.CTRL;
import djFlixel.FLS;
import djFlixel.SND;
import djFlixel.fx.BoxScroller;
import djFlixel.fx.FilterFader;
import djFlixel.fx.TextScroller;
import djFlixel.gfx.Palette_DB32;
import djFlixel.gui.Align;
import djFlixel.gui.Toast;
import djFlixel.tool.DataTool;
import djFlixel.tool.Sequencer;
import flixel.FlxG;
import flixel.FlxState;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxColor;


/**
 * Intro part 2, a paralax sky with a dialog box
 */
class St_Intro2 extends FlxState
{
	// Quick reference parameters object, read from the params.json file
	var P:Dynamic;
	
	// --
	var seq:Sequencer;

	var upd:Void->Void = null;
	// -
	override public function create():Void 
	{
		super.create();
		
		Common.setPixelPerfect();
		
		P = DataTool.copyFieldsC(FLS.JSON.St_intro2);
		
		camera.bgColor = P.colorBG;
	
		seq = new Sequencer(function(step){
		switch(step) { default:
			
		case 1:
			seq.nextF();
			
		case 2:
			Common.create_8bitLoader(0.7, seq.nextF);
			
		case 3:
			create_paralax();
			seq.next(0.6);
			
		case 4:
			create_particles();
			seq.next(0.5);
			
		case 5:
			// Sine Text Scroller
			var ts = new TextScroller(P.sineText, seq.nextF, P.sineParams);
			add(ts);
			
			// --
			var t = new Toast(FLS.JSON.St_intro.toast);
			add(t);
			t.fire("Press #ESC# to skip", {easeOut:"quadOut", timeTween:0.15});
			upd = function(){
				if (FlxG.keys.justPressed.ESCAPE || CTRL.CURSOR_OK() || FlxG.mouse.justPressed)
				{
					ts.callback = null; // ensure it doesn't fire
					seq.next();
				}
			}
			
		case 6:
			upd = null;
			// Fade to black
			new FilterFader("toblack", seq.nextF, {autoRemove:true});
			
		case 7:
			// Show FX letters
			var s = new SubState_Letters("DJFLIXEL", seq.nextF, P.lettersFX);
			openSubState(s);
			
		case 8:
			FlxG.switchState(new St_Menu());
			
		}});
		
		seq.next();

	}//---------------------------------------------------;
	

	
	// -- Create a parallax gradient background 
	// -- 
	function create_paralax()
	{
		var colors = FlxColor.gradient(P.gradient.colorA, P.gradient.colorB, P.gradient.steps);
		var parallaxes:Array<BoxScroller> = [];
		
		for (i in 0...colors.length) 
		{
			var b = new BoxScroller("assets/stripe_02.png", 0, 0, FlxG.width);
				b.color = colors[i];
				b.autoScrollX = -(0.2 + (i * 0.15)) * (1 + (i * 0.06));
				b.randomOffset();
				parallaxes.push(b);
				add(b);
		}
		
		// Aligns the boxes vertically, equally spaced from each-other
		Align.inVLine(0, 0, FlxG.height, cast parallaxes, "justify");
	}//---------------------------------------------------;
	
	
	
	// -- Create a bunch of particles flying from left to right
	// --
	function create_particles()
	{
		var em = new FlxEmitter(P.emitter.x, P.emitter.y, P.emitter.size);
		em.height = P.emitter.h;
		em.particleClass = ParBall;
		em.launchMode = FlxEmitterMode.SQUARE;
		em.velocity.set(P.emitter.vx0, 0, P.emitter.vx1);
		em.start(false, P.emitter.freq);
		em.lifespan.set(99); // Large lifespan, the particle will killself on offsreen
		add(em);
	}//---------------------------------------------------;
	
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		FLS.debug_keys();
		if (upd != null) upd();
	}//---------------------------------------------------;
	
	
}// --


//====================================================;
// The particles, will move up and down in a sine
// Also will self-kill() when offscreen
//====================================================;

class ParBall extends FlxParticle
{
	static var wMin:Int = 32;	 // Min Wave
	static var wMax:Int = 64;	 // Max Wave
	static var FREQ:Float = 0.1; // Update the wave every 0.1 seconds
	static var inc:Float = 0.4;
	var c:Float = 0; 
	var t:Float = 0;
	var w:Float = 0;
	// --
	public function new()
	{
		super();
		loadGraphic("assets/ball_01.png", true, 16, 16, true);
		animation.add("main", [0, 1, 2, 3, 4, 5, 6], 14);
		lifespan = 0;
		
		// Randomize the color ::
		if (FlxG.random.bool())
		{
			replaceColor(Palette_DB32.COL[28], Palette_DB32.COL[26]);
		}
		else
		{
			if (FlxG.random.bool())
			{
				replaceColor(Palette_DB32.COL[28], Palette_DB32.COL[17]);
				replaceColor(Palette_DB32.COL[8], Palette_DB32.COL[19]);
			}
		}
	}//---------------------------------------------------;
	//--
	override public function onEmit():Void 
	{
		super.onEmit();
		animation.play("main");
		c = Math.random() * Math.PI;
		w = FlxG.random.int(wMin, wMax);
	}//---------------------------------------------------;
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		t += elapsed;
		
		if (t > FREQ){
			t = 0;
			velocity.y = Math.sin(c) * w;
			c += inc;
			if (x > FlxG.width) kill();
		}
	}//---------------------------------------------------;
}//--
