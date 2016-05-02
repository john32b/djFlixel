package djFlixel.fx.particles;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;



/**
 * Particle Group for Generic particles
 * Can be used to create and handle generic particles
 * ------------------------------------------
 *  + Supports one spriteSheet and one class
 * 
 */
class ParticlesGroup extends FlxTypedGroup<ParticleGeneric>
{
	
	// Keep this many particles in a pool for quick retrieval
	var BUFFER_LEN:Int = 16;

	// The node object describing the particles
	var info:_ParticleJsonParams;
	
	//====================================================;

	/**
	 * Create a particle group
	 * @param	particleInfoNode The node name in the JSON params file
	 * @param	buffer Options, create this many particles for recycling
	 */
	public function new(particleInfoNode:String, buffer:Int = 16 )
	{
		super();
		
		// maxSize = 0; Growing style.
		
		BUFFER_LEN = buffer;
		info = Reflect.getProperty(Reg.JSON, particleInfoNode);
		
		// Create some buffer particles
		for (i in 0...BUFFER_LEN)
		{
			var p = new ParticleGeneric(info);
			p.kill();
			add(p);
		}
		
	}//---------------------------------------------------;
	
	// --
	public function createOneAt(x:Float, y:Float, ?type:String, centerPivot:Bool = false):ParticleGeneric
	{
		var p:ParticleGeneric = recycle(ParticleGeneric, function() { return new ParticleGeneric(info); } );
		
		if (centerPivot)
		{
			p.setPosition(x - (p.width / 2) , y - (p.height / 2));
		}else
		{
			p.setPosition(x, y);
		}

		if (type != null) p.start(type);
		p.velocity.set(0, 0);
		
		return p;
	}//---------------------------------------------------;
	

	
	/**
	 * 
	 * @param	x World Coords
	 * @param	y World Coords
	 * @param	radius Maximum how far from the center to reach
	 * @param	type Child particle type
	 * @param	total Total number of particles to spawn
	 * @param	freq Spawn a particle every X seconds
	 * @param	soundID, if provided, will play this sound on each explosion
	 */
	public function createManyRandomAt(x:Float, y:Float, radius:Float, type:String, total:Int, 
										freq:Float = 0.14, ?soundID:String, ?onComplete:Void->Void)
	{
		var timer:FlxTimer = new FlxTimer();
		timer.start(freq, function(_) {
			createOneAt(x + FlxG.random.float(radius), y + FlxG.random.float(radius), type, false);
			if (soundID != null) SND.play(soundID);
			if (timer.loopsLeft == 0) {
				if (onComplete != null) onComplete();
			}
		},total - 1);
		// The first particle should start now
		createOneAt(x + FlxG.random.float(radius), y + FlxG.random.float(radius), type, false);
	}//---------------------------------------------------;
	

	// --
	public function popup(x:Float, y:Float, frame:Int)
	{
		var p = createOneAt(x, y, null, true);
		p.velocity.set(0, Reg.JSON._popup.speed);
		p.animation.frameIndex = frame;
		var timer:FlxTimer = new FlxTimer();
		timer.start(Reg.JSON._popup.timer1, function(_) {
			p.velocity.set(0, 0);
			FlxFlicker.flicker(p, Reg.JSON._popup.timer2, 0.03, true, true, function(_) { p.kill(); } );
		});
	}//---------------------------------------------------;
	
	
	/**
	 * Round out particles.
	 * @param	x World pos
	 * @param	y World pos
	 * @param	type Defined in the particleGeneric
	 * @param	numberOfParticles
	 * @param	speedMulti
	 */
	public function createCircular(x:Float, y:Float, type:String, numberOfParticles:Int = 4, speedMulti:Float = 1)
	{
		var baseSpeed:Int = Std.int(75 * speedMulti);
		var r1:Float = 0;
		var r1_step:Float = (2 * Math.PI) / numberOfParticles;
		var r1_third = r1_step / 3;
		var p:FlxSprite;
		
		r1 = Math.random() * r1_step;
	
		for (i in 0...numberOfParticles)
		{
			p = createOneAt(x, y, type, true);
			p.velocity.x = baseSpeed * Math.cos(r1);
			p.velocity.y = baseSpeed * Math.sin(r1);
			r1 += r1_step + Math.random() * (r1_third);
		}
		
	}//---------------------------------------------------;
	
}// --


// --
typedef _ParticleJsonPAnims = {
	name:String,
	frames:Array<Int>,
	fps:Int
}

// --
typedef _ParticleJsonParams = {
	height:Int,
	width:Int,
	sheet:String,
	anims:Array<_ParticleJsonPAnims>
}
