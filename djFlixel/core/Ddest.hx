/**
	DJFlixel Object DESTroyer
	================
	
	- Accessible from (D.dest)
	
	- This is like the FlxDestroyUtil class
	  But destroys more specific objects like timers and tweens
 
*******************************************/

 
package djFlixel.core;

import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.tweens.misc.NumTween;
import flixel.tweens.misc.VarTween;
import flixel.util.FlxTimer;
import flixel.util.FlxDestroyUtil;


@:dce
class Ddest
{
	
	public function new() {}
	
	/**
	 * Quickly cancel() and destroy() a timer with one call
	 */
	public function timer(t:FlxTimer):FlxTimer
	{
		if (t != null) {
			t.cancel(); t.destroy();
		} return null;
	}//---------------------------------------------------;	
	
	/**
	 * Cancels a Tween
	 */
	public function tween(t:VarTween):VarTween
	{
		if (t != null) {
			t.cancel(); t.destroy();
		} return null;
	}//---------------------------------------------------;	
	
	public function numTween(t:NumTween):NumTween
	{
		if (t != null) {
			t.cancel(); t.destroy();
		} return null;
	}//---------------------------------------------------;
	
	/**
	 * Destroy an Array of Tweens
	 * @return
	 */
	public function tweenAr(a:Array<VarTween>):Array<VarTween>
	{
		if (a != null) {
			for (i in a) i = tween(i); 
		} return null;
	}//---------------------------------------------------;
	
	/**
	 * Destroy a MAP containing IFlxDestroyables
	 */
	public function map<A,B:(IFlxDestroyable)>(m:Map<A,B>):Map<A,B>
	{
		if (m != null){
			for (e in m) { e.destroy(); e = null;}
		}
		return null;
	}//---------------------------------------------------;
	
	/**
	   Kill all group elements.
	   Keep (X) amount and destroy the rest
	   @param	gr
	   @param	keep
	**/
	public function groupKeep(gr:FlxGroup, X:Int = 1)
	{
		var keep:Array<FlxBasic> = [];
		for (m in gr.members) {
				m.kill();
			if (keep.length < X) {
				keep.push(m);
			}else{
				m.destroy();
			}
		}
		gr.clear(); // remove all
		for (m in keep) gr.add(m); // add the ones I kept
	}//---------------------------------------------------;
	
}// -- 