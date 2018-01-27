package common;
import djFlixel.SND;
import djFlixel.gui.Align;
import djFlixel.tool.DataTool;
import djFlixel.tool.DelayCall;
import djFlixel.tool.StepTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;

// TODO: Put in in the djflixel.fx package

/**
 * A full screen effect that displays a string letter by letter
 * ...
 */
class SubState_Letters extends FlxSubState
{
	
	// Text to display
	var TEXT:String;
	
	var current:Int;
	
	var P:Dynamic;
	
	var letter:FlxText;
	
	var timer:Float;
	
	var nextTime:Float;
	
	var flag_next_ON:Bool; // Toggle between two wait states
	
	var tween:VarTween;
	
	var callback:Void->Void;
	
	/**
	 * Fullscreen Effect Show huge letters in the center of the screen one by one
	 * @param	TXT The Text to show, letter by letter
	 * @param	Callback Once it ends
	 * @param	Params Check code inside
	 */
	public function new(TXT:String, Callback:Void->Void, ?Params:Dynamic)
	{
		super();
		
		P = DataTool.copyFieldsC(Params, {
			
			font:null,
			fontSize:128,			
			
			color:0xFFFFFFFF,		// Letter color
			colorBG:0xFF000000,		// Background color, (-1) for NO background
			
			timeLetter:0.14,		// Time to spend on each letter
			timeWait:0.04,			// Time to pause after each letter
			
			timePre:0,				// Time to wait before starting the FX
			timePost:0,				// Time to wait after completion to callback/end
			
			autoRemove:true,		// If true will remove the state from the mainstate
			sound:null,				// Play this sound on each letter
			
			ease:"elasticOut",		// Letter ease type
			ofEnd   : [0, 0],		// The state tries to center the letters, but you can apply an offset
			ofStart : [0,-16]		// Start from these positions
		});
		
		TEXT = TXT;
		callback = Callback;
	}//---------------------------------------------------;

	// --
	override public function create():Void 
	{
		super.create();
		
		
		if (P.colorBG !=-1)
		{
			var box = new FlxSprite();
			box.makeGraphic(FlxG.width, FlxG.height, P.colorBG);
			add(box);
			
		}
		
		// -
		letter = new FlxText();
		letter.color = P.color;
		letter.font = P.font;
		letter.size = P.fontSize;
		add(letter);
		
		flag_next_ON = true; // next update new letter
		current = 0;
		timer = 0;
		nextTime = P.timePre;	// Wait this much for the first update
	}//---------------------------------------------------;
	
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if ( (timer += elapsed) >= nextTime)
		{
			timer = 0;
			
			if (flag_next_ON)
			{
				if (current == TEXT.length)
				{
					// Reached the End.
					new DelayCall(function(){
						
						if (P.autoRemove)
						{
							close();
						}
						
						if (callback != null) 
						{
							callback();
						}
						
					}, P.timePost, this);
					
					return;
				}
				
				letter.text = TEXT.charAt(current);
				letter.visible = true;
				Align.screen(letter);
				
				letter.x += P.ofEnd[0];
				letter.y += P.ofEnd[1];
				
				nextTime = P.timeLetter;
				flag_next_ON = false;
				current++;
				
				tween = FlxTween.tween(letter, {y:letter.y, x:letter.x}, P.timeLetter * 0.5, {
					ease:Reflect.field(FlxEase, P.ease)
				});
				
				letter.x += P.ofStart[0];
				letter.y += P.ofStart[1];
				
				if (P.sound != null)
				{
					SND.play(P.sound);
				}
			}
			else
			{
				letter.visible = false;
				nextTime = P.timeWait;
				flag_next_ON = true;
			}
		}
	}//---------------------------------------------------;
	
	
}// --