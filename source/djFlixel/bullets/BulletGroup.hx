package djFlixel.bullets;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxVelocity;


// --
typedef _BulletJsonPAnims = {
	name:String,
	frames:Array<Int>,
	fps:Int
}
// --
typedef _BulletJsonParams = {
	height:Int,
	width:Int,
	sheet:String,
	anims:Array<_BulletJsonPAnims>
}



/**
 * Bullet Group managing Generic bullets
 * ------------------------------------------
 *  + Bullets will go on forever until out of screen, then killed
 *  + Bullets are being checked with a timer
 *  + Supports one spriteSheet and one class
 * 
 */
class BulletGroup extends FlxTypedGroup<FlxSprite>
{
	
	// Keep this many particles in a pool for quick retrieval
	var BUFFER_LEN:Int = 16;

	// The node object describing the particles
	var info:_BulletJsonParams;
	
	// Hold the number of active bullets
	var activeBullets:Int;
	
	// Last time bullets were checked for offscreen
	var checkTimer:Float;
	
	// Every x seconds, do an offscreen cleanup. 
	// this is to reduce cpu usage. Bullets don't need to be checked every frame
	var CHECK_FREQUENCY:Float = 1.5;
	
	//====================================================;

	/**
	 * Create a particle group
	 * @param	particleInfoNode The node name in the JSON params file
	 * @param	buffer Options, create this many particles for recycling
	 */
	public function new(bulletInfoNode:String, buffer:Int = 16 )
	{
		super();
		
		// maxSize = 0; Growing style.
		
		BUFFER_LEN = buffer;
		info = Reflect.getProperty(Reg.JSON, bulletInfoNode);
		
		// Create some buffer particles
		for (i in 0...BUFFER_LEN)
		{
			var b = _createNewBullet();
				b.kill();
			add(b);
		}
		
		activeBullets = 0;
		checkTimer = 0;
	}//---------------------------------------------------;
	
	/**
	 * Fire a bullet from this coordinates to X
	 * @param	type The animation name as defined on the params.json
	 * @param	x starting point, centered
	 * @param	y starting point, centered
	 */
	public function fireBulletAt(type:String, x:Float, y:Float, o:FlxSprite, speed:Float = 50)
	{
		var b = recycle(FlxSprite, _createNewBullet);
		
		// Put centered.
		b.setPosition(x - (b.width / 2) , y - (b.height / 2));
		b.animation.play(type, true);
		
		//	b.velocity.copyFrom(FlxVelocity.velocityFromAngle(FlxG.random.float(0, 360), 40));
		FlxVelocity.moveTowardsObject(b, o, speed);
		
		activeBullets++;
	}//---------------------------------------------------;	
	
	
	// --
	// Factory generator for bullets
	function _createNewBullet():FlxSprite
	{
		var b = new FlxSprite();
		b.loadGraphic(info.sheet, true, info.width, info.height);
		b.setSize(2, 2);
		b.centerOffsets();
		for (i in info.anims) {
			b.animation.add(i.name, i.frames, i.fps);
		}
		return b;
	}//---------------------------------------------------;
	
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (activeBullets > 0)
		{
			checkTimer += FlxG.elapsed;
			if (checkTimer >= CHECK_FREQUENCY)
			{
				checkTimer = 0;
				
				forEachAlive(function(bullet:FlxSprite) {
					if (Game.map.spriteIsOffScreen(bullet)) {
						activeBullets--;
						bullet.kill();
					}
				});
			}
		}
		
	}//---------------------------------------------------;

	

}// --