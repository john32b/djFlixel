package djFlixel.gui;

import djFlixel.gfx.GfxTool;
import djFlixel.tool.DEST;
import djFlixel.tool.DataTool;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.utils.Timer;
import flash.geom.Rectangle;
import flixel.FlxSprite;
import flixel.util.FlxTimer;


/**
 * A Panel with a solid background that pops up with an animation
 * 
 * NOTE: It starts off as transparent.
 * 
 * Usage: 
 * -------
 * 	var bg = new BGPOP(200,200,{bo);
 * 	bg.setStepTables([0.1, 0.4, 0.6, 1],[0.1, 0.6, 0.8, 1]);
 *  add(bg);
 *  bg.start();
 * 
 * 
 */
class PanelPop extends FlxSprite
{
	// -- Default update rate
	public static var DEF_TICK:Float = 0.12;
	//---------------------------------------------------;
	var timer:FlxTimer;
	// Helper store the drawing rect
	var rect:Rectangle; 
	// Current step in the tables
	var step:Int; 
	// Ratios to final height
	var heightSteps:Array<Float>;
	// Ratios to final width
	var widthSteps:Array<Float>;
	// --
	var bgColor:Int;
	// --
	var onComplete:Void->Void = null;
	
	// -- BORDER ::	
	var borderIm:BitmapData;
	var bs:Int; // Same as border.size, used for readability
	
	// Border Parameters
	public var border(default, null):Dynamic;
	
	// Declare the ID of the sounds you want to be played
	// # USER SET 
	public var sound:Dynamic = {
		start:null,	// at first step
		step:null,	// at every step
		end:null    // at last step
	};
	
	//---------------------------------------------------;
	
	/**
	 * 
	 * @param width Final width of the panel
	 * @param height Final height of the panel
	 * @param bgColor Color of the panel
	 * @param _border { size:Int, sheet:FlxGraphicAsset, inset:Int }
	 */
	public function new(width:Float, height:Float, _bgColor:Int = 0xFF000000, ?_border:Dynamic)
	{
		super();
		
		#if debug
			if (width <= 0 || height <= 0) throw "ERROR : Panel Size can't be 0";
		#end
		
		scrollFactor.set(0, 0);
		bgColor = _bgColor;

		// Default table works well on wide panels
		widthSteps =  [0.15, 1, 1, 1]; 
		heightSteps = [0.25, 0.5, 0.7, 1];
		
		// --
		border = DataTool.copyFields(_border, {
			sheet:null, // FlxGraphic: 8 square tiles, check the assets for examples
			size:8,		// int: Square size of the spritesheet
			inset:0		// int: Draw the background this much pixels inside of the area
		});
		
		bs = border.size;
		
		// --
		if (border.sheet != null) {
			borderIm = GfxTool.resolveBitmapData(border.sheet);
		}
		
		// Make the graphic transparent
		makeGraphic(cast width, cast height, 0x00000000);
		
	}//---------------------------------------------------;
	
	/**
	 * Set custom steps, you can use as many steps as you want
	 * Ratios from 0 to 1, Always end with 1
	 * @param	widthSt e.g. [0.1,0.4,0.7,1]
	 * @param	heightSt If ommitted, will copy the width
	 */
	public function setStepTables(ww:Array<Float>, ?hh:Array<Float>)
	{
		if (hh != null && ww.length != hh.length) {
			throw "Tables must have same length";
			return;
		}
		if (hh == null) hh = ww;
		widthSteps = ww;
		heightSteps = hh;
	}//---------------------------------------------------;
	
	/**
	 * Update the border animation by one step
	 * NOTE: Does not erase the previous step, it overwrites the pixels
	 * @param t Required to run this inside an FlxTimer
	 */
	function updateBorder(?t:FlxTimer)
	{
		var ww:Int = Std.int(widthSteps[step] * width);
		var hh:Int = Std.int(heightSteps[step] * height);
		var xx:Int = Std.int((width - ww) / 2); 
		var yy:Int = Std.int((height - hh) / 2);
		
		var rr = new Rectangle(xx + border.inset, yy + border.inset, ww - border.inset * 2, hh - border.inset * 2);
		
		pixels.lock();
		pixels.fillRect(rr, bgColor);
		
		// -- Draw the border if any
		if (borderIm != null)
		{
			var p = new Point();
			var l:Int;
			inline function	cp() {
				pixels.copyPixels(borderIm, rr, p, null, null, true);
			}
						
			// -- top line
			l = 0; rr.setTo(bs * 4, 0, bs, bs);
			while ((l += bs) < (ww - bs)) {
				p.setTo(xx + l, yy);
				cp();
			}
			// -- bottom line
			l = 0; rr.setTo(bs * 5, 0, bs, bs);
			while ((l += bs) < (ww - bs)) {
				p.setTo(xx + l, yy + hh - bs);
				cp();
			}
			// -- left stripe
			l = 0; rr.setTo(bs * 6, 0, bs, bs);
			while ((l += bs) < (hh - bs)) {
				p.setTo(xx , yy + l);
				cp();
			}
			// -- right stripe
			l = 0; rr.setTo(bs * 7, 0, bs, bs);
			while ((l += bs) < (hh - bs)) {
				p.setTo(xx + ww - bs, yy + l);
				cp();
			}
			
			// -- topleft corner
			rr.setTo(0, 0, bs, bs);
			p.setTo(xx, yy);
			cp();
			// -- topright corner
			rr.x += border.size; // go to the next tile
			p.setTo(xx + ww - bs, yy);
			cp();
			// -- bottom left corner
			rr.x += border.size;
			p.setTo(xx, yy + hh - bs);
			cp();
			// -- bottom right corner
			rr.x += border.size;
			p.setTo(xx + ww - bs, yy + hh - bs);
			cp();
			
		}
		
		if (sound.step != null) SND.play(sound.step);
		
		// --
		pixels.unlock();
		dirty = true;
		if ((++step) == widthSteps.length) {
			timer = DEST.timer(timer);
			if (onComplete != null) onComplete();
			if (sound.end != null) SND.play(sound.end);
		}
	}//---------------------------------------------------;
	
	/**
	 * Start the pop animation
	 * @param	_oncomplete Called when the pop animation is complete
	 * @param	speed Update rate for the animation, set to 0 for instant open
	 */
	public function open(?_oncomplete:Void->Void, speed:Float = -1)
	{
		timer = DEST.timer(timer); // Just in case it is running
		
		onComplete = _oncomplete;
		if (speed ==-1) speed = DEF_TICK;
		
		if (sound.start != null) SND.play(sound.start);
		if (speed == 0){
			// Set the step to be the final on the array
			step = widthSteps.length - 1;
			updateBorder(null);
		}else{
			step = 0;
			timer = new FlxTimer().start(speed, updateBorder, 0);
		}
	}//---------------------------------------------------;
	
	
	/**
	 * Close/Clear the graphic, without removing it from the stage
	 * INDEV: Do it with an animation
	 */
	public function clear()
	{
		// -- Clear the bitmap
		var rr = new Rectangle(0, 0, width, height);
		pixels.fillRect(rr, 0x00000000);
		dirty = true;
		timer = DEST.timer(timer);
	}//---------------------------------------------------;
	
	
	/**
	 * Change the background Color
	 * @param	col
	 */
	public function setBGColor(col:Int)
	{
		bgColor = col;
		updateBorder();
	}//---------------------------------------------------;
	
	// --
	override public function destroy():Void 
	{
		super.destroy();
		timer = DEST.timer(timer);
	}//---------------------------------------------------;
	
}// --