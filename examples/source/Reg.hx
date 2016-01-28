package;

import flixel.FlxG;
import flixel.util.FlxSave;
import djFlixel.tool.FileParams;
import djFlixel.gapi.ApiEmpty;
import djFlixel.SAVE;
import djFlixel.Controls;
import djFlixel.SND;


/*
 * Default REG class
 * --------------
 * You should copy-paste this file to your new Project and use this as a template.
 * Expand the functions as you like
 */

class Reg
{
	// -- Parameters file --
	// -  It is useful to have various game parameters to an external file
	// -  so that I don't have to compile everytime I want to change a value.
	inline static public var PARAMS_FILE:String = "params.json";
	
	// -  These vars are loaded externally from the JSON parameters file ::
	//    If the parameter is not present on the ext file, then defaults will be used.
	public static var VERSION:String = "0.1";
	public static var NAME:String = "HaxeFlixel app";
	public static var FULLSCREEN:Bool = false;
	public static var VOLUME:Float = 0.6;
	// Currently Antialiasing on/off, comes with a setter that applies to all cameras
	public static var ANTIALIASING(default, set):Bool = true;
	
	// ------- 
	// Store the json parameters loaded from the file
	public static var JSON:Dynamic;
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
	
	//====================================================;
	// FUNCTIONS
	//====================================================;
	//--
	// Do a once per program run, initialization.
	// Auto called right after the FlxGame is ready 
	// and before any state is created.
	public static function initOnce()
	{
		trace("Info: Initializing REG --");		
		// --
		JSON = FileParams.JSON;	// *Pointer for quicker access
		applyParamsInto("reg", Reg); // Works with static objects as well.
		
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
			
		/*
		 * Or auto-load sounds from the params file:
		 */
		for (field in Reflect.fields(JSON.sounds)) {
			trace('- Loading Sound with ID-$field, FILE -' + Reflect.field(JSON.sounds, field));
			SND.as(Reflect.field(JSON.sounds, field), field);
		}
		
	}//---------------------------------------------------;
	
	// --
	// Gets called after every state switch.
	static function onStateSwitch()
	{
		// Force the cameras to use the default AA (with setter)
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
	
	// --
	// Apply all the variables from a json node into an object
	// WARNING: FIELDS MUST HAVE THE SAME NAME!!
	// e.g. json.player.speed ==> player.speed
	public static function applyParamsInto(node:String, Object:Dynamic)
	{
		var jsonNode = Reflect.getProperty(JSON, node);
		
		for (field in Reflect.fields(jsonNode)) {
			Reflect.setField(Object, field, Reflect.field(jsonNode, field));
		}
	}//---------------------------------------------------;
	
	#if debug
	// -- Call this on main update() to reload settings and reset the game
	public static function OnKeyReloadParamsAndGame()
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			trace("Re-loading external parameters file ---");
			FileParams.loadSettings(PARAMS_FILE, function() {
					JSON = FileParams.JSON;
					FlxG.resetGame();
			});
		}
	}//---------------------------------------------------;
	#end
}//--