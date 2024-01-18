/**
 
 Simple timer that ticks/callbacks a specified number of times at an interval
 - Optionally auto-adds itself to the state
 - Removes itself from the state when it ends
 - Support backwards counting. e.g. tick(10),tick(9)....
 - Can specify total time or tick time
 
 
 TODO:
 -------
 - Ability to loop repeat/pingpong
 
 EXAMPLE:
 ----------
 	add(new StepTimer( 0, 9, 2.5 ,(a,b)->{} ));
 
  // Will call fn() 10 times (0->9 == 10 ticks), every 2.5/11 times
  // Output:
	- fn(0,false) // second parameter is finished or not 
	- fn(1,false)
	- ...
	- ..
	- fn(10,true) // finished
	
===================================================== */


package djFlixel.other;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;

class StepTimer extends FlxBasic
{
	var c_current:Int;
	var c_target:Int;
	var c_dir:Int;
	var t:Float; 	// Elapsed Time Accumulator 
	var tick:Float;	// Time Tick
	var onTick:Int->Bool->Void; // (step,finished)->{}
	
	/**
	 * Create and start a stepTimer, calling ONTick(.) with the progress
	 * @param	ONTick (a,b) a:Int = Current Step, b:Bool = Finished 
	 * @param	state The state to add this, Useful if running from a substate where the main state is paused
	 */
	public function new(?autoAdd:Bool = true, ONTICK:Int->Bool->Void)
	{
		super();
		active = false;
		onTick = ONTICK;
		if (autoAdd) {
			FlxG.state.add(this);
		}
	}//---------------------------------------------------;
	
	/**
	   Start the timer and count (from) -> (to)
	   The first step will be immediately called
	   @param	from
	   @param	to
	   @param	time Negative for tick time, positive for total time
	**/
	public function start(from:Int, to:Int, time:Float):StepTimer
	{
		if (from == to) {
			onTick(from, true);
			return this;
		}
		c_current = from;
		c_target = to;
		t = 0;
		
		if (to > from) c_dir = 1; else c_dir = -1;
		if (time < 0){
			tick = -time;
		}else{
			var totalSteps = Math.abs(to - from) + 1;
			tick = time / totalSteps;
		}
		active = true;
		onTick(c_current, false);
		return this;
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if ((t += elapsed) >= tick) {
			t = 0; c_current += c_dir;
			if (c_current == c_target) { // Finished
				destroy();
				onTick(c_current, true);
			}else{
				onTick(c_current, false);
			}
		}
	}//---------------------------------------------------;
	
	override public function destroy():Void 
	{
		if (!exists) return;
		FlxG.state.remove(this);
		super.destroy();
	}//---------------------------------------------------;
}// --