package;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import haxe.Json;
import openfl.Assets;

#if EXTERNAL_LOAD
	import djFlixel.tool.MacroHelp;
	import djFlixel.net.DataGet;
#end


/**
 * IMPORTANT NOTE:
 * ---------------
 * Remember to remove the EXTERNAL_LOAD flag on release
 * ----------------------------------------------------*/

class Main extends Sprite 
{
	var gameWidth:Int = 320;
	var gameHeight:Int = 240;
	var initialState:Class<FlxState> = State_Main;
	var zoom:Float = 2;
	// 50 is ok and fast. If it feels choppy, set to 60
	var framerate:Int = 50;
	var skipSplash:Bool = true; 
	var startFullscreen:Bool = false; 
	
	//====================================================;
	
	public static function main():Void
	{	
		Lib.current.addChild(new Main());
	}//---------------------------------------------------;
	
	public function new() 
	{
		super();
		
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
		
		// Load external files and continue with game
		loadExternal(setupGame);
	}//---------------------------------------------------;
	
	// -- NEW --
	// 
	function loadExternal(onLoadComplete:Void->Void)
	{
		
		var PARAMS_FILE_PATH = "assets/data/" + Reg.PARAMS_FILE;
		
		// Quick function called when can't read parameters file
		var _paramsLoadError = function() {
			trace('Error: JSON, Could not read ${PARAMS_FILE_PATH}, skipping.');
			Reg.JSON = null;
			onLoadComplete();
		};
		
		
		#if EXTERNAL_LOAD
			// Load the parameters at runtime
			var get:DataGet = new DataGet(MacroHelp.getProjectPath() + PARAMS_FILE_PATH, 
				function(loadedData:Dynamic) { // On load
					Reg.JSON = loadedData;
					onLoadComplete();
				},function(err:Int) { // On error
					_paramsLoadError();
				}
			);
		#else
			// Load the embedded parameters file
			try {
				Reg.JSON = Json.parse(Assets.getText(PARAMS_FILE_PATH));
				onLoadComplete();
			}catch (e:Dynamic) {
				_paramsLoadError();
			}
		#end	
	}//---------------------------------------------------;
	
	function setupGame():Void
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

		// - Do this only once in the game lifetime
		FlxG.signals.stateSwitched.addOnce(function() {
				Reg.initOnce();
		});
			
		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));
	}//---------------------------------------------------;
}