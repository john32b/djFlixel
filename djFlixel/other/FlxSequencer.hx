/**
	- FlxSequencer calls a function at custom time intervals
	- Listen to <onStep> or <callback> 
	- Useful for making short sequences of code execution
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
import flixel.FlxG;

class FlxSequencer extends FlxBasic
{
	public var callback:FlxSequencer->Void;
	public var step(default, null) = 0;
	var _timer:Float = 0;
	
	/**
	   @param	cb callback 
	   @param	autoStart Milliseconds. if >=0 will call next(autoStart time)
	**/
	public function new(?cb:FlxSequencer->Void, autoStart:Float = -1)
	{
		super();
		active = false;
		callback = cb;
		if (autoStart >-1) next(autoStart);
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (_timer > 0)
		{
			if ((_timer -= elapsed) <= 0)
			{
				next();
			}
		}
	}//---------------------------------------------------;

	// Acts like a reset
	override public function revive():Void 
	{
		super.revive();
		step = 0; _timer = 0;
		active = false;
	}//---------------------------------------------------;
	
	public function next(time:Float = 0):Void
	{
		if (!alive) return;	// DEV: ??
		
		_timer = time;
		active = true;
		
		if (_timer == 0) 
		{
			step++;
			
			if (callback != null) 
			{
				FlxG.signals.postUpdate.addOnce(callback.bind(this));
			}
		}
	}//---------------------------------------------------;
	
	/** Useful to pass as void callback function to things 
	 *  DEV: You can also do next.bind(0) */
	public function nextV():Void
	{
		next();
	}//---------------------------------------------------;
	
	/** Force to a specific step */
	public function goto(s:Int)
	{
		step = s - 1; next();
	}//---------------------------------------------------;
	
}//--





/**
   FlxSequencer with Anonymous Functions
   puts them all in a queue and executes in order
   call delay is supported
   ---
   Example:
   
	var S = new FlxSequencer2();
	S.add( (f)->{
			trace("first");
			f();	// Go to the next now
		});
		
	S.add( (f)->{
			trace("second");
		});
		
	F.next(1);	// Delay 1 second to call the first fn
	add(F);		// Need to add it to the State
   
**/

typedef FlxSeqCallback = (?Float->Void)->Void;

class FlxSequencer2 extends FlxBasic
{
	var _timer:Float = 0;
	var queue:Array<FlxSeqCallback> = [];
	
	public function new()
	{
		super();
		active = false;
	}//---------------------------------------------------;
	
	/** Add a function to the end of the queue */
	public function add(fn:FlxSeqCallback)
	{
		queue.push(fn);
	}//---------------------------------------------------;
	/** Add a function directly after the current one */
	public function addNext(fn:FlxSeqCallback)
	{
		queue.unshift(fn);
	}//---------------------------------------------------;
	
	/** Call the next function in the sequence
		@param time in Seconds 0 for instant */
	public function next(time:Float = 0):Void	
	{
		active = true;
		_timer = time;
		
		if (_timer == 0)
		{
			var f:FlxSeqCallback = queue.shift();
			if (f == null) {
				trace("WARNING: FlxSequencer2, Nothing to execute in Queue!");
				return;
			}
			
			FlxG.signals.postUpdate.addOnce(()->{
				f(next);
			});
		}

	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (_timer > 0)
		{
			if ((_timer -= elapsed) <= 0)
			{
				next();
			}
		}
	}//---------------------------------------------------;
	
}//--