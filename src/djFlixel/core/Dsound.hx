/**
	DjFlixel Sound Helpers
	===================
	
	- Accessible from D.snd
	- Handles sound metadata (volumes, grouping, quickIDs)
   
	- Play sounds with custom volumes
	- Sound Groups
	
	Usage:
	-------
		>> You MUST declare in <project.xml> where to look for sounds. The default place to look
			for is "assets/sounds/" and "assets/music/".
			When you rename the asset when including it, like this:
				<assets path="assets/sounds" type="sound" include="*.ogg" rename="snd"/>
			You Must then declare it like so:
				<haxedef name="DJFLX_SND" value="snd/" />
				<haxedef name="DJFLX_MUS" value="snd/" />
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


@:dce
class Dsound
{
	// File Extension, based on build target. Currently only flash needs .mp3
	static inline var FILE_EXT = #if (flash) ".mp3"; #else ".ogg"; #end
	
	// Declare where to look for sounds. Check header of this file for more info
	static inline var ROOT_SND = #if (!DJFLX_SND) "assets/sounds/" #else Macros.getDefine("DJFLX_SND") #end;
	static inline var ROOT_MSC = #if (!DJFLX_MUS) "assets/music/" #else Macros.getDefine("DJFLX_MUS") #end;
	
	// Map shortID to full Sound Info as it's on the json node
	var volumes:Map<String,Float>;
	
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
	 * NOTE: You must declare the MUSIC files in `project.xml`
	 * @param	asset Use ASSET ID declared in `project.xml`
	 * @param	customVolume
	 */
	public function playMusic(soundID:String, customVolume:Float = 1)
	{
		var vol = volumes.get(soundID);
		if (vol != null) customVolume = customVolume * vol;
		FlxG.sound.playMusic(ROOT_MSC + soundID + FILE_EXT, customVolume);
	}//---------------------------------------------------;
	
	/**
	 * Stop if playing 
	 */
	public function stopMusic()
	{
		if (FlxG.sound.music != null) FlxG.sound.music.stop();
	}//---------------------------------------------------;
	
}//-- end --//
