package djFlixel.fx.particles;
import djFlixel.fx.particles.ParticlesGroup._ParticleJsonParams;
import djFlixel.tool.DynAssets;
import flixel.FlxG;
import flixel.FlxSprite;


// NOTE: Really immature, Needs updating

/**
 * Simple Particle, Managed by "ParticlesGroup.hx"
 * ...
 * Is not responsible for animation
 * particle animation is done by the manager
 */
class ParticleGeneric extends FlxSprite
{
	// Optional, gets called on particle life completion
	public var onComplete:Void->Void;
	
	// 0 : Forever
	// 1 : Play Once then kill/callback
	// N : Play N times then kill/callback
	var repeatTimes:Int;
	
	//====================================================;
	
	// --
	public function new(info:_ParticleJsonParams) 
	{
		super();
		
		loadGraphic(info.sheet, true, info.width, info.height);
		
		if (info.anims != null)
		for (i in info.anims) {
			// Looped = true
			animation.add(i.name, i.frames, i.fps, false);
		}
		
		animation.finishCallback = __onAnimationFinish;
		
	}//---------------------------------------------------;
	
	// --
	// NOTE: Be careful when setting the times to play to 0
	//		 You will need to kill the particle manually
	public function start(animationName:String, timesToPlay:Int = 1)
	{
		repeatTimes = timesToPlay;
		animation.play(animationName, true);
	}//---------------------------------------------------;
	
	// --
	// Handle animation end
	function __onAnimationFinish(_name:String)
	{		
		if (--repeatTimes == 0) // Infinite particles eventually are going to stop after 4 billion times.
		{
			kill();
			if (onComplete != null) onComplete();
		}else {	
			animation.curAnim.restart();
		}
	}//---------------------------------------------------;
	
}// --


