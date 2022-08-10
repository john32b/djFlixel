
/**
 * A full screen effect that displays a string letter by letter
 * - Will run as soon as it starts
 * 
 ************************************************************/

package common;

import djA.DataT;
import djFlixel.D;
import djFlixel.core.Dtext.DTextStyle;
import djFlixel.other.DelayCall;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;

class SubState_Letters extends FlxSubState
{
	var P = {
		text:{					// DTextStyle
			s:128,
			c:0xFFFFFFFF,
		},
		bg:0xFF000000,			// Background color, (-1) for NO background
		tLetter:0.14,			// Time to spend on each letter
		tWait:0.04,				// Time to pause after each letter
		tPre:0,					// Time to wait before starting the FX
		tPost:0,				// Time to wait after completion to callback/end
		snd:null,				// Play this sound at each letter
		autoRemove:true,		// If true will remove the state from the mainstate
		ease:"elasticOut",		// Letter ease type
		ofEnd   : [0, 0],		// The state tries to center the letters, but you can apply an offset
		ofStart : [0,-16]		// Start from these positions
	};
	
	var TEXT:String;
	var current:Int;
	var letter:FlxText;
	var timer:Float;
	var nextTime:Float;
	var flag_next_ON:Bool; // Toggle between two wait states
	var tween:VarTween;
	var callback:Void->Void;
	
	/**
	 * Fullscreen Effect Show huge letters in the center of the screen one by one
	 * @param	TXT The Text to show, letter by letter
	 * @param	CB  Once it ends
	 * @param	PAR Check <DEF_PAR> for overrides
	 */
	public function new(TXT:String, CB:Void->Void, ?PAR:Dynamic)
	{
		super();
		TEXT = TXT;
		callback = CB;
		P = DataT.copyFields(PAR, P);
		FlxG.state.openSubState(this);
	}//---------------------------------------------------;

	// --
	override public function create():Void 
	{
		super.create();
		
		// -- Background
		if (P.bg !=-1) {
			var box = new FlxSprite();
			box.makeGraphic(FlxG.width, FlxG.height, P.bg);
			add(box);
		}
		// -
		letter = D.text.get('', 0, 0, P.text);
		add(letter);
		// -
		flag_next_ON = true; 	// next update new letter
		current = 0;
		timer = 0;
		nextTime = P.tPre;		// Wait this much for the first update
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
					nextTime = 999; // HACK, don't update again
					this.add(new DelayCall(false, P.tPost, ()->{
						if (P.autoRemove) close();
						if (callback != null) callback();
					}));
					return;
				}
				
				letter.text = TEXT.charAt(current);
				letter.visible = true;
				D.align.screen(letter);
				
				letter.x += P.ofEnd[0];
				letter.y += P.ofEnd[1];
				
				nextTime = P.tLetter;
				flag_next_ON = false;
				current++;
				
				tween = FlxTween.tween(letter, {y:letter.y, x:letter.x}, P.tLetter * 0.5, {
					ease:Reflect.field(FlxEase, P.ease)
				});
				
				letter.x += P.ofStart[0];
				letter.y += P.ofStart[1];
				
				if (P.snd != null) D.snd.playV(P.snd);
			}
			else
			{
				letter.visible = false;
				flag_next_ON = true;
				nextTime = P.tWait;
			}
		}
	}//---------------------------------------------------;
	
	
}// --