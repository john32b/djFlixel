package djFlixel.fx.particles;
import djFlixel.fx.particles.ParticlesGroup._ParticleJsonParams;
import djFlixel.tool.DynAssets;
import flixel.FlxSprite;

/**
 * ...
 * @author 
 */
class ParticleGeneric extends FlxSprite
{
	// --
	public var onComplete:Void->Void;
	
	// Length of the current animation
	var animLength:Int;
	
	// 0 : Forever
	// 1 : Play Once then kill/callback
	// N : Play N times then kill/callback
	var repeatTimes:Int;
	
	//====================================================;
	
	// --
	public function new(info:_ParticleJsonParams) 
	{
		super();
		
		loadGraphic(DynAssets.getImage(info.sheet), true, info.width, info.height);
		
		for (i in info.anims)
		{
			// Looped = true
			animation.add(i.name, i.frames, i.fps);
		}
		
	}//---------------------------------------------------;
	
	// --
	public function start(animationName:String, timesToPlay:Int = 1)
	{
		repeatTimes = timesToPlay;
		animation.play(animationName, true);
		
		// Don't call the callbackfunction if the animation loops forever
		if (timesToPlay > 0)
		{
			animLength = animation.getByName(animationName).numFrames - 1;
			animation.callback = __onAnimationEndStop;
		}else
		{
			animation.callback = null;
		}
	}//---------------------------------------------------;
	
	// --
	// Handle animation end
	function __onAnimationEndStop(_name:String, _index:Int, _frame:Int)
	{
		if (_index == animLength)
		{
			if (--repeatTimes == 0)
			{
				kill();
				if (onComplete != null) onComplete();
			}
		}
	}//---------------------------------------------------;
	
}// --


