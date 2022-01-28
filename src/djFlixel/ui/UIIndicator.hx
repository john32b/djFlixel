/**
  Sprite with purpose to be used as an Indicator UI Element
   - blinking
   - traveling, looping (for arrows)
   - can initialize self using djFlixel icons
	
== Examples: ------
  
*  var a = new UIIndicator(10,10,{ic:"8:heart"}).applyFX({c:0xFF334455,sc:0xFF223322,so:[2,2]});
  
*  var b = new UIIndicator(20,20);
	  b.loadGraphic("customGraphic");
	  b.applyFx({...}); // You can still apply fx to a custom graphic
	  
*  var a = new UIIndicator(40, 140, "12:heart")
	 .applyFX({c:Palette_DB32.COL_28, sc:Palette_DB32.COL_02, so:[1, 2]})
	 .setAnim(1, {travel:"y:-4", steps:4, time:0.5});
	 add(a);
	
	 
== TIP: Use a TEXT character
	// > This way will get the text in white color
	var a = new UIIndicator();
		a.pixels = D.text.get("->").pixels;
		a.setAnim(1, {travel:"x:4");
	// > Use this to get an flxtext + colors + borders
		a.fromFlxText(..);
	 
 ==========================================================================*/
	 
package djFlixel.ui;
import djA.DataT;
import djFlixel.other.StepLoop;
import flash.display.BitmapData;
import flixel.FlxSprite;
import flixel.text.FlxText;

 
class UIIndicator extends FlxSprite
{
	// Special separator for parameters like {travel:"y:4"}
	inline static var CSV_SEP = ":";
	
	var stimer:StepLoop;
	
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
	
	/**
	   You can use `IC` parameter to quickly load a standard icon, 
	   or you can load custom graphic with .loadGraphic()
	   @param   IC Set Icon, CSV: "size:iconName" or "size:iconIndex"
	   @param	X 
	   @param	Y
	**/
	public function new(?IC:String, X:Float = 0, Y:Float = 0)
	{
		super(X, Y);
		scrollFactor.set(0, 0);
		// - Parse the icon data
		if (IC!=null) {
			var ic = IC.split(CSV_SEP);
			var b = D.ui.getIcon(Std.parseInt(ic[0]), ic[1], Std.parseInt(ic[1]));
			loadGraphic(b);
		}
		lockPos();
		active = false;
		visible = false;
	}//---------------------------------------------------;	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (stimer != null) {
			stimer.update(elapsed);
		}
	}//---------------------------------------------------;
	
	/** Use this to get the full graphic from a FlxText Color+Borders **/
	public function fromFlxText(f:FlxText)
	{
		makeGraphic(f.pixels.width, f.pixels.height, 0x00000000, true);
		stamp(f);
	}//---------------------------------------------------;
	
	/**
	   Apply Color + Shadow Color + Shadow Offset
	   DEV : Applying shadow, changes the sprite size
	   @param  O { c:Int|color, sc:Int|shadow Color, so:Array<Int>|shadow offset [x,y] }
	   @return Self
	**/
	public function applyFX(O:Dynamic):UIIndicator
	{
		if (O.so == null) O.so = [1, 1];
		var b = pixels;
		if (O.c != null) {
			D.bmu.replaceColor(b, 0xFFFFFFFF, O.c);
		}
		if (O.sc != null) {
			b = D.bmu.applyShadow(b, O.sc, O.so[0], O.so[1]);
		}
		pixels = b;
		dirty = true;
		return this;
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
			param.steps = 2;
			stimer = new StepLoop(1, param.steps, param.time, on_timer_blink);
		}else{
			if (param.axis.charAt(0) == "-") param._neg = -1;
			param._ax = (param.axis.charAt(param.axis.length - 1) == "x");
			stimer = new StepLoop(type, param.steps, param.time, on_timer_move);
		}
		stimer.start();
		//setEnabled();
		// fire?
		return this;
	}//---------------------------------------------------;
	
	public function lockPos()
	{
		startX = x;
		startY = y;
	}//---------------------------------------------------;
	
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