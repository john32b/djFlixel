package djFlixel;

import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import haxe.Json;

/**
 * Load a JSON file
 * ................
 */
class DataGet
{
	public var loader:URLLoader;
	public var lData:LoaderData;

	var sourceURL:String;

	// Store the DataGet object here:
	public var data(default, null):Dynamic;
	public var type(default, null):String = "text";
	
	// User callback, returns loaded data on load
	public var onLoad:Dynamic->Void = null;
	public var onError:Int->Void = null;
	public var isLoaded(default, null):Bool;
	
	// Set to true to force loading file as binary, 
	// useful for loading sounds.
	public var flag_force_binary:Bool = false;
	
	// ===================================================;
	public function new(?url:String, ?callback:Dynamic->Void, ?_error:Int->Void) 
	{
		sourceURL = url;
		onLoad = callback;
		onError = _error;
		if (sourceURL != null) startLoading();
		
	}//---------------------------------------------------;
	
	// --
	public function startLoading():Void
	{
		// trace('Info: Loading from $sourceURL');
		
		loader = new URLLoader();
		if (flag_force_binary) 
		{
			trace("Loading as BINARY");
			loader.dataFormat = URLLoaderDataFormat.BINARY;
		}
		
		lData = new LoaderData(loader);
		lData.onLoad = onContentLoad;
		lData.onError = onError;
		
		loader.load(new URLRequest(sourceURL));
		
	}//---------------------------------------------------;
	
	// --
	// Auto tries to parse as JSON, else return a string.
	private function onContentLoad():Void
	{
		if (flag_force_binary)
		{
			data = loader.data;
			type = "binary";
		}
		else //If it's text type
		{
			try {
				//Json File
				data = Json.parse(loader.data);
				type = "json";
			}catch (e:Dynamic)
			{
				//Normal File
				data = loader.data;
				type = "text";
			}
		}
		
		isLoaded = true;
		
		//loader = null; // I need it.
		if (lData != null)
		if (!lData.isAttachedToGetManager) lData = null;
		
		if (onLoad != null) onLoad(data);
	}//---------------------------------------------------;
	
}//-- end --//