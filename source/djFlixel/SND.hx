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
	static var group:Map<String,Array<String>> = null;
	
	// helper pointer
	static var rg:Array<String>;
	
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
		trace(" - SND init()");
		
		hash = new Map();
		group = new Map();		
	}//---------------------------------------------------;
	
	// Play a sound and destroy it right after playing
	// * Useful for sounds that are going to be played Rarely, or once
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
	public static function as(fileShort:String, ?ID:String, volumeRatio:Float = 1):FlxSound
	{
		if (ID == null) ID = fileShort;
		
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
		s.persist = true;	// -- Do not delete this if you switch states
		
		hash.set(ID, s);

		return s;
	}//---------------------------------------------------;
	// --
	// + Add Sound Group
	// Quick way to add a sound into a group
	public static function addGroup(soundID:String, groupID:String)
	{
		if (group.exists(groupID) == false) {
			group.set(groupID, new Array<String>());
		}
		group.get(groupID).push(soundID);
	}//---------------------------------------------------;
	
	// -- Play the sound with id $soundID
	public static inline function play(soundID:String, restart:Bool = true)
	{
		hash.get(soundID).play(restart);
	}//---------------------------------------------------;
	// -- 
	public static function playMusic(name:String)
	{
		// IN DEV
	}//---------------------------------------------------;
	// --
	// Play a random sound from a group
	public static function playGroup(groupID:String)
	{
		rg = group.get(groupID);
		play(rg[Std.random(rg.length)]);
	}//---------------------------------------------------;
	// --
	public static function destroy()
	{
		trace(" - Destroying SND");
		
		for (i in hash) {
			i.destroy();
			i = null;
		}
		
		for (i in group) {
			i = null;
		}
		
		hash = null;
		group = null;
	}//---------------------------------------------------;
}//-- end --//