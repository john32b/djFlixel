package djFlixel.tool;

import djFlixel.net.DataGet;
import djFlixel.tool.MacroHelp;
import openfl.Assets;

// Raname to something else, like External File Loader, etc.
class FileParams 
{

	static var DATA_PATH = "assets/data/";
	
	// Map a fileID with fileContents
	// Useful for dynamically reloading maps, etc.
	public static var files:Map<String,String>;
	// Hold the json files
	public static var json:Map<String,Dynamic>;
	
	// Holds all the dynamically loaded map files
	static var filesToLoad:Array<String>;
	// The json file to load
	
	
	//====================================================;
	// FUNCTIONS 
	//====================================================;
	
	// Add files to the queue
	public static function addFile(file:String)
	{
		if (filesToLoad == null) filesToLoad = [];
		filesToLoad.push(file);
	}//---------------------------------------------------;
	
	
	/**
	 * Reload all the queue files
	 * ---- 
	 * @NOTE: inline is VERY IMPORTANT. Prevents bug where the JSON object doesn't work properly.
	 */
	
	inline public static function loadFiles(onLoadComplete:Void->Void)
	{
		files = new Map();
		json = new Map();
		
		if (filesToLoad == null) {
			trace("Warning: No files to load");
			onLoadComplete();
			return;
		}
		
		trace("LOADING EXT FILES");
		trace(filesToLoad);
		
		var ar:ArrayExecSync<String> = new ArrayExecSync(filesToLoad);
		
		ar.queue_complete = onLoadComplete;
		
		ar.queue_action = function(f:String) {
		
			#if (EXTERNAL_LOAD) // ------------------------
				
			trace("+ Files from external sources");
			
			var get:DataGet = new DataGet(MacroHelp.getProjectPath() + DATA_PATH + f, 
				function(loadedData:Dynamic) { // On load
					trace('Loaded file $f..');
					if (Std.is(loadedData, String)) {
						trace('.. as string.');
						files.set(f, loadedData);	
					}else {
						trace('.. as JSON.');
						json.set(f, loadedData);
					}
					ar.next();
				},function(err:Int) { // On error
					trace('Error: Could not read ${f}, skipping.');
					ar.next();
				}
			);
			
			#else // Just load the JSON files from the assets
			
			trace("+ Files from embedded assets");
			
			if (f.substr( -4).toLowerCase() == "json")
			{
				trace('---------- LOADING JSON FILE---------------'); // test
				try{
					json.set(f, haxe.Json.parse(Assets.getText(DATA_PATH + f)));
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
	
	
	
	
}// --