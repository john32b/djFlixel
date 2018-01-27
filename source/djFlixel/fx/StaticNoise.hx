package djFlixel.fx;
import djFlixel.tool.DataTool;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * Quick static noise box.
 * Prerenders a custom amount of frames and loops between them. ( CPU efficient )
 * Starts running as soon as it's created
 * ...
 */
class StaticNoise extends FlxSprite
{
	// How many frames total
	var framesTotal:Int;
	// The current frame that is being displayed
	var currentFrame:Int;
	//-- Hold the prerendered frames
	var pFrames:Array<BitmapData>;
	// Update frame every this many milliseconds
	var FREQ:Float; 
	// Keep track of frame updates
	var timer:Float;
	// --
	var _tr:Rectangle;
	var _tp:Point;
	
	//====================================================;
	
	/**
	 * 
	 * @param	X Screen pos
	 * @param	Y Screen pos
	 * @param	WIDTH
	 * @param	HEIGHT
	 * @param	par { .color1 | .color2 | .frames:how many frames to prerender | fps:Playback rate }
	 */
	public function new(X:Float = 0, Y:Float = 0, WIDTH:Int = 0, HEIGHT:Int = 0, ?params:Dynamic)
	{
		super(X, Y);
		
		if (WIDTH < 1) WIDTH = FlxG.width;
		if (HEIGHT < 1) HEIGHT = FlxG.height;
		
		moves = false;
		
		makeGraphic(WIDTH, HEIGHT, 0);
		
		// Default parameters
		params = DataTool.copyFields(params, {	
			color1:0xFF222222, // dark gray
			color2:0xFF777777, // gray
			frames:5,
			fps:14,
			ratio:0.5
		});
		
		setFPS(params.fps);
		
		currentFrame = 0;
		framesTotal = params.frames;
		
		pFrames = [];
		// -- Create the frames
		
		for (i in 0...framesTotal)
		{
			var f = new BitmapData(WIDTH, HEIGHT);
			f.lock();
			for (xx in 0...WIDTH)
			for (yy in 0...HEIGHT)
			f.setPixel32(xx, yy, Math.random() < params.ratio?params.color1:params.color2);
			f.unlock();
			pFrames.push(f);
		}
		
		timer = FREQ + 1; // Force update
		
		_tr = new Rectangle(0, 0, WIDTH, HEIGHT);
		_tp = new Point(0, 0);
	}//---------------------------------------------------;
	
	// --
	public function setFPS(fps:Int)
	{
		if (fps < 1) fps = 1;
		FREQ = (1 / fps);
		timer = FREQ; // Force update at the next cycle
	}//---------------------------------------------------;
	
	
	// -
	override public function update(elapsed:Float):Void 
	{
		if ((timer+=elapsed) > FREQ)
		{
			timer = 0;
			pixels.lock();
			pixels.copyPixels(pFrames[currentFrame], _tr, _tp);
			pixels.unlock();
			dirty = true;
			if (++currentFrame >= framesTotal) currentFrame = 0;
		}
		
		super.update(elapsed);
	}//---------------------------------------------------;
	
	
	override public function destroy():Void 
	{
		for (i in pFrames){
			i.dispose();
		}
		pFrames = null;
		super.destroy();
	}//---------------------------------------------------;
	
}// --