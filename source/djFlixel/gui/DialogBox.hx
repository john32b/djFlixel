package djFlixel.gui;

import djFlixel.FlxAutoText;
import djFlixel.gfx.Palette_DB32;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;
import haxe.Timer;

/** ==========================
 *   DialogBox.hx, Version 0.1
 *  ==========================
 * A simple dialog box, using FlxAutoText for
 * autotyping dialog lines.
 * -----------------
 * Notes:
 * 
 * TODO:
 * + Blinking Indicator at the end of the autotext or page?
 * 		+ wait a bit before displaying and accepting resume input
 * + Force showpage, stop animation and forcefuly show the page
 * + StatusUpdates with events or callbacks
 *--------------------------------*/

class DialogBox extends FlxSpriteGroup
{
	// Default time to wait between a new pages
	static inline var PAUSE_NEXT_PAGE:Float = 6;
	static inline var PAUSE_EMPTY_LINE:Float = 0.2;
	static inline var PAUSE_W:Float = 0.7;
	
	// Width is autocalculated based on the Flxg.width
	public var WIDTH(default, null):Int;
	// Height is autocalculated based on the number of lines
	public var HEIGHT(default, null):Int;
	
	// * Autocalculated, How many character fit on the X, Based on fontsize
	public var CHARACTERS_WIDTH(default, null):Int;
	
	// User callback when the entire dialog is complete
	public var onComplete:Void->Void;
	
	// Close the dialog box when the dialog ends?
	public var flag_autoClose:Bool;
	
	//  CURSOR
	// ========
	
	// Cursor Carier sprite.
	var cursor:FlxText;
	// Timer counter for the cursor
	var cursor_timer:Float;
	// The cursor will loop through these strings
	var cursor_states:Array<String> = ['', '.', '..', '...', ' ..', '  .'];
	// Current cursor state
	var cursor_state:Int;
	// Update the cursor every this many seconds
	var cursor_freq:Float = 0.12;
	
	//---------------------------------------------------;
	
	// Padding of the text from the edges of the box;
	var paddingText:Int;

	// Alignment on the screen [ "top", "bottom" ]
	var alignY:String;
	
	// How many lines does the DialogBox fit
	var numberOfLines:Int;

	// Hold the autotext objects here, Every line is an AutoText instance
	var lines:Array<FlxAutoText>;
	
	// The dialog lines that are going to be displayed
	var queue:Array<String>;
	
	// The next line (from numberOflines) that is going to be feeded next
	var lineToFeed:Int;
	
	// The flow is paused and it awaits user key to advance
	var isPaused:Bool;
	
	// Is it currently in the process of displaying text?
	public var isAnimating(default,null):Bool; // unused?
	
	// Is it currently onscreen?
	public var isOpen(default,null):Bool;
	
	// Wait between lines or pages
	var pauseTimer:FlxTimer;
	
	//---------------------------------------------------;
	public function new(_numberOfLines:Int = 3, _fontSize:Int = 8, ?_font:String)
	{
		super();
		paddingText = 4;
		alignY = "bottom";
		
		numberOfLines = _numberOfLines;
		if (numberOfLines < 1) numberOfLines = 1;	// Safeguard
		
		pauseTimer = new FlxTimer();
		queue = [];
		lineToFeed = 0;
		isPaused = false;
		isAnimating = false;
		isOpen = true;
		
		// --
		WIDTH = FlxG.width;
		HEIGHT = (_fontSize * numberOfLines) + (numberOfLines + 1) * (paddingText);
		CHARACTERS_WIDTH = Math.ceil((WIDTH - (paddingText * 2)) / _fontSize);
		
		trace("Characters Width === " + CHARACTERS_WIDTH);
		
		// -- Create a basic background
		var bgBox = new FlxSprite(0, 0);
			bgBox.makeGraphic(WIDTH, HEIGHT, Palette_DB32.COL_02);
			bgBox.alpha = 0.9;
			add(bgBox);
		
		// -- Create the AutoTypers
		lines = [];
		for (i in 0...numberOfLines) {
			lines[i] = new FlxAutoText(	paddingText, 
										(paddingText/2) + i * (_fontSize+paddingText),
										WIDTH - (paddingText * 2), _fontSize);
			if (_font != null) {
				lines[i].font = _font;
			}
			lines[i].color = Palette_DB32.COL_22;
			lines[i].visible = false;
			add(lines[i]);
		}
		
		// -- Create the carrier
		cursor = new FlxText(WIDTH - paddingText - _fontSize * 1.2, HEIGHT - paddingText - _fontSize * 1.2, 0, "...", _fontSize);
		cursor_state = 0;
		cursor_timer = Std.int(cursor_freq); // Guarantee change on the first call
		cursor.visible = false;
		updateCursor();
		cursor.alignment = "right";
		add(cursor);
	}//---------------------------------------------------;

