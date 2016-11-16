package djFlixel.fx;

import djFlixel.gfx.GfxTool;
import djFlixel.tool.DataTool;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;


/**
 * Fades the camera this sprite belongs to
 * using per pixel operations
 * 
 * Version 0.3
 * -----------
 *  + It works
 *  + Fade into and out of a custom color
 * 
 * How to Use
 * -----------
 * 
 *  Just call "new PixelFader("toblack");
 *  It will automatically get added to the state.
 *  check new() for parameters
 * 
 */

 
class PixelFader extends FlxSprite
{
	var onComplete:Void->Void = null;
	
	var timer:Float;
	var fadeSteps:Int;
	var timePost:Float;
	var stepTime:Float; // Fade every;
	
	var flag_toBlack:Bool;
	var flag_complete:Bool;
	var flag_autoDestroy:Bool;
	var flag_isInited:Bool;	// I want the first initialisation to happen later when the camera buffer is full

	// Only used when fading into screen. keeps a copy of the camera
	var source:BitmapData = null;
	
	static var OFFSET_MAP:Array<Int> = [32, 70, 100, 160, 255];
	
	// -- To black colors
	var blackR:Int;
	var blackG:Int;
	var blackB:Int;
	
	//====================================================;
	
	/**
	 * 
	 * @param   action "toblack", "toscreen"
	 * @param	params onComplete,pre,post,autoDestroy,stepTime
	 */
	public function new(action:String = "toblack", ?params:Dynamic)
	{
		super();
		params = DataTool.defParams(params, { 
				onComplete:null, 
				pre:0, 
				post:0, 
				autoDestroy:false, 
				stepTime:0.188,
				color: 0xFF000000 // Fade into or from this color
		} );
		scrollFactor.set(0, 0);
		solid = false;
		moves = false;
		onComplete = params.onComplete;
		stepTime = params.stepTime;
		timePost = params.post;
		timer = -params.pre;	
		
		flag_toBlack = action == "toblack";
		flag_autoDestroy = params.autoDestroy;
		flag_complete = false;
		flag_isInited = false;
		
		// -- 
		blackR = GfxTool.extractRed(params.color);
		blackG = GfxTool.extractGreen(params.color);
		blackB = GfxTool.extractBlue(params.color);
		
		fadeSteps = -1; // So it will start with 0 at the first increment
		
		if (flag_toBlack) {
			FlxG.state.draw(); // It's ok to draw now
			makeGraphic(camera.width, camera.height, camera.bgColor);
			stamp(camera.screen);
			flag_isInited = true;
		}else {
			// from black to screen
			makeGraphic(camera.width, camera.height, params.color);
			fadeSteps++; // skip the first step, as it's all black anyway
		}
		
		FlxG.state.add(this);
		
		// -- INFOS --
		// trace(" - Created PixelFader");
		// trace('   . width $width, height $height');
	}//---------------------------------------------------;
	
	override public function draw():Void 
	{
		if (!flag_isInited && !flag_toBlack) {
			flag_isInited = true;
			source = camera.buffer.clone();
		}
		super.draw();
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (!flag_isInited) return;
		
		if (flag_complete) 
		{
			timePost -= elapsed;
			if (timePost < 0) {
				// Don't update anymore
				active = false;
				// when going to screen, destroy by default.
				if (flag_autoDestroy || !flag_toBlack ) {
					FlxG.state.remove(this);
					destroy();
				}
				if (onComplete != null) onComplete();
				
			}
		}
		else 
		{
			timer += elapsed;
			if (timer > stepTime) {
				timer = 0;
				doFadeStep();
			}
			
		}
	}//---------------------------------------------------;
	
	
	// --
	function doFadeStep()
	{
		if (fadeSteps++ == OFFSET_MAP.length){
			flag_complete = true;
			if (!flag_toBlack) visible = false;
			return;
		}
		
		var p, R, G, B:Int;
		
		pixels.lock();
		
		if (flag_toBlack)
		{
	
			for (xx in 0...pixels.width)
			for (yy in 0...pixels.height)
			{
				p = pixels.getPixel(xx, yy);
				R = GfxTool.extractRed(p) - OFFSET_MAP[fadeSteps];
				G = GfxTool.extractGreen(p) - OFFSET_MAP[fadeSteps];
				B = GfxTool.extractBlue(p) - OFFSET_MAP[fadeSteps];
				if (R < blackR) R = blackR;
				if (G < blackG) G = blackG;
				if (B < blackB) B = blackB;
				pixels.setPixel(xx, yy, (R << 16) + (G << 8) + B);
			}
			
		}else { // It's faster this way
			// Works as above, but in reverse array
			for (xx in 0...pixels.width)
			for (yy in 0...pixels.height)
			{
				p = source.getPixel(xx, yy);
				R = GfxTool.extractRed(p) - OFFSET_MAP[OFFSET_MAP.length - fadeSteps];
				G = GfxTool.extractGreen(p) - OFFSET_MAP[OFFSET_MAP.length - fadeSteps];
				B = GfxTool.extractBlue(p) - OFFSET_MAP[OFFSET_MAP.length - fadeSteps];
				if (R < blackR) R = blackR; 
				if (G < blackG) G = blackG;
				if (B < blackB) B = blackB;
				pixels.setPixel(xx, yy, (R << 16) + (G << 8) + B);
			}
		}
		
		pixels.unlock();
		dirty = true;
	}//---------------------------------------------------;
	
	// --
	override public function destroy():Void 
	{			
		if (source != null) { source.dispose(); source = null; }	
		super.destroy();
	}//---------------------------------------------------;
}// --