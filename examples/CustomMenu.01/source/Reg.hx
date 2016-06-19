/*
 * Default REG class
 * =======================
 * Version: 05-2016
 * ---------------- *
 * 
 * You should copy-paste this file to your new Project and use this as a template.
 * Expand the functions as you like
 * 
 */

package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxSave;
import djFlixel.tool.DynAssets;
import djFlixel.gapi.ApiEmpty;
import djFlixel.SAVE;
import djFlixel.Controls;
import djFlixel.SND;
import openfl.events.KeyboardEvent;

class Reg
{
	
	// -- Parameters file --
	// -  It is useful to have various game parameters to an external file
	// -  so that I don't have to compile everytime I want to change a value.
	inline static public var PARAMS_FILE:String = "data/params.json";

	// -  These vars are loaded externally from the JSON parameters file ::
	//    If the parameter is not present on the ext file, then defaults will be used.
	public static var VERSION:String = "0.1";
	public static var NAME:String = "HaxeFlixel app";
	public static var VOLUME:Float = 0.6;
	public static var MUSIC:Bool = false;

	// Changing this will also take effect
	public static var FULLSCREEN(default, set):Bool = false;
	// Currently Antialiasing on/off, comes with a setter that applies to all cameras
	public static var ANTIALIASING(default, set):Bool = true;
	
	// Store the json parameters loaded from the file
	public static var JSON:Dynamic;
	
	// -- APIS  ------ 
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
		trace(" - Initializing REG :");

		// When an SWF is being played from a browser,
		// The fullscreen switch must be done in the same call as the keyboard input
		#if (flash)
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(event:KeyboardEvent) {
			if (event.keyCode == 113) { // F11 key
				Reg.FULLSCREEN = !Reg.FULLSCREEN;
			}
		});
		#end
		
		// JSON data was loaded earlier over at Main.HX class
		// Works with static objects as well.
		applyParamsInto("reg", Reg);
		
		// Add a state switch trigger, useful to re-set antialiasing automatically
		FlxG.signals.stateSwitched.add(onStateSwitch);
		FlxG.signals.preGameReset.add(onPreGameReset);
		FlxG.signals.postGameReset.add(onPostGameReset);
		FlxG.mouse.useSystemCursor = true;
		FlxG.sound.volume = VOLUME;
		FlxG.fullscreen = FULLSCREEN;
		FlxG.autoPause = false;
		
		
		// Init and load Sounds
		trace(" - Initializing Sound");
		SND.init();
		SND.MUSIC_ENABLED = MUSIC;
		loadSounds();
		
		trace(" - Initializing Controls");
		// Init the controls
		Controls.init();
		
		// Enable Saving
		// SAVE.init("Game_Unique_Name");
		
	}//---------------------------------------------------;
	
	
	// --
	// Sounds on the json file are autoloaded
	// # User can expand this with custom sounds
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
		 * example node in params.json: 	
			"sounds" : {
				"c_tick" : "cursor_tick",
			}
			// cursor_tick is in assets/sounds/cursor_tick.mp3, c_tick is the ID
			
			"soundGroups" : { "explosion" : ["expl1","expl2"] }
			// expl1, expl2 are sound IDs, defined in the "sounds" node
		 */
		
		if (JSON.soundGroups != null)
		for (field in Reflect.fields(JSON.soundGroups)) {
			var sounds:Array<String>;
			sounds = Reflect.getProperty(JSON.soundGroups, field);
			for (s in sounds) {
				SND.addGroup(s, field);	
			}
		}
		 
		var customVolume:Float;
		
		if (JSON.soundFiles != null)
		for (field in Reflect.fields(JSON.soundFiles)) {
			
			// Look for custom volumes
			if (JSON.soundVolumes != null && Reflect.hasField(JSON.soundVolumes, field)) {
				customVolume = cast Reflect.field(JSON.soundVolumes, field);
			}else {
				customVolume = 1;
			}
			
			
			SND.as(Reflect.field(JSON.soundFiles, field), field, customVolume);
		}
		
	}//---------------------------------------------------;
	
	//====================================================;
	// SYSTEM FUNCTIONS
	//====================================================;
	
	// --
	// Gets called after every state switch.
	static function onStateSwitch()
	{
		// Force the cameras to use the default AA (with setter)
		Reg.ANTIALIASING = Reg.ANTIALIASING;
	}//---------------------------------------------------;
	
	// --
	static function onPreGameReset()
	{
		trace("- on Pre Game Reset");
		SND.destroy();
	}//---------------------------------------------------;
	
	// --
	static function onPostGameReset()
	{
		// Reload the sounds!
		trace("- on Post Game Reset");
		SND.init();
		loadSounds();
	}//---------------------------------------------------;
	
	
	// --
	// Quick way to alter the Antialiasing of all cameras
	static function set_ANTIALIASING(value:Bool):Bool
	{
		ANTIALIASING = value;
		for (i in FlxG.cameras.list) {
			i.antialiasing = ANTIALIASING;
		}
		return value;
	}//---------------------------------------------------;
	
	// --
	// Quick way to alter the Antialiasing of all cameras
	static function set_FULLSCREEN(value:Bool):Bool
	{
		FULLSCREEN = value;
		FlxG.fullscreen = FULLSCREEN;
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
			try{
			Reflect.setField(Object, field, Reflect.field(jsonNode, field));
			}catch (e:Dynamic) {
				trace('Could not set field $field');
			}
		}
	}//---------------------------------------------------;
	
	// Apply a dynamic's object fields into another field
	public static function applyFieldsInto(node:Dynamic, into:Dynamic)
	{
		for (field in Reflect.fields(node)) {
			Reflect.setField(into, field, Reflect.field(node, field));
		}
	}//---------------------------------------------------;

	//-- Quickly set the default parameters of an object
	public static function defParams(obj:Dynamic, target:Dynamic):Dynamic
	{
		if (obj == null) {
			obj = { };
		}

		// THIS IS VERY IMPORTANT ::
		obj = Reflect.copy(obj);
		
		for (field in Reflect.fields(target)) {
			if (!Reflect.hasField(obj, field)) {
				Reflect.setField(obj, field, Reflect.field(target, field));
			}
		}
		
		return obj;
	}//---------------------------------------------------;
	
	
	//====================================================;
	// DEBUGGING
	//====================================================;

	#if debug
	public static function debug_keys()
	{	
		if (FlxG.keys.justPressed.F12)
		{
			trace(" = Reloading external parameters file :: ");
			DynAssets.loadFiles(function() {
					JSON = DynAssets.json.get(PARAMS_FILE);
					FlxG.resetState();
			});
		}else
		if (FlxG.keys.justPressed.F9)
		{
			ANTIALIASING = !ANTIALIASING;
		}
	}//---------------------------------------------------;
	
	// -
	// Useful tool for debugging
	public static function translateDir(dir:Int):String
	{
		return switch(dir) {
			case FlxObject.LEFT:"left";	
			case FlxObject.RIGHT:"right";	
			case FlxObject.UP:"up";	
			case FlxObject.DOWN:"down";	
			default:"";
		}
	}//---------------------------------------------------;
	#end
	
}//--