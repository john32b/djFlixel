/*
 * Default REG class
 * =======================
 * Version: 11-2016
 * ---------------- *
 * 
 * You should copy-paste this file to your new Project and use this as a template.
 * Expand the functions as you like
 * 
 */

package;
import djFlixel.gapi.ApiOffline;
import djFlixel.tool.DataTool;
import flixel.FlxG;
import djFlixel.tool.DynAssets;
import djFlixel.SAVE;
import djFlixel.Controls;
import djFlixel.SND;

#if desktop
	import openfl.filters.BitmapFilter;
	import openfl.filters.BlurFilter;
#end

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
	public static var ANTIALIASING(default, set):Bool = false;
	
	// Store the json parameters loaded from the file
	public static var JSON:Dynamic;

	public static var api:ApiOffline = new ApiOffline();
	
	//====================================================;
	// FUNCTIONS
	//====================================================;
	//--
	// Do a once per program run, initialization.
	// Auto called right after the FlxGame is ready 
	// and before any state is created.
	public static function initOnce()
	{
		trace("\n  :: Initializing REG ------------ \n");
		
		#if (desktop)
			initFilters();
		#end
		
		trace("Loading and applying JSON parameters.");
		applyParamsInto("reg", Reg);
		
		// Add a state switch trigger, useful to re-set antialiasing automatically
		FlxG.signals.stateSwitched.add(onStateSwitch);
		FlxG.signals.preGameReset.add(onPreGameReset);
		FlxG.signals.postGameReset.add(onPostGameReset);
		FlxG.fullscreen = FULLSCREEN;
		FlxG.mouse.useSystemCursor = false;
		FlxG.autoPause = false;
		
		trace("Initializing Sounds.");
		FlxG.sound.volume = VOLUME;
		SND.init();
		SND.MUSIC_ENABLED = MUSIC;
		SND.VOL_MUSIC = 0.88; // Hand adjust
		SND.VOL_EFFECTS = 0.76; // Hand adjust
		SND.loadFromJSON(JSON);
		
		trace("Initializing Controls.");
		Controls.init();
		
	}//---------------------------------------------------;
	
	
	
	#if desktop
	static var screenFilter:BitmapFilter;
	// Get params from JSON file and set the filter
	static function initFilters()
	{
		trace("Initializing Filters.");
		var params = DataTool.defParams(Reg.JSON.filter, { x:3.0, y:3.0, q:1 } );
		screenFilter = new BlurFilter(params.x, params.y, params.q);
		// Make sure no camera uses antialiasing
		for (i in FlxG.cameras.list) i.antialiasing = false;
	}//---------------------------------------------------;
	#end

	
	//====================================================;
	// SYSTEM FUNCTIONS
	//====================================================;
	
	// --
	// Gets called after every state switch.
	static function onStateSwitch()
	{
		// Force the cameras to use the default AA (with setter)
		#if (flash)
			Reg.ANTIALIASING = Reg.ANTIALIASING;
		#end
	}//---------------------------------------------------;
	
	// --
	static function onPreGameReset()
	{
		SND.destroy();
	}//---------------------------------------------------;
	
	// --
	static function onPostGameReset()
	{
		// Reload the sounds!
		SND.init();
		SND.loadFromJSON(JSON);
	}//---------------------------------------------------;
	
	
	// --
	// Quick way to alter the Antialiasing of all cameras
	static function set_ANTIALIASING(value:Bool):Bool
	{
		ANTIALIASING = value;
		#if (desktop)
			if (ANTIALIASING) {
				FlxG.game.setFilters([screenFilter]);
			}else {
				FlxG.game.setFilters([]);
			}
		#end
		
		#if(flash)
			for (i in FlxG.cameras.list) {
				i.antialiasing = ANTIALIASING;
			}
		#end
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

	//====================================================;
	// DEBUGGING
	//====================================================;

	#if debug
	public static function debug_keys()
	{	
		#if EXTERNAL_LOAD
		if (FlxG.keys.justPressed.F12)
		{
			trace(" = Reloading external parameters file :: ");
			DynAssets.loadFiles(function() {
					JSON = DynAssets.json.get(PARAMS_FILE);
					FlxG.resetState();
			});
		}else
		#end
		if (FlxG.keys.justPressed.F9)
		{
			ANTIALIASING = !ANTIALIASING;
		}
	}//---------------------------------------------------;
	
	#else
	
	// Inline so it will not be called at all.
	public static inline function debug_keys() { }	
	
	#end
	
}//--