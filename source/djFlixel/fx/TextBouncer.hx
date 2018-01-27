package djFlixel.fx;

import djFlixel.SND;
import djFlixel.gui.Gui;
import djFlixel.tool.DEST;
import djFlixel.tool.DataTool;
import djFlixel.tool.StepTimer;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.util.FlxDestroyUtil;

/**
 * Generate a text effect where letter bounce/tween one by one
 * ...
 */
class TextBouncer extends FlxSpriteGroup
{	
	// Parameters
	var P:Dynamic;
	var text:String;
	var letters:Array<FlxText>;
	var numberOfLetters:Int;
	// Hold the tweens
	var tweens:Array<VarTween> = null;
	var stimer:StepTimer;
	var easeFn:EaseFunction;
	
	//---------------------------------------------------;
	
	/**
	 * 
	 * @param	text_ The Text to display
	 * @param	X Coordinates
	 * @param	Y Coordinates
	 * @param	params_ Check setParameters()
	 */
	public function new(Text:String, X:Float = 0, Y:Float = 0, ?Params:Dynamic)
	{
		super();
		x = X;
		y = Y;
		scrollFactor.set(0, 0);
		text = Text;
		
		P = DataTool.copyFields(Params, {
			font:null,
			fontSize:8,
			color:0xFFFFFFFF,
			colorBorder:-1,
			pad:2,
			time:1,			// Time to complete the whole animation
			timeLetter:0.2,	// Time it takes for one letter to complete the tween
			startY:-50, 	// Starting Y Offset
			startX: 0, 		// Starting X Offset
			ease:"bounceOut",
			snd:null		// If set, it will play this sound with `SND.play()` every time a letter hits the ground
		});
		
		easeFn = Reflect.field(FlxEase, P.ease);
		// -- Create the letters but don't add them to the stage yet.
		numberOfLetters = text.length;
		letters = [];
		
		Gui.autoplaceOff(); // Just In Case
		
		var lastX:Float = 0;
		for (i in 0...numberOfLetters)
		{
			// var t = new FlxText(0, 0, 0, text_.charAt(i), P.fontSize);
			var t = Gui.getQText(text.charAt(i), P.fontSize, P.color, P.colorBorder);
			t.font = P.font;
			letters.push(t);
			// It's useful to have the text at their end positions now:
			t.x = lastX; lastX = t.x + t.width + P.pad;
			t.alpha = 0;
			add(t);
		}
		
	}//---------------------------------------------------;

	/**
	 * Start the text animation
	 * @param	onComplete_ Optional callback
	 */
	public function start(?onComplete:Void->Void)
	{
		if (tweens != null){
			trace("Error: Effect in progress");
			return;
		}
		
		if (numberOfLetters < 1) {
			trace("Error: Can't TextBounce with no letters");
			return;
		}
		
		tweens = [];
		// -- new way:
		stimer = new StepTimer(0, numberOfLetters - 1, P.time, function(a, b){
			
			var finalX = letters[a].x;
			
			letters[a].y += P.startY; // Initial position
			letters[a].x += P.startX; // Initial position
			
			if (P.snd != null) SND.play(P.snd);
			var t = FlxTween.tween(letters[a], {alpha:1, y:this.y, x:finalX}, P.timeLetter, { ease:easeFn });
			if (b == true) { // Last letter :
				t.onComplete = function(_){
					tweens = DEST.tweenAr(tweens);
					if (onComplete != null) onComplete();
				}
			}
			tweens.push(t);
		});
	}//---------------------------------------------------;
	
	// --
	override public function destroy():Void 
	{
		stimer  = FlxDestroyUtil.destroy(stimer);
		tweens = DEST.tweenAr(tweens);
		super.destroy();
	}//---------------------------------------------------;
	
}// --