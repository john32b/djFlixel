/**--------------------------------------------------------
 RainbowBorder.hx
 --------------------------------------------------------
 - Amstrad like animated Colorful borders
 - Default colors are Amstrad CPC based
 - Set your own COLORS by directly accessing the array "COLORS" to as many as you want
 
 -- *EXAMPLE*
	var rainbow = new RainbowStripes();
	rainbow.COLORS = [color1,color2,color3];
	add(rainbow);
	rainbow.queueModes(["1:0.4", "2:0.6", "3:0.6", "1:0.2"],()->{trace("Complete");});
	rainbow.setOn();
 
 *********************************************************/
package djFlixel.gfx;

import djFlixel.gfx.pal.Pal_CPC;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil;
import openfl.geom.Rectangle;


class RainbowStripes extends FlxSprite
{
	// defaults:
	static inline var DEF_MAX_STRIPE_HEIGHT:Int = 30;
	static inline var DEF_MIN_STRIPE_HEIGHT:Int = DEF_MAX_STRIPE_HEIGHT - 4;
	static inline var DEF_SPEED:Int = 40;
	
	// * Pointer to the active color array
	public var COLORS:Array<Int>;
			
	var st_height1:Int;			// Stripe Max Height
	var st_height0:Int;			// Min height
	var st_updateRate:Float;	// Every this much time stripes will be redrawn randomly
	var st_timer:Float;			// Timer for the stripe effect (counts down to 0)
	
	// A zoom value of 2+ is recommended to improve speed, as quality doesn't drop
	var zoom:Int;
	
	// Helpers
	var _rc:Rectangle; 
	var _ch:Int = 0;
	
	// Changes between predefined modes. setPredefs
	var _mTimer:Float;	// Timer for changing mode queue (counts down to 0)
	var _mQueue:Array<String>;
	var _mCb:Void->Void;
	//---------------------------------------------------;
	
	/**
		Creates a box with the effect, check file header for more info
	   @param	Width 0 for Full Width
	   @param	Height 0 for Full height
	   @param	Zoom Scales the bitmap data effect so it is faster to render
	**/
	public function new(Width:Float = 0, Height:Float = 0, Zoom:Int = 2)
	{
		super();
		width = Width != 0 ? Width: FlxG.width;
		height = Height != 0 ? Height: FlxG.height;
		zoom = Zoom;
		
		solid = moves = false;
		
		makeGraphic(Std.int(width / zoom), Std.int(height / zoom), 0xFFFFFFFF, true);
		
		scale.x = scale.y = zoom;

		origin.set(0, 0);
		updateHitbox();
		
		_rc = new Rectangle();
		_rc.width = pixels.width;
		
		COLORS = Pal_CPC.COL;
		
		setMode(1);
		setOn(false);
	}//---------------------------------------------------;

	/**
	   Visible and updating
	   @param	enabled
	**/
	public function setOn(enabled:Bool = true)
	{
		visible = enabled;
		active = enabled;
		if (!enabled) _mQueue = null;
	}//---------------------------------------------------;
	
	/**
	 * Set a predefined mode to run this.
	 * @param	mode [0-3] 0:Biggest stripes, 3:Smallest stripes
	 * @return
	 */
	public function setMode(mode:Int)
	{
		if (mode > 3) mode = 3;
		if (mode < 0) mode = 0;
		
		var i:Float;
		switch(mode)
		{
			case 0:
				i = pixels.height * 0.75;
				setStripeParam(i, i / 3, 0.24);
			case 1:	
				i = pixels.height / 3;
				setStripeParam(i, i / 4, 0.13);
			case 2:	
				i = pixels.height / 6;
				setStripeParam(i, i / 2, 0.1);
			case 3:	
				i = pixels.height / 16;
				setStripeParam(i, i / 2.5, 0.08);
			default:
		}
		
	}//---------------------------------------------------;
	
	/**
	   Queue a bunch of predefined modes in a sequence
	   - First mode is applied immediately
	   - Does not set ON or OFF, do it manually
	   @param ar format : [ "mode:time(seconds)" ... ] e.g. ["0:0.3" ,"1:0.4", "2:0.3" ]
	   @param cb Callback function when the sequence ends
	**/
	public function queueModes(ar:Array<String>, cb:Void->Void)
	{
		_mQueue = ar;
		_mCb = cb;
		queueProcess();
	}//---------------------------------------------------;
	
	// PRE, Queue != null
	function queueProcess()
	{
		if (_mQueue.length == 0)
		{
			_mQueue = null;
			if (_mCb != null) return _mCb();
		}else
		{
			// Next queue
			var s = _mQueue.shift().split(':');
			setMode(Std.parseInt(s[0]));
			_mTimer = Std.parseFloat(s[1]);
		}
	}//---------------------------------------------------;
	
	/**
	   Set a solid color by index ID (of COLORS array)
	**/
	public function setSolid(colorIndex:Int)
	{
		FlxSpriteUtil.drawRect(this, 0, 0, width, height, COLORS[colorIndex]);
	}//---------------------------------------------------;
	
	/**
	   Change stripe height and speed. This is for advanced usage. Just call setMode()
	   @param	maxH Max Height
	   @param	minH Min Height
	   @param	sp Update speed in millisecs
	**/
	public function setStripeParam(maxH:Float, minH:Float, sp:Float)
	{
		if (minH == 0) minH = maxH / 3;
		if (minH > maxH) maxH = minH + 1;
		if (minH == maxH) maxH++;
		st_height1 = Std.int(maxH);
		st_height0 = Std.int(minH);	
		st_updateRate = sp;
		st_timer = 0;
	}//---------------------------------------------------;

	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (_mQueue != null)
		{
			if ((_mTimer -= elapsed) <= 0)
			{
				queueProcess();
			}
		}
		
		if ((st_timer -= elapsed) <= 0)
		{
			// Render a new frame
			st_timer = st_updateRate;
			_ch = 0;
			pixels.lock();
			while (_ch < pixels.height)
			{
				_rc.y = _ch;
				_rc.height = FlxG.random.int(st_height0, st_height1) / zoom;
				_ch += Std.int(_rc.height);
				pixels.fillRect(_rc, COLORS[Math.floor( Math.random() * COLORS.length)]);
			}
			pixels.unlock();
			dirty = true;
		}
	}//---------------------------------------------------;
	

}//-- end class --//