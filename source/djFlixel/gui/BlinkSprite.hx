package djFlixel.gui;

import flixel.FlxSprite;

/**
 * ...
 * @author JohnDimi
 */
class BlinkSprite extends FlxSprite
{
	
	public var blinkRate:Float = 0.25;
	
	// I want a synced timer
	var timer:Float = 0;
	
	/**
	 * If size_ is set then it will assume that the image is a spritesheet,
	 * @param	X
	 * @param	Y
	 * @param	image_ Path of the image
	 * @param	size_ Set this to force a sprite sheet. BOX sized for now
	 * @param	frame_ Only set if spritesheet
	 */
	public function new(?X:Float = 0, ?Y:Float = 0, image_:String, size_:Int=0, frame_:Int = 0) 
	{
		super(X, Y);
		if (size_ > 0)
		{
			loadGraphic(image_, true, size_, size_);
			animation.frameIndex = frame_;
		}else {
			loadGraphic(image_);
		}
		
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		timer += elapsed;
		if (timer > blinkRate) {
			timer = 0;
			visible = !visible;
		}
	}//---------------------------------------------------;
	
	public function set(bool:Bool)
	{
		if (active == bool) return;
		active = bool;
		visible = bool;
	}//---------------------------------------------------;
	
}