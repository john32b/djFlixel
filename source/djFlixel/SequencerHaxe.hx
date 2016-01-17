/**--------------------------------------------------------
 * SequencerHaxe.hx
 * @author: johndimi, <johndimi@outlook.com> @jondmt
 * --------------------------------------------------------
 * @Description
 * -------
 * General purpose Sequencer, ( HAXE library based)
 * 
 * @Notes
 * ------
 * 02-2015. rewritten
 * 
 *********************************************************/
package djFlixel;
import haxe.Timer;

// TODO:
// Make the sequencer use the FlxTimer
class SequencerHaxe
{
	public var callback:Int->Void = null;	
	private var timer:Timer = null;	
	private var currentStep:Int = 0;
	//----------------------------------------------------;
	public function new(?callback_:Int->Void) 
	{
		callback = callback_;
		currentStep = 0;
	}//---------------------------------------------------;
	public function stop()
	{
		if (timer != null)
		{
			timer.stop();
			timer = null;
		}
	}//---------------------------------------------------;
	public function doXTimes()
	{
		// LOG.log("In Development");
	}//---------------------------------------------------;
	//-- 
	// Call this when you want to quickly call a waiting seq.next(XXXX) timer
	// e.g. A timer on a menu that is set to 5 seconds, but a keystroke 
	//      calls this function to skip waiting.
	public function resolveNextAndWait()
	{
		stop(); 
		callback(currentStep);
	}//---------------------------------------------------;
	public function reset()
	{
		stop();
		currentStep = 0;
	}//---------------------------------------------------;
	public function next(?delay:Int)
	{
		currentStep++;
		// Somehow the timer is running, kill it.
		stop(); 
		if (delay > 0)
		{
			timer = new Timer(delay);
			timer.run = resolveNextAndWait;
		}
		else
		{
			callback(currentStep);
		}
	}//---------------------------------------------------;
	

	public function forceTo(step:Int)
	{
		reset();
		currentStep = step;
		callback(currentStep);
	}//---------------------------------------------------;
	
}//-- end --//