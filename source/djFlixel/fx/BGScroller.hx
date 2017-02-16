package djFlixel.fx;
import djFlixel.Controls;
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/// DEPRECATED

/**
 * Just use FlxBackdrop,same deal, I wrote this for nothing.
 * ...
 */
class BGScroller extends FlxSprite
{
	static inline var DEF_ANGLE:Int = 180;
	static inline var DEF_SPEED:Float = 1.2;
	static inline var DEF_FPS:Float = 220;
	
	// * Pointer to the texture to show
	var texture:BitmapData;

	// The angle which the stars are traveling in degrees
	var currentAngle:Float;
	var currentSpeed:Float;
	
	// Calculated Vector for traveling of the stars
	var dirX:Float;
	var dirY:Float;
	// --
	var updateFrequency:Float;
	var updateTimer:Float;

	// How many times the texture fits on the X and Y axis
	var times_x:Int;
	var times_y:Int;
	
	// Current scrolling offset for the texture, max is texture.width or height
	var xOffset:Float;
	var yOffset:Float;
	
	// Temp FS Rectangle
	var fsRect:Rectangle;
	var cx0:Int;
	var cx1:Int;
	
	var cy0:Int;
	var cy1:Int;
	
	//====================================================;
	
	// --
	public function new(Width:Int = 0, Height:Int = 0, filename:String)
	{
		super();
		
		width = Width != 0 ? Width: FlxG.width;
		height = Height != 0 ? Height: FlxG.height;
		solid = false;
		
		texture = Assets.getBitmapData(filename);
		
		times_x = Math.ceil(width / texture.width);
		times_y = Math.ceil(height / texture.height);
		
		xOffset = 0;
		yOffset = 0;
		
		setSpeed(DEF_SPEED);
		setDirection(DEF_ANGLE);
		setUpdateFPS(DEF_FPS);
		
		// -- Initialize with new texture ::
		// Make the graphic bigger so it was space to scroll
		makeGraphic(times_x * texture.width, times_y * texture.height, 0xFF224411);
		
		var tex_rect = new Rectangle(0, 0, texture.width - 1, texture.height - 1);
		var tex_point = new Point();
		
		pixels.lock();
		
		for (xx in 0...times_x)
		{
			tex_point.x = xx * texture.width;
			
			for (yy in 0...times_y)
			{
				tex_point.y = yy * texture.height;
				pixels.copyPixels(texture, tex_rect, tex_point);
			}
		}
		
		pixels.unlock();
		
		
		
		#if debug
		trace('Info: === Creating BG Scroller, size = ($width,$height)');
		trace('Info: Texture size = (${texture.width},${texture.height}');
		trace('Info: Texture timesX=($times_x), timesY=($times_y)');
		trace('Info: Direction = ($dirX,$dirY)');
		#end
			
	}//---------------------------------------------------;
	override public function destroy():Void 
	{
		super.destroy();
		if (texture != null) texture = null;
		_rect = null;
		_point = null;
	}//---------------------------------------------------;
	// --
	public function setDirection(angl:Float)
	{
		currentAngle = angl;
		var toRads:Float = Math.PI / 180;
		dirX = Math.cos(currentAngle * toRads);
		dirY = Math.sin(currentAngle * toRads);	
	}//---------------------------------------------------;
	public function setSpeed(spd:Float)
	{
		currentSpeed = spd;
	}//---------------------------------------------------;
	public function setUpdateFPS(fps:Float)
	{
		updateFrequency = 1 / fps;
		updateTimer = 0;
	}//---------------------------------------------------;

	
	// --
	override public function update(elapsed:Float):Void 
	{
		
		if (Controls.pressed(Controls.LEFT)){
			dirX -= 0.3;
		}else
		if (Controls.pressed(Controls.RIGHT)){
			dirX += 0.3;
		}else
		if (Controls.pressed(Controls.UP)){
			dirY -= 0.3;
		}else
		if (Controls.pressed(Controls.DOWN)){
			dirY += 0.3;
		}
		
		updateTimer -= FlxG.elapsed;
		
		if (updateTimer < 0)
		{
			updateTimer = updateFrequency;
			
			xOffset += dirX;
			yOffset += dirY;
			
			if (xOffset > texture.width) {
				xOffset -= texture.width;
			}else
			if (xOffset < texture.width) {
				xOffset += texture.width;
			}
			
			if (yOffset > texture.height) {
				yOffset -= texture.height;
			}else
			if (yOffset < texture.height) {
				yOffset += texture.height;
			}
			
			x = xOffset;
			y = yOffset;
		}
		
		super.update(elapsed);
		
	}//---------------------------------------------------;

}// -- end -- 