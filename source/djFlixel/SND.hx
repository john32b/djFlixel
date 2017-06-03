package djFlixel;

import djFlixel.SND.SoundInfo;
import flixel.FlxG;
import flixel.system.FlxSound;

/**
 * Sound Static class
 * Responsible for loading and playing sounds.
 * 
 * + Steamlined loading: You can bulk load sounds from the master JSON file
 * + Sound groups: You can declare many sounds to belong to a group, and then play one at random
 * + Simple one music track management
 * 
 */

 
typedef SoundInfo = {
	var id:String;
	var file:String;
	var path:String; // Full path of the sound. Precalculated on creation
	var vol:Float;
	var fast:Bool;
	@:optional var group:String;
}
 
#if (flash)
class SND
{
	static inline var PATH_SOUNDS:String = "assets/sounds/";
	static inline var PATH_MUSIC:String = "assets/music/";
	static inline var FILE_EXT_MP3:String = ".mp3";
	static inline var FILE_EXT_OGG:String = ".ogg";
	public static var VOL_MUSIC:Float = 0.85;	// Global music volume
	public static var VOL_SOUND:Float = 0.85;	// Global effects volume
	public static var MUSIC_ENABLED:Bool = true;
	//---------------------------------------------------;
	// Short ID to Actual Asset ID
	static var memorySounds:Map<String,FlxSound> = null;
	// Groups of sounds
	static var group:Map<String,Array<String>> = null;
	// Map shortID to full Sound Info as it's on the json node
	static var infos:Map<String,SoundInfo>;
	// Helper pointer for group playing
	static var _r1:Array<String>;
	// Helper var
	static var _r2:SoundInfo;
	
	//====================================================;
	// FUNCTIONS
	//====================================================;
	//--
	//-- Preload and init the sounds
	public static function init()
	{	
		if (memorySounds != null) {
			trace("Warning: SND already inited");
			return;
		}
		
		memorySounds = new Map();
		group = new Map();
		infos = new Map();
	}//---------------------------------------------------;
	
	
	/**
	 * Node Example:
	 * 
	 * 	"soundFiles": [
	 * 		{ "id":"fx2", "file":"effect_01", "fast":true, "group" : "tres", "vol": 0.9 },
	 * 		{ .. }
	 * ]
	 * 
	 * 	id: Short identifier
	 *  file: Filename in the sounds folder without the extension
	 *  fast: If true, then this sound will be kept in memory @optional @default=false
	 *  group: An identifier to group sounds @optional
	 *  vol: Float custom volume @optional
	 * 
	 *  ---
	 * 	Snd.play("fx1");	  :: Will play the sound
	 * 	Snd.playGroup("fx");  :: Will play a random sound from the group
	 * @param	JSON
	 * @return
	 */
	public static function loadFromJSON(JSON:Dynamic)
	{
		var numOfSounds:Int = 0;
		var numOfCached:Int = 0;
		trace(":: Loading sounds from JSON node --");
		
		var jsonData:Array<SoundInfo> = JSON.soundFiles;
		
		if (jsonData == null) {
			trace("Can't find 'soundFiles' node to load sounds from JSON");
			jsonData = [];
			return;
		}
		
		for (i in jsonData)
		{
			numOfSounds++;
			// -- Create the node in the Info
			if (!Reflect.hasField(i, "vol")) Reflect.setField(i, "vol", 1.0);
			if (!Reflect.hasField(i, "fast")) Reflect.setField(i, "fast", false);
			i.path = PATH_SOUNDS + i.file + 
				#if flash
					FILE_EXT_MP3;
				#else
					FILE_EXT_OGG;
				#end
			infos.set(i.id, i);
			
			if (i.fast == true) {
				cacheSound(i.file, i.id, i.vol);
				numOfCached++;
			}
			
			if (i.group != null) {
				addGroup(i.id, i.group);
			}
			
		}// --
		
		trace("  total sounds : " , numOfSounds);
		trace("  total cached : " , numOfCached);
		// trace("  sound Groups  ::");
		// for (i in group.keys()) trace(' "$i" => ', group.get(i));
	}//---------------------------------------------------;
	
	// --
	// + Preload a sound, create a soundObject to stay in memory.
	//
	public static function cacheSound(fileShort:String, ?ID:String, volumeRatio:Float = 1):FlxSound
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
			
		s.volume = VOL_SOUND * volumeRatio;
		s.persist = true;	// -- Do not delete this if you switch states
		
