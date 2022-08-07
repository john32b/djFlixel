/**
 - Loops integer numbers and callbacks on each tick()
 - Loop and PingPong Modes
 - Must call update() manually
 
 = EXAMPLE
 
	var st = new StepLoop(2,5,3, (t)->{
		trace(t);
	});
	>> output : 0,1,2,3,4,5,4,3,2,1,0,1,2,3,4,5 .......
 
 DEV : This could be an object, but I want to be able to use this on an 
		FlxSpriteGroup as well but they don't support adding objects (just sprites)
		So I am doing it manually (plus more lightweight)
	   
***************************************/

package djFlixel.other;

class StepLoop
{
	public var c(default, null):Int;	// The current step if you want to read it
	var t:Float;
	var m:Int;		// used in looping. increment by this much.
	var type:Int;	// 1 repeat, 2 loop
	var steps:Int;
	var stepTime:Float;
	var onTick:Int->Void;
	var active:Bool;
	
	/**
	   For ON/OFF use STEPS=1
	   @param	TYPE 1=Repeat, 2=Ping Pong 
	   @param	STEPS How many total steps for a full cycle | steps=2 to callback (0,1)
	   @param	TIME Time for a full cycle
	   @param	TICK Callbacks with current step! Starting with 0 and ending with STEPS-1
	**/
	public function new(TYPE:Int, STEPS:Int, TIME:Float, TICK:Int->Void)
	{
		type = TYPE;
		steps = STEPS;
		stepTime = TIME / STEPS;
		onTick = TICK;
		stop();
	}//---------------------------------------------------;

	public function stop()
	{
		active = false;
	}//---------------------------------------------------;
	
	public function start()
	{
		active = true;
		c = 0;	// Current
		t = 0;
		m = 1;
	}//---------------------------------------------------;
	
	// Can be useful sometimes?
	public function fire()
	{
		onTick(c);
	}//---------------------------------------------------;
	
	public function syncFrom(S:StepLoop)
	{
		c = S.c;
		t = S.t;
		m = S.m;
		active = S.active;
	}//---------------------------------------------------;

	public function update(elapsed:Float):Void 
	{
		if (!active) return;
		if ((t += elapsed) >= stepTime) {
			t = 0;
			if (type == 1){ // repeat
				if (++c >= steps) c = 0;
			}else{ // loop
				c += m;
				if (c<=0 || c>=steps-1) m=-m;
			}
			onTick(c);
		}
	}//---------------------------------------------------;
	
}// --