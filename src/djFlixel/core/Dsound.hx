/**
	DjFlixel Sound Helpers
	===================
	
	- Accessible from D.snd
	- Handles sound metadata (volumes, grouping, quickIDs)
	- Play Music/Sounds with preset volumes
	- Sound Groups
	
	Usage:
	-------
		>> By default HTML5 will require .ogg files but you can override it.
			Declare <haxedef name="MP3" if="html5"/> in your `project.xml` file
			
		>> You MUST declare in <project.xml> where to look for sounds. The default place to look
			for is "assets/sounds/" and "assets/music/".
			When you rename the asset when including it, like this:
				<assets path="assets/sounds" type="sound" include="*.ogg" rename="snd"/>
			You Must then declare it like so:
				<haxedef name="DJFLX_SND" value="snd/" />
				<haxedef name="DJFLX_MUS" value="mus/" />
			Note that the value must end with "/" 
	
		>> To play something
			// This will play "/snd/player_jump.mp3" or ".ogg" depending on the platform
			D.snd.play('player_jump');	
			
*******************************************/
package djFlixel.core;

import djA.Macros;
import flixel.system.FlxSound;
import flixel.FlxG;
import haxe.ds.Map;
import openfl.Assets;


@:dce
class Dsound
{
	// File Extension, based on build target. Currently only flash needs .mp3
	static inline var FILE_EXT = #if (MP3) ".mp3"; #else ".ogg"; #end
	
	// Declare where to look for sounds. Check header of this file for more info
	static inline var ROOT_SND = #if (!DJFLX_SND) "assets/sounds/" #else Macros.getDefine("DJFLX_SND") #end;
	static inline var ROOT_MSC = #if (!DJFLX_MUS) "assets/music/" #else Macros.getDefine("DJFLX_MUS") #end;
	
	// Map shortID to full Sound Info as it's on the json node
	var volumes:Map<String,Float>;
	
	/* If (false) calls to D.snd.playMusic() will do nothing */
	public var MUSIC_ENABLED(default, set):Bool = true;
	
	/* If (false) calls to D.snd.play() will do nothing */
	public var SOUNDS_ENABLED:Bool = true;
	
	// The asset ID of the music playing
	var musicID:String;
	
	// Shortcut to FlxG.sound.music
	var mus:FlxSound;
	
	//====================================================;
	
	public function new()
	{
		volumes = new Map();
	}//---------------------------------------------------;
	
	/**
	 * Set the volume for either the default groups or the entire app
	 * @param	group master|sounds|music
	 * @param	vol
	 */
	public function setVolume(?group:String, vol:Float = 1)
	{
		switch(group) {
			case "sounds": FlxG.sound.defaultSoundGroup.volume = vol;
			case "music" : FlxG.sound.defaultMusicGroup.volume = vol;
			default: FlxG.sound.volume = vol;
		}
	}//---------------------------------------------------;
	
	
	/**
	   Declare Sound Volumes from an object with the format 
	    { 	
			soundName :   soundVolume(float) , 
			soundName2 : "soundvolume"(string) 
		}
		
	   - Example: {
				"pl_slide" : "0.4", // Strings will be parsed
				"pl_jump"  : 0.5,
				pl_slide   : 0.3,   // Also valid
			}
	**/
	public function addSoundInfos(node:Dynamic)
	{
		if (node == null) {
			trace("Sound infos is null"); return;
		}
		
		for (f in Reflect.fields(node)) 
		{
			var val:Dynamic = Reflect.field(node, f);
			try{
				volumes.set(f, Std.parseFloat(val));
			}catch (_) {
				volumes.set(f, Math.fround(val * 100) / 100);
			}
		}
		
		#if debug
		var c = Reflect.fields(node).length;
		if (c > 0) 
			trace('::DSound - Predefined volumes for ($c) sounds');
		#end
	}//---------------------------------------------------;
	
	/**
	 * Play a sound. Will search for loaded metadata and will apply volumes.
	 * @param	soundID Without extension, must be in "ROOT_SND" | e.g. "bang"
	 * @param	volumeMultiplier Volume Multiplier applied just for now
	 * @param	restart
	 */
	public function playV(soundID:String, volumeMultiplier:Float = 1, Looped:Bool = false, AutoDestroy:Bool = true):FlxSound
	{
		var vol = volumes.get(soundID);
		if (vol != null) volumeMultiplier = volumeMultiplier * vol;
		return play(soundID, volumeMultiplier, Looped, AutoDestroy);
	}//---------------------------------------------------;
	
	/**
	 * Quick play a sound calling the short filename (! NO FOLDER, NO EXTENSION )
	 * e.g. playFile("bang"); -> will play "sounds/bang.mp3" and depending on target it will play "sounds/band.ogg" etc
	 * @param	soundID Without extension, must be in "ROOT_SND"
	 * @param	customVolume
	 */
	public inline function play(soundID:String, customVolume:Float = 1, Looped:Bool = false, AutoDestroy:Bool = true):FlxSound
	{
		if (!SOUNDS_ENABLED) return null;
		return FlxG.sound.play(ROOT_SND + soundID + FILE_EXT, customVolume, Looped, null, AutoDestroy);
	}//---------------------------------------------------;

	/**
	 * Play a random sound from a group
	 * @param	groupID Make sure the group exists
	 */
	public function playR(ar:Array<String>, vol:Float = 1):FlxSound
	{
		return play(ar[Std.random(ar.length)], vol);
	}//---------------------------------------------------;
	
	/**
	 * Play a music file. Preset volume will be applied
	 * @param	asset short filename (! NO FOLDER, NO EXTENSION ) e.g. "track_01"
	 * @param	loopTime the point (in milliseconds) from where to restart the sound when it loops back
	 * @param	restart If already playing the same soundID, do a restart (true) or ignore (false)
	 * @param	customVolume Will be applied on top of custom volume
	 */
	public function playMusic(soundID:String, loopTime:Float = 0, restart:Bool = false, customVolume:Float = 1):FlxSound
	{
		if (!MUSIC_ENABLED) return null;
		
		var vol = volumes.get(soundID);
		if (vol != null) customVolume = customVolume * vol;
		
		if (musicID != soundID)
		{
			FlxG.sound.playMusic(ROOT_MSC + soundID + FILE_EXT, customVolume);	
			mus = FlxG.sound.music;
			mus.loopTime = loopTime;
			musicID = soundID;
		}else
		{
			// DEV: The same music ID is playing (it can't be null)
			// In case it was altered with a fade or something else:
			mus.volume = customVolume;
		}
		
		if (mus.fadeTween != null) mus.fadeTween.cancel(); // Just in case
		
		return FlxG.sound.music;
	}//---------------------------------------------------;
	
	/** 
	 * If any music fade it to off
	 **/
	public function musicFadeOff(time:Float = 1,stop:Bool = true):Void
	{
		if (!MUSIC_ENABLED) return;
		if (mus == null || !mus.active || mus.volume == 0) return;
			FlxG.sound.music.fadeOut(time, 0, (_)->{
			if (stop) stopMusic();
		});
	}//---------------------------------------------------;
	
	/**
	 * Stop if playing 
	 */
	public function stopMusic()
	{
		if (mus != null) {
			mus.stop();
			if (mus.fadeTween != null) mus.fadeTween.cancel();
		}
		musicID = null;
	}//---------------------------------------------------;
	
	
	function set_MUSIC_ENABLED(val:Bool):Bool
	{
		if (val == MUSIC_ENABLED) return val;
		MUSIC_ENABLED = val;
		if (!val) stopMusic();
		return val;
	}//---------------------------------------------------;
	
}//-- end --//
