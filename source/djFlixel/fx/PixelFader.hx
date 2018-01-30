package djFlixel.fx;

import djFlixel.gfx.GfxTool;
import djFlixel.tool.DataTool;
import djFlixel.tool.DelayCall;
import djFlixel.tool.StepTimer;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.NumTween;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;


/**
 * Fades the camera this sprite belongs to, using per pixel operations
 * -----------
 * 
 *  + Fade into and out of a custom color
 *  + It's not Dynamic!!! It will capture a screenshot and work on that screenshot
 * 
 * How to Use
 * -----------
 * 
 *  - Just call "new PixelFader("toblack");
 *  	It will automatically get added to the state. and use the default camera.
 *  	check new() for parameters
 * 	- To stop/remove the effect just call destroy();
 *  
 * NOTE:
 * -------
 * 
 */

 
class PixelFader extends FlxSprite
{
	// Fade steps, from 0->255
	public static var OFFSET_MAP:Array<Int> = [0, 32, 64, 96, 160, 255];
	// --
	var flag_toBlack:Bool;
	// --
	var callback:Void->Void;
	// Only used when fading into screen. keeps a copy of the camera
	var source:BitmapData = null;
	var blackR:Int;	// Minimum color value the pixels can be
	var blackG:Int; // -
	var blackB:Int; // -
	// Parameters
	var P:Dynamic;
	
	var st:StepTimer;
	var dc:DelayCall;
	// --
	var isInited:Bool = false;
	//====================================================;
	
	/**
	 * 
	 * @param   action "toblack", "toscreen"
	 * @param	params {
	 * 					onComplete:Void->Void
	 * 					pre:Float, time to wait before running
	 * 					post:Float, time to wait after completing
	 * 					autoDestroy:Bool, if true it will get removed from the stage after
	 * 					stepTime:Float, Time to wait for each step
	 * 					color:Int, recover from this color
	 * 				 }
	 */
	public function new(action:String = "toblack", ?Callback:Void->Void, ?params:Dynamic)
	{
		super();
			
		P = DataTool.copyFieldsC(params,{ 
				delayPost:0.5,
				time:2,				// Total time to complete the fade
				color: 0xFF000000 	// Fade into or from this color
		});
		
		callback = Callback;
		scrollFactor.set(0, 0);
		solid = false;
		moves = false;
		flag_toBlack = action == "toblack";
		
		#if neko
			trace("Error: PixelFader, not supported in NEKO");
			if (callback != null) callback();
			return;
		#end
		
		// -- 
		blackR = GfxTool.extractRed(P.color);
		blackG = GfxTool.extractGreen(P.color);
		blackB = GfxTool.extractBlue(P.color);

		makeGraphic(camera.width, camera.height, 0x00000000, true);
		FlxG.state.add(this);
		
	}//---------------------------------------------------;
	
	// --
	function initialize()
	{
		
		source = camera.buffer.clone();
		stamp(camera.screen);
		
		var _tickFN = function(val,finished){
			doFadeStep(val);
			if (finished) {
				dc = new DelayCall(function(){
					if (!flag_toBlack) destroy();
					if (callback != null) callback();
				}, P.delayPost);
			}
		};
		
		if (flag_toBlack) 
		{
			st = new StepTimer(0, OFFSET_MAP.length - 1, P.time, _tickFN);
		}
		else
		{
			st = new StepTimer(OFFSET_MAP.length - 1, 0, P.time, _tickFN);
		}
	}//---------------------------------------------------;
	
	
	
	/**
	 * I am initializing at the first draw to get a complete camera buffer, otherwise it's wrong
	 */
	override public function draw():Void 
	{
		if (!isInited) {
			isInited = true;
			FlxG.state.draw();
			initialize();
			return;
		}
		super.draw();
	}//---------------------------------------------------;
	
	
	/**
	 * 
	 * @param	st Make sure this is in [0...OFFSET_MAP.length]
	 */
	function doFadeStep(st:Int)
	{
		var p, R, G, B:Int;
		
		pixels.lock();
		
		for (xx in 0...pixels.width)
		for (yy in 0...pixels.height) 
		{
			p = source.getPixel(xx, yy);
			R = GfxTool.extractRed(p) - OFFSET_MAP[st];
			G = GfxTool.extractGreen(p) - OFFSET_MAP[st];
			B = GfxTool.extractBlue(p) - OFFSET_MAP[st];
			if (R < blackR) R = blackR;
			if (G < blackG) G = blackG;
			if (B < blackB) B = blackB;
			pixels.setPixel(xx, yy, (R << 16) + (G << 8) + B);
		}
		
		pixels.unlock();
		dirty = true;
	}//---------------------------------------------------;
	
	// --
	override public function destroy():Void 
	{
		FlxG.state.remove(this);
		st = FlxDestroyUtil.destroy(st);
		dc = FlxDestroyUtil.destroy(dc);
		source = FlxDestroyUtil.dispose(source);
		super.destroy();
	}//---------------------------------------------------;
}// --