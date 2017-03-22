package djFlixel.fx;

import djFlixel.tool.StepTimer;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import openfl.display.BlendMode;


/// TODO: This class is a mess, re-write it

/**
 * An object simulating a pallete fade,
 * It works as an overlay solid rect, fading the alpha
 * through hard steps. So it creates the illusion of fading the palette
 * ...
 */
class PalleteFaderFake extends FlxSprite
{	
	// Fade a step every this seconds
	public var step_frequency:Float = 0.10;
	
	// The main timer
	var stime:StepTimer;
	
	// Stores the callback for when ending a fade
	var callback_complete:Void->Void = null;
	
	// Slide the alpha through predefined steps 
	var ALPHA_STEPS:Array<Float> = [0, 0.15, 0.3, 0.5, 0.65, 0.8, 1 , 1];

	// General purpose flag, can be used for keeping track of the effects
	public var flag:Bool;
	
	//====================================================;
	// FUNCTIONS
	//====================================================;
	// --
	public function new(_width:Int = 0, _height:Int = 0)
	{
		super();
		
		if (_width == 0) _width = FlxG.width;
		if (_height == 0) _height = FlxG.height;
		
		setSize(_width, _height);
		scrollFactor.set(0, 0);
		
		makeGraphic(_width, _height);
		
		visible = false;
		active = false;
		
		stime = new StepTimer();
	}//---------------------------------------------------;
	
	/**
	 * As many steps as you want, from low to high.
	 * @param	ar [..] 0 to 1 values
	 */
	public function setAlphaSteps(ar:Array<Float>)
	{
		ALPHA_STEPS = ar;
		// Duplicate the last
		ALPHA_STEPS.push(ar[ar.length - 1]);	
	}//---------------------------------------------------;
	
	// --
	// Set the overylay to a solid color,
	// Call restore() to fade out of it later
	// public function solidColor(col:Int = 0xFF000000)
	public function solidColor(col:Int = 0xFF000000, ?autoRestoreTime:Float, ?callback:Void->Void)
	{
		active = false;
		visible = true;
		color = col;
		blend = null;
		
		// Autorestore to normal after x seconds
		if (autoRestoreTime != null)
		{
			new FlxTimer().start(autoRestoreTime, function(_) {
				restore(callback);
			});
		}
	}//---------------------------------------------------;
	
	/**
	 * Fade into a colored overlay
	 * @param	col The color to fade to, default BLACK
	 * @param	callback Call this when fade is complete
	 * @param	blendMode Blendmode
	 * @param	speedRatio Tweak the speed
	 */
	public function fadeColor(col:FlxColor = 0xFF000000, ?callback:Void->Void, ?blendMode:BlendMode, speedRatio:Float = 1)
	{		
		active = true;
		callback_complete = callback;
		blend = blendMode;
		color = col;
		
		// If it was already at an FX, hard set it to the new one
		if (visible == true)
		{
			stime.clear();
			alpha = 1;
			if (callback != null) callback();
		}else
		{
			visible = true;
			stime.once(0, ALPHA_STEPS.length - 1, step_frequency * speedRatio,
				function(s:Int) { 
					this.alpha = ALPHA_STEPS[s]; 
				}, _stepTimerComplete);
		}

	}//---------------------------------------------------;
	
	// --
	function _stepTimerComplete()
	{
		active = false;
		if (alpha == 0) visible = false;
		if (callback_complete != null) callback_complete();
	}//---------------------------------------------------;
	
	// --
	// Call this to fade out of the overlay
	// speedratio, customize speed, less than 1 for faster
	public function restore(?callback:Void->Void, speedRatio:Float = 1)
	{		
		callback_complete = callback;
		
		if (alpha != 1 || visible == false)
		{ 
			// trace("Warning: Trying to restore from a not solid state");
			resetState();
			return;
		}
		
		// The sprite is colored, now return it to normal
		active = true;
		visible = true;
		stime.once(ALPHA_STEPS.length - 1, 0, step_frequency * speedRatio, 
			function(s:Int) { 
				this.alpha = ALPHA_STEPS[s]; 
			}, 
			_stepTimerComplete);
		
	}//---------------------------------------------------;
	
	/**
	 * Force reset to a blank state
	 */
	public function resetState()
	{
		callback_complete = null;
		alpha = 0;
		stime.clear();
		_stepTimerComplete();
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		stime.update();
	}//---------------------------------------------------;
	
	// --
	override public function destroy():Void 
	{
		stime.clear();
		stime = null;
		callback_complete = null;
		super.destroy();
	}//---------------------------------------------------;

}// -- end -- //