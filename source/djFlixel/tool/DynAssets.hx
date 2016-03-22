package djFlixel.tool;

import djFlixel.net.DataGet;
import djFlixel.tool.MacroHelp;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

class DynAssets
{
	static var ASSETS_PATH = "assets/";
	
	// Map a fileID with fileContents
	// Useful for dynamically reloading maps, etc.
	public static var files:Map<String,String>;
	// Hold the json files
	public static var json:Map<String,Dynamic>;
	// Hold images
	public static var images:Map<String,BitmapData>;
	
	// Holds all the dynamically loaded map files
	// #Set this directly
	public static var filesToLoad:Array<String>;
	
	//====================================================;
	// FUNCTIONS 
	//====================================================;

	
	/**
	 * Reload all the queue files
	 * ---- 
	 * @NOTE: inline is VERY IMPORTANT. Prevents bug where the JSON object doesn't work properly.
	 */
	
	inline public static function loadFiles(onLoadComplete:Void->Void)
	{
		json = new Map();
		files = new Map();
		
		#if debug // save some memory?
			images = new Map();
		#end
		
		if (filesToLoad == null) {
			trace("Warning: No files to load");
			onLoadComplete();
			return;
		}
		
		var ar:ArrayExecSync<String> = new ArrayExecSync(filesToLoad);
		
		ar.queue_complete = onLoadComplete;
		
		ar.queue_action = function(f:String) {
		
			#if (EXTERNAL_LOAD) // ------------------------
				
			var get:DataGet = new DataGet();
			get.url = MacroHelp.getProjectPath() + ASSETS_PATH + f;
			get.onLoad = function(loadedData:Dynamic) {
				trace('Loaded file $f..');
				switch(get.type) {
				case "text":
					trace('.. as text.');
					files.set(f, loadedData);
				case "json":
					trace('.. as JSON.');
					json.set(f, loadedData);
				case "image":
					trace('.. as image.');
					images.set(ASSETS_PATH + f, cast(loadedData, Bitmap).bitmapData);
				default : trace('.. as text\n WARING: unhandled loader type!');
				}
				ar.next();
			};
			get.onError = function(err:Int) { 
				trace('Error: Could not read ${f}, skipping.');
				ar.next();
			};
			get.startLoading();
							
			#else // Just load the JSON files from the assets
			
			if (f.substr( -4).toLowerCase() == "json")
			{
				trace("- Getting JsonFile from embedded assets");
				try{
					json.set(f, haxe.Json.parse(Assets.getText(ASSETS_PATH + f)));
				}catch (e:Dynamic) {
					trace('Error: Could not read ${f}, skipping.');
					ar.next();
				}
			}
			
			ar.next();

			#end
			
		};
		
		ar.start();
	
	}//---------------------------------------------------;
	
	
	// --
	#if debug
	public static function getImage(path:String):FlxGraphicAsset
	{
		#if EXTERNAL_LOAD
		if (images.exists(path)) {
			return(images.get(path));
		}else {
			return path;
		}
		#else
			return path;
		#end
	}//---------------------------------------------------;
	#else
	
	// Don't even check on Release.
	inline public static function getImage(path:String):String { 
		return path; 
	}//---------------------------------------------------;
	
	#end
}// --