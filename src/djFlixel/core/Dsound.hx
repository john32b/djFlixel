/**
	DjFlixel SOUND Core
	===================
	
	- Accessible from D.snd
	- Handles sound metadata (volumes, grouping, quickIDs)
	- Sound helpers
   
	Usage:
	-------
		
		// If you have put/declared your sound folder, you NEED to declare it here. e.g.
		D.snd.ROOT_SND  = "snd/";
		D.snd.ROOT_MSC  = "mus/
		
		// To play something
		// >> This will play "/snd/player_jump.mp3"	or ".ogg" depending on the platform
		D.snd.play('player_jump');	
**/

package djFlixel.core;

import flixel.system.FlxSound;
import flixel.FlxG;
import haxe.ds.Map;
import haxe.io.Float32Array;


@:dce
class Dsound
{
	static inline var FILE_EXT_MP3:String = ".mp3";
	static inline var FILE_EXT_OGG:String = ".ogg";
	
	/** Override and place what is declared as the Asset Root . END WITH '/'
		e.g. you when can declare the sound assets as :
			<assets path="assets/sounds" type="sound" rename="snd"/>
		    you should ROOT_SND = "snd/"
	**/
	public var ROOT_SND  = "assets/sounds/";
	public var ROOT_MSC  = "assets/music/";
	
	// Current file extension for sounds (auto-set based on build platform)
	var FILE_EXT:String;
	
	// Map shortID to full Sound Info as it's on the json node
	var volumes:Map<String,Float>;
	//====================================================;
	
	public function new()
	{
		#if (flash)
			FILE_EXT = FILE_EXT_MP3;
		#else
			FILE_EXT = FILE_EXT_OGG;
		#end
		
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
		{ soundName:soundVolume(float) , soundName2:"soundvolume"(string) }
	   - So you can easily pass a JSON object here
	   - Example: 
			{
				"pl_slide" : "0.4", // Strings will be parsed
				"pl_jump"  : 0.5
			}
	**/
	public function addSoundInfos(node:Dynamic)
	{
		if (node == null) {
			trace("Sound infos is null"); return;
		}
		
		for (f in Reflect.fields(node)) 
		{
			var f = Reflect.field(node, f);
			if(Std.isOfType(f,String))
				volumes.set(f, Std.parseFloat(f));
			else
				volumes.set(f, cast f);
			//#if (neko || hl)
			//volumes.set(f, Reflect.field(node, f));
			//#else
			//volumes.set(f, Std.parseFloat(Reflect.field(node, f)));
			//#end
			//trace("Sound Volume define for", f, Reflect.field(node, f));
		}
		
		#if debug
		var c = Reflect.fields(node).length;
		if (c > 0) 
			trace('::DSound - Predefined volumes for ($c) sounds');
		#end
	}//---------------------------------------------------;
	
	/**
	 * Play a sound. Will search for loaded metadata and will apply volumes.
	 * @param	soundID Asset or Sound ID
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
	 * @param	filename Without extension, must be in "ROOT_SND"
	 * @param	customVolume
	 */
	public inline function play(fileshort:String, customVolume:Float = 1, Looped:Bool = false, AutoDestroy:Bool = true):FlxSound
	{
		return FlxG.sound.play(ROOT_SND + fileshort + FILE_EXT, customVolume, Looped, null, AutoDestroy);
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
