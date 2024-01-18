/**
 = TEXT EFFECT =
 = Horizontal scroll
 
 - supports wave/sine effect
 - scrolls into the whole screen width.
 
 == EXAMPLE :
 	var ts = new TextScroller("FUTURE KNIGHT DX - ", 
		{f:'fnt/text.ttf', s:16, bc:Pal_CPCBoy.COL[2]},
		{y:100,speed:2,sHeight:32, w0:4, w1:0.06} );
	add(ts);
 
 ========================================== */

package djFlixel.gfx;

import djA.DataT;
import djFlixel.core.Dtext.DTextStyle;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxText;


class TextScroller extends FlxTypedGroup<FlxText>
{
	// Default parameters
	static var DEF_PAR = {
		pad:4,				// Letter padding
		x:0,
		y:32,				// Screen Y location 
		width:0,			// 0 for default whole screen (FlxG.width)
		// --
		sHeight:16,			// Wave height, in pixels
		w0:2,				// Wave width, Smaller numbers, bigger length. Related on P.Width
		w1:0.02,			// Wave. Accumulator. Makes the wave slide a bit, USE SMALL VALUES! or 0
		speed:1,			// Scroll speed from right to left
		loopMode:1			// 0=No loop, 1=Loops tightly, 2=Loops When all letters have passed
	};
	
	var letterWidth:Int; 		// Letter width PLUS padding
	var lastLetter:FlxText; 	// Pointer to the last letter fired
	var maxLetters:Int;			// How many letters the screen fits
	var nextLetterIndex:Int;	// Next letter index to fire
	var text:String;			// The text string to show
	var P:Dynamic;				// Active Parameters
	var PiStep:Float;			// Pi increment at x position
	
	public var onLoop:Void->Void;	// Fires when a loop has completed. If loopMode==0 will fire once
	
	/**
		Creates a text scrolling effect. check file header for infos.
	 * @param	Text The text to display
	 * @param	Callback Callbacks when a loop has been completed
	 * @param	Params Default parameters override for `DEF_PAR` check code inside
	 */
	public function new(TEXT:String, ?TS:DTextStyle, ?PAR:Dynamic)
	{
		super();

		P = DataT.copyFields(PAR, Reflect.copy(DEF_PAR));
		if (P.width == 0) P.width = FlxG.width - P.x;
		
		var temp = D.text.get('O', TS);
		letterWidth = temp.width + P.pad;
		
		text = TEXT;
		nextLetterIndex = 0; // Total = text.length-1
		maxLetters = Math.ceil(P.width / letterWidth) + 1;
		
		PiStep = (P.w0 * Math.PI) / P.width;
		
		// -- PreCreate some letters, as many as the screen can fit
		for (i in 0...maxLetters)
		{
			var l = D.text.get('', TS);
			l.exists = false;
			l.moves = false;
			l.scrollFactor.set(0, 0);
			add(l);
		}
		
		fireNextLetter();
	}//---------------------------------------------------;
	
	// --
	// Create and fire a letter, the next in the sequence
	function fireNextLetter()
	{
		if (nextLetterIndex == text.length) // No more letters to get
		{
			if (P.loopMode == 1)		// Loop tight
			{
				nextLetterIndex = 0; 	// Start Over
			}
			else
			{
				lastLetter = null;
				return;	// Wait
			}
		}
		
		var l = getFirstAvailable();
			l.ID = nextLetterIndex;
			l.exists = true;
			l.text = text.charAt(l.ID);
			l.x = P.x + P.width;
			l.y = P.y + Math.cos(PiStep * (l.x - P.x)) * P.sHeight;
			// ^ DEV: Because there is a slight gap between placing and updating later
			//        the letter jumps so I am setting the y position here as well
		lastLetter = l;
		nextLetterIndex++;
	}//---------------------------------------------------;
	
	
	// -- Letter went offscreen
	function onLetterExit(l:FlxText)
	{
		l.exists = false;
		
		// It was the last letter to go off
		if (l.ID == text.length - 1)
		{
			if (P.loopMode == 0)
			{
				// NO LOOP: stop everything
				for (i in members) {
					remove(i);
					i.destroy();
					i = null;
				}
				clear();
				
			}else 
			if (P.loopMode == 2) // Loop over
			{
				nextLetterIndex = 0;
				fireNextLetter();	// Start over from the first letter
			}
			
			if (onLoop != null) onLoop();
		}
	}//---------------------------------------------------;
		var cc:Float = 0;
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);

		cc += P.w1;
		if (cc > 6.283) cc = 0;	// 2pi
		
		forEachExists(function(l:FlxText) 
		{
			l.x -= P.speed;
			l.y = P.y + Math.cos((PiStep * (l.x - P.x)) - cc) * P.sHeight;
			// ^ DEV: (l.x - P.x) to get a range from (0->P.width)
			if (l.x < P.x - letterWidth) 
			{
				onLetterExit(l);
			}
		});
		
		if (lastLetter != null && lastLetter.x < (P.x + P.width - letterWidth))
		{
			fireNextLetter();
		}
	}//---------------------------------------------------;
}// --