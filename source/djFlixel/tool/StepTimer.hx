package djFlixel.tool;

import flixel.FlxG;


/// TODO: This class is a mess, remove it!

/**
 * TODO: Make it an FLXBasic so that it gets removed automatically
 * 
 * Counts and callback Numbers in a range
 * Doesn't use flxTimer, User needs to call update manually :-/
 * 
 * ...
 * @author JohnDimi, @jondmt
 */
class StepTimer
{
	
	var isActive:Bool;
	// 
	var step_current:Int = 0;
	//
	var step_target:Int = 0;
	// Speed increment of the steps, +1 or -1
	var step_dir:Int = 0;
	// -
	var step_frequency:Float;
	// -
	var step_timer:Float;
	
	// Call this on step
	var callback_tick:Int->Void;
	// Call this when all steps are done
	var callback_complete:Void->Void;
	
	//====================================================;
	//====================================================;
	
	public function new() 
	{
		clear();
	}//---------------------------------------------------;
	
	/**
	 * 
	 * @param	from Count from here
	 * @param	to to this
	 * @param	frequency in seconds
	 * @param	onTick
	 * @param	onComplete
	 */
	public function once(from:Int, to:Int, frequency:Float, onTick:Int->Void, ?onComplete:Void->Void)
	{
		if (from == to)
		{
			trace("Warning: Start and Target is the same. Returning");
			if (onComplete != null) onComplete();
			return;
		}
		
		step_timer = 0;
		step_current = from;
		step_target = to;
		step_frequency = frequency;
		isActive = true;
		
		if (from < to)
		{
			step_dir = 1;
		}else
		{
			step_dir = -1;
		}
		
		callback_complete = onComplete;
		callback_tick = onTick;
		
		// Hard set the first, because the next call will be in (frequancy time) and will invoke the next step
		onTick(from);
		
	}//---------------------------------------------------;
	
	// Call this on an update function.
	// --
	public function update():Void 
	{		
		if (!isActive) return;
		
		step_timer += FlxG.elapsed;
		if (step_timer > step_frequency)
		{
			step_timer = 0;
			step_current += step_dir;
			callback_tick(step_current);
			if (step_current == step_target)
			{
				isActive = false;
				if (callback_complete != null) callback_complete();
			}
		}
		
	}//---------------------------------------------------;
	
	// --
	// Apply a loop X many times
	public function loop()
	{
		// TODO
	}//---------------------------------------------------;
	
	// --
	public function clear()
	{
		isActive = false;
		callback_complete = null;
		callback_tick = null;
	}//---------------------------------------------------;
	
}// -- end -- //