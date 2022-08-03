/**
 == Overlay FX Transition :: STRIPES
 
	- Animated Vertical Stripes effect on a new substate overlay

 Example
 --------
 
 		persistentUpdate = true; // true to keep the parent state updating
		openSubState(new Stripes( ()->{
					switchState();// complete
				}, {
					mode:"off-out",
					color:0xFFFFFFFF,
					time:2
				}));
		// -- or even with no parameters		
		
		openSubState(new Stripes( switchState_function ));
		
========================================================== */

 
package djFlixel.gfx.statetransit;

import djA.DataT;
import djFlixel.other.DelayCall;
import djFlixel.other.StepTimer;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;


class Stripes extends FlxSubState
{
	// A new camera will be created
	var cam:FlxCamera;
	// Reusable timer object for various triggers
	var timer:FlxTimer;
	
	// --
	var stripe_width:Float;			// autocalculated,
	var stripe_height:Float;		// autocalculated,
	var stripes:Array<FlxSprite>;	// stores all the stripes
	
	// Running Parameters
	var P:Dynamic;
	
	// Default Running Parameters
	var PAR_DEF = {
			// Running mode. A-B format
			// A: on, off | on, the stripes will appear and cover | off, the stripe will dissapear and uncover
			// B: out, in, left, right | direction of the animation
			mode:"on-right",
			// true, it will create a new camera and apply to the whole screen
			// false, will apply to the current camera
			fullscreen : false,
			// How many stripes
			stripes: 15,			
			// Time to complete the whole animation,
			time:1.2,
			// Time to tween a single stripe
			timeStripe:0.2,
			// Time To wait before starting
			timePre: 0.1, 
			// Time to wait after completion to call the callback
			timePost: 0.1,
			// Sound ID to play with "D.snd.playV" every time a stripe triggers
			snd: "",
			// Color of the stripes
			color: 0xFF000000,
			// Type of ease
			ease:"cubeOut"
		};
	
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
	 * @param   mode  , "x-y" x:on,off, y:left,right,in,out. e.g. "off-out"
	 * @param	params, Check in Code
	 * 	
	 */
	public function new(?onComplete:Void->Void, ?params:Dynamic)
	{
		super();
		
		this.onComplete = onComplete;
	
		P = DataT.copyFields(params, Reflect.copy(PAR_DEF));
				
		// Now check for valid data
		if (P.stripes % 2 == 0) {
			P.stripes ++;
			trace("Info: Stripes must be an odd number, converted to", P.stripes);
		}
		
		halfIndex = Math.ceil( (P.stripes) / 2) - 1;
		tween_ease = Reflect.field(FlxEase, P.ease);
		
		var rm = P.mode.split('-');
		runMode = rm[0];
		runDir = rm[1];
		#if debug
			if (["on", "off"].indexOf(runMode) < 0 || runDirID.indexOf(runDir) < 0) 
				throw "Invalid Mode" + P.mode;
		#end
	}//---------------------------------------------------;
	
	// --
	override public function create():Void 
	{
		super.create();
		
		stripes = [];
		if (P.fullscreen) {
			stripe_width = Math.ceil(FlxG.width/ P.stripes);
		}else {
			stripe_width = Math.ceil(FlxG.camera.width / P.stripes);
		}
		
		if (P.fullscreen) {
			stripe_height = FlxG.height;
			#if (!desktop)
				cam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
				FlxG.cameras.add(cam);
				cam.bgColor = 0x00000000; // IMPORTANT: You must set the BG to transparent!!
			#else
				trace("Warning: Fullscreen stripes not supported in neko,cpp");
			#end
		}else {
			stripe_height = FlxG.camera.height;
		}
		
		// Create the stripe boxes
		for (i in 0...P.stripes)
		{
			var s = new FlxSprite((stripe_width * i), 0);
				s.scrollFactor.set(0, 0);
				s.makeGraphic(Std.int(stripe_width), Std.int(stripe_height), P.color);
				s.visible = false;
				#if (!desktop) if (P.fullscreen) s.cameras = [cam]; #end
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
		
		new DelayCall(startAnimation, P.timePre);
		
	}//---------------------------------------------------;
	
	// --
	// Reset the state of the stripes
	function forceSet(toOn:Bool)
	{
		for (i in 0...P.stripes) 
		{
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
	function getMirrored(f:Int):Int
	{
		return (stripes.length - 1) - f;
	}//---------------------------------------------------;
	
	// PRE:
	// Stripes are initialized into the starting position
	function startAnimation()
	{
		var ri = runDirID.indexOf(runDir); 
		
		// One steptimer function for all directions
		var st = new StepTimer(true, (a, b)->{
			playSound();
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
	
	// --
	// I am not calling at stripe on or off, because some stripes run at parallel
	function playSound()
	{
		if (P.snd != "") D.snd.playV(P.snd);
	}//---------------------------------------------------;
	
	//--
	function _transitionComplete()
	{
		new DelayCall(()->{
			
			// There is no point on keeping it onscreen
			if (runMode == "off")
				close();

			if (onComplete != null) onComplete();
			
		}, P.timePost);
		
	}//---------------------------------------------------;
	
	// --
	function _tweenStripeOn(s:Int,lastOne:Bool = false)
	{
		stripes[s].visible = true;
		FlxTween.tween(stripes[s].scale, { x:1 }, P.timeStripe, { ease:tween_ease, onComplete:function(_) {
			if (lastOne) _transitionComplete();
		}} );
	}//---------------------------------------------------;	
	
	// --
	function _tweenStripeOff(s:Int, lastOne:Bool = false)
	{
		FlxTween.tween(stripes[s].scale, { x:0 }, P.timeStripe, { ease:tween_ease, onComplete:function(_) {
			if (lastOne) _transitionComplete();
		}} );
	}//---------------------------------------------------;
	
	// --
	override public function destroy():Void 
	{
		stripes = FlxDestroyUtil.destroyArray(stripes);
		
		// Important to remove, else the camera will stay forever
		// In case the superstate removes the camera first
		// do a check to avoid a warning ::
		#if (!desktop)
		if (P.fullscreen && FlxG.cameras.list.indexOf(cam) >-1)
			FlxG.cameras.remove(cam); 
		#end
		
		super.destroy();
	}//---------------------------------------------------;
	
}//-- end class --//