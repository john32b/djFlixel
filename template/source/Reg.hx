package;

import flixel.FlxG;
import flixel.util.FlxSave;
import djFlixel.SAVE;
import djFlixel.Controls;
import djFlixel.SND;
import djFlixel.gapi.ApiEmpty;
import haxe.Json;

import openfl.Assets;
import haxe.Json;

#if debug
import djFlixel.net.DataGet; // Loads external files
#end


/*
 * = djFlixel = 
 * Default REG class
 * --------------
 * You should copy-paste this file to your new Project and use this as a template.
 */

class Reg
{
	// -- Usually every game has parameters, this file stores them
	static public var PARAMS_PATH_EMBED:String = "assets/data/params.json";
	// Put the file in the same dir as the .swf
	static public var PARAMS_PATH_ONDIR:String = "params.json";
	
	// --
	public static inline var VERSION:String 	= "0.2.0";
		   static inline var FULLSCREEN:Bool 	= false;	// starting state, do not read
		   static inline var VOLUME:Float 		= 0.6;		// starting state, do not read
		   
	//-- Starting values of some settings
	//   Note: These are going to be loaded and saved to settings.
	public static var ANTIALIASING(default, set):Bool = true;
	
	// -- Init once per program run.
	public static var isInited:Bool = false;

	// -- If this is true, then parameters file is loaded from external file
	//    Useful to modifing things without re-compiling every time
	public static var flag_ext_load:Bool = true;
	
	// -- APIS 
	//#if GAMEJOLT
		// Extend the ApiGameJoltGeneric and set it to api
		// public static var api:ApiGameJolt = new ApiGameJolt();
	//#elseif KONG
		// Extend the ApiKongregateGeneric and set it to api
		// public static var api:ApiKongregate = new ApiKongregate();
	//#elseif NEWGROUNDS
		// public static var api:ApiNewgrounds = new ApiNewgrounds();
	//#else
		// public static var api:ApiEmpty = new ApiEmpty();
	//#end
	
	// Store the json parameters loaded from the file
	public static var JSON:Dynamic;
	
	
	//====================================================;
	// FUNCTIONS
	//====================================================;
	//--
	// Do a once per program run, initialization.
	// Auto called right after the FlxGame is ready 
	// and before any state is created.
	public static function initOnce()
	{
		if (isInited) return;
			isInited = true;
			
		trace("Info: Initializing REG -------------------- ");
		
		// Add some triggers
		FlxG.signals.stateSwitched.add(onStateSwitch);
		
		FlxG.sound.volume = VOLUME;
		FlxG.fullscreen = FULLSCREEN;
		FlxG.mouse.useSystemCursor = true;
		#if debug
			FlxG.autoPause = false;
		#else
			FlxG.autoPause = true;
		#end

		// Init the controls
		Controls.init();
		
		// Enable Saving
		// SAVE.init("Game_Unique_Name");
		
		// Load the sounds.
		SND.init();
		loadSounds();
	}//---------------------------------------------------;
	
	
	// -- USER CODE --
	// This function can be called dynamically and statically
	// Handle every json parameter set here.
	static function processJSONParams(json:Dynamic, onComplete:Void->Void)
	{
		trace("Warning: JSON processed OK");
		JSON = json;
		onComplete();
		/* 
			Delete the code above and call onComplete when done.
		    Write code to accept and handle JSON parameters
		*/
	}//---------------------------------------------------;
	
	// -- USER CODE --
	static function loadSounds()
	{
		/* LOAD SOUNDS HERE
		 * ----------------

		 All sounds must be placed in the assets/sounds directory
		 You can load a sound by calling it's filename without the extension, like this:
		 SND.as("cursor");
		*/
	}//---------------------------------------------------;
	
	//====================================================;
	// INTERNAL FUNCTIONS
	//====================================================;

	// --
	// This is called before the FlxGame is created.
	// Mainly for loading the external parameters json file
	public static function preloadApp(onLoadComplete:Void->Void)
	{
		// Quick function called when can't read parameters file
		var _paramsLoadError = function(){
			trace('Error: JSON, Could not read $PARAMS_PATH_ONDIR, skipping.');
			JSON = null;
			onLoadComplete();
		};
		
		// The JSON data loaded, if any.
		var obj:Dynamic = null;
		
		// If loaded statically, just apply the JSON parameters and return
		if (!flag_ext_load) 
		{	
			// -- test JSON --
			try {		
				obj = Json.parse(Assets.getText(PARAMS_PATH_EMBED));
			}catch (e:Dynamic) {
				_paramsLoadError();
				return;
			}
			processJSONParams(obj, onLoadComplete);
			return;
		} // --
		
		#if debug
		else
		{
			var get:DataGet = new DataGet(PARAMS_PATH_ONDIR, 
				function(loadedData:Dynamic) { // On load
					processJSONParams(loadedData, onLoadComplete);
				},function(err:Int) { // On error
					_paramsLoadError();
				}
			);
		}
		#end
		
	}//---------------------------------------------------;
	
	//====================================================;
	// Automatic Calls
	//====================================================;
	
	// --
	// Gets called after every state switch.
	static function onStateSwitch()
	{
		// Force the cameras to use the default Antialiasing.
		Reg.ANTIALIASING = Reg.ANTIALIASING;
	}//---------------------------------------------------;
	
	
	// --
	// Quick way to alter the Antialiasing of all cameras
	static function set_ANTIALIASING(value:Bool):Bool
	{
		ANTIALIASING = value;
		
		for (i in FlxG.cameras.list)
		{
			i.antialiasing = ANTIALIASING;
		}
	
		return value;
	}//---------------------------------------------------;
	
}//--