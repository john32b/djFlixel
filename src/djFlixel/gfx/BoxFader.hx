/**

 A colored square that changes its alpha value in hard steps
 Can be placed on top of everything to create fade-like effects
 
 NOTE:
 	- use kill() if you want to stop the animation.
	
	
 NOTES:
 
	BLENDMODES:
 	add|alpha|darken|difference|erase|hardlight|invert|layer|lighten|multiply|
 	normal|overlay|screen|shader|subtract
	
 ============================================================== */


package djFlixel.gfx;

import djA.DataT;
import djFlixel.other.DelayCall;
import djFlixel.other.StepTimer;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;
import flash.display.BlendMode;


class BoxFader extends FlxSprite
{
	// All available blend modes, useful to have in an array
	// Not useful?
	//public static var BLEND_MODES = [
			//"normal", "add", "darken", "difference", "erase",
			//"hardlight", "invert", "lighten", "multiply", 
			//"overlay", "screen", "subtract"];
	
	// - Default Parameters
	var DEF_PAR = {
		time:1.25,		// How much time to take to reach the fade
		steps:4, 		// How many steps to take to reach the fade
		delayPost:0.2,	// How much time to wait after fading to callback (if any)
		blend:"normal",	// Apply this blendmode
		autoRemove:false // on FADEOFF() Remove from the state
	};
			
	var tickFadeAmount:Float;	// How much alpha to add/sub at each step
	var st:StepTimer = null;	// I Keep these in case I want to kill them while they are updating
	var dc:DelayCall = null;
	//====================================================;
	
   /**
	  If WIDTH, HEIGHT 0 it defaults to  FlxG.width\FlxG.Height
   **/
	public function new(X:Float = 0, Y:Float = 0, WIDTH:Float = 0, HEIGHT:Float = 0)
	{
		super(X, Y);
		if (WIDTH == 0) WIDTH = FlxG.width;
		if (HEIGHT == 0) HEIGHT = FlxG.height;
		makeGraphic(Std.int(WIDTH), Std.int(HEIGHT)); // White
		scrollFactor.set(0, 0);
		moves = active = false;
		setOff();
	}//---------------------------------------------------;
		
	/**
	 * Stop and remove any ongoing effect and disable the effect
	 */
	override public function kill():Void 
	{
		if (st != null) st.destroy();
		if (dc != null) dc.destroy();
	}//---------------------------------------------------;
	
	/**
	 * Show the box and hard set it to a color/blendmode,
	 * @param	color Color 0xRRGGBB, no alpha
	 * @param	blendMode add|alpha|darken|difference|erase|hardlight|invert|layer|lighten|multiply|normal|overlay|screen|shader|subtract
	 */
	public function setColor(Color:Int, ?BMode:String, ?Alpha:Float = 1)
	{
		kill();	// Just in case it is running
		alpha = Alpha;
		color = Color; // Because this is white, it should colorize this properly
		visible = true;
		if (BMode != null) blend = BMode;
	}//---------------------------------------------------;

	/**
	 * Hard reset the box to default/OFF
	 */
	public function setOff()
	{
		kill();	// Just in case it is running
		alpha = 0;
		visible = false;
		blend = BlendMode.NORMAL;
	}//---------------------------------------------------;

	/**
	 * Restore from current state to clear. If you want to fade from a solid color 
	 * call setColor(_) beforehand
	 * @param	CB Callback on complete
	 * @param	P Parameters Check BoxFader.DEF_PAR 
	 */	
	public function fadeOff(?CB:Void->Void, ?P:Dynamic)
	{
		P = DataT.copyFields(P, Reflect.copy(DEF_PAR));
		kill();
		tickFadeAmount = 1 / P.steps;
		
		st = new StepTimer((s, end)->{
			alpha = tickFadeAmount * s;
			if(end){
				setOff();
				dc = new DelayCall(CB, P.delayPost);
				if (P.autoRemove) FlxG.state.remove(this);
			}
		});
		st.start(P.steps, 0, P.time);
	}//---------------------------------------------------;
	
	/**
	 * Fade the box to a color
	 * @param Color Color to set the fade to
	 * @param CB Callback
	 * @param P Parameters object, Can override fields Check `BoxFader.DEF_PAR`
	 */
	public function fadeColor(?Color:Int = 0xFF000000, ?CB:Void->Void, ?P:Dynamic)
	{
		P = DataT.copyFields(P, Reflect.copy(DEF_PAR));
		kill();	
		tickFadeAmount = 1 / P.steps;
		
		// Color the surface, set the blend, and set the alpha
		// Set the alpha to either 0 or leave it to whatever it is
		setColor(Color, cast P.blend, alpha);
		
		st = new StepTimer((s, end)->{
			alpha = tickFadeAmount * s;
			if(end) {
				alpha = 1;
				dc = new DelayCall(CB, P.delayPost);
			}
		});
		st.start(0, P.steps, P.time);		
	}//---------------------------------------------------;
}// --