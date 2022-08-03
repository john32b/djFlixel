package;

import djFlixel.D;
import djFlixel.gfx.BoxScroller;
import djFlixel.gfx.TextScroller;
import djFlixel.gfx.pal.Pal_DB32;
import djFlixel.other.FlxSequencer;

import flixel.FlxG;
import flixel.FlxState;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxColor;

class State_TextScroll extends FlxState
{
	var NEXTSTATE = State_Menu;
	var SCROLLER_TEXT =  "djFlixel - Tools and helpers for HaxeFlixel   "; // keep it short
	
	override public function create():Void 
	{
		super.create();
		
		add(new FlxSequencer((s)->{ switch(s.step) {
			case 1:
				Main.create_add_8bitLoader(0.7, s.nextV);
			case 2:
				// -- Paralax bg
				var colors = FlxColor.gradient(0xFF0080FF, 0xFF200050, 12);
				var parallaxes:Array<BoxScroller> = [];
				var h0 = 48;
				var inc = FlxG.height / (colors.length-1);
				for (i in 0...colors.length) {
					var b = new BoxScroller("im/stripe_02.png", 0, 0, FlxG.width);
						b.color = colors[i];
						b.autoScrollX = -(0.2 + (i * 0.15)) * (1 + (i * 0.06));
						b.randomOffset();
						parallaxes.push(b);
						b.x = 0;
						b.y = (inc * i) - 24;
						add(b);
				}
				s.next(0.6);
			case 3:
				// -- Particles
				var em = new FlxEmitter(320, 32, 64);
					em.height = 64;
					em.particleClass = ParBall;
					em.launchMode = FlxEmitterMode.SQUARE;
					em.velocity.set( -40, 0, -70);
					em.start(false, 0.3);
					em.lifespan.set(99); // Large lifespan, the particle will killself on offsreen
					add(em);
				s.next(1);
			case 4:
				// -- Text scroller
				var ts = new TextScroller(SCROLLER_TEXT, {
						s:16,
						c:Pal_DB32.COL[21],
						bc:Pal_DB32.COL[1],
						bt:2, bs:3
					}, {
						y:170,
						pad:1,
						speed:2.4,
						loopMode:0,	// no loop
						sHeight:20,
						w0:1.5
					});	
				ts.onLoop = s.nextV;
				add(ts);
			case 5:
				for (i in this) remove(i);
				var s = new SubState_Letters("DJFLIXEL", s.nextV,
				{c:Pal_DB32.COL[29]}, {snd:"cursor_low", tPre:0.4, tPost:0.2, colorBG:Pal_DB32.COL[1]} );
				openSubState(s);
			case 6:
				Main.goto_state(NEXTSTATE);
			case _:
		}}, 0));
		
	}//---------------------------------------------------;

	
}// -- end class --




/*************************************
   Ball Particle
   ***************
   - Moves up and down in a sine
   - Self kill when off-screen
*************************************/
class ParBall extends FlxParticle
{
	static var wMin = 32;	// Min Wave
	static var wMax = 64;	// Max Wave
	static var FREQ = 0.12;	// Update the wave every this seconds
	static var inc  = 0.4;
	var c:Float = 0; 
	var t:Float = 0;
	var w:Float = 0;
	// --
	public function new()
	{
		super();
		loadGraphic("im/ball_01.png", true, 16, 16, true);
		animation.add("main", [0, 1, 2, 3, 4, 5, 6], 14);
		lifespan = 0;
		// Randomize the color ::
		if (FlxG.random.bool()) {
			replaceColor(Pal_DB32.COL[28], Pal_DB32.COL[26]);
		}
		else if (FlxG.random.bool()) {
			replaceColor(Pal_DB32.COL[28], Pal_DB32.COL[17]);
			replaceColor(Pal_DB32.COL[8], Pal_DB32.COL[19]);
		}
	}//---------------------------------------------------;
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
		if ((t += elapsed) > FREQ) {
			t = 0;
			velocity.y = Math.sin(c) * w;
			c += inc;
			if (x > FlxG.width) kill();
		}
	}//---------------------------------------------------;
}//--
