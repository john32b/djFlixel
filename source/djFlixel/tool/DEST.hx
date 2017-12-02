package djFlixel.tool;

import flixel.tweens.misc.NumTween;
import flixel.tweens.misc.VarTween;
import flixel.util.FlxTimer;
import flixel.util.FlxDestroyUtil;

/**
 * Object DESTroyer
 * Kind of like the FlxDestroyUtil class
 * But destroys more specific objects like timers and tweens
 * ------------------------------------------------------
 */
class DEST
{
	/**
	 * Quickly cancel() and destroy() a timer with one call
	 */
	public static function timer(t:FlxTimer):FlxTimer
	{
		if (t != null) {
			t.cancel(); t.destroy();
		} return null;
	}//---------------------------------------------------;	
	
	/**
	 * Cancels a Tween
	 */
	public static function tween(t:VarTween):VarTween
	{
		if (t != null) {
			t.cancel(); t.destroy();
		} return null;
	}//---------------------------------------------------;	
	
	/**
	* Cancel a numeric Tween
	*/
	public static function numTween(t:NumTween):NumTween
	{
		if (t != null) {
			t.cancel(); t.destroy();
		} return null;
	}//---------------------------------------------------;
	
	/**
	 * Destroy an Array of Tweens
	 * @return
	 */
	public static function tweenAr(a:Array<VarTween>):Array<VarTween>
	{
		if (a != null) {
			for (i in a) i = tween(i); 
		} return null;
	}//---------------------------------------------------;
	
	/**
	 * Destroy a MAP containing IFlxDestroyables
	 */
	public static function map<A,B:(IFlxDestroyable)>(m:Map<A,B>):Map<A,B>
	{
		if (m != null){
			for (e in m) { e.destroy(); e = null;}
		}
		return null;
	}//---------------------------------------------------;
	
}// -- 