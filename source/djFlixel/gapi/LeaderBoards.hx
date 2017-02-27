package djFlixel.gapi;

import flixel.group.FlxGroup;
import djFlixel.gapi.ApiOffline.ScoreApi;
import djFlixel.gui.Align;
import djFlixel.gui.Gui;
import djFlixel.tool.DataTool;

import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;
import flixel.FlxG;

/**
 * LEADERBOARDS 
 * ---------------
 * A templated sprite group with build in functionality to retrieve scores
 * from the connected API and then display them
 * 
 * NOTES :
 * 
 * + Requires the following TextStyles to be set:
 * 	 '!' - for slot number
 * 	 '%' - for score
 * 	 username is default color text
 * 
 * + Requires Reg.api to be set, it can be the empty one.
 * 
 * + Will work on whatever Service as long as you populate Reg.api.scores
 * 
 * -------------------------------
 * 	
 */

class LeaderBoards extends FlxGroup
{
	/*
	 * Paranoid code, UNUSED
	 * only once per X seconds, otherwise show old results? */
	static inline var MIN_TIME_BETWEEN_LOADS:Float = 5; 
	
	var SLOTS_TOTAL:Int = 10;
	var SLOT_DISPLAY_TIME:Float = 0.18;
	var SLOT_BETWEEN:Int = 11;
	// --
	var loadingText:FlxText;
	var slots:Array<FlxText>;
	var headerText:FlxText;
	//--
	public var flag_new_scores_ready:Bool = false;
	var flag_has_timed_out:Bool = false;
	// --
	var timeoutFail:FlxTimer;	
	var callback:Void->Void;
	var blinkScore:Float; // Is same user name and same score then blink this score
	// --
	var y:Float; // Starting y to start drawing
	var flag_show_title:Bool = false;
	//---------------------------------------------------;
	
	/**
	 * Create the group, will align automatically on the X axis of the screen
	 * @param	startY Y position on the screen
	 * @param	showTitle Bool e.g. Displays "Gamejolt leaderboards" at the top
	 */
	public function new(startY:Float = 0, showTitle:Bool = true )
	{
		super();
		y = startY;
		flag_show_title = showTitle;
		// Header
		if (flag_show_title)
		{
			headerText = Gui.getFText('|${Reg.api.SERVICE_NAME} Leaderboards|', 16);
			Align.screen(headerText, "center", "none");
			headerText.y = startY;
		}
		// Add a loading indicator
		loadingText = Gui.getFText('loading..');
		Align.screen(loadingText, "center", "none");
		loadingText.y  = y + 64;
	}//---------------------------------------------------;
	
	
	/**
	 * Fetches and displays at once
	 * @param	timeout Timeout to fail, callbacks
	 * @param	callback callback when finished or failed
	 * @param	blinkScore_ A preliminary way to blink a row, useful to indicate the score that was just set
	 */
	public function fetch(timeout:Float = 5, ?callback_:Void->Void, blinkScore_:Float = -1)
	{
		trace(" - Going to blink for score", blinkScore);
		flag_new_scores_ready = false;
		flag_has_timed_out = false;
		callback = callback_;
		blinkScore = blinkScore_;
		
		// -- Now it's a good time to clear the previous results
		// -- If slots are already set, delete them
		if (slots != null)
		for (i in slots) { remove(i); i.destroy(); } 
		slots = [];
		
		if(flag_show_title) add(headerText);
		
		loadingText.text = "loading..";
		add(loadingText);
		
		timeoutFail = new FlxTimer().start(timeout, function(_) {
			scoresFail();
		});
		
		trace(" - Fetching new scores ");
		Reg.api.fetchScores(function() {
			if (Reg.api.scores == null)
				scoresFail();
			else
				scoresReady();
		});
		
		#if debug // If will get the fake scores later
			if (!Reg.api.isConnected) scoresReady();
		#end
	}//---------------------------------------------------;
	
	
	/** 
	 * For whatever reason scores timed out
	 **/
	private function scoresFail()
	{
		trace(" - SCORES FAIL - ");
		flag_has_timed_out = true; // If for whatever reason the scores fire LATER,
		loadingText.text = "Failed to get scores.";
		if (callback != null) callback();
	}//---------------------------------------------------;
	
	/**
	 * Scores are ready and fresh, in Reg.api.scores
	 */
	private function scoresReady() 
	{
		if (flag_has_timed_out) return; // It is possible when it timeouts and the API fires the scores later
		
		trace(" - Scores fetched - ");
		flag_new_scores_ready = true;
				
		timeoutFail.cancel(); timeoutFail.destroy();
		trace(" - Scores Success - ");
		// --
		remove(loadingText);
		
		// -- Begin showing scores!
		
		var tim:FlxTimer = new FlxTimer();
		var blinkThis:Bool = false;
		var scores:Array<Dynamic> = Reg.api.scores; // Guaranteed fresh
		var offsetY:Int = cast (flag_show_title?(headerText.height + 6):6);
		#if debug
			if(!Reg.api.isConnected) scores = Reg.api.scoresFAKE;
		#end
		
		tim.start(SLOT_DISPLAY_TIME, function(e:FlxTimer) {
			var slotNum = e.elapsedLoops - 1;
			var score:ScoreApi = scores[slotNum]; // The score object I to work with
			var str = '!${slotNum+1}! - '; //Building string to display
			if (score != null) {	
				str += DataTool.padTrimString(score.user, 20, "_", false);
				str += ' - %${score.score_num}%';
				if (blinkScore >-1 && score.score_num == blinkScore && score.user == Reg.api.getUser())
				{
					blinkThis = true; // blink the next text
					blinkScore = -1; // don't check the next ones
				}
			}else {
				str += DataTool.padTrimString("", 20, "_", false);
				str += ' - %0%';
			}
			
			var text = Gui.getFText(str, 8);
				text.alignment = "left";
				
			slots.push(text);
			
			if (blinkThis) {
				FlxFlicker.flicker(text, 6, 0.2);
				blinkThis = false;
			}
				
			Align.screen(text, "center", "none");
			text.y = y + offsetY;
			Gui.addAndTween(text, 0, -5, true);
			add(text);
			offsetY += SLOT_BETWEEN; // 
			
			if (e.loopsLeft == 0) {
				if (callback != null) callback();
			}
			
		},SLOTS_TOTAL);
		
		
	}//---------------------------------------------------;
	
	override public function destroy():Void 
	{
		loadingText.destroy();
		headerText.destroy();
		super.destroy();
	}//---------------------------------------------------;
	

}//--

