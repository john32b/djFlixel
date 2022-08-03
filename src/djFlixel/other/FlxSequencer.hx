/**
	- FlxSequencer calls a function at manual time intervals
	- Listen to <onStep> or <callback> 
	- Useful in making short sequences of code execution
	- Example for doing a sequence:
  
	add(new FlxSequencer((s)->{ 
		switch(s.step){
			case 1:
				something(); s.next(); // Go to next step now
			case 2:
				something(); s.next(300);	// wait 0.3 seconds and go to next step
			case 3:
				something();
				-- 
			case _: 
		}
	});
*******************************************************/

package djFlixel.other;
import flixel.FlxBasic;

class FlxSequencer extends FlxBasic
{
	public var onStep:Int->Void;
	public var callback:FlxSequencer->Void;
	public var step(default, null) = 0;
	
	var _timer:Float = 0;
	var _waitTime:Float = 0;
	
	/**
	   You can set CB or you can set onStep manually
	   @param	CB callback 
	   @param	autoStart Milliseconds. if >=0 will call next(autoStart time)
	**/
	public function new(?CB:FlxSequencer->Void, autoStart:Float = -1)
	{
		super();
		active = false;
		callback = CB;
		if (autoStart >-1) next(autoStart);
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		_timer += elapsed;
		if (_timer >= _waitTime) {
			next();
		}
	}//---------------------------------------------------;
	
	override public function revive():Void 
	{
		super.revive();
		step = 0;
		active = false;
	}//---------------------------------------------------;
	
	public function next(d:Float = 0)
	{
		if (!alive) return;
		if (d == 0) {
			active = false;
			step++;
			if (onStep != null) onStep(step);
			if (callback != null) callback(this);
			return;
		}
		_timer = 0;
		_waitTime = d;
		active = true;
	}//---------------------------------------------------;
	
	/** Useful to pass as void callback function to things 
	 * DEV: You can also do next.bind(0) */
	public function nextV()
	{
		next();
	}//---------------------------------------------------;
	
	/* Force to a specific step, will callback */
	public function goto(s:Int)
	{
		step = s - 1;
		next();
	}//---------------------------------------------------;
		
	
}//--