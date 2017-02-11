package djFlixel;

import openfl.display.Sprite;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flash.events.Event;
import flash.Lib;
import haxe.Json;
import djFlixel.tool.DynAssets;


class MainTemplate extends Sprite
{
	var render_width:Int = 320;
	var render_height:Int = 240;
	var framerate:Int = 40; // 40 is ok and fast. If it feels choppy, set to more (60)
	var zoom:Float = 2;
	var skipSplash:Bool = true;
	var startFullscreen:Bool = true;
	var initialState:Class<FlxState>;
	
	/**
	 * 
	 * @param	startState
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
	
		//Load external files and continue with game
		DynAssets.loadFiles(setupGame);
	}//---------------------------------------------------;
	
	// --
	function setupGame():Void
	{
		//-- Try to get the initial state to boot
		Reg.JSON = DynAssets.json.get(Reg.PARAMS_FILE);

		try {
			if (Reg.JSON.reg.START_STATE != null) {
				trace("Forced Initial State :: ", Reg.JSON.reg.START_STATE);
				initialState = cast Type.resolveClass(Reg.JSON.reg.START_STATE);
				
			}
		}catch (e:Dynamic) {
			trace(e);
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
			Reg.initOnce();
		});
					
		addChild(new FlxGame(render_width, render_height, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));
		
	}//---------------------------------------------------;
}// --