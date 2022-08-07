/**
  
  Simple non-modal notification that slides into the screen from the edge
  and then auto-hides. Customizable colors, width, duration, etc.
  
  - Use the static version .FIRE() which is the easiest way to use this
  
  * Example
 
		FlxToast.FIRE("Press OK to continue", {timeOn:4} );
		
	- The static call autoadds and autoremoves the toast from the state
	
	
 ****************************************/
package djFlixel.ui;

import djA.DataT;
import djA.types.SimpleVector;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import djFlixel.gfx.pal.Pal_DB32 as DB32;

class FlxToast extends FlxSpriteGroup 
{
	static var toast:FlxToast;
	
	/** Set Global Toast Parameters,
	 * Overrides default parameters, check FlxToast {P} object
	 * @param	PAR Overlay parameters for the global Toast. They will persist.
	 */
	public static function init(?PAR:Dynamic)
	{
		if (toast == null || !toast.exists) {
			toast = new FlxToast();
		}
		if (PAR != null) toast.P = DataT.copyFields(PAR, toast.P);
	}//---------------------------------------------------;
	
	/**
	   Create a ToastSprite Add it to current state and Fire it at once.
	   - Gets automatically removed
	   @param	TXT Text supports Markup styles [ # , $ ]
	   @return The Toast Object, in case you want to remove/cancel it
	**/
	public static function FIRE(TXT:String):FlxToast
	{
		init();
		FlxG.state.add(toast);
		toast.onEnd = FlxG.state.remove.bind(toast, false);
		toast.fire(TXT);
		return toast;
	}//---------------------------------------------------;
	
	
	// ===================================================;
	
	// -- Visual Elements
	var text:FlxText;
	var bg:FlxSprite;
	
	// When animating, start and end to these positions
	var anim0:SimpleVector;
	var anim1:SimpleVector;
	
	// Called when the toast goes off screen
	var onEnd:Void->Void;
	
	// Default Running Parameters
	var P = {
		
		screen : "center:top",	// screen X,Y == left,center,right:top,bottom . e.g. "left:top" "right:bottom"
	
		minWidth : 32,			// Minimum width for the box
		maxWidth : 160,			// Maximum width of the box. If text is longer. It will word wrap
		
		padding: 4,				// Text padding to box
		margin: 2,				// Box margin from screen edge
	
		timeTween : 0.4,		// Time it takes to tween
		timeOn	  : 3,			// Time it stays on screen
		
		easeIn  : "elasticOut",	// Name of EaseFunction for when going in
		easeOut : "circIn",		// Name of EaseFunction for when going out
		
		alpha:1,				// Alpha of the background
		bg: DB32.COL[2],		// Background color
			
		textStyle:{
			c:DB32.COL[21],
			bc:DB32.COL[1]
		},
		
		colF1:DB32.COL[8],		// Format 1 Color #
		colF2:DB32.COL[18],		// Format 2 Color $
	};
	
	public function new() 
	{
		super();
		
		moves = visible = false;
		scrollFactor.set(0, 0);
		
		// --
		bg = new FlxSprite();
		bg.moves = false;
		bg.alpha = P.alpha;
		add(bg);

		// --
		text = D.text.get("", P.padding, P.padding, P.textStyle);
		add(text);
		
		// --
		anim0 = new SimpleVector();
		anim1 = new SimpleVector();
		
		// DEV: If those are already set, will do nothing
		D.text.markupAdd("#", P.colF1);
		D.text.markupAdd("$", P.colF2);
	}//---------------------------------------------------;
	
	
	// --
	// Usually when this is called, it will be for a state switch
	// Where all tweens will be auto-removed
	// But just in case I am removing the tweens manually
	override public function destroy():Void 
	{
		FlxTween.cancelTweensOf(this);
		super.destroy();
	}//---------------------------------------------------;
	
	
	/**
	 * Fire the toast
	 * @param	TXT Text supporting Markup styles [ # , $ ] e.g. "Press $ESC$ to Exit"
	 */
	public function fire(TXT:String)
	{
		
		// DEV: This is not as fast as keeping the `VarTween` Object. But a toast is not speed critical
		FlxTween.cancelTweensOf(this);
		
		D.text.applyMarkup(text, TXT);
		
		text.fieldWidth = 0; // Allow autosize
		var tmaxw = P.maxWidth - (P.padding * 2);
		if (text.width > tmaxw) {
			text.fieldWidth = tmaxw;
		}
		
		var W = Std.int(text.width + (P.padding * 2));
		var H = Std.int(text.height + (P.padding * 2));
		if (W < P.minWidth) W = P.minWidth;
		
		bg.makeGraphic(W, H, P.bg, true);
		
		// Screen Align (X,Y)
		var align = P.screen.split(':');
		
		switch (align[0]){
			case "left":
				anim0.x = anim1.x = 0 + P.margin;
			case "right":
				anim0.x = anim1.x = FlxG.width - W - P.margin;
			case "center":
				anim0.x = anim1.x = (FlxG.width / 2) - (W / 2);
			default: throw "Error";	
		}
		
		switch(align[1]) {
			case "top":
				anim0.y = -H + P.margin;
				anim1.y = 0 + P.margin;
			case "bottom":
				anim0.y = FlxG.height;
				anim1.y = anim0.y - H - P.margin;
			default: throw "Error";	
		}

		setPosition(anim0.x, anim0.y);
		visible = true;
		
		// - Start the tween
		FlxTween.tween(this, { x:anim1.x, y:anim1.y }, P.timeTween, {
				ease:Reflect.field(FlxEase, P.easeIn), 
				onComplete: function(e:FlxTween) {
					trace('Toast ComeIn - END');
					// When the toast is on, wait X seconds and anim out
					FlxTween.tween(this, { x:anim0.x, y:anim0.y }, P.timeTween, {
						  ease:Reflect.field(FlxEase ,P.easeOut),
						  startDelay:P.timeOn,
						  onComplete:function(e:FlxTween) {
							trace('Toast Backup - END');
							this.visible = false;
							if (onEnd != null) onEnd();
							}
						});
					}
				});
				
	}//---------------------------------------------------;
	
}// -- 