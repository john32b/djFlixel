package djFlixel.gui;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/// IN DEVELOPMENT

/**
 * Animate objects in and out of view
 * ...
 * EXPERIMENTAL, BETA,
 * STATIC CLASS
 */

class PageAnimator
{	
	
	static public function fromleft(
					xpoint:Float, amount:Float, 
					elIN:FlxSprite, ?elOUT:FlxSprite, ?callbackComplete:Void->Void )
	{
		var animTime = 0.4;
		var easeFN = FlxEase.backOut;
		elIN.x -= amount;
		elIN.alpha = 0;
		FlxTween.tween(elIN, { x:xpoint, alpha:1 }, animTime, 
						{ ease:easeFN, onComplete:function(_) {
							if (callbackComplete != null) 
								callbackComplete();
						}
		});
		
		if (elOUT != null)
		FlxTween.tween(elOUT, { x:elOUT.x + amount, alpha:0 }, animTime, { ease:easeFN } );
	}//---------------------------------------------------;

}// --