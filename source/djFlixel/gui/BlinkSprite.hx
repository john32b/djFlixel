package djFlixel.gui;

import flixel.FlxSprite;


/**
 * A Sprite that blinks forever. Used in GUI elements
 * -----
 * LinkedSprites : 
 * . you "link" other sprites to this blinkSprite and all the linked sprites
 *   will blink in sync with this one. Add with addLinked(..)
 * 
 */
class BlinkSprite extends FlxSprite
{
	// Blink every X seconds
	public var blinkRate:Float = 0.25;
	
	// Keep the time
	var timer:Float = 0;
	
	// If a sprite has linked sprites, they will blink in sync with this one
	var linked:Array<FlxSprite>;
	
	//====================================================;
	// -- No constructor --
	// -- Just call .loadGraphic() yourself, it's more versatile this way
	//====================================================;
	
	/**
	 * Link a blinkSprite to this one.
	 * @param	s A child/linked sprite that will copy the blink from this one
	 */
	public function addLinked(s:FlxSprite)
	{
		if (linked == null) linked = []; 
		linked.push(s);
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		timer += elapsed;
		if (timer > blinkRate) {
			timer = 0;
			visible = !visible;
			if (linked != null) for (i in linked) i.visible = this.visible;
		}
	}//---------------------------------------------------;
	
	/**
	 * Resets the timer, useful when you want to sync the blink rate of multiple blinksprites,
	 * call sync() on all of them
	 */
	public function sync()
	{
		timer = 0;
		if (active) visible = true;
	}//---------------------------------------------------;
	
	/**
	 * Enable or Disable the blinking
	 * @param	bool If False it will automatically hide it
	 */
	public function set(state:Bool)
	{
		if (active == state) return;
		active = state;
		visible = state;
		if (linked != null) for (i in linked) {i.visible = visible; }	
	}//---------------------------------------------------;

}// --