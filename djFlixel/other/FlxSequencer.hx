/**
   - Call a function at manual time intervals
   - Create and add to a state
   - Listen to <onStep> or <callback> 
   - Call next step with next(time);
**/

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
	   @param	autoStart if >=0 will call call next(autoStart)
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
	
	/** Useful to use as a void callback */
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