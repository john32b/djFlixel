package djFlixel.fx;

import djFlixel.tool.DEST;
import djFlixel.tool.DataTool;
import djFlixel.tool.DelayCall;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;
import openfl.display.BlendMode;


/**
 * A Simple Colored Box that fades in and out by changing the alpha through hard steps.
 * 
 * NOTE:
 * 	use kill() if you want to stop the animation.
 * 
 * BLENDMODES:
 * 	add|alpha|darken|difference|erase|hardlight|invert|layer|lighten|multiply|
 * 	normal|overlay|screen|shader|subtract
 * ...
 */
class BoxFader extends FlxSprite
{
	// Some defaults::
	// How many steps to take to reach the fade
	inline public static var FADE_STEPS:Int = 4;
	// How much time to take to reach the fade
	inline public static var FADE_TIME:Float = 1.25;
	// How much time to wait after fading to callback (if any)
	inline public static var DELAY_POST:Float = 0.2;
	
	// All available blend modes, useful to have in an array
	public static var BLEND_MODES = [
			"normal", "add", "darken", "difference", "erase",
			"hardlight", "invert", "lighten", "multiply", 
			"overlay", "screen", "subtract"];
	
	var tm:FlxTimer;
	var dc:DelayCall;
	var flag_is_clear:Bool = true;		// True if the effect is not being applied
	//====================================================;
	// --
	public function new(X:Float = 0, Y:Float = 0, WIDTH:Float = 0, HEIGHT:Float = 0)
	{
		super(X, Y);
		moves = false;
		active = false;	// Timer updates this
		if (WIDTH == 0) WIDTH = FlxG.width;
		if (HEIGHT == 0) HEIGHT = FlxG.height;
		makeGraphic(Std.int(WIDTH), Std.int(HEIGHT)); // White
		setOff();
	}//---------------------------------------------------;
	
	/**
	 * Stop and remove any ongoing effect and disable the effect
	 */
	override public function kill():Void 
	{
		tm = DEST.timer(tm);
		dc = FlxDestroyUtil.destroy(dc);
	}//---------------------------------------------------;
	
	/**
	 * Show the box and hard set it to a color/blendmode,
	 * @param	color Color 0xRRGGBB, no alpha
	 * @param	blendMode add|alpha|darken|difference|erase|hardlight|invert|layer|lighten|multiply|normal|overlay|screen|shader|subtract
	 */
	public function setColor(Color:Int, ?BMode:BlendMode, Alpha:Float = 1)
	{
		kill();	// Just in case it is running
		flag_is_clear = false;
		alpha = Alpha;
		visible = true;
		color = Color;
		if (BMode != null) blend = BMode;
	}//---------------------------------------------------;
	
	/**
	 * Hard reset the box to default/OFF
	 */
	public function setOff()
	{
		kill();	// Just in case it is running
		flag_is_clear = true;
		alpha = 0;
		visible = false;
		blend = BlendMode.NORMAL;
	}//---------------------------------------------------;

	/**
	 * Restore from current state to clear. If you want to fade from a solid color 
	 * call setColor(.) beforehand.
	 * @param	callback
	 * @param	params
	 */	
	public function fadeOff(?Callback:Dynamic, ?P:Dynamic)
	{
		P = DataTool.copyFieldsC(P, {
			time:FADE_TIME,
			steps:FADE_STEPS,
			delayPost:DELAY_POST,
			callback:Callback
		});
		
		if (flag_is_clear){
			if (P.callback != null) P.callback();
			return; // It's already off
		}
		
		kill();
		
		// Keep the current color and alpha,
		_timerHardStep(P.time, alpha, 0, P.steps, function(){
			setOff();
			if (P.callback != null) P.callback();
		},P.delayPost);
		
	}//---------------------------------------------------;
	
	/**
	 * Fade the box to a color
	 * @param	callback
	 * @param	params
	 */
	public function fadeColor(Color:Int = 0xFF000000, ?P:Dynamic)
	{
		P = DataTool.copyFieldsC(P, {
			time:FADE_TIME,
			steps:FADE_STEPS,
			delayPost:DELAY_POST, 
			blend:"normal",
			keepAlpha:true,	// if false will hard set the alpha to 0 on start
			callback:null
		});
		// Color the surface, set the blend, and set the alpha
		// Set the alpha to either 0 or leave it to whatever it is
		setColor(Color, P.blend, P.keepAlpha?alpha:0);
		// Start the timer and step towards alpha 1
		_timerHardStep(P.time, alpha, 1, P.steps, P.callback, P.delayPost);
	}//---------------------------------------------------;
	
	
	//-- Tween the alpha using an FlxTimer to achieve hard steps
	function _timerHardStep(totalTime:Float, start:Float, end:Float, steps:Int, ?callback:Void->Void, delayCall:Float = 0)
	{
		var tickTime = totalTime / steps;
		var fadeStep = (end - start) / steps;
		tm = new FlxTimer();
		tm.start(tickTime, function(_) {
			alpha += fadeStep;
			if (tm.loopsLeft == 0) {
				alpha = end;
				dc = new DelayCall(callback, delayCall);
			}
		}, steps);
	}//---------------------------------------------------;
	
}// --