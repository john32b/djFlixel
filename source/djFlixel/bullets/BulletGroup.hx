package djFlixel.bullets;

import djFlixel.GroupBuffered;
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
class BulletGroup extends FlxTypedGroup<Bullet>
{
	
	// The node object describing the particles
	var info:_BulletJsonParams;
	var minSize:Int;

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
		minSize = buffer;
	
		info = Reflect.getProperty(Reg.JSON, bulletInfoNode);
		
		// Create some buffer particles
		for (i in 0...minSize)
		{
			var b = _createNewBullet();
				b.kill();
			add(b);
		}
		
		// NEW: No offscreen killer.
		
	}//---------------------------------------------------;
	
	/**
	 * Fire a bullet from this coordinates to X
	 * @param	type The animation name as defined in the parameters object
	 * @param	x starting point, centered
	 * @param	y starting point, centered
	 */
	public function fireBulletAt(type:String, x:Float, y:Float, o:FlxSprite, speed:Float = 50, TTL:Float = 1)
	{
		var b = recycle(Bullet, _createNewBullet);
		
		// Put centered.
		b.setPosition(x - (b.width / 2) , y - (b.height / 2));
		b.animation.play(type, true);
		b.start(TTL);
		
		//b.velocity.copyFrom(FlxVelocity.velocityFromAngle(FlxG.random.float(0, 360), 40));
		FlxVelocity.moveTowardsObject(b, o, speed);
	}//---------------------------------------------------;	
	
	// --
	// Factory generator for bullets
	function _createNewBullet():Bullet
	{
		var b = new Bullet();
		b.loadGraphic(info.sheet, true, info.width, info.height);
		b.setSize(2, 2);
		b.centerOffsets();
		for (i in info.anims) {
			b.animation.add(i.name, i.frames, i.fps);
		}
		return b;
	}//---------------------------------------------------;
	
	
	// -- Destroy all sprites exceeding the minSize
	//    The rest are killed()
	public function reset()
	{
		for (i in this) i.kill();
		
		if (minSize > 0 && length > minSize) {
			var delta:Int = length - minSize;
			for (i in 0...delta) { members.pop().destroy(); }
			length = members.length;
		}
	}//---------------------------------------------------;
	
}// --