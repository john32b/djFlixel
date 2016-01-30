package djFlixel.net;

import openfl.display.Loader;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import haxe.Json;

/**
 * Load a file into memory
 * can be either [ binary, text, Json ]
 * Can load the file from the NET or LOCALLY
 */
class DataGet
{
	public var loader:URLLoader;
	public var lData:LoaderData;

	// The url to download from. Can be set later
	public var url:String;
	// Called when data is loaded with parameter the Data Loaded
	public var onLoad:Dynamic->Void = null;	
	// Called when error occured, # passthrough for the ldata.onError
	public var onError:Int->Void = null;

	// The data loaded
	public var data(default, null):Dynamic;
	public var type(default, null):String = "text";	// binary,text,json
	
	// Whether this is loaded or not.
	public var isLoaded(default, null):Bool;
	
	//-- Set to true to force loading file as binary, 
	//   ( images, sounds, etc )
	public var flag_force_binary:Bool = false;
	
	//====================================================;
	// FUNCTIONS 
	//====================================================;
	
	public function new(?_url:String, ?_onLoad:Dynamic->Void, ?_onError:Int->Void)
	{
		url = _url;
		onLoad = _onLoad;
		onError = _onError;
		
		if (url != null && _onLoad != null) {
			startLoading();
		}
	}//---------------------------------------------------;
	
	// --
	public function startLoading():Void
	{
		// trace('Info: Loading from $url');
		
		loader = new URLLoader();
		if (flag_force_binary) {
			
			//trace("Info: Loading as BINARY");
			loader.dataFormat = URLLoaderDataFormat.BINARY;
		}
		
		/// Should I check for the other dataformats?
		
		lData = new LoaderData(loader);
		lData.onLoad = onContentLoad;
		lData.onError = onError;
		
		loader.load(new URLRequest(url));

	}//---------------------------------------------------;
	
	// --
	// Auto tries to parse as JSON and returns it, 
	// else returns a string.
	private function onContentLoad():Void
	{
		if (flag_force_binary)
		{
			data = loader.data;
			type = "binary";
		}
		else // If it's text type
		{
			try {
				//- Json File
				data = haxe.Json.parse(loader.data);
				type = "json";
			}catch (e:Dynamic)
			{
				//- Normal File
				data = loader.data;
				type = "text";
			}
		}
		
		isLoaded = true;
		
		// loader = null; // I need it.
		if (lData != null && !lData.isAttachedToGetManager) {
			lData = null;
		}
		
		if (onLoad != null) onLoad(data);
	}//---------------------------------------------------;
	
}//-- end --//