package djFlixel;

import openfl.display.Sprite;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flash.events.Event;
import flash.Lib;
import haxe.Json;
import djFlixel.tool.DynAssets;

/**
 * Generalized MAIN sprite to be added on the stage
 * Works with DynAssets.hx and preloads any files automatically
 */
class MainTemplate extends Sprite
{
	// Some defaults
	var render_width:Int = 320;
	var render_height:Int = 240;
	var framerate:Int = 40; // 40 is ok and fast. If it feels choppy, set to more (60)
	var zoom:Float = 2;		// A zoom level of 2 is ok for now
	var skipSplash:Bool = true;
	var startFullscreen:Bool = true; // Unused, User can manually go to fullscreen
	var initialState:Class<FlxState>;
	
	/**
	 * Constuctor
	 * @param	startState
	 * @param	w_ Width Default 320
	 * @param	h_ Height Default 240
	 * @param	f_ Framerate Default 40
	 * 
	 */
	public function new(startState:Class<FlxState>, w_:Int = 0, h_:Int = 0, f_:Int = 0)
	{
		super();
		
		if (w_ > 0) render_width = w_;
		if (h_ > 0) render_height= h_;
		if (f_ > 0) framerate = f_;
		// zoom ??
		
		initialState = startState;
		
		if (stage != null) {
			init();
		} else {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}//---------------------------------------------------;
	
	private function init(?E:Event):Void 
	{
		if (hasEventListener(Event.ADDED_TO_STAGE)) {
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
	
		DynAssets.FILE_LOAD_LIST.push(FLS.PARAMS_FILE);
		//Load external files and continue with game
		DynAssets.loadFiles(setupGame);
	}//---------------------------------------------------;
	
	// --
	function setupGame():Void
	{
		//-- Try to get the initial state to boot
		FLS.JSON = DynAssets.json.get(FLS.PARAMS_FILE);

		#if debug
		if (FLS.JSON.sys == null) {
			trace("Error: JSON params file missing 'sys' node");
			return;
		}
		#end
		
		try {
			if (FLS.JSON.sys.START_STATE != null) {
				initialState = cast Type.resolveClass(FLS.JSON.sys.START_STATE);
				trace("Forced Initial State :: ", initialState);
			}
		}
		
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / render_width;
			var ratioY:Float = stageHeight / render_height;
			zoom = Math.min(ratioX, ratioY);
			render_width = Math.ceil(stageWidth / zoom);
			render_height = Math.ceil(stageHeight / zoom);
		}

		// - Do this only once in the game lifetime
		FlxG.signals.stateSwitched.addOnce(function() {
			if (FLS.extendedClass == null) FLS.extendedClass = FLS;
			Type.createInstance(FLS.extendedClass, []);
		});
					
		addChild(new FlxGame(render_width, render_height, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));
		
	}//---------------------------------------------------;
}// --