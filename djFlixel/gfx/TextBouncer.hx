/**
 = Text Bouncer

 - Drops letters into view and they bounce
 - Automatically sets `scrollFactor = 0`
 - Does not autostart, you need to call `start()`
 - Before calling `start()` the letters are at the final position 0 alpha
   so you can use aligning functions like `D.align.screen()`
 
 = EXAMPLE :
	var lb = new TextBouncer("HELLO WORLD", 100, 100, 
		{f:'fnt/score.ttf', s:6, bc:Pal_CPCBoy.COL[2]}, 
		{time:2, timeL:0.5});
	add(lb);
	D.align.screen(lb); // center to screen
	lb.start(()->{
		trace("Bounce complete");
	});

 ===================================== */

package djFlixel.gfx;

import djA.DataT;
import djFlixel.core.Dtext.DTextStyle;
import djFlixel.other.StepTimer;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.util.FlxDestroyUtil;

class TextBouncer extends FlxSpriteGroup
{	
	// Running Parameters
	var P = {
		pad 	: 2,	// Horizontal Pad between letters
		time  	: 2,	// Time to complete the whole animation
		timeL	: 0.5,	// Time it takes for one letter to complete the tween
		startX  : 0,	// Start Offset X from the final (X,Y) pos
		startY  : -42,	// Start Offset Y from the final (X,Y) pos
		ease	: "bounceOut",	// Ease function name, consult <FlxEase.hx>
		snd0	: null, // Sound to play at each letter start. using D.snd.playV()
		snd1	: null  // Sound to play at each letter end. using D.snd.playV()
	}
	
	var letters:Array<FlxText>;
	var numberOfLetters:Int;
	var tweens:Array<VarTween> = null; // Holds all letter tweens
	var stimer:StepTimer;
	var easeFn:EaseFunction;
	
	/**
		Creates a spritegroup with dropping letters 
	   @param	TEXT Text
	   @param	X First letter final X
	   @param	Y First letter final Y
	   @param	ST Text Style
	   @param	Params Parameters override for `P` parameters object; check code inside.
	**/
	public function new(TEXT:String, X:Float, Y:Float, ?ST:DTextStyle, ?Params:Dynamic)
	{
		super();
		scrollFactor.set(0, 0);
		x = X;
		y = Y;

		this.moves = false;
		
		letters = []; // -- Create the letters but don't add them to the stage yet.
		numberOfLetters = TEXT.length;
		
		DataT.copyFields(Params, P);
		easeFn = Reflect.field(FlxEase, P.ease);
		
		var lastX:Float = 0;
		for (i in 0...numberOfLetters)
		{
			var t = D.text.get(TEXT.charAt(i), lastX, 0, ST);
			letters.push(t);
			lastX = t.x + t.width + P.pad;
			t.alpha = 0;
			add(t);
		}
		
	}//---------------------------------------------------;

	/**
	 * Start the text animation
	 * @param	onComplete Optional callback
	 */
	public function start(?onComplete:Void->Void)
	{
		if (tweens != null) {
			trace("Error: Effect in progress"); return;
		}
		if (numberOfLetters < 1) {
			trace("Error: Can't TextBounce with no letters"); return;
		}
		
		tweens = [];
		stimer = new StepTimer((a, end)->{
			var l = letters[a];
			var finalX = l.x;
			l.x += P.startX;
			l.y += P.startY;
			if (P.snd0 != null) D.snd.playV(P.snd0);
			var t = FlxTween.tween(l, {alpha:1, y:this.y, x:finalX}, P.timeL, {
					ease:easeFn,
					onComplete:(_)->{
						if (P.snd1 != null) D.snd.playV(P.snd1);
						if (end) {
							tweens = D.dest.tweenAr(tweens);
							if (onComplete != null) onComplete();
						}
					}});
			tweens.push(t);
		});// -- end stimer
		stimer.start(0, numberOfLetters - 1, P.time);
	}//---------------------------------------------------;
	
	// --
	override public function destroy():Void 
	{
		stimer = FlxDestroyUtil.destroy(stimer);
		tweens = D.dest.tweenAr(tweens);
		super.destroy();
	}//---------------------------------------------------;
	
}// --