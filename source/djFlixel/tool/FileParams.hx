package djFlixel.tool;

import djFlixel.net.DataGet;
import djFlixel.tool.MacroHelp;
import haxe.Json;
import openfl.Assets;

class FileParams
{
	public static var JSON:Dynamic;
	
	/**
	 * 
	 * @param file Path in relation to the project. e.g 'assets/data/one.json'
	 * @param onLoadComplete Gets called when the loading is complete
	 */
	public static function loadSettings(file:String,onLoadComplete:Void->Void):Void
	{
		var PARAMS_FILE_PATH = "assets/data/" + file;
		
		JSON = null;
		
		trace("Loading parameters from " + PARAMS_FILE_PATH);
		
		// Quick function called when can't read parameters file
		var _paramsLoadError = function() {
			trace('Error: JSON, Could not read ${PARAMS_FILE_PATH}, skipping.');
			JSON = null;
			onLoadComplete();
		};
		
		
		#if EXTERNAL_LOAD
			// Load the parameters at runtime
			var get:DataGet = new DataGet(MacroHelp.getProjectPath() + PARAMS_FILE_PATH, 
				function(loadedData:Dynamic) { // On load
					JSON = loadedData;
					onLoadComplete();
				},function(err:Int) { // On error
					_paramsLoadError();
				}
			);
		#else
			// Load the embedded parameters file
			try {
				JSON = Json.parse(Assets.getText(PARAMS_FILE_PATH));
				onLoadComplete();
			}catch (e:Dynamic) {
				_paramsLoadError();
			}
		#end	
	}//---------------------------------------------------;
	
}// --