	override public function destroy():Void 
	{
		super.destroy();
		pauseTimer = FlxDestroyUtil.destroy(pauseTimer);
		lines = FlxDestroyUtil.destroyArray(lines);
	}//---------------------------------------------------;
	
	/**
	 * Resets and sets new dialog.
	 * Warning: Line width must not overflow the target character width!
	 * @param	dialogArray An array containing the dialog lines.
	 * @param   autoStart , if false will not autostart the new dialog, use start();
	 */
	public function setDialog(dialogArray:Array<String>, autoStart:Bool = true )
	{
		// Note to self:
		// Don't pre-process the data to fit long lines etc. User should do that.
		
		queue = dialogArray.copy();
		
		lineToFeed = 0;
		
		// Reset timer and unpause Just In Case
		pauseTimer.cancel();
		isPaused = false;
		
		if (autoStart) feedNext();
		
	}//---------------------------------------------------;
	
	
	// --
	public function clearLines()
	{
		lineToFeed = 0;
		for (i in 0...numberOfLines) {
			lines[i].visible = false;
			lines[i].text = "";
		}
	}//---------------------------------------------------;
	
	// - 
	// Request to feed the next lines of the queue.
	// If the queue has reached the end, stop it and callback to user.
	public function feedNext()
	{
		if (queue.length == 0)
		{
			//trace("+ Feed Completed, callback to user");
			if (onComplete != null) onComplete();
			return;
		}
		
		// This is the first time the page is to be occupied.
		if (lineToFeed == 0)
		{
			clearLines();
		}
	
		// Get the top line of the dialog.
		var newLine = queue.shift();
		//trace("+ Feeding new line = " + newLine);
		

		// -- Check some basic markup
		switch(newLine)
		{
			case "":
				// If the new line is blank, wait for a bit and then feed the next line
				pauseTimer.start(PAUSE_EMPTY_LINE, function(_) { onLineComplete(); } );
				// I can skip setting the textobject with data, because it's always empty.
				
				
			case "!np": 
				// Pause and New Page!
				feedWait();
				// By setting this to 0, the next time the feeder is called
				//  it's going to clear all the lines and start from the top.
				lineToFeed = 0;
				
			case "w":
				pauseTimer.start(PAUSE_W, function(_) { feedNext(); } );
				
			default: // Normal text line
				// -- Check for overflow only in debug
				#if debug
					if (newLine.length > CHARACTERS_WIDTH) {
						trace("Warning: Line might overflow " + newLine);
						// newLine = newLine.substr(0, CHARACTERS_WIDTH - 2) + "..";
					}
				#end
				
				lines[lineToFeed].visible = true;
				lines[lineToFeed].start(newLine, onLineComplete);
		}
		
	}//---------------------------------------------------;
	
	// -
	// Autocalled when an autotext finishes.
	// Calls the next line
	function onLineComplete()
	{		
		lineToFeed++;
		
		// If the dialog box is full, then wait for a keypress,
		// also show the cursor carrier.
		if (lineToFeed > numberOfLines - 1) {
			lineToFeed = 0;	
			feedWait();
		}
		else
		{
			feedNext();
		}
		
	}//---------------------------------------------------;
	
	// -- 
	// Stop the flow and wait for a bit
	function feedWait()
	{
		// Todo: Wait for a bit, then start accepting input, because the
		//       player might be mashing the A button?
		// trace("+ Feed Wait");
		
		isPaused = true;
		cursor.visible = true;
		//pauseTimer.start(PAUSE_NEXT_PAGE, function(_) {
		//	feedResume();
		//});
	}//---------------------------------------------------;
	
	
	// -
	// Resumes the feed.
	// This function is called from a) user input b) Timer
	function feedResume()
	{
		if (!isPaused) {
			// trace("Warning: The flow is not paused");
			return;
		}
		
		pauseTimer.cancel();
		isPaused = false;
		cursor.visible = false;
		cursor_state = 0;
		feedNext();
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float) 
	{
		super.update(elapsed);

		if (isPaused)
		{
			updateCursor(); // Cursor should only be there if the flow is paused
			
			if (Controls.CURSOR_OK())
			{
				feedResume();
			}
		}
	}//---------------------------------------------------;
	
	
	// --
	function updateCursor()
	{
		cursor_timer += FlxG.elapsed;
		
		if (cursor_timer >= cursor_freq)
		{
			cursor_timer = 0;
			cursor_state++;
			if (cursor_state >= cursor_states.length) cursor_state = 0;
			cursor.text = cursor_states[cursor_state];
		}
	}//---------------------------------------------------;
	
	
}// -- end --//	