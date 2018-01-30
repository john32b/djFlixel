package djFlixel;

import flixel.system.FlxSound;
import flixel.FlxG;

/**
 * Sound Static class
 * 
 * - Handles sound metadata (volumes, grouping, quickIDs)
 */

typedef SoundInfo = {
	var id:String;		// ID to call
	var file:String;	// File without the folder and filename
	var asset:String; 	// Full asset of the sound. Precalculated on creation if null
	var vol:Float;
	@:optional var group:String;
}
 
#if (FLX_SOUND_SYSTEM)
class SND
{
	static inline var FILE_EXT_MP3:String = ".mp3";
	static inline var FILE_EXT_OGG:String = ".ogg";
	
	// --
	static var FILE_EXT:String;	// Current file extension for sounds, AUTOCALCULATED
	public static var MUSIC_ENABLED:Bool;	// Copied from FPS
	//---------------------------------------------------;
	
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
	
	// --
	// Preload and init the sounds
	// @AUTOCALLED from FLS.hx
	public static function init()
	{
		// Note: The Default groups are not destroyed in the lifetime of the app
		setVolume("sounds", FLS.VOL_SOUND);
		setVolume("music", FLS.VOL_MUSIC);
		
		#if (flash)
		FILE_EXT = FILE_EXT_MP3;
		#else
		FILE_EXT = FILE_EXT_OGG;
		#end
		
		group = new Map();
		infos = new Map();
	}//---------------------------------------------------;
	
	/**
	 * Set the volume for either the default groups or the entire app
	 * @param	group master|sounds|music
	 * @param	vol
	 */
	public static function setVolume(?group:String, vol:Float = 1)
	{
		switch(group){
			case "sounds": FlxG.sound.defaultSoundGroup.volume = vol;
			case "music" : FlxG.sound.defaultMusicGroup.volume = vol;
			default: FlxG.sound.volume = vol;
		}
	}//---------------------------------------------------;
	
	
	/**
	 * Append Sound Metadata. Useful to adding extra parameters for your sounds like
	 * grouping and custom volumes. Also you can load sounds by calling an ID or the
	 * short filename, instead of calling the whole assetPath name
	 * 
	 * Node Example:
	 * 	[
	 * 		{ "id":"fx2", "file":"effect_01", "group" : "tres", "vol": 0.9 },
	 * 		{ "id":"fx2", "asset":"fx2", "vol":0.2},
	 * 		{ .. }
	 * 	]
	 * 
	 * 	id: Short identifier @optional
	 *  asset: Asset path as it is declared in openFL @optional
	 * 	file: ShortFilename without folder and extension @optional
	 *  group: An identifier to group sounds @optional
	 *  vol: Float custom volume @optional
	 * 
	 * 	//-- You MUST set either the "file" or the "asset"
	 * 
	 *  ---
	 * 	Snd.play("fx1");	  :: Will play the sound
	 * 	Snd.playGroup("fx");  :: Will play a random sound from the group
	 * @param	Node An Array/JsonNode containing SoundInfo Objects
	 * @return
	 */
	public static function addMetadataNode(node:Dynamic)
	{
		if (node == null) {
			trace("Metadata is null");
			return;
		}
		
		var numOfSounds:Int = 0;
		var jsonData:Array<SoundInfo> = node;
		
		trace(":: Loading sounds from JSON node --");
		
		for (i in jsonData)
		{
			numOfSounds++;
			// -- Create the node in the Info
			if (!Reflect.hasField(i, "vol")) Reflect.setField(i, "vol", 1);
			if (i.asset == null){
				if (i.file == null){
					trace("Error: Sound has neither 'asset' or 'file' field");
					continue;
				}
				i.asset = FLS.SOUND_PATH + i.file + FILE_EXT;
			}
			if (i.id == null){
				if (i.file != null) i.id = i.file;
				else i.id = i.asset;
			}
			
			infos.set(i.id, i);
			
			// Process the group, creates it if not exists
			if (i.group != null) {
				if (group.exists(i.group) == false) {
					group.set(i.group, new Array<String>());
				}
				group.get(i.group).push(i.id);
			}
			
		}// --
		
		#if debug
		trace(" sounds loaded : " , numOfSounds);
		trace(" sound Groups  ::");
		for (i in group.keys()) trace(' "$i" => ', group.get(i));
		trace(infos);
		#end
	}//---------------------------------------------------;
	
	/**
	 * Play a sound. Will search for loaded metadata and will apply volumes.
	 * @param	soundID Asset or Sound ID
	 * @param	volumeMultiplier Volume Multiplier applied just for now
	 * @param	restart
	 */
	public static function play(soundID:String, volumeMultiplier:Float = 1):FlxSound
	{
		_r2 = infos.get(soundID);
		if (_r2 == null) 
		{
			trace("Warning: No Metadata for soundID", soundID, _r2);
			return playFile(soundID, volumeMultiplier);
		}
		return FlxG.sound.play(_r2.asset, _r2.vol * volumeMultiplier);
	}//---------------------------------------------------;
	
	/**
	 * Quick play a sound calling the short filename (no folder, no extension)
	 * e.g. playFile("bang"); -> will play "sounds/bang.mp3"
	 * 
	 * @param	filename Without extension, must be in "FLS.SOUND_PATH"
	 * @param	customVolume
	 */
	inline public static function playFile(fileshort:String, customVolume:Float = 1):FlxSound
	{
		return FlxG.sound.play(FLS.SOUND_PATH + fileshort + FILE_EXT, customVolume);
	}//---------------------------------------------------;
	
	/**
	 * Quick play a sound by calling its asset name ( e.g. "fx3" )
	 * Used when you define custom IDs to sounds in the project.xml file
	 * @param	asset As it is declared
	 * @param	customVolume
	 */
	inline public static function playAsset(asset:String, customVolume:Float = 1)
	{
		FlxG.sound.play(asset, customVolume);
	}//---------------------------------------------------;

	/**
	 * Play a random sound from a group
	 * @param	groupID Make sure the group exists
	 */
	public static function playGroup(groupID:String)
	{
		_r1 = group.get(groupID);
		play(_r1[Std.random(_r1.length)]);
	}//---------------------------------------------------;
	
	
	/**
	 * Audio files must be in the FLS.MUSIC_PATH dir.
	 * NOTE: You must declare the MUSIC files in `project.xml`
	 * @param	asset Use ASSET ID declared in `project.xml`
	 * @param	customVolume
	 */
	public static function playMusic(asset:String, customVolume:Float = 1)
	{
		if (MUSIC_ENABLED == false) {
			stopMusic();
			return;
		}
		FlxG.sound.playMusic(asset, customVolume);
	}//---------------------------------------------------;
	
	//-- Stop if music is playing
	public static function stopMusic()
	{
		if (FlxG.sound.music != null) FlxG.sound.music.stop();
	}//---------------------------------------------------;
	
	// -- No need for destroy, this class lives until the program exits
	
}//-- end --//


#else


/**
 * By making the calls inline and empty, they will not even be called at the final code
 */

class SND
{
	public static var MUSIC_ENABLED:Bool;
	public static inline function init(){}
	public static inline function addMetadataNode(node:Dynamic){}
	public static inline function play(soundID:String, volumeMultiplier:Float = 1){}
	public static inline function playFile(fileshort:String, customVolume:Float = 1){}
	public static inline function playAsset(assetName:String, customVolume:Float = 1){}
	public static inline function playGroup(groupID:String){}
	public static inline function playMusic(filename:String, customVolume:Float = 1){}
	public static inline function stopMusic(){}
	public static inline function setVolume(?grp:String, vol:Float = 1){}
	
}

#end