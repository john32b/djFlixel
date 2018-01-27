package djFlixel.tool;

import djFlixel.tool.MacroHelp;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

/**
 * Access from <FLS.assets>
 * This is a helper class useful for debugging
 * It keeps a list of path to files that can be reloaded at runtime.
 * e.g. Reload some JSON or MAP files to quickly test out new things.
 * 
 * -- Requires : <haxedef name="EXTERNAL_LOAD"/>  to be set.
 * 
 * You can safely use this class to load files on production just make sure to
 * remove the "EXTERNAL_LOAD" def and then it will load all the files from the internal assets
 * and not seek them externally
 * 
 * -- NOTE : Most of this class is roughly coded, just the json loading is curently working and useful
 * 
 */
class DynAssets
{
	// Text Files, (asset,content)
	public var files(default, null):Map<String,String>;
	
	// JSON Objects, (asset, json object)
	public var json(default, null):Map<String,Dynamic>;
	
	// Images (asset, bitmapdata)
	public var images(default, null):Map<String,BitmapData>;
	
	// Asset/File List that will be dynamically reloaded in runtime
	// Push files here with .add(..)
	var FILE_LIST(default,null):Array<String> = [];
	//====================================================;

	public function new()
	{
	}//---------------------------------------------------;
	
	/**
	 * Add a file to the List, allowing it to be loaded dynamically in runtime
	 * @param	assetPath Be sure the assetPath is clean, meaning the path should exist in a clear folder structure.
	 * 			e.g. "assets/data/map.json"
	 */
	public function add(assetPath:String)
	{
		FILE_LIST.push(assetPath);
	}//---------------------------------------------------;
	
	/**
	 * Resets and Reloads everything in [FILE_LIST] from the start
	 */
	public function loadFiles(onLoadComplete:Void->Void)
	{
		json = new Map();
		files = new Map();
		
		#if debug // Save some memory as Images are only used in debug?
		
			if (images != null) // Try to destroy any images
				for (i in images) {
					i.dispose(); i = null;
				}
			images = new Map();
			
		#end
		
		if (FILE_LIST.length == 0) {
			trace('Info: No files to load');
			onLoadComplete();
			return;
		}

		// Load the asset from static assets
		// WARNING!!! In order for this to work ASSETS must end with filename
		function _staticLoadAsset(asset:String) 
		{
			if ( asset.substr( -4).toLowerCase() == "json" )
			{
				try{
					json.set(asset, haxe.Json.parse(Assets.getText(asset)));
				}catch (e:Dynamic) {
					trace('Error: Could not read ${asset} from Static Assets');
				}
			}else{
				trace('Warning: Dynamically loading asset [$asset] that is not json! Treating as Text!');
				files.set(asset, Assets.getText(asset));
			}
		}//---------------------------------------------------;
		
		// -- Start Processing the files
		var ar:ArrayExecSync<String> = new ArrayExecSync(FILE_LIST);
		ar.queue_complete = onLoadComplete;
		ar.queue_action = function(assetF:String) {
		#if (EXTERNAL_LOAD) // ------------------------
		
		//trace(' - External_load ASSET [$assetF]');
		//trace(' - PATH = ' + Assets.getPath(assetF)); 
		
		// -- NOTE: Assets.getPath() doesn't work in flash, so scrapping this approach..
		
			var get = new djFlixel.net.DataGet();
			get.url = MacroHelp.getProjectPath() + assetF; // Assumes assetF is a real path
			
			// --
			get.onLoad = function(loadedData:Dynamic) {
				var nfo = 'Loaded file $assetF..';
				switch(get.type) {
				case "text":
					trace('$nfo .. as text.');
					files.set(assetF, loadedData);
				case "json":
					if (loadedData == null) {
						trace('$nfo .. ERROR!! Could not Parse, Check for typos.');
					}else {
						trace('$nfo .. as JSON.');
						json.set(assetF, loadedData);
					}
				case "image":
					trace('$nfo .. as image.');
					images.set(assetF, cast(loadedData, Bitmap).bitmapData);
				default : trace('$nfo .. \n WARING: unhandled loader type!');
				}
				ar.next();
			};
			// --
			get.onError = function(err:Int) { 
				trace('Error: Could not handle [${assetF}] DYNAMICALLY, trying to load from STATIC ASSETS..');
				_staticLoadAsset(assetF);
				ar.next();
			};
			// --
			get.startLoading();
							
		#else // Just load the files from the assets
			_staticLoadAsset(assetF);
			ar.next();
		#end
			
		};
		
		ar.start();
	
	}//---------------------------------------------------;
	
	
	/**
	 * Dynamically load a file from real path
	 * 
	 * @param	path Path of file to load e.g. "assets/maps/level1.tmx"
	 * @param	onComplete Called when the file is loaded. String param is the file contents
	 * 
	 */
	public function getFileAsText(path:String, onComplete:String->Void)
	{
		#if (EXTERNAL_LOAD)
		trace(' - Loading Dynamically "$path" as Text...');
		
		var get = new djFlixel.net.DataGet();
			get.url = MacroHelp.getProjectPath() + path;
			get.onLoad = function(loadedData:Dynamic) {
				onComplete(cast loadedData);
			};
			get.onError = function(err:Int) { 
				trace('Error: Could not get path..');
				onComplete(null);
			};
			get.startLoading();
			
		#else
			trace("Info: <EXTERNAL_LOAD> is not set, getting " + path + " from STATIC ASSETS");
			onComplete(Assets.getText(path));
		#end
	}//---------------------------------------------------;
			
	
	
	// -- Put a file to the available file list then callback.
	//  I am using this to load maps, as the code there reads the file list
	public function putTextFile(path:String, onComplete:Void->Void)
	{
		if (files.exists(path)) {
			files.remove(path);
		}
		
		getFileAsText(path, function(s:String) {
			trace(' - File "$path" successfully put to dynamic list');
			files.set(path, s);
			onComplete();
		});
	}//---------------------------------------------------;
	
	
	// --
	#if debug
	// V0.01 Testing out dynamically loading images.
	public function getImage(path:String):FlxGraphicAsset
	{
		#if EXTERNAL_LOAD
		if (images.exists(path)) {
			return(images.get(path));
		}
		#end
		
		return path;
	}//---------------------------------------------------;
	
	#else
	
	// Don't even check on Release.
	inline public function getImage(path:String):String { 
		return path; 
	}//---------------------------------------------------;
	
	#end
}// --