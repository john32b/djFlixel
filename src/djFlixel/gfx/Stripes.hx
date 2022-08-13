/**
 == FX Transition :: STRIPES
 
	- Animated Vertical Stripes effect on a new substate overlay

 Example
 --------
 
========================================================== */

package djFlixel.gfx;

import djA.DataT;
import djFlixel.other.DelayCall;
import djFlixel.other.StepTimer;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;


class Stripes extends FlxSpriteGroup
{
	
	/**
	   Create Stripes and add to current State,
	   Will auto remove them if mode==off
	   @param	ONCOMPLETE
	   @param	PAR
	**/
	public static function CREATE(ONCOMPLETE:Void->Void, PAR:Dynamic)
	{
		var s = new Stripes(ONCOMPLETE, PAR);
		if (s.runMode == "off")
		{
			s.onComplete = ()->{
				FlxG.state.remove(s);
				s.destroy();
				ONCOMPLETE();
			}
		}
		FlxG.state.add(s);
	}//---------------------------------------------------;
	
	
	// Running Parameters
	// Override fields in the constructor
	var P = {
			
			// Total width, 0 for FlxG.width
			width:0,
			
			// Total height, 0 for FlxG.height
			height:0,
			
			// Running mode. A,B format
			// A: on, off | on, the stripes will appear and cover | off, the stripe will dissapear and uncover
			// B: out, in, left, right | direction of the animation
			mode:"on,right",
			
			// How many stripes. MUST BE ODD NUMBER!
			stripes: 15,		
			
			// Time to complete the whole animation,
			time:1.2,
			
			// Time to tween a single stripe
			timeStripe:0.2,
			
			// Time to wait after completion to call the callback
			timePost: 0.1,
			
			// Sound ID to play with "D.snd.playV" every time a stripe triggers
			snd: "",
			
			// Color of the stripes
			color: 0xFF000000,
			
			// Type of ease
			ease:"cubeOut"
		};
	
		
	// Reusable timer object for various triggers
	var timer:FlxTimer;
	
	// --
	var stripe_width:Float;				// autocalculated,
	var stripe_height:Float;			// autocalculated,
	var stripes:Array<FlxSprite> = [];	// stores all the stripes
	
	// --
	var runFunc:Int->?Bool->Void; 		// Function applied to each stripe on time tick
	var runMode:String; 				// on or off
	var runDir:String;					// out, in, left, right
	var runDirID = ['out', 'in', 'left', 'right'];	// DO NOT CHANGE ORDER! Used in startAnimation()
	
	// Call this on transition end
	var onComplete:Void->Void;
	var tween_ease:EaseFunction;
	var halfIndex:Int;
	//====================================================;
	
	/**
	 * Create 
	 * @param   onComplete 
	 * @param	PAR, Override Running Parameters, Check in Code {P} object
	 * 	
	 */
	public function new(ONCOMPLETE:Void->Void, ?PAR:Dynamic)
	{
		super();
	
		moves = false;
		scrollFactor.set(0, 0);
		
		P = DataT.copyFields(PAR, P);
		onComplete = ONCOMPLETE;
				
		// Now check for valid data
		if (P.stripes % 2 == 0) {
			P.stripes ++;
			trace("Info: Stripes must be an odd number, converted to", P.stripes);
		}
		
		halfIndex = Math.ceil( (P.stripes) / 2) - 1;
		tween_ease = Reflect.field(FlxEase, P.ease);
		
		var rm = P.mode.split(',');
		runMode = rm[0];	// on,off
		runDir = rm[1];		// out, in, left, right
		
			#if debug
				if (["on", "off"].indexOf(runMode) < 0 || runDirID.indexOf(runDir) < 0) 
					throw "Invalid Mode" + P.mode;
			#end
			
		if (P.width == 0) P.width = FlxG.width;
		if (P.height == 0) P.height = FlxG.height;
		
		stripe_width = Math.ceil(P.width / P.stripes);
		stripe_height = P.height;
				
		// -- Create stripe objects and run
		
		// Create the stripe boxes
		for (i in 0...P.stripes) {
			var s = new FlxSprite((stripe_width * i), 0);
				s.makeGraphic(Std.int(stripe_width), Std.int(stripe_height), P.color);
				s.visible = false;
			add(s);
			stripes[i] = s;
		}
		
		// -- Start Running
		if (runMode == "on") {
			runFunc = _tweenStripeOn;
			forceSet(false);
		}else{
			runFunc = _tweenStripeOff;
			forceSet(true);
		}
		
		startAnimation();
	}//---------------------------------------------------;
	
	
	// --
	// Reset the state of the stripes
	// toOn TRUE = stripes are visible an enabled, ready to be disabled
	// toOn FALSE = stripes are hidden, ready to be enabled
	function forceSet(toOn:Bool)
	{
		for (i in 0...P.stripes) {
			if (toOn) {
				stripes[i].visible = true;
				stripes[i].scale.x = 1;
			}else{
				stripes[i].visible = false;
				stripes[i].scale.x = 0;
			}
		}
	}//---------------------------------------------------;
	
	
	/**
	 * (f) Must be 0 -> middle
	 * @param	f return the mirror to center index
	 * @return
	 */
	inline function getMirrored(f:Int):Int
	{
		return (stripes.length - 1) - f;
	}//---------------------------------------------------;
	
	
	function startAnimation()
	{
		var ri = runDirID.indexOf(runDir); 
		
		// One steptimer function for all directions
		var st = new StepTimer(true, (a, b)->{
			if (P.snd != "") D.snd.playV(P.snd);
			runFunc(a, b);
			if (ri < 2) { // [out,in], requires mirror
				var mirrored = getMirrored(a);
				if (mirrored != a) runFunc(mirrored);
			}
		});
		
		switch(runDir) {
			case "out":
				st.start(halfIndex, 0, P.time);
			case "in":
				st.start(0, halfIndex, P.time);
			case "left":
				st.start(0, stripes.length - 1, P.time);
			case "right":
				st.start(stripes.length - 1, 0, P.time);
			case _:
		}
	}//---------------------------------------------------;
	
	function _tweenStripeOn(s:Int, lastOne:Bool = false)
	{
		stripes[s].visible = true;
		FlxTween.tween(stripes[s].scale, { x:1 }, P.timeStripe, { ease:tween_ease, onComplete:function(_) {
			if (lastOne) new DelayCall(P.timePost, onComplete);
		}} );
	}//---------------------------------------------------;	
	
	function _tweenStripeOff(s:Int, lastOne:Bool = false)
	{
		FlxTween.tween(stripes[s].scale, { x:0 }, P.timeStripe, { ease:tween_ease, onComplete:function(_) {
			if (lastOne) new DelayCall(P.timePost, onComplete);
		}} );
	}//---------------------------------------------------;
	
}//-- end class --//