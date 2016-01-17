package djFlixel;

import flixel.FlxG;
import flixel.system.FlxSound;


/**
 * Responsible for loading and playing sounds.
 */
class SND
{
	static inline var PATH_SOUNDS:String = "assets/sounds/";
	static inline var FILE_EXT_MP3:String = ".mp3";
	static inline var FILE_EXT_OGG:String = ".ogg";
	
	static var VOL_MUSIC:Float = 0.6;	// Global music volume
	static var VOL_EFFECTS:Float = 0.7;	// Global effects volume
	
	//---------------------------------------------------;
	static var isInited:Bool = false;
	
	// Store all the sounds here
	static var hash:Map<String,FlxSound> = null;
	
	// Groups of sounds
	static var group:Map<String,Array<FlxSound>> = null;
	
	// Helper
	static var rg:Array<FlxSound>;
	
	//====================================================;
	// FUNCTIONS
	//====================================================;
	//--
	//-- Preload and init the sounds
	public static function init()
	{	
		if (hash != null) {
			trace("Warning: SND already inited");
			return;
		}
		hash = new Map();
		group = new Map();		
	}//---------------------------------------------------;
	
	// Play a sound and destroy it right after playing
	// * Useful for sounds that are going to be played RARELY
	// --
	public static function playAndDestroy(fileShort:String)
	{
		FlxG.sound.load(PATH_SOUNDS + fileShort +	
		#if flash
		FILE_EXT_MP3,
		#else
		FILE_EXT_OGG,
		#end
		VOL_EFFECTS, false, true, true);
	}//---------------------------------------------------;
	
	// --
	// + Add Sound
	// Quick way to add a sound
	public static function as(fileShort:String, ?name:String, volumeRatio:Float = 1):FlxSound
	{
		if (name == null) name = fileShort;
		
		var s:FlxSound = FlxG.sound.load(PATH_SOUNDS + fileShort + 
		#if flash
			FILE_EXT_MP3);
		#else
			FILE_EXT_OGG);
		#end
		
		#if debug
		if (s == null) {
			trace('Error: Problem loading file - $fileShort');
			return null;
		}
		#end
			
		s.volume = VOL_EFFECTS * volumeRatio;
		s.persist = true;	// -- new
		
		hash.set(name, s);

		return s;
	}//---------------------------------------------------;
	// --
	// + Add Sound Group
	// Quick way to add a sound into a group
	public static function asGrp(fileShort:String, groupName:String, volumeRatio:Float = 1)
	{
		if (group.exists(groupName) == false) {
			group.set(groupName, new Array<FlxSound>());
		}
		group.get(groupName).push(as(fileShort, fileShort, volumeRatio));
	}//---------------------------------------------------;
	
	// -- Play the sound named $name
	public static inline function play(name:String, restart:Bool = true)
	{
		hash.get(name).play(restart);	
	}//---------------------------------------------------;
	// -- 
	public static function playMusic(name:String)
	{
		// IN DEV
	}//---------------------------------------------------;
	// --
	static function playRandom(groupName:String)
	{
		rg = group.get(groupName);
		rg[Std.random(rg.length)].play(true);
	}//---------------------------------------------------;
	// --
	public static function destroy()
	{
		for (i in hash) {
			i.destroy();
			i = null;
		}
		hash = null;
		group = null;
	}//---------------------------------------------------;
}//-- end --//