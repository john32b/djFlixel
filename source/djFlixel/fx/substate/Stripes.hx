package djFlixel.fx.substate;

import djFlixel.gui.FlxAutoText;
import djFlixel.SND;
import djFlixel.SimpleCoords;
import djFlixel.tool.DataTool;
import djFlixel.tool.DelayCall;
import djFlixel.tool.StepTimer;
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
	
	// Function applied to each stripe when they are timer triggered
	var runFunc:Int->?Bool->Void; 
	
	// Running parameters: check the constructor
	var P:Dynamic;
	
	// --
	var runMode:String; // on or off
	var runDir:String;	// out, in, left, right
	
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
	public function new(mode:String, ?onComplete:Void->Void, ?params:Dynamic)
	{
		super();
		
		this.onComplete = onComplete;
	
		P = DataTool.copyFields(params, {
			// true, it will create a new camera and apply to the whole screen
			// false, will apply to the current camera
			fullscreen : false,
			// How many stripes
			stripes: 15,			
			// Time to complete the whole animation,
			time:1.2,
			// Time to tween a single stripe
			timeStripe:0.2,
			// Time To wait before going
			timePre: 0.1, 
			// Time to wait after completing
			timePost: 0.1,
			// Sound ID to play with SND.play every time a stripe triggers
			soundID: "",
			// Color of the stripes
			color: 0xFF000000,
			// Type of ease
			ease:"cubeOut"
		});
				
		// Now check for valid data
		if (P.stripes % 2 == 0) {
			P.stripes ++;
			trace("Info: Stripes must be an odd number, converted to", P.stripes);
		}
		
		halfIndex = Math.ceil( (P.stripes) / 2) - 1;
		tween_ease = Reflect.field(FlxEase, P.ease);
		
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
		
		new DelayCall(startAnimation, P.timePre, this);
		
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
		
		switch(runDir)
		{		
			case "out": // Mirror Inside to Outer ::
				
				new StepTimer(halfIndex, 0, P.time, function(a, b){
					var mirrored = getMirrored(a);
					playSound();
					runFunc(a, b);
					if (mirrored != a) runFunc(mirrored);
				}, this);
				
			case "in": 	// Mirror Outside to Inner ::
				
				new StepTimer(0, halfIndex, P.time, function(a, b){
					var mirrored = getMirrored(a);
					playSound();
					runFunc(a, b);
					if (mirrored != a) runFunc(mirrored);
				}, this);

			case "left":
				
				new StepTimer(0, stripes.length - 1, P.time, function(a, b){
					playSound();
					runFunc(a, b);
				}, this);
				
			case "right":
				
				new StepTimer(stripes.length - 1, 0, P.time, function(a, b){
					playSound();
					runFunc(a, b);
				}, this);
				

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
		new DelayCall(function(){
			
			// There is no point on keeping it onscreen
			if (runMode == "off")
				close();

			if (onComplete != null) onComplete();
			
		}, P.timePost, this);
		
	}//---------------------------------------------------;
	
	// --
	function _tweenStripeOn(s:Int,lastOne:Bool = false)
	{
		stripes[s].visible = true;
		FlxTween.tween(stripes[s].scale, { x:1 }, P.timeStripe, { ease:tween_ease, onComplete:function(_) {
			if (lastOne ) _transitionComplete();
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
		for (i in stripes) {
			i.destroy();
		}
		stripes = null;
		
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