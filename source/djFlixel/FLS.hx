package djFlixel;


import flixel.FlxG;
import flixel.FlxObject;
import djFlixel.tool.DynAssets;
import djFlixel.tool.DataTool;

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
 * + Extra nodes in 'sys' node :
 * 	 START_STATE : string, You can specify a state name to override the default starting state
 * 
 */
class FLS
{
	//====================================================;
	// STATIC 
	//====================================================;
	
	// -- Parameters file --
	// -  It is useful to have various game parameters to an external file
	// -  so that I don't have to compile everytime I want to change a value.
	// -  !NOTE! This is automatically added to the DynAssets Load Files list.
	static public var PARAMS_FILE:String = "data/params.json";
	
	// -  These vars are loaded externally from the JSON parameters file ::
	//    If the parameter is not present on the ext file, then these defaults will be used.
	public static var VERSION:String = "0.3";
	public static var NAME:String = "HaxeFlixel app";
	public static var VOLUME:Float = 0.7; // Master volume
	public static var VOL_SOUND:Float = 0.85; // Sound Effects Volume
	public static var VOL_MUSIC:Float = 0.85; // Music Volume
	public static var MUSIC_ON:Bool = true;
	public static var WEBSITE:String = "";
	
	// Changing this will also take effect
	public static var FULLSCREEN(default, set):Bool = false;
	// Current Antialiasing on/off, comes with a setter that applies to all cameras
	public static var ANTIALIASING(default, set):Bool = false;
	
	// Store the json parameters loaded from the file
	public static var JSON:Dynamic;
			
	// Keep an instantiated object of this class
	public static var self:FLS;
	
	// # USER SET # Point to the extended class to be created on program init
	public static var extendedClass:Class<FLS> = null;
	
	#if(desktop)
		static var screenFilter:BitmapFilter;
	#end
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
				DynAssets.loadFiles(function() {
						JSON = DynAssets.json.get(PARAMS_FILE);
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
	//====================================================;
	
	// -- Should be called once right after the FlxGame is created
	public function new() 
	{
		trace("\n:: Initializing FLS ------------ \n");
	
		FLS.self = this;
		
		#if (desktop)
			initFilters();
		#end
		
		DataTool.applyFieldsInto(JSON.sys, FLS);
		trace(':: $NAME, $VERSION');
		
		// Add a state switch trigger, useful to re-set antialiasing automatically
		FlxG.signals.stateSwitched.add(onStateSwitch);
		FlxG.signals.preGameReset.add(onPreGameReset);
		FlxG.signals.postGameReset.add(onPostGameReset);
		FlxG.fullscreen = FULLSCREEN;
		FlxG.mouse.useSystemCursor = false;
		FlxG.autoPause = false;
		
		trace("Initializing Sounds.");
		SND.init();
		SND.VOL_SOUND = VOL_SOUND;
		SND.VOL_MUSIC = VOL_MUSIC;
		SND.MUSIC_ENABLED = MUSIC_ON;
		SND.loadFromJSON(JSON);
		FlxG.sound.volume = VOLUME;
		
		trace("Initializing Controls.");
		Controls.init();
		
		// --
		// Extended class responsible for API, GAMESAVE and other things
		
	}//---------------------------------------------------;

	// --
	// Gets called after every state switch.
	private function onStateSwitch()
	{
		// Force the cameras to use the default AA (with setter)
		#if (!desktop)
			FLS.ANTIALIASING = FLS.ANTIALIASING;
		#end
	}//---------------------------------------------------;
	
	// --
	private function onPreGameReset()
	{
		SND.destroy();
	}//---------------------------------------------------;
	
	// --
	private function onPostGameReset()
	{
		// I need to reload the sounds because reseting flxG destroys all sounds
		SND.init();
		SND.loadFromJSON(JSON);
	}//---------------------------------------------------;
	
	
	#if desktop
	
	// !WARNING! This is untested and WORK IN PROGRESS
	//			 Needs a filter node in the JSON file
	private function initFilters()
	{
		trace("Initializing Filters.");
		var params = DataTool.defParams(JSON.filter, { x:3.0, y:3.0, q:1 } );
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