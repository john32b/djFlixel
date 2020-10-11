/**
 
 Fades the screen in and out using BitmapFilters
 
 NOTES
 -------
  - Automatically being added and removed from the state
  - Fading to a solid color is not implemented, only black is supported
 
 HELP
 -------
 
 redResult   = (a[0]  * srcR) + (a[1]  * srcG) + (a[2]  * srcB) + (a[3]  * srcA) + a[4]
 greenResult = (a[5]  * srcR) + (a[6]  * srcG) + (a[7]  * srcB) + (a[8]  * srcA) + a[9]
 blueResult  = (a[10] * srcR) + (a[11] * srcG) + (a[12] * srcB) + (a[13] * srcA) + a[14]
 alphaResult = (a[15] * srcR) + (a[16] * srcG) + (a[17] * srcB) + (a[18] * srcA) + a[19]
 
 defaultMatrix = 
 	    R  G  B  A  Offset
 	[	1, 0, 0, 0, 0,		// R
 		0, 1, 0, 0, 0,		// G
 		0, 0, 1, 0, 0,		// B
		0, 0, 0, 1, 0	];	// A
 
=================================================== */

 
package djFlixel.gfx;

import djA.DataT;
import djFlixel.other.DelayCall;
import djFlixel.other.StepTimer;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.BitmapFilter;


class FilterFader extends FlxObject 
{

	// - Default Parameters
	var DEF_PAR = {
		time:1.25,		// How much time to take to reach the fade
		steps:4, 		// How many steps to take to reach the fade
		delayPost:0.2,	// How much time to wait after fading to callback (if any)
		autoRemove:true	// on FADEOFF() Remove from the state
	};
	
	var P:Dynamic;	// Current run parameters
	var toBlack:Bool;
	var callback:Void->Void;
	var backupFilters:Array<BitmapFilter>;
	
	var st:StepTimer = null;	// I Keep these in case I want to kill them while they are updating
	var dc:DelayCall = null;

	/**
	   @param	toblack True to fade to black, False to fade from black
	   @param	CB Complete callback
	   @param	P Parameters, see <FilterFader.DEF_PAR>
	**/
	public function new(?TOBLACK:Bool = true, ?CB:Void->Void, ?PAR:Dynamic)
	{
		super();
		P = DataT.copyFields(PAR, Reflect.copy(DEF_PAR));
		active = moves = false;
		toBlack = TOBLACK;
		callback = CB;
		//-- Backup if any filters are set? Because they are going to be overwritten?
		backupFilters = camera.flashSprite.filters;
		st = new StepTimer(_stepTimerTick);
		if (toBlack){
			st.start(0, P.steps, P.time);
		}else{
			st.start(P.steps, 0, P.time);
		}
		FlxG.state.add(this);
	}//---------------------------------------------------;
	// --
	function _stepTimerTick(step:Int, finished:Bool)
	{
		applyFilterStep(step);
		if (finished){
			dc = new DelayCall(()->{
				if (!toBlack && P.autoRemove) kill();
				if (callback != null) callback(); 
			}, P.delayPost);
		}
	}//---------------------------------------------------;
	// --
	override public function kill():Void 
	{
		camera.setFilters(backupFilters);
		if (st != null) st.destroy();
		if (dc != null) dc.destroy();
		FlxG.state.remove(this);
		super.kill();
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