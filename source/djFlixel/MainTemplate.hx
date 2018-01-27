package djFlixel;

import djFlixel.tool.DynAssets;
import djFlixel.FLS;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.display.Sprite;

/**
 * Generalized MAIN sprite to be added on the stage
 * Works with DynAssets.hx and preloads any files automatically
 */
class MainTemplate extends Sprite
{
	// Some defaults
	var RENDER_WIDTH:Int = 320;
	var RENDER_HEIGHT:Int = 240;
	var FPS:Int = 40; 				// 40 is ok and fast. If it feels choppy, set to more (60)
	var ZOOM:Float = 2;				// A zoom level of 2 is ok for now
	var SKIP_SPLASH:Bool = true;
	var INITIAL_STATE:Class<FlxState>;
	
	/**
	 */
	public function new()
	{
		super();
		// Dynamic Assets init
		FLS.assets = new DynAssets();
		// Initialize User
		init();
		// The default main parameters file
		FLS.assets.add(FLS.PARAMS_ASSET);
		// This is Async, will call setupGame when all files are loaded
		FLS.assets.loadFiles(setupGame);
	}//---------------------------------------------------;

	
	/**
	 * OVERRIDE THIS to set running parameters
	 */
	function init()
	{
		// example to use on the overriden class:
		//
		// FLS.extendedClass = Reg;	
		//
		// RENDER_WIDTH = 640;
		// RENDER_HEIGHT = 480;
		// FPS = 60;
		// ZOOM = 1;
		//
		// SKIP_SPLASH = false;
		// INITIAL_STATE = State_Menu;
		//
		// Push user files to the Dynamic File List:
		// FLS.assets.FILE_LIST.push("map.tmx"); <-- This file will reload on F12
	}//---------------------------------------------------;
	
	
	// --
	function setupGame():Void
	{
		//-- Try to get the initial state to boot
		FLS.JSON = FLS.assets.json.get(FLS.PARAMS_ASSET);

		#if debug
		if (FLS.JSON == null || FLS.JSON.sys == null) {
			throw "Error: JSON params file ERROR or missing 'sys' node";
		}
		if (INITIAL_STATE == null)
		{
			throw "Error: You forgot to set the INITIAL_STATE";
		}
		#end
		
		// - Read FPS
		if (FLS.JSON.sys.FPS != null) {
			FPS = Std.parseInt(FLS.JSON.sys.FPS);
		}
		
		// - Do this only once in the game lifetime
		FlxG.signals.stateSwitched.addOnce(function() {
			if (FLS.extendedClass == null) FLS.extendedClass = FLS;
			Type.createInstance(FLS.extendedClass, []);
		});
		
		
		addChild(new FlxGame(RENDER_WIDTH, RENDER_HEIGHT, INITIAL_STATE, ZOOM, FPS, FPS, SKIP_SPLASH));
		
	}//---------------------------------------------------;
}// --