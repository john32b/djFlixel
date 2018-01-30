package djFlixel.fx;

import djFlixel.gfx.GfxTool;
import djFlixel.tool.DEST;
import djFlixel.tool.DataTool;
import djFlixel.tool.DelayCall;
import djFlixel.tool.StepTimer;
import flash.filters.ColorMatrixFilter;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import openfl.filters.BitmapFilter;

/**
 * Fades the screen in and out using BitmapFilters
 * 
 * NOTES :
 *  - Automatically being added and removed from the state
 * 	- Fading to a solid color is not implemented, only black is supported
 * 
 * HELP:
 * 
 * redResult   = (a[0]  * srcR) + (a[1]  * srcG) + (a[2]  * srcB) + (a[3]  * srcA) + a[4]
 * greenResult = (a[5]  * srcR) + (a[6]  * srcG) + (a[7]  * srcB) + (a[8]  * srcA) + a[9]
 * blueResult  = (a[10] * srcR) + (a[11] * srcG) + (a[12] * srcB) + (a[13] * srcA) + a[14]
 * alphaResult = (a[15] * srcR) + (a[16] * srcG) + (a[17] * srcB) + (a[18] * srcA) + a[19]
 * 
 * defaultMatrix = 
 * //	R  G  B  A  Offset
 * 	[	1, 0, 0, 0, 0,		// R
 * 		0, 1, 0, 0, 0,		// G
 * 		0, 0, 1, 0, 0,		// B
 *		0, 0, 0, 1, 0	];	// A
 * ...
 * @author John Dimi
 */
class FilterFader extends FlxObject 
{
	// Some defaults::
	// How many steps to take to reach the fade
	inline public static var FADE_STEPS:Int = 4;
	// How much time to take to reach the fade
	inline public static var FADE_TIME:Float = 1.25;
	// How much time to wait after fading to callback (if any)
	inline public static var DELAY_POST:Float = 0.2;
	
	// Parameters
	var P:Dynamic;
	var tm:FlxTimer;
	var flag_toBlack:Bool;
	var callback:Void->Void;
	var backupFilters:Array<BitmapFilter>;
	var st:StepTimer;
	
	//====================================================;
	public function new(action:String = "toblack", ?Callback:Void->Void, ?params:Dynamic)
	{
		super();
		active = false;
		moves = false;
		P = DataTool.copyFieldsC(params, {
				time:FADE_TIME,			// Total time to complete the fade
				steps:FADE_STEPS,		// How many fade steps to execute
				delayPost:DELAY_POST,	// Delay this much time before callback
				color: 0xFF000000, 		// Fade into or from this color
				autoRemove:false		// Will remove itself from the state once complete
		});
		
		flag_toBlack = action == "toblack";
		callback = Callback;
		FlxG.state.add(this);

		#if debug
		if (P.color != 0xFF000000){
			trace("Warning: Fading to other than black is not supported");
		}
		#end
		
		//-- Backup if any filters are set
		backupFilters = camera.flashSprite.filters;
		
		tm = new FlxTimer();
		
		if (flag_toBlack) 
		{
			st = new StepTimer(0, P.steps, P.time, _stepTimerTick);
		}
		else
		{
			st = new StepTimer(P.steps, 0 , P.time, _stepTimerTick);
		}
		
	}//---------------------------------------------------;
	// --
	function _stepTimerTick(step:Int, finished:Bool)
	{
		applyFilterStep(step);
		if (finished){
			tm.start(P.delayPost, function(_){
				if (!flag_toBlack || P.autoRemove) destroy();
				if (callback != null) callback(); 
			});
		}
	}//---------------------------------------------------;
	// --
	override public function destroy():Void 
	{
		camera.setFilters(backupFilters);
		if (st != null) st.destroy();
		DEST.timer(tm);
		FlxG.state.remove(this);
		super.destroy();
	}//---------------------------------------------------;
	/**
	 * Apply a filter fade step
	 * @param	st From 0 - > P.steps
	 */
	function applyFilterStep(st:Int)
	{
		var V = (1 / P.steps) * st;
		if (st == P.steps) V = 1; // Make sure the last step is a round 1
		var matrix = [
			1, 0, 0, 0, -V * 255,
			0, 1, 0, 0, -V * 255,
			0, 0, 1, 0, -V * 255,
			0, 0, 0, 1, 0];
		camera.setFilters([new ColorMatrixFilter(matrix)]);
	}//---------------------------------------------------;
	
}// --