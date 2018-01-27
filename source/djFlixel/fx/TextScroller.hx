package djFlixel.fx;

import djFlixel.gui.Styles;
import djFlixel.tool.DataTool;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

/**
 * Horizontal Text Scroll, supports wave/sine effect
 * Scrolls into the whole screen width.
 * ...
 * @author John Dimi
 */
class TextScroller extends FlxTypedGroup<FlxText>
{
	// Global parameters	
	var P:Dynamic;
	
	// Letter width PLUS padding
	var letterWidth:Int;
	
	// pointer to the last letter fired
	var lastLetter:FlxText;
	
	// How many letters the screen fits
	var maxLetters:Int;
	
	// Next letter index to fire
	var nextLetterIndex:Int;
	
	// The text string to show
	var text:String;
	
	// Callbacks when a loop has completed
	public var callback:Void->Void;
	
	// --
	/**
	 * 
	 * @param	Text The text to display
	 * @param	Callback Callbacks when a loop has been completed
	 * @param	Params See inner code
	 */
	public function new(Text:String, Callback:Void->Void, ?Params:Dynamic)
	{
		super();

		// - Default parameters
		P = DataTool.copyFieldsC(Params, {
			font:null,
			fontSize:16,
			border_type:1,
			color_border:0xFF554433,
			color:0xFFFFFFFF,
			// --
			pad:4,					// Letter padding
			y:120,					// Screen Y location 
			
			sineSpeedRatio:0.03,	// Sine speed in relation to X POS
			sineWidthRatio:2.3,		// Wave width multiplier, Experiment!
			sineHeight:32,			// In pixels
			
			speed:1.2,			// Scroll speed from right to left
			loopMode:0			// 0=No loop, 1=Loops tightly, 2=Loops When all letters have passed
			
		});
				
		text = Text;
		callback = Callback;
		letterWidth = P.fontSize + P.pad;
		nextLetterIndex = 0; // Total = text.length-1
		
		maxLetters = Math.ceil(FlxG.width / letterWidth) + 1;
		
		// -- PreCreate some letters, as many as the screen can fit
		for (i in 0...maxLetters)
		{
			var l = new FlxText();
			Styles.applyTextStyle(l, P);
			l.exists = false;
			l.moves = false; // Manual movement
			l.scrollFactor.set(0, 0);
			add(l);
		}
		
		requestFireNext();
		
	}//---------------------------------------------------;
	
	// --
	// Create and fire a letter, the next in the sequence
	function requestFireNext()
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
		l.x = FlxG.width;
		l.y = P.y;
		lastLetter = l;
		
		nextLetterIndex++;
	}//---------------------------------------------------;
	
	
	// ---
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
				requestFireNext();	// Start over from the first letter
			}
			
			if (callback != null) callback();
		}
	}//---------------------------------------------------;
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		forEachExists(function(l:FlxText)
		{
			l.x -= P.speed;
			l.y = P.y + Math.cos(
				(l.x * P.sineSpeedRatio) + // Movement speed of wave
				(maxLetters / Math.PI ) * l.ID * P.sineWidthRatio) * P.sineHeight;
			
			if (l.x < -letterWidth) 
			{
				onLetterExit(l);
			}
			
		});
		
		if (lastLetter != null && lastLetter.x < FlxG.width - letterWidth)
		{
			requestFireNext();
		}
	}//---------------------------------------------------;
}// --