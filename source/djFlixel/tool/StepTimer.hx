package djFlixel.tool;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;


/**
 * Simple timer that counts real numbers and callbacks
 * Automatically gets added/removed to the state so you can use it like
 * 
 * e.g. 
 * 	new StepTimer(0,10,2.5,fn(a,b){});
 * 
 *  Will call fn() 11 times, every 2.5/11 times
 * 	- fn(0,false) // second parameter is finished or not
 *  - fn(1,false)
 *  - ...
 *  - ..
 *  - fn(10,true) // finished
 * ...
 */
class StepTimer extends FlxBasic
{
	var c_current:Int;
	var c_target:Int;
	var c_dir:Int;
	var t:Float; 	// timer
	var tick:Float;
	var onTick:Int->Bool->Void; // fn(Step,Finished){};
	// --
	
	/**
	 * Create and start a stepTimer, calling ONTick(.) with the progress
	 * @param	from Any Interger
	 * @param	to Any Interger
	 * @param	totalTime Total Time to spend counting, Step time will be equally divided
	 * @param	ONTick (a,b) a:Int = Current Step, b:Bool = Finished 
	 * @param	state The state to add this, Useful if running from a substate where the main state is paused
	 */
	public function new(from:Int, to:Int, totalTime:Float, ONTick:Int->Bool->Void, ?state:FlxState)
	{
		super();
		onTick = ONTick;
		if (from == to){
			trace("Warning: Start and Target is the same. Returning");
			if (onTick != null) onTick(from, true);
			return;
		}
		
		if (state != null){
			state.add(this);
		}else{
			FlxG.state.add(this);
		}
		
		c_current = from;
		c_target = to;
		if (to > from) c_dir = 1; else c_dir = -1;
		var totalSteps = Math.abs(to - from) + 1;
		t = 0; tick = totalTime / totalSteps;
		// Call the first step right now
		onTick(c_current, false);
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
	// --
	override public function destroy():Void 
	{
		FlxG.state.remove(this);
		super.destroy();
	}//---------------------------------------------------;
	
}// -- end -- //