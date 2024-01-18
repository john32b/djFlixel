/**
  Sprite with purpose to be used as an Indicator UI Element
  
   - blinking
   - traveling, looping (for arrows)
   - You must give it a Bitmap
	
* EXAMPLE:  
	
	var b = new UIIndicator(20,20);
		b.loadGraphic( D.ui.getIcon(8,"heart") );
		b.setAnim(1, {travel:"y:-4", steps:4, time:0.5});
		b.setEnabled();
		add(b);
	
* Using TEXT as character

	- use ind.fromFlxText(..);
	- use ind.loadGraphic(D.text.get(">").pixels );
	
***********************************************************/
	 
package djFlixel.ui;

import djA.DataT;
import djFlixel.other.StepLoop;
import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.text.FlxText;
 
class UIIndicator extends FlxSprite
{
	// Special separator for parameters like {travel:"y:4"}
	inline static var CSV_SEP = ":";
	
	var param = {
		axis:"x", 		// Axis to move "-x", "-y" for negatives
		time:0.5,		// Time to complete a full cycle
		steps:2,		// How many steps to take to reach distance
		// Internal:
		_ax:true,		// true:x, false:y
		_neg:1,			// negative
	};
	
	var startX:Float;
	var startY:Float;
	
	var stimer:StepLoop;
	
	/**
	   You can use `IC` parameter to quickly load a standard icon, 
	   or you can load custom graphic with .loadGraphic()
	   - Starts off as Disabled. So you must setEnabled() later
	   - If you don't set X,Y now, and do it later, you MUST then call lockPos()
	   @param   b Set a custom bitmap
	   @param	X 
	   @param	Y
	**/
	public function new(?b:BitmapData, X:Float = 0, Y:Float = 0)
	{
		super(X, Y);
		if (b != null){
			loadGraphic(b);
		}
		lockPos();
		moves = active = visible = false;
	}//---------------------------------------------------;	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (stimer != null) {
			stimer.update(elapsed);
		}
	}//---------------------------------------------------;
	
	/** Use this to get the full graphic from a FlxText, Color+Borders **/
	public function fromFlxText(f:FlxText)
	{
		makeGraphic(f.pixels.width, f.pixels.height, 0x00000000, true);
		stamp(f);
	}//---------------------------------------------------;
	
	/**
	   Enable / Disable
	   Disabling hides it and stops all animation
	   Enabling shows it and starts animation
	   @return State. I need ot for the sync to work
	**/
	public function setEnabled(s:Bool = true)
	{
		if (active != s) {
			active = s;
			visible = s;
		}
	}//---------------------------------------------------;	
	
	/** Set sprite UI animation. You need to manually active it with setEnabled()
	   @param	type 1:Jerky Repeat, 2:Jerky Ping Pong , 3:Blink
	   @param	P { axis:"y", time:0.4, steps:2 }
	**/
	public function setAnim(type:Int, ?P:Dynamic):UIIndicator
	{
		param = DataT.copyFields(P, Reflect.copy(param));
		// If it is to blink, just alter the parameters
		if (type >= 3) {
			param.steps = 2; // on, off steps
			stimer = new StepLoop(1, param.steps, param.time, on_timer_blink);
		}else{
			if (param.axis.charAt(0) == "-") param._neg = -1;
			param._ax = (param.axis.charAt(param.axis.length - 1) == "x");
			stimer = new StepLoop(type, param.steps, param.time, on_timer_move);
		}
		
		stimer.start();
		//setEnabled(); -- no user will --
		return this;
	}//---------------------------------------------------;
	
	/** You need to call this, to make the current X,Y positions as 
	 * the starting positions, So animations will run from there 
	 **/
	public function lockPos()
	{
		startX = x;
		startY = y;
	}//---------------------------------------------------;
	
	/**
	   Sync Blinking of this Indicator to another Indicator
	**/
	public function syncFrom(U:UIIndicator)
	{
		stimer.syncFrom(U.stimer);
		stimer.fire();
	}//---------------------------------------------------;
	
	// --
	function on_timer_blink(v:Int)
	{
		visible = (v == 1);
	}//---------------------------------------------------;
	
	// --
	function on_timer_move(v:Int)
	{
		if (param._ax){
			x = startX + (v * param._neg);
		}else{
			y = startY + (v * param._neg);
		}
	}//---------------------------------------------------;
	
}// --