		memorySounds.set(ID, s);

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
	public static function play(soundID:String, restart:Bool = true)
	{
		// Lookup the table only once
		_r2 = infos.get(soundID);
		#if debug
		if (_r2 == null) {
			trace('ERROR: Can\'t get sound with id $soundID');
			return;
		}
		#end
		if (_r2.fast) {
			memorySounds.get(soundID).play(restart);
		}else {
			FlxG.sound.play(_r2.path, VOL_SOUND * _r2.vol);
		}
	}//---------------------------------------------------;
	// -- Play a sound with soundID with a temp custom volume 
	public static function playV(soundID:String, restart:Bool = true, volRatio:Float = 1)
	{
		_r2 = infos.get(soundID);
		if (_r2.fast) {
			var s = memorySounds.get(soundID);
				s.volume = VOL_SOUND * _r2.vol * volRatio;
				s.play(restart);
		}else {
			FlxG.sound.play(_r2.path, VOL_SOUND * _r2.vol * volRatio);
		}
	}//---------------------------------------------------;
	
	// --
	// In some cases you may need a sound object to stop/pause/etc
	public static function getSound(soundID:String):FlxSound
	{
		_r2 = infos.get(soundID);
		if (_r2 != null && _r2.fast) { return memorySounds.get(soundID); }
		trace("Error: Could not get sound. Did you load it? Is it fast/cached?");
		return null;
	}//---------------------------------------------------;
	
	/**
	 * Audio files must be in the PATH_MUSIC dir e.g."assets/music/XXXX.mp3"
	 * @param	filename
	 * @param	customVolume
	 */
	public static function playMusic(filename:String, customVolume:Float = -1)
	{
		if (MUSIC_ENABLED == false) {
			stopMusic();
			return;
		}
		var vol:Float = VOL_MUSIC;
		if (customVolume > 0) vol = customVolume;
		FlxG.sound.playMusic(PATH_MUSIC + filename + ".mp3", vol, true); // todo OGG?
	}//---------------------------------------------------;
	
	//-- Stop if music is playing
	public static function stopMusic()
	{
		if (FlxG.sound.music != null) FlxG.sound.music.stop();
	}//---------------------------------------------------;
	
	/**
	 * Quick play a sound
	 * 
	 * @param	filename Without extension, must be in /assets/sounds
	 * @param	customVolume
	 */
	public static function playFile(fileshort:String, customVolume:Float = 1)
	{
		FlxG.sound.play(PATH_SOUNDS + fileshort + 
			#if flash
				FILE_EXT_MP3 ,
			#else
				FILE_EXT_OGG , 
			#end
		VOL_SOUND * customVolume);
	}//---------------------------------------------------;
	
	// --
	// Play a random sound from a group
	public static function playGroup(groupID:String)
	{
		_r1 = group.get(groupID);
		play(_r1[Std.random(_r1.length)]);
	}//---------------------------------------------------;
	// --
	public static function destroy()
	{
		trace(" - Destroying SND");
		
		for (i in memorySounds) {
			i.destroy();
			i = null;
		}
		
		for (i in group) {
			i = null;
		}
		
		memorySounds = null;
		group = null;
	}//---------------------------------------------------;
}//-- end --//


#else

// Currently just just the flash build supports sound
// The functionality is the same, it's just I don't want to deal with .ogg files for when testing other targets
// So this completely nulls the SND system.

class SND
{
	public static var MUSIC_ENABLED:Bool = true;
	public static var VOL_MUSIC:Float = 0.8;
	public static var VOL_SOUND:Float = 0.8;
	public static inline function init()
	{	
	}//---------------------------------------------------;
	public static inline function cacheSound(fileShort:String, ?ID:String, volumeRatio:Float = 1):FlxSound
	{
		return null;
	}//---------------------------------------------------;
	public static inline function addGroup(soundID:String, groupID:String)
	{
	}//---------------------------------------------------;
	public static inline function play(soundID:String, restart:Bool = true)
	{
	}//---------------------------------------------------;
	public static inline function playV(soundID:String, restart:Bool = true, volRatio:Float = 1)
	{
	}// --
	public static inline function playMusic(filename:String, customVolume:Float = -1)
	{
	}//---------------------------------------------------;
	public static inline function playGroup(groupID:String)
	{
	}//---------------------------------------------------;
	public static inline function loadFromJSON(JSON:Dynamic)
	{
	}	//---------------------------------------------------;
	public static inline function destroy()
	{
	}//---------------------------------------------------;
	public static inline function playFile(fileshort:String, customVolume:Float = 1)
	{
	}//---------------------------------------------------;
	public static inline function stopMusic()
	{
	}//---------------------------------------------------;
	public static inline function getSound(soundID:String):FlxSound
	{
		return null;
	}//---------------------------------------------------;
	
}//-- end --//


#end