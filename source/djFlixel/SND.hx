package djFlixel;

import flixel.FlxG;
import flixel.system.FlxSound;

/**
 * Version 0.3
 * Responsible for loading and playing sounds.
 */

#if (flash) 
class SND
{
	static inline var PATH_SOUNDS:String = "assets/sounds/";
	static inline var FILE_EXT_MP3:String = ".mp3";
	static inline var FILE_EXT_OGG:String = ".ogg";
	
	static var VOL_MUSIC:Float = 0.8;	// Global music volume
	static var VOL_EFFECTS:Float = 0.8;	// Global effects volume
	
	public static var MUSIC_ENABLED:Bool = true;
	
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
	
	
	/*
	 *  --
	 * Load sounds from the main JSON file automatically
	 * JSON file example:
	 * ---------------	
	 * 		"soundFiles" : {
	 *			"fx1"  : "fx1" , ==> fx1 is the handle for "assets/sounds/fx1.mp3" 
	 *			"fx2"  : "fx2", ==> fx2 is the handle for "assets/sounds/fx2.mp3"
	 * 
	 * 		"soundGroups" : { "fx" : ["fx1","fx2"] }
	 * 	
	 * 		"soundVolumes" : { "fx1" : 0.6 ,"fx2":0.2 }
	 * 
	 * :: 
	 * 
	 *  If SoundVolume is set it's applied to the sound
	 * 	Snd.play("fx1");	  :: Will play the sound
	 * 	Snd.playGroup("fx");  :: Will play a random sound from the group
	 * 
	 * @param	JSON pointer to the JSON object to load from
	 */
	public static function loadFromJSON(JSON:Dynamic)
	{
		
		if (JSON.soundGroups != null)
		for (field in Reflect.fields(JSON.soundGroups)) {
			var sounds:Array<String>;
			sounds = Reflect.getProperty(JSON.soundGroups, field);
			for (s in sounds) {
				addGroup(s, field);	
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
			
			as(Reflect.field(JSON.soundFiles, field), field, customVolume);
		}
		
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
	// Audio files must be in the "assets/music/XXXX.mp3"
	public static function playMusic(filename:String, customVolume:Float = -1)
	{
		if (MUSIC_ENABLED == false) {
			if (FlxG.sound.music != null) FlxG.sound.music.stop();
			return;
		}
		var vol:Float = VOL_MUSIC;
		if (customVolume > 0) vol = customVolume;
		FlxG.sound.playMusic("assets/music/" + filename + ".mp3", vol, true); // todo OGG?
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



#else

// If you set the NO_OGG flag then no sounds will be loaded or player
// Useful when you don't have any ogg sounds yet


class SND
{
	public static var MUSIC_ENABLED:Bool = true;
	public static inline function init()
	{	
	}//---------------------------------------------------;
	public static inline function playAndDestroy(fileShort:String)
	{
	}//---------------------------------------------------;
	public static inline function as(fileShort:String, ?ID:String, volumeRatio:Float = 1):FlxSound
	{
		return null;
	}//---------------------------------------------------;
	public static inline function addGroup(soundID:String, groupID:String)
	{
	}//---------------------------------------------------;
	public static inline function play(soundID:String, restart:Bool = true)
	{
	}//---------------------------------------------------;
	public static inline function playMusic(filename:String, customVolume:Float = -1)
	{
	}//---------------------------------------------------;
	public static inline function playGroup(groupID:String)
	{
	}//---------------------------------------------------;
	public static function loadFromJSON(JSON:Dynamic)
	{
	}	//---------------------------------------------------;
	public static inline function destroy()
	{
	}//---------------------------------------------------;
}//-- end --//


#end