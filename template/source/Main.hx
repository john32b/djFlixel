package;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;


/**
 * IMPORTANT NOTE:
 * ---------------
 * If you ever want to upload a debug version to the web, DISABLE the flag_ext_load
 * 
 * ----------------------------------------------------*/

class Main extends Sprite 
{
	var gameWidth:Int = 320; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 240; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = State_Main; // The FlxState the game starts with.
	var zoom:Float = 2; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 50; // How many frames per second the game should run at.
	var skipSplash:Bool = false; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	
	// You can pretty much ignore everything from here on - your code should go in your states.
	
	public static function main():Void
	{	
		Lib.current.addChild(new Main());
	}//---------------------------------------------------;
	
	public function new() 
	{
		super();
		
		if (stage != null) 
		{
			init();
		}
		else 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}//---------------------------------------------------;
	
	private function init(?E:Event):Void 
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// -- Game Starts here
		#if debug
			trace("Warning: Flag set to load assets dynamically");
			Reg.flag_ext_load = true;
		#else // release
			trace("Warning: Flag set to load assets statically");
			Reg.flag_ext_load = false;
		#end

		// - new
		Reg.preloadApp(setupGame);
		
	}//---------------------------------------------------;
	
	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		// - new
		FlxG.signals.stateSwitched.addOnce(function() {
				Reg.initOnce();
		});
			
		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));
	}//---------------------------------------------------;
}