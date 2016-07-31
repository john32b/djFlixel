package djFlixel.bullets;

import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author JohnDimi
 */
class Bullet extends FlxSprite
{

	var timeToLive:Float;
	var flag_flicker:Bool;
	
	public function start(TTL:Float = 5)
	{
		timeToLive = TTL;
		FlxFlicker.stopFlickering(this);
		flag_flicker = false;
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (alive) {	
			timeToLive-= elapsed;
			if (timeToLive <= 0) {
				kill();
			}else
			if (timeToLive <= 0.5 && !flag_flicker) {
				FlxFlicker.flicker(this, 0.5);
				flag_flicker = true;
			}
			
		}
	}//---------------------------------------------------;

}