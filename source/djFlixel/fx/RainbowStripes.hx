/**--------------------------------------------------------
 * RainbowBorder.hx
 * @author: johndimi, <johndimi@outlook.com> @jondmt
 * --------------------------------------------------------
 * @Description
 * -------
 * Amstrad like animated Colorful borders
 * 
 * @Notes
 * ------
 * 02-2015. rewritten from AS3
 * 
 *********************************************************/
package djFlixel.fx;

import djFlixel.gfx.Palette_Amstrad;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;


/**
 * User Example:
 * -------------
 * 	var R = new RainbowBorder();
 * 	R.setPredefined(1);
 * 	add(R);
 * 
 */

class RainbowStripes extends FlxSprite
{
	// defaults:
	private static inline var DEF_MAX_STRIPE_HEIGHT:Int = 30;
	private static inline var DEF_MIN_STRIPE_HEIGHT:Int = DEF_MAX_STRIPE_HEIGHT - 4;
	private static inline var DEF_SPEED:Int = 40;
	
	// * Pointer to the active color array
	public var COLORS:Array<Int>;
			
	// Parameters, the max and min height of a border color.
	private var param_max_height:Int;
	private var param_min_height:Int;
	private var param_speed:Float;		// Update rate of the stripes, in seconds
	private var timer:Float;
	
	// A zoom value of 2+ is recommended to improve speed, as quality doesn't drop
	private var zoom:Int;
	
	// Helpers 
	private var _rc:Rectangle;
	private var _ch:Int = 0;
	
	//---------------------------------------------------;
	// --
	public function new(Width:Float = 0, Height:Float = 0, Zoom:Int = 2)
	{
		super();
		width = Width != 0 ? Width: FlxG.width;
		height = Height != 0 ? Height: FlxG.height;
		zoom = Zoom;
		
		solid = false;
		moves = false;
		
		makeGraphic(Std.int(width / zoom), Std.int(height / zoom), 0xFFFFFFFF, true);
		
		// Note, scaling in flash is a bit slow.
		scale.x = zoom;
		scale.y = zoom;
		origin.set(0, 0);
		
		updateHitbox();
		
		_rc = new Rectangle();
		_rc.width = pixels.width;
		
		COLORS = Palette_Amstrad.COL;	// FUTURE: Set custom colors
		
		setPredefined(3);
		
	}//---------------------------------------------------;
	
	/**
	 * Set a predefined mode to run this.
	 * @param	mode [0-3] 0-one color border, 1-big borders, 2-smaller 3-smallest
	 * @return
	 */
	public function setPredefined(mode:Int)
	{
		if (mode > 3) mode = 3;
		if (mode < 0) mode = 0;
		
		var i:Float;
		switch(mode)
		{
			case 0:
				i = pixels.height * 0.75;
				setStripeHeight(i, i / 3);
				setSpeed(0.24);
			case 1:	
				i = pixels.height / 3;
				setStripeHeight(i, i / 4);
				setSpeed(0.13);
			case 2:	
				i = pixels.height / 6;
				setStripeHeight(i, i / 2);
				setSpeed(0.1);
			case 3:	
				i = pixels.height / 16;
				setStripeHeight(i, i / 2.5);
				setSpeed(0.08);
		}
		
	}//---------------------------------------------------;
	// --
	@:deprecated("I need to test this")
	public function setSolidBg(colorIndex:Int)
	{
		_ch = 0;
		while (_ch < pixels.height)
		{
			_rc.y = _ch;
			_rc.height = pixels.height;
			_ch += Std.int(_rc.height);
			
			pixels.fillRect(_rc,COLORS[colorIndex]);
		}
	}//---------------------------------------------------;
	// --
	/**
	 * Customize the line height. It will be randomized between a min and a max
	 * @param	maxH MAX height
	 * @param	minH MIN if 0 will get autocalculated to be 1/3 of MAX
	 */
	public function setStripeHeight(maxH:Float, minH:Float = 0)
	{
		if (minH == 0) minH = maxH / 3;
		if (minH > maxH) maxH = minH + 1;
		if (minH == maxH) maxH++;
		
		param_max_height = Std.int(maxH);
		param_min_height = Std.int(minH);
	}//---------------------------------------------------;
	
	/**
	 * Update every this many seconds
	 * @param	sp Seconds between updates
	 */
	public function setSpeed(sp:Float)
	{
		param_speed = sp;
		timer = 0;
	}//---------------------------------------------------;

	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// DON'T FORGET:
		// -------------
		// This will be called even if visible=false;
		// Use this.active = false to prevent this from updating.
		// ---------------
		
		timer -= FlxG.elapsed;
		
		if (timer < 0)
		{
			// Render a new frame
			timer = param_speed;
			
			_ch = 0;

			pixels.lock();
			
			while (_ch < pixels.height)
			{
				_rc.y = _ch;
				_rc.height = FlxG.random.int(param_min_height, param_max_height) / zoom;
				_ch += Std.int(_rc.height);
				pixels.fillRect(_rc, COLORS[Math.floor( Math.random() * COLORS.length)]);
			}
			
			pixels.unlock();
			dirty = true;
			
		}
	}//---------------------------------------------------;
	

}//-- end class --//