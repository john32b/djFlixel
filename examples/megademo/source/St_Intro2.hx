package;
import djFlixel.FLS;
import djFlixel.fx.BoxScroller;
import djFlixel.fx.PalleteFaderFake;
import djFlixel.gfx.Palette_Arne16;
import djFlixel.gui.Align;
import flixel.FlxG;
import flixel.FlxState;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;


/**
 * Intro part 2, a paralax sky with a dialog box
 */
class St_Intro2 extends FlxState
{
	// Quick reference parameters object, read from the params.json file
	var P:Dynamic;
	
	// -
	override public function create():Void 
	{
		super.create();
		
		// --
		P = FLS.JSON.st_intro2;
		
		
		// -- 
		// -- Create a parallax background 
		var parallaxes:Array<BoxScroller> = [];
		var col:Int = Palette_Arne16.length; // Create as many stripes as this much colors on the palette
		for (i in 1...col) {
			var p = new BoxScroller("assets/stripe_01.png", 0, 0, FlxG.width);
				p.color = Palette_Arne16.COL[col--];
				p.autoScrollX = -(0.2 + (i * 0.15)) * (1 + (i * 0.06));
				p.randomOffset();
				parallaxes.push(p);
				add(p);
		}
		// Aligns the boxes vertically, equally spaced from each-other
		Align.inVLine(0, 0, FlxG.height, cast parallaxes, "justify");
		
		
		
		// --
		// -- Create a bunch of birds flying from left to right
		var em = new FlxEmitter(P.emitter.x, P.emitter.y, P.emitter.size);
		em.height = P.emitter.h;
		em.particleClass = ParBird;
		em.launchMode = FlxEmitterMode.SQUARE;
		em.velocity.set(P.emitter.vx0, 0, P.emitter.vx1);
		em.start(false, P.emitter.freq);
		em.lifespan.set(99); // Large lifespan, the particle will killself if offsreen
		add(em);
		
		
		
		// --
		// -- Fade the screen from white
		var p = new PalleteFaderFake();
		add(p);
		p.solidColor(0xFFFFFFFF, 0.2, function(){remove(p); });
	}//---------------------------------------------------;
	
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		FLS.debug_keys();
	}//---------------------------------------------------;
	
	
}// --


//====================================================;
// The bird particles, will move up and down in a sine
// Also will self-kill() when offscreen
//====================================================;

class ParBird extends FlxParticle
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
		loadGraphic("assets/bird_anim.png", true, 16, 16);
		animation.add("var1", [0, 1, 2, 3], 14);
		animation.add("var2", [4, 5, 6, 7], 14);
		animation.add("var3", [8, 9,10,11], 14);
		lifespan = 0;
	}//---------------------------------------------------;
	//--
	override public function onEmit():Void 
	{
		super.onEmit();
		animation.play("var" + FlxG.random.int(1, 3));
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
