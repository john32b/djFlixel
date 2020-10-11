/*******************************************************************************
  Dynamic Assets Helper
  ==========================
 
 - Requires : <haxedef name="DYN_ASSETS"/>  to be set.
 - Accessible from (D.assets)
 
 - This is a helper class useful for debugging
   It keeps a list of path to files that can be reloaded at runtime.
   e.g. Reload some JSON or MAP files to quickly test out new things.
 
 - You can safely use this class to load files on production just make sure to
   remove the "DYN_ASSETS" def and then it will load all the files from the internal assets
   and not seek them externally
 
 - Use Example:
	
	D.assets.DYN_FILES = ['assets\config.json'];
	D.assets.onAssetLoad = ()->{
		REG.json = D.assets.json.get('assets\config.json');
	}
	D.assets.reload( ()->{ new FlxGame(....); } );

	//-> Enable `debug-keys` in D.init() to enable F12 reloading
	
********************************************************************************/
 
 
package djFlixel.core;

import djA.ArrayExecSync;
import djA.Macros;
import openfl.Assets;

@:dce
class Dassets
{
	/** Asset Contents, (asset, content) */
	public var files(default, null):Map<String,String>;
	
	// #USERSET
	// Asset/File List that will be dynamically reloaded in runtime
	// - e.g. "assets/data/map.json
	public var DYN_FILES:Array<String> = [];

	// #USERSET 
	// Gets called whenever it loads the dynamic assets
	public var onAssetLoad:Void->Void;
	
	//====================================================;
	public function new() {}
		
	/**
	 * Resets and Reloads everything in [DYN_FILES] from the start
	 */
	public function reload(?cb:Void->Void):Void
	{
		trace(" = Dynamic Asset Reload :: ");
		
		var _onLoad = ()->{
			if (onAssetLoad != null) onAssetLoad();
			if (cb != null) cb();
		};
		
		if (DYN_FILES.length == 0) {
			trace('Info: No files to load');
			return _onLoad();
		}
		
		files = [];
		
		var AXS = new ArrayExecSync(DYN_FILES);
		AXS.onComplete = _onLoad;
		AXS.onItem = (A)->{
			#if (DYN_ASSETS) // ------------------------
				var get = new djfl.net.DataGet();
				get.url = Macros.getProjectPath() + A; // Assumes A is a real path
				trace("Dynamic Load -->> ", get.url);
				get.onLoad = (g)->{
					trace("[OK]");
					files.set(A, g.data);
					//trace('Loaded file "$A"..',A,g.data);
					AXS.next();
				};
				get.onError = ()->{ 
					trace('Error: Could not handle [${A}] DYNAMICALLY, trying to load from STATIC ASSETS..');
					_staticLoadAsset(A);
					AXS.next();
				};
				get.load();
			#else // Just load the files from the assets
				_staticLoadAsset(A);
				AXS.next();
			#end
		};
		
		AXS.start();
	}//---------------------------------------------------;
	
	
	/**
	 * Dynamically load a file from real path 
	 * - path must be in relation to project path
	 * - This is for loading files outside the main "DYN_FILES"
	 * @param	path Path of file to load e.g. "assets/maps/level1.tmx"
	 * @param	onComplete Called when the file is loaded. String param is the file contents
	 * 
	 */
	public function getTextFile(path:String, onComplete:String->Void)
	{
		#if (DYN_ASSETS)
		trace(' [DYNAMIC_ASSETS] - Loading "$path" as Text...');
		
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
			trace("Info: <DYN_ASSETS> is not set, getting " + path + " from STATIC ASSETS");
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