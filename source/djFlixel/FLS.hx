package djFlixel;


import djFlixel.gui.Gui;
import djFlixel.gui.Styles;
import flixel.FlxG;
import flixel.FlxObject;
import djFlixel.tool.DynAssets;
import djFlixel.tool.DataTool;
import haxe.Log;

#if desktop
	import openfl.filters.BitmapFilter;
	import openfl.filters.BlurFilter;
#end

/**
 * DjFlixel global system functions {FLixel System}
 * 
 * NOTES:
 * -----
 * + Set the 'extendedClass' on program MAIN, use a class that extends this
 * + data/params.json file must exist
 * + JSON file must include a 'sys' node at root
 * + All the public statics vars can be overriden in the JSON file
 * 		[VERSION,NAME,VOLUME,MUSIC,WEBSITE,FULLSCREEN,ANTIALIASING,VOL_SOUND,VOL_MUSIC]
 * + Extra FLS Nodes:
 * 	FPS: Force the render FPS
 */
class FLS
{
	//====================================================;
	// STATIC 
	//====================================================;
	
	// 
	public inline static var DJFLX_VERSION:String = "0.3";
	
	// -- Parameters file --
	// -  It is useful to have various game parameters to an external file
	// -  so that I don't have to compile everytime I want to change a value.
	// -  !NOTE! This is automatically added to the DynAssets Load Files list.
	// -  !NOTE! In order for <external load> to work (flash target), this ID needs to be a valid path
	static public var PARAMS_ASSET:String = "assets/data/params.json";
	
	// -  These vars are loaded externally from the JSON parameters file ::
	//    If the parameter is not present on the ext file, then these defaults will be used.
	public static var VERSION:String = "0.1";
	public static var NAME:String = "HaxeFlixel app";
	// -- SOUNDS
	public static var VOLUME:Float = 0.7; 		// Master volume (Flixel Main Volume)
	public static var VOL_SOUND:Float = 0.85; 	// Sound Effects Volume
	public static var VOL_MUSIC:Float = 0.85; 	// Music Volume
	public static var MUSIC_ON:Bool = true;
	public static var SOUND_PATH = "sounds/";	// Where are the sound files placed/declared in assets
	public static var MUSIC_PATH = "music/";	// Where are the music files placed/declared in assets
	// --
	public static var WEBSITE:String = "";
	
	// Changing this will also take effect
	public static var FULLSCREEN(default, set):Bool = false;
	// Current Antialiasing on/off, comes with a setter that applies to all cameras
	public static var ANTIALIASING(default, set):Bool = false;
	
	// Store the system json parameters loaded from the system params file "PARAMS_ASSET"
	public static var JSON:Dynamic;
			
	// Keep an instantiated object of this class
	public static var self:FLS;
	
	// # USER SET # Point to the extended class to be created on program init
	public static var extendedClass:Class<FLS> = null;
	
	#if(desktop)
		static var screenFilter:BitmapFilter;
	#end
	
	// Handles asset reloading, JSON parameters and dynamic images
	public static var assets:DynAssets;
	
	//---------------------------------------------------;
	
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
			return value;
		#end
		
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
	
	
	//====================================================;
	// DEBUGGING
	//====================================================;

	#if debug
	
	/**
	 * Debug keys ::
	 * F12 : Reload external files and reset state
	 * SHIFT F12 : Reset Game
	 * F9 : Antialiasing toggle
	 */
	public static function debug_keys()
	{	
		if (FlxG.keys.justPressed.F12) {
			if (FlxG.keys.pressed.SHIFT){
				FlxG.resetGame();
			}else{
				#if EXTERNAL_LOAD
				trace(" = Reloading external parameters file :: ");
				assets.loadFiles(function() {
						JSON = assets.json.get(PARAMS_ASSET);
						FlxG.resetState();
				});
				#end
			}
		}else
		if (FlxG.keys.justPressed.F9) {
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
	#else
	
	// Inline so it will not be called at all.
	public static inline function debug_keys() { }
	public static inline function translateDir(dir:Int):String { return ""; }
	#end
	
	
	//====================================================;
	// INSTANTIATED
	// ----------
	// Extend these functions with a custom class
	// You need to set it up with `FLS.extendedClass = myClass`
	//====================================================;
	
	// -- Should be called once right after the FlxGame is created
	public function new() 
	{
		FLS.self = this;
				
		DataTool.copyFields(JSON.sys, FLS);
		
		trace('\n:: DjFlixel v$DJFLX_VERSION\n:: $NAME, $VERSION\n:: ----------------------------\n');
		
		#if (desktop)
			initFilters();
		#end
		
		// Add a state switch trigger, useful to re-set antialiasing automatically
		FlxG.signals.stateSwitched.add(onStateSwitch);
		FlxG.signals.preGameReset.add(onPreGameReset);
		FlxG.signals.postGameReset.add(onPostGameReset);
		FlxG.fullscreen = FULLSCREEN;
		FlxG.mouse.useSystemCursor = false;
		FlxG.autoPause = false;
		
		trace("Initializing Sounds.");
		SND.init();
		SND.MUSIC_ENABLED = MUSIC_ON;
		SND.addMetadataNode(JSON.soundFiles);
		SND.setVolume(VOLUME);
		
		trace("Initializing Controls.");
		CTRL.init();
		
		// -- Other
		Gui.initOnce();
		
		// --
		// You can extend this class and have additional custom initialization to the extended class
		
	}//---------------------------------------------------;

	// --
	// Gets called right before the new state is created
	private function onStateSwitch()
	{
		// Just in case:
		Gui.autoplaceOff();
		Gui.mapTweens = new Map();
		
		// Force the cameras to use the default AA (with setter)
		#if (!desktop)
			FLS.ANTIALIASING = FLS.ANTIALIASING;
		#end
	}//---------------------------------------------------;
	
	// --
	// -- Calls this then onStateSwitch() later
	private function onPreGameReset()
	{
	}//---------------------------------------------------;
	
	// --
	private function onPostGameReset()
	{
	}//---------------------------------------------------;
	
	
	#if desktop
	
	// !WARNING! This is untested and WORK IN PROGRESS
	//			 Needs a filter node in the JSON file
	private function initFilters()
	{
		trace("Desktop Target .. Initializing Filters.");
		var params = DataTool.copyFields(JSON.filter, {x:2.0, y:2.0, q:1 });
		screenFilter = new BlurFilter(params.x, params.y, params.q);
		
		// Make sure no camera uses antialiasing
		for (i in FlxG.cameras.list) i.antialiasing = false;
		
		// Don't add yet! it will be auto added if needed ::
		// FlxG.game.setFilters([screenFilter]);
		
		// GLSL SHADERS :: UNUSED ::
		// add some post processing FX
		//var SHADER = new PostProcess("assets/shaders/blur.txt");
		//SHADER.setUniform("diry", 1);
		//SHADER.setUniform("dirx", 1);
		//SHADER.setUniform("radius", 1);
		//FlxG.addPostProcess(SHADER);
	}//---------------------------------------------------;
	#end
}// --