package djFlixel.fx;
import djFlixel.tool.DataTool;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * Quick static noise box that is pre-rendered for speed
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
	 * @param	par { .color1 | .color2 | .frames:how many frames to prerender }
	 */
	public function new(X:Float = 0, Y:Float = 0, WIDTH:Int = 0, HEIGHT:Int = 0, ?par:Dynamic)
	{
		super(X, Y);
		
		if (WIDTH == 0) WIDTH = FlxG.width;
		if (HEIGHT == 0) HEIGHT = FlxG.height;
		
		makeGraphic(WIDTH, HEIGHT, 0);
		
		// Default parameters
		par = DataTool.defParams(par, {
			color1:0xFF333333, // dark gray
			color2:0xFF999999, // gray
			frames:5,
			fps:14
		});
		
		FREQ = (1 / par.fps);
		
		currentFrame = 0;
		framesTotal = par.frames;
		
		pFrames = [];
		// -- Create the frames
		
		for (i in 0...framesTotal)
		{
			var f = new BitmapData(WIDTH, HEIGHT);
			f.lock();
			for (xx in 0...WIDTH)
			for (yy in 0...HEIGHT)
			f.setPixel32(xx, yy, Math.random() < 0.5?par.color1:par.color2);
			f.unlock();
			pFrames.push(f);
		}
		
		timer = FREQ + 1; // Force update
		
		_tr = new Rectangle(0, 0, WIDTH, HEIGHT);
		_tp = new Point(0, 0);
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
	
	
}// --