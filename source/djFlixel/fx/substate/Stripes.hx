package djFlixel.fx.substate;

import djFlixel.FlxAutoText;
import djFlixel.SND;
import djFlixel.SimpleCoords;
import djFlixel.tool.DataTool;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;

/**
 * Overlay FX Transition, STRIPES
 * -----
 * Usage:
 * 
 * 		persistentUpdate = true; // true to keep the parent state updating
 *		openSubState(new Stripes(
 * 				"on-right",
 * 				{ color:0xFF33FF00 },
 * 				function() {
 * 					FlxG.switchState(new GameState());
 * 				})
 * 		);
 * 
 */
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
	
	// Is a transition curently running
	var isRunning(default, null):Bool;
	
	// Function applied to each stripe when they are timer triggered
	var runFunc:Int->Void; 
	
	// Store the index of the last stripe of the transition.
	// When this stripe completes the animation, fires the END trigger
	var lastStripeIndex:Int;
	
	// Running parameters: check the constructor
	var P:Dynamic;
	
	// --
	var runMode:String; // on or off
	var runDir:String;	// out, in, left, right
	
	// Call this on transition end
	var onComplete:Void->Void;
	//====================================================;
	
	/**
	 * @param   mode  , "x-y" x:on,off, y:left,right,in,out. e.g. "off-out"
	 * @param	params, Check Below:
	 * 	
	 */
	public function new(mode:String, ?params:Dynamic, ?onComplete:Void->Void)
	{
		super();
		
		this.onComplete = onComplete;
	
		P = DataTool.defParams( params, {
			// true, it will create a new camera and apply to the whole screen
			// false, will apply to the current camera
			fullscreen : false,
			// How many stripes
			stripes: 15,	
			// Time between stripes
			timeA: 0.1, 
			// Stripe Tween Time
			timeB: 0.3,
			// Time To wait before going
			timePre: 0.1, 
			// Time to wait after completing
			timePost: 0.1,
			// Sound ID to play with SND.play every time a stripe triggers
			soundID: "",
			// Color of the stripes
			color: 0xFF000000
		});
				
		// Now check for valid data
		if (P.stripes % 2 == 0) {
			P.stripes ++;
			trace("Stripes must be an odd number, converted to", P.stripes);
		}

		isRunning = false;
		runMode = mode.split("-")[0];
		if (runMode == null) runMode = "in";
		runDir = mode.split("-")[1];
		if (runDir == null) runDir = "out";
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
		if (runMode == "on")
		{
			runFunc = _tweenStripeOn;
			forceSet(false);
			timer = new FlxTimer().start(P.timePre, startTimer);
		}else
		{
			runFunc = _tweenStripeOff;
			forceSet(true);
			timer = new FlxTimer().start(P.timePre, startTimer);
		}
		
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
	
	// PRE:
	// Stripes are initialized into the starting position
	function startTimer(?t:FlxTimer)
	{
		isRunning = true;
		
		switch(runDir)
		{		
			case "out": // Mirror Inside to Outer ::
				var half:Int = Math.ceil(P.stripes / 2);
				lastStripeIndex = 0;
				timer = new FlxTimer().start(P.timeA, function(e:FlxTimer) {
					playSound();
					runFunc(e.loopsLeft);
					if (e.loopsLeft < half) {	
						runFunc(cast(P.stripes - e.loopsLeft - 1));
					}
				},half);
				
			case "in": 	// Mirror Outside to Inner ::
				var half:Int = Math.ceil(P.stripes / 2);
				lastStripeIndex = half;
				var c:Int = 0;
				timer = new FlxTimer().start(P.timeA, function(e:FlxTimer) {
					playSound();
					runFunc(c);
					if (c < half - 1){
						runFunc(cast(P.stripes - c - 1));
					}
					c++;
				},half);
				
			case "left":
				lastStripeIndex = 0;
				timer = new FlxTimer().start(P.timeA, function(e:FlxTimer) {
					playSound();
					runFunc(e.loopsLeft);
				},P.stripes);
				
			case "right":
				lastStripeIndex = cast(P.stripes - 1);
				timer = new FlxTimer().start(P.timeA, function(e:FlxTimer) {
					playSound();
					runFunc(cast(P.stripes - e.loopsLeft - 1));
				},P.stripes);
			default:
				
		}
		
	}//---------------------------------------------------;
	
	// --
	// I am not calling at stripe on or off, because some stripes run at parallel
	function playSound()
	{
		if (P.soundID != "") SND.play(P.soundID);
	}//---------------------------------------------------;
	
	//--
	function _transitionComplete()
	{
		timer = new FlxTimer().start(P.timePost, function(_) {
			
			isRunning = false;
			// There is no point on keeping it onscreen
			if (runMode == "off")
				close();
				
			if (onComplete != null) onComplete();
		});
	}//---------------------------------------------------;
	
	// --
	inline function _tweenStripeOn(s:Int)
	{
		stripes[s].visible = true;
		FlxTween.tween(stripes[s].scale, { x:1 }, P.timeB, { ease:FlxEase.cubeOut, onComplete:function(_) {	
			if (s == lastStripeIndex) _transitionComplete();
		}} );
	}//---------------------------------------------------;	
	
	// --
	inline function _tweenStripeOff(s:Int)
	{
		FlxTween.tween(stripes[s].scale, { x:0 }, P.timeB, { ease:FlxEase.cubeOut, onComplete:function(_) {	
			if (s == lastStripeIndex) _transitionComplete();
		}} );
	}//---------------------------------------------------;
	
	// --
	override public function destroy():Void 
	{
		super.destroy();
		for (i in stripes) {
			i.destroy();
		}
		// Can I cancel any pending tweens?
		stripes = null;
		timer = FlxDestroyUtil.destroy(timer);
		
		// Important to remove, else the camera will stay forever
		// In case the superstate removes the camera first
		// fo a check to avoid a warning ::
		#if (!desktop)
		if (P.fullscreen && FlxG.cameras.list.indexOf(cam) >-1)
			FlxG.cameras.remove(cam); 
		#end
		
		//trace(" - Done destroying fadesprites");
	}//---------------------------------------------------;
	
}//-- end class --//