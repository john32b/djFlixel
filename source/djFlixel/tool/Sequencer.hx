/**--------------------------------------------------------
 * Sequencer.hx
 * @author: johndimi, <johndimi@outlook.com> @jondmt
 * --------------------------------------------------------
 * @Description
 * -------
 * General purpose Sequencer, ( Flixel library based)
 * 
 * @Notes
 * ------
 * 02-2015. rewritten
 * 
 *********************************************************/
package djFlixel.tool;

import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * Simple Sequencer
 * ----------------
 * Using the FlxTimer,
 * @note use Seconds for time
 * 
 * Example:
 * 	var s = new Sequencer();
 * 		s.callback = function(s:Int){
 * 		switch(s){ default: //--
 * 			case 1: 
 * 				// do things
 * 				s.next(0.4);
 *			case 2:
 * 				// do things
 * 				s.next(1.4);
 *		}		
 * 	});
 */
class Sequencer implements IFlxDestroyable
{
	// The callback to call when the timer triggers
	public var callback:Int->Void = null;
	// --
	public var timer(default, null):FlxTimer = null;
	// --
	var currentStep:Int = 0;
	
	// Useful flag, if true will not callback anything
	var isCancelled:Bool = false;
	//----------------------------------------------------;
	/**
	 * 
	 * @param	callback_ The function handling the steps
	 */
	public function new(?callback_:Int->Void) 
	{
		callback = callback_;
		currentStep = 0;
		timer = new FlxTimer();
	}//---------------------------------------------------;
	
	// -- Like stop but also prevents any more callbacks from ongoing steps to being called
	public function cancel()
	{
		stop();
		isCancelled = true;
	}//---------------------------------------------------;
	
	// --
	public function stop()
	{
		timer.finished = true;
		timer.active = false;
		// faster than calling cancel();
	}//---------------------------------------------------;
	@:deprecated("In Development")
	public function doXTimes()
	{
	}//---------------------------------------------------;
	/**
	 * HELPER: Useful to attach to FlxTimer callbacks
	 * @param	t
	 */
	public function resolveNextAndWait(?t:FlxTimer)
	{
		stop(); 
		callback(currentStep);
	}//---------------------------------------------------;
	/**
	 * Stop and reset to 0, but doesn't start over
	 */
	public function reset()
	{
		stop();
		currentStep = 0;
	}//---------------------------------------------------;
	/**
	 * Proceed to the next step
	 * @param	delay Call the next action in X seconds
	 */
	public function next(?delay:Float)
	{
		if (isCancelled) return;
		
		currentStep++;
		
		// If somehow the timer is running, kill it.
		stop();
		
		if (delay > 0) {
			timer.start(delay, resolveNextAndWait, 1);
		}
		else {
			callback(currentStep);
		}
	}//---------------------------------------------------;
	/**
	 * Forces the sequencer to stop and call a specified step
	 * @param	step
	 */
	public function forceTo(step:Int)
	{
		if (isCancelled) return;
		
		reset();
		currentStep = step;
		callback(currentStep);
	}//---------------------------------------------------;
	
	/**
	 * Quick use on a void callback
	 */
	public function nextF()
	{
		if (isCancelled) return;
		next();
	}//---------------------------------------------------;
		
	/**
	 * Quick use on a tween callback
	 * @param e
	 */
	public function nextT(e:FlxTween)
	{
		if (isCancelled) return;
		
		next();
	}//---------------------------------------------------;
	
	// --
	public function destroy():Void 
	{
		if (timer != null) {
			timer.cancel();
			timer.destroy();
			timer = null;
		}
	}//---------------------------------------------------;
	
}//-- end --//