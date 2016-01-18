package;

import flixel.FlxG;
import flixel.util.FlxSave;
import djFlixel.gapi.ApiEmpty;
import djFlixel.SAVE;
import djFlixel.Controls;
import djFlixel.SND;
import openfl.Assets;

/*
 * Default REG class
 * --------------
 * You should copy-paste this file to your new Project and use this as a template.
 * Expand the functions as you like
 */

class Reg
{
	// -- GAME PARAMS
	public static inline var VERSION:String 	= "0.2.0";
		   static inline var FULLSCREEN:Bool 	= false;	// starting state, do not read
		   static inline var VOLUME:Float 		= 0.6;		// starting state, do not read
		   
	// -- FILES
	inline static public var PARAMS_FILE:String = "params.json";
	
	// You can use this to change the smoothing in real time
	public static var ANTIALIASING(default, set):Bool = true;
	
	// -- APIS 
	#if GAMEJOLT
		// Extend the ApiGameJoltGeneric and set it to api
		// public static var api:ApiGameJolt = new ApiGameJolt();
	#elseif KONG
		// Extend the ApiKongregateGeneric and set it to api
		// public static var api:ApiKongregate = new ApiKongregate();
	#elseif NEWGROUNDS
		// public static var api:ApiNewgrounds = new ApiNewgrounds();
	#else
		public static var api:ApiEmpty = new ApiEmpty();
	#end
	
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
		trace("Info: Initializing REG : ");
		
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

		// Load the sounds.
		SND.init();
		loadSounds();
		
		// Init the controls
		Controls.init();
		
		// Enable Saving
		// SAVE.init("Game_Unique_Name");
		
	}//---------------------------------------------------;
	
	// --
	// # USER CODE
	static function loadSounds()
	{
		/* LOAD SOUNDS HERE
		 * ----------------
		 All sounds must be placed in the assets/sounds directory
		 You can load a sound by calling it's filename without the extension, like this:
			SND.as("cursor");
		 
		 You can then playback a sound by calling
			Snd.play("cursor");
		*/
	}//---------------------------------------------------;
	
	// --
	// Gets called after every state switch.
	static function onStateSwitch()
	{
		// Force the cameras to use the default Antialiasing.
		Reg.ANTIALIASING = Reg.ANTIALIASING;
		
		// # USER CODE
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