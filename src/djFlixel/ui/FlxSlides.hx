
/**
  Presents sprites and text in slides
  
	- No width/height
	- Basic mouse, just click to go forward, click at the last page = close
	- AnyKey or RIGHT will go forward
	- Listen to events with onEvent
	- ESC will send "close" event
	
  Example:
  
	var slides = new FlxSlides(); add(slides);
	slides.newSlide();
	slides.a(D.text.get("HELLO WORLD", 24, 24));
	slides.a(D.align.down(D.text.get("This line will be placed below the previous one"), slides.last));
	.
	slides.newSlide();
	.
	.
	slides.finalize();
	slides.setArrows(8, 20, 100, 200);
	slides.onEvent=(e)->{ if(e=="close") .... };
	slides.goto(0);
  
 ================================================================ */
  
 
package djFlixel.ui;
import djA.DataT;
import djA.types.SimpleCoords;
import djFlixel.core.Dcontrols;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;


class FlxSlides extends FlxGroup
{
	// All slides
	var slides:Array<Array<FlxSprite>> = [];
	// Store all tweens that are in use
	var tweens:Array<VarTween> = [];
	// Pointer to active slide
	var slide:Array<FlxSprite>; 
	// Index of current viewing slide
	var index:Int = -1;
	
	// Store the starting positions of all the sprites
	var positions:Array<Array<SimpleCoords>>;
	
	var params = {
		delay:0.1,		// Delay between each sprite
		time:0.18,		// Time for sprite to animate in
		offset:"0:-16",	// Offset from final position
		ease:"backOut",	// FlxEase function
		mouse:true,		// Enable the use of mouse (it's very simple, clicking will go next, and at the end it will close)
	};
	
	// Last element added, user helper for aligning sprites
	public var last(default, null):FlxSprite;
	
	// Indicator Arrows, optional, enable with `setArrows()`
	var arrows:Array<UIIndicator>;
	
	// Basic events ::
	// - close
	// - next
	// - previous
	public var onEvent:String->Void = (b)->{};
	
	
	/**
	   You can override the default parameters, or some of its fields
	   @param	P Check source code `params` object
	**/
	public function new(?P:Dynamic) 
	{
		super();
		if (P != null) {
			params = DataT.copyFields(P, Reflect.copy(params));
		}
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (index ==-1) return;	// nothing is set yet
		
		#if (FLX_KEYBOARD)
		if (D.ctrl.justPressed(DButton.LEFT)) {
			if (index > 0) {
				goto(index - 1); onEvent('previous');
			}
		}else
		if (D.ctrl.justPressed(DButton.RIGHT)) {
			if (index < slides.length - 1) {
				goto(index + 1); onEvent('next'); 
			}
		}else
		if (FlxG.keys.justPressed.ESCAPE || D.ctrl.justPressed(DButton.X)) {
			onEvent('close');
		}else
		if (D.ctrl.justPressed(DButton._ANY)){
			if (index < slides.length - 1) {
				goto(index + 1); onEvent('next'); 
			}else{
				onEvent('close');
			}
		}
		#end
		
		if (params.mouse)
		{
			if (FlxG.mouse.justPressed) {
				if (index < slides.length - 1) {
					goto(index + 1); onEvent('next'); 
				}else{
					onEvent('close');
				}
			}
		}
	}//---------------------------------------------------;
	
	// --	
	override public function destroy():Void 
	{
		clearTweens();
		super.destroy();
		for (sl in slides) {
			for (o in sl) {
				o.destroy();
			}
		}
		
	}//---------------------------------------------------;
	
	/** Add a sprite to the last created slide with `newSlide()` */
	public function a(S:FlxSprite):FlxSprite
	{
		if (slide == null) throw "Forgot to create a new slide";
		slide.push(S);
		last = S;
		return S;
	}//---------------------------------------------------;
	
	/** Call this right after you are done adding sprites to slides 
	 *  - Locks position of all spites in all slides */
	public function finalize()
	{
		positions = [];
		for (sl in slides) {
			var posAr:Array<SimpleCoords> = [];
			for (sp in sl) {
				posAr.push(new SimpleCoords(Std.int(sp.x), Std.int(sp.y)));
			}
			positions.push(posAr);
		}
	}//---------------------------------------------------;
	
	/** Create a new slide for adding sprites */
	public function newSlide()
	{
		slide = [];
		slides.push(slide);
		last = null;
	}//---------------------------------------------------;
	
	/**  Goto a slide, starting from index 0 */
	public function goto(I:Int)
	{
		#if debug
		if (I<0 || I>=slides.length) throw "Out of bounds";
		#end
		
		// :: Remove old slide, even if it is ongoing
		clearTweens();
		if (slide != null) {
			for (i in slide) remove(i);
		}
		
		index = I;
		slide = slides[I];
		var pos = positions[I];
		if (pos == null) throw "Forgot to finalize";
		
		
		#if hl
		var off:Array<Int> = [for (i in params.offset.split(':')) Std.parseInt(i)];
		#else
		var off:Array<Int> = params.offset.split(':').map((i)->Std.parseInt(i));
		#end
		
		var easeFn:Float->Float = Reflect.field(FlxEase, params.ease);
		var i = 0;
		while (i < slide.length)
		{
			var s = slide[i];
			var p = pos[i];
			s.alpha = 0;
			s.setPosition(p.x + off[0], p.y + off[1]);
			tweens.push(FlxTween.tween(s, {x:p.x, y:p.y, alpha:1}, params.time, {startDelay:(i * params.delay) , ease:easeFn}));
			add(s);
			i++;
		}
		
		//if (tweens.length > 0) {
			//tweens[tweens.length - 1].onComplete = (_)->{
				//trace("Slide in complete");
				//if (onEvent != null) onEvent('slide-end');
			//};
		//}
		
		update_arrow_state();
	}//---------------------------------------------------;
	
	
	/**
	   Enable the use of indicator arrows.
	   - The arrows will be "left" , "right"
	   - Call this before GOTO()
	   @param	size Icon Size in the default icon set. MAKE SURE YOU HAVE INITIALIZED THE ICONS WITH D.ui.initIcons()
	   @param	x Position of the LEFT Arrow
	   @param	y Position of the LEFT Arrow
	   @param	width Mirror the second arrow to this much pixels to the first arrow
	**/
	public function setArrows(size:Int, x:Float, y:Float, width:Float)
	{
		arrows = [];
		arrows.push(new UIIndicator('$size:ar_left', x - size, y).setAnim(2, {axis:"-x", time:0.3, steps:3}));
		arrows.push(new UIIndicator('$size:ar_right', x + width, y).setAnim(2, {axis:"x", time:0.3, steps:3}));
		add(arrows[0]);
		add(arrows[1]);
	}//---------------------------------------------------;
	
	// Call after a page change, to refresh left-right arrow visibility
	function update_arrow_state()
	{
		if (arrows == null) return;
		arrows[0].setEnabled(index > 0);
		arrows[1].setEnabled(index < slides.length - 1);
		arrows[0].syncFrom(arrows[1]);
	}//---------------------------------------------------;
	
	function clearTweens()
	{
		for (t in tweens) D.dest.tween(t);
		tweens = [];
	}//---------------------------------------------------;
	
}// --