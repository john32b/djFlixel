/**
	DJFLIXEL Main Static Helper Class
	=================================
	- Provides general purpose tools
	- Acessible globally with (D)
	
	= Usage =
		
		- Call D.init() before creating the FlxGame()
		- Checkout <DSound.hx> on how to init sounds 
		- On DEBUG builds, _debug_keys() is enabled
		
	= Debug keys =
		- `F9` - calls _cycle_filters(), override this to set your own
		- `F12` - resets state and reloads any assets from disk if `HOT_RELOAD` is defined
		- `SHIFT F12` - reset game
		
 *******************************************************************/

package djFlixel;

import djFlixel.core.*;
import djfl.util.BitmapUtil;
import djA.DataT;
import djA.Macros;
import flixel.FlxG;
import openfl.Lib;


class D
{
	/** Defined in djFlixel `haxelib.json` */
	public inline static var DJFLX_VER:String = Macros.getDefine("djFlixel");
	
	/** Init Parameters , you can set your own when you call D.init(..);
	**/
	public static var IP(default, null) = {
		name:"djflixel_app",	// Used for log infos
		version:"0.1",			// Used for log infos
		web:"",					// Custom Use
		// ------
		volume: -1,				// float (0 to 1), if >0 Will set global flixel volume to this 
		fullscreen:false,		// Start fullscreen
		savename:"",			// OPTIONAL - Savegame ID, make sure it is unique among djflixel projects
		init:null				// Void->Void | Will call this onPreGameStart
	};
	
	/** Sound Helpers */
	public static var snd(default, null):Dsound;
	/** Control System */
	public static var ctrl(default, null):Dcontrols;
	/** Save System */
	public static var save(default, null):Dsave;
	/** Asset System */
	public static var assets(default, null):Dassets;
	/** Destroy helper */
	public static var dest(default, null):Ddest;
	/** Text gen */
	public static var text(default, null):Dtext;
	/** Align functions */
	public static var align(default, null):Dalign;
	/** UI functions */
	public static var ui(default, null):Dui;
	/** Bitmap manipulation utilities */
	public static var bmu(default, null):BitmapUtil;
	/** Other GFX utilities (flixel/djflixel) specific */
	public static var gfx(default, null):Dgfxutil;
		
	/** Depends on fullscreen size, how big the window can get in zoom increments */
	public static var MAX_WINDOW_ZOOM(default, null):Int = 1;
	
	/** Called when F9 is pressed on debug mode */
	public static var _cycle_filters:Void->Void;
	
	/** 
	 * Initialize this static class. Call this before creating FlxGame();
	 * @param O You can override fields of `IP` check in code
	 **/
	public static function init(?O:Dynamic)
	{
		if (dest != null) return; // Check if is already inited
			
		DataT.copyFields(O, IP);
		trace('\n:: DjFlixel v$DJFLX_VER\n:: ${IP.name}, ${IP.version}\n:: ----------------------------');
			var c = Lib.current.stage.window.context;
			trace(':: Renderer :', c.type, c.attributes);
		
		dest = new Ddest();
		snd = new Dsound();
		assets = new Dassets();
		text = new Dtext();
		align = new Dalign();
		ui = new Dui();
		bmu = new BitmapUtil();
		gfx = new Dgfxutil();
		
		if (IP.savename != "") {
			save = new Dsave(IP.savename);
		}
		
		FlxG.signals.postStateSwitch.add(onStateSwitch);
		//FlxG.signals.gameResized.add(onResize);
		
		// :: Some code that needs to run after flxgame is created
		FlxG.signals.preGameStart.addOnce( ()-> 
		{
			MAX_WINDOW_ZOOM = Math.floor(Lib.current.stage.fullScreenWidth / FlxG.width) - 1;
			if (IP.volume >= 0) snd.setVolume(null, IP.volume);
			FlxG.mouse.useSystemCursor = true;
			FlxG.fullscreen = IP.fullscreen;
			ctrl = new Dcontrols(); // This needs to init after new FlxGame
			if (IP.init != null) IP.init();
		});
		
		#if (debug)
			// CHANGE: Always add debug keys for debug builds
			trace('Debug : Enabling Debug keys');
			FlxG.signals.postUpdate.add(_debug_keys);
		#end
	}//---------------------------------------------------;
	
	
	// --
	// Gets called right after the new state is created
	static function onStateSwitch()
	{	
		#if debug
		DEBUG_RELOADED = false;
		#end
	}//---------------------------------------------------;

	// --
	static function onResize(x, y)
	{
	}//---------------------------------------------------;
	
	
	/**
	   Set Windowed Scale, automatically disables Fullscreen
	   @param	zoom 1,2,3,4...
	**/
	public static function setWindowed(zoom:Int)
	{
		FlxG.fullscreen = false;
		FlxG.stage.window.width = Math.floor(FlxG.width * zoom);
		FlxG.stage.window.height = Math.floor(FlxG.height * zoom);
		//trace("-- Windowed mode set : ", zoom, FlxG.stage.window.width, FlxG.stage.window.height);
	}//---------------------------------------------------;
	
	
	
	#if (debug)
	
	/** Read this var to check whether the current state was reloaded with F12, useful in some cases */
	public static var DEBUG_RELOADED:Bool = false;
	
	/**
	 * Debug keys, autocalled on update.
	 * F9 : Antialiasing toggle
	 * F12 : Hot Reload declared files and reset state <Dassets.hx>
	 * SHIFT F12 : Reset Game
	 */
	static function _debug_keys()
	{
		#if html5
		if (FlxG.keys.justPressed.DELETE) {
		#else
		if (FlxG.keys.justPressed.F12) {
		#end
			if (FlxG.keys.pressed.SHIFT){
				FlxG.resetGame();
			}else{
				#if HOT_LOAD
				FlxG.signals.preStateSwitch.addOnce( ()->{ DEBUG_RELOADED = true; });
				assets.reload( FlxG.resetState );
				#end
			}
		}
		
		else if (FlxG.keys.justPressed.F9)
		{
			if (_cycle_filters != null) _cycle_filters();
		}
		
	}//---------------------------------------------------;
	
	#end 
	
}// --