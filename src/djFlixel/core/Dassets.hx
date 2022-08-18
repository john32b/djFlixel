/**
  Dynamic Assets Helper -- HOT LOADING --
  ==========================
 
 - Requires : <haxedef name="HOT_LOAD"/> to be set.
 - Accessible from (D.assets)
 
 - This is a helper class useful for debugging
   It keeps a list of path to files that can be reloaded at runtime (hotloaded)
	e.g. Reload some JSON or MAP files to quickly test out new things
 
 - Changed in V0.5 : Managing the HotLoaded files is now more manual
	It is advised you handle the code with preprocessors and leave
	the final build loading from FlxAssets normally
   
 - Example:
	
		// Declare which files are to be hotloaded
	D.assets.HOT_LOAD = ['assets\config.json']
	
		// Whenever you press [F12] and the state resets, this get auto called
		// you can manage your stuff here.
	D.assets.onLoad = ()->{
		REG.json = D.assets.files.get('assets\config.json');
	}
	
********************************************************************************/
 

// ::TODO. Make it ERROR when not HOT_LOAD and loading from this
 
package djFlixel.core;

import djA.ArrayExecSync;
import djA.Macros;
import openfl.Assets;

@:dce
class Dassets
{
	/** Hotloaded assets (assetID, content) 
	 *  Read this after a hotload to get data
	 */
	public var files(default, null):Map<String,String>;
	
	// #USERSET
	// Asset/File List that will be dynamically reloaded at runtime
	// - e.g. "assets/data/map.json
	public var HOT_LOAD:Array<String> = [];

	// #USERSET 
	// Gets called whenever it loads all of the HOT_LOAD[] assets
	public var onLoad:Void->Void;
	
	//====================================================;
	public function new() {}
		
	
	/**
	   Load the HOT_LOAD files immediately
	   from Static assets
	**/
	public function loadNow()
	{
		files = [];
		for (f in HOT_LOAD) _staticLoadAsset(f);
		if (onLoad != null) onLoad();
	}//---------------------------------------------------;
	
	
	/**
	 * Resets and Reloads everything in [HOT_LOAD] from the start
	 */
	public function reload(?cb:Void->Void):Void
	{
		trace(" = HOT_LOAD :: reload() ");
		
		files = [];
		
		var _onLoad = ()->{
			trace('HOTLOAD: Loaded :', HOT_LOAD.length);
			if (onLoad != null) onLoad();
			if (cb != null) cb();
		};
		
		ArrayExecSync.run(HOT_LOAD, (it, next)->{
			if (it == null) return _onLoad();
			
			var get = new djfl.net.DataGet();
				get.url = Macros.getProjectPath() + it; // Assumes A is a real path
				trace(" Loading :: ", get.url);
				get.onLoad = (g)->{
					trace("[OK]");
					files.set(it, g.data);
					next();
				};
				get.onError = ()->{ 
					trace('Error: Could not hotload [${it}], trying to load from STATIC ASSETS..');
					_staticLoadAsset(it);
					next();
				};
				get.load();
		});
	}//---------------------------------------------------;
	
	
	/**
	 * Dynamically load a file from real path 
	 * - path must be in relation to project path
	 * - This is for loading files outside the main "HOT_LOAD"
	 * @param	path Path of file to load e.g. "assets/maps/level1.tmx"
	 * @param	onComplete Called when the file is loaded. String param is the file contents
	 * 
	 */
	public function getTextFile(path:String, onComplete:String->Void)
	{
		#if (HOT_LOAD)
		trace(' [HOT_LOAD] - Loading "$path" as Text...');
		
		var get = new djfl.net.DataGet();
			get.url = Macros.getProjectPath() + path;
			get.onLoad = (g)->{
				onComplete(cast g.data);
			};
			get.onError = ()-> { 
				trace('Error: Could not get path..');
				onComplete(null);
			};
			get.load();
			
		#else
			trace("Info: <HOT_LOAD> is not set, getting " + path + " from STATIC ASSETS");
			onComplete(Assets.getText(path));
		#end
	}//---------------------------------------------------;
		
	// Load the asset from static assets
	// WARNING!!! In order for this to work properly ASSETS must end with filename
	function _staticLoadAsset(asset:String) 
	{
		if (!Assets.exists(asset)) {
			trace('Warning: Cannot load "{$asset}"');
			return;
		}
		
		files.set(asset, Assets.getText(asset));
	}//---------------------------------------------------;
	
}// --