package djFlixel.gui;

import djFlixel.tool.DEST;
import flash.geom.Rectangle;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.NumTween;
import flixel.util.FlxSpriteUtil;

/**
 * A simple line that animated from left to right
 * ...
 * @author John Dimi
 */
class DecoLine extends FlxSprite 
{
	var t:NumTween;	// 
	var C:Int;		// Color

	public function new(?X:Float = 0, ?Y:Float = 0, ?WIDTH:Int = 100, ?HEIGHT:Int = 2, ?COLOR:Int = 0xFFFFFFFF)
	{
		super(X, Y);
		#if debug
		if (WIDTH <= 0 || HEIGHT <= 0) {
			trace('Error: WIDTH=$WIDTH HEIGHT=$HEIGHT .must be positive');
		}
		#end
		C = COLOR; makeGraphic(WIDTH, HEIGHT, 0x00000000);
	}//---------------------------------------------------;
	
	/**
	 * Resets the sprite and animates the line from the start
	 * @param	time Time to complete the animation
	 * @param	Ease The name of the ease function, check FlxEase.hx
	 * @param	callback When finished
	 */
	public function start(time:Float = 1, ?Ease:String = "linear", ?callback:FlxTween->Void)
	{
		// Reset tween and clear
		stop(true);
		t = FlxTween.num(0, width, time, {ease:Reflect.field(FlxEase, Ease)}, function(v:Float){
			FlxSpriteUtil.drawRect(this, 0, 0, Std.int(v), height, C);
		});
		
	}//---------------------------------------------------;
	public function stop(clear:Bool = false)
	{
		t = DEST.numTween(t);
		if (clear) {
			pixels.floodFill(0, 0, 0x00000000);
			dirty = true;
		}
	}//---------------------------------------------------;
	// --
	override public function destroy():Void 
	{
		stop();
		super.destroy();
	}//---------------------------------------------------;
	
}// -- end class