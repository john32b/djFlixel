package djFlixel.gui;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;




// --
// Simple tool to scroll pages/objects in and out of the view
class PageScroller
{

	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	
	//====================================================;
	// 
	//====================================================;
	// --
	public function new(X:Float,Y:Float,W:Float,H:Float)
	{
		x = X;
		y = Y;
		width = W;
		height = H;
	}//---------------------------------------------------;
	
	// --
	public function animateIN(newObj:FlxSprite, oldObj:FlxSprite)
	{
		// can be a simple tween, or a sequence of tweens?
		// Fire a callback on complete?
	}//---------------------------------------------------;
	
}// --