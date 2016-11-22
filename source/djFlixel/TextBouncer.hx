package djFlixel;

import djFlixel.SND;
import djFlixel.gui.Align;
import djFlixel.tool.DataTool;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;

/**
 * Generate a text bounce effect
 * ...
 * @author 
 */
class TextBouncer extends FlxSpriteGroup
{	
	// Optional;
	public var onComplete:Void->Void = null;
	
	// Parameters
	var p:Dynamic;
	// --
	var text:String;
	var fontSize:Int;
	// -- 
	var letters:Array<FlxText>;
	var numberOfLetters:Int;
	// Hole the tweens
	var tweens:Array<VarTween>;
	
	//---------------------------------------------------;
	// --
	public function new(text_:String, fontSize_:Int, X:Float = 0, Y:Float = 0, ?params_:Dynamic)
	{
		super();
		x = X;
		y = Y;
		scrollFactor.set(0, 0);
		text = text_;
		fontSize = fontSize_;
		
		// -- Create the letters but don't add them to the stage yet.
		numberOfLetters = text_.length;
		letters = [];
		for (i in 0...numberOfLetters)
		{
			// Text Styling?
			var t = new FlxText(0, 0, 0, text_.charAt(i), fontSize);
			letters.push(t);
		}
		
		setParameters(params_);
	
	}//---------------------------------------------------;

	
	public function start(?onComplete_:Void->Void)
	{
		onComplete = onComplete_;
		
		// Add the letter objects
		// Set starting positions
		// Start tweens all at once?
		
		if (numberOfLetters < 1) {
			trace("Error: Can't TextBouncer with 0 letters");
			return;
		}
		
		tweens = [];
		
		for (i in 0...numberOfLetters)
		{
			if (i > 0)
				letters[i].x =  letters[i - 1].x + letters[i - 1].width - x; /// -x is bugfix, hack
				// First one is 0
			letters[i].y = -p.height;
			letters[i].alpha = 0;
			add(letters[i]);
			var t:VarTween = FlxTween.tween(letters[i], { alpha:1, y:this.y }, p.sp2, {
				ease:FlxEase.bounceOut, 
				startDelay:i * p.sp1, 
				onStart:function(_) { if (p.snd != null) SND.play(p.snd); }	
			});
			tweens.push(t);
		}// --

		this.width = letters[numberOfLetters - 1].x + letters[numberOfLetters - 1].width;
		this.height = letters[0].height;
		
		tweens[tweens.length - 1].onComplete = function(_) {
			if (onComplete != null) onComplete();
		}
		
		if (p.alignX) {
			Align.screen(this, "center", "none");
		}
		
		
	}//---------------------------------------------------;
	
	
	// --
	override public function destroy():Void 
	{
		for (i in tweens) {
			if (i != null) i.cancel();
		}
		super.destroy();
	}//---------------------------------------------------;

	/**
	 * Call this before starting the animation
	 * 
	 * @param	params, object:
	 * 
	 * 	sp1 : speed between letters, 0 for all at once
	 *  sp2 : speed of each letter to go down
	 *  height: height to fall from
	 *  alignX:Bool
	 * 
	 */
	public function setParameters(params:Dynamic)
	{
		p = DataTool.defParams(params, {
			sp1:0.08,
			sp2:1.0,
			height:100,
			alignX:false,
			snd:null
		});
	}//---------------------------------------------------;
	
}