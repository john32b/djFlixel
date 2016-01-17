/**--------------------------------------------------------
 * SequencerHaxe.hx
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

import flixel.util.FlxTimer;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * Simple Sequencer
 * ----------------
 * Using the FlxTimer,
 * @note use Seconds for time
 */
class Sequencer implements IFlxDestroyable
{
	// The callback to call when the timer triggers
	public var callback:Int->Void = null;
	
	var timer:FlxTimer = null;	
	var currentStep:Int = 0;
	//----------------------------------------------------;
	public function new(?callback_:Int->Void) 
	{
		callback = callback_;
		currentStep = 0;
		timer = new FlxTimer();
	}//---------------------------------------------------;
	public function stop()
	{
		timer.finished = true;
		timer.active = false;
		// faster than calling cancel();
	}//---------------------------------------------------;
	public function doXTimes()
	{
		// LOG.log("In Development");
	}//---------------------------------------------------;
	//-- 
	// Call this when you want to quickly call a waiting seq.next(XXXX) timer
	// e.g. A timer on a menu that is set to 5 seconds, but a keystroke 
	//      calls this function to skip waiting.
	public function resolveNextAndWait(?t:FlxTimer)
	{
		stop(); 
		callback(currentStep);
	}//---------------------------------------------------;
	// --
	public function reset()
	{
		stop();
		currentStep = 0;
	}//---------------------------------------------------;
	// --
	public function next(?delay:Float)
	{
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
	// --
	public function forceTo(step:Int)
	{
		reset();
		currentStep = step;
		callback(currentStep);
	}//---------------------------------------------------;
	// --
	public function nextF()
	{
		next();
	}//---------------------------------------------------;
	
	// --
	public function destroy():Void 
	{
		if (timer != null)
		{
			timer.cancel();
			timer.destroy();
			timer = null;
		}
	}//---------------------------------------------------;
	
}//-- end --//