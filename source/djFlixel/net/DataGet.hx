package djFlixel.net;

import flixel.util.typeLimit.OneOfTwo;
import openfl.display.Loader;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import haxe.Json;

/**
 * Load a file into memory
 * can be either [ binary, text, Json ]
 * Can load the file from the NET or LOCALLY
 * ----
 * NEW:
 * - Can load images as well.
 * 
 * WARNING:
 * - .json files filename MUST end with "json"
 */
class DataGet
{
	// --
	public var loader:OneOfTwo<URLLoader,Loader>;
	public var lData:LoaderData;

	// The url to download from. Can be set later
	public var url:String;
	// Called when data is loaded with parameter the Data Loaded
	public var onLoad:Dynamic->Void = null;	
	// Called when error occured, # passthrough for the ldata.onError
	public var onError:Int->Void = null;

	// The data loaded, This is the var to read when loader is loaded
	public var data(default, null):Dynamic;
	public var type(default, null):String = "text";	// binary,text,json,image
	
	// Whether this is loaded or not.
	public var isLoaded(default, null):Bool;
	
	//-- Set to true to force loading a text file as binary
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
		// NEW:
		// - Try guess the type
		
		var _ldatainit = function() {
				lData = new LoaderData(loader);
				lData.onLoad = onContentLoad;
				lData.onError = onError;
		};
		
		var ext = url.substr( -4).toLowerCase();
		
		if ([".png", ".jpg", ".gif"].indexOf(ext) > -1) {
				loader = new Loader();
				type = "image";
				_ldatainit();
				cast(loader, Loader).load(new URLRequest(url));
		}
		else
		{
			// Proceed to load as text
			loader = new URLLoader();
			if (flag_force_binary) {
				type = "binary";
				cast(loader, URLLoader).dataFormat = URLLoaderDataFormat.BINARY;
			}
			else if(ext == "json") // JSON FILES MUST END IN JSON!
			{
				type = "json";
			}else
			{
				type = "text";
			}
			
			_ldatainit();
			cast(loader, URLLoader).load(new URLRequest(url));
		}
	}//---------------------------------------------------;
	
	// --
	// Auto tries to parse as JSON and returns it, 
	// else returns a string.
	private function onContentLoad():Void
	{
		
		switch(type)
		{
			case "image":  data = cast(loader, Loader).content;
			case "binary": data = cast(loader, URLLoader).data;
			case "json":
				try{
					data = haxe.Json.parse(cast(loader, URLLoader).data);
				}catch (e:Dynamic) {
					trace("Error: Could not parse JSON");
					data = null;
				}
			case "text": data = cast(loader, URLLoader).data;
			default:
		}
		
		isLoaded = true;
		
		// loader = null; // I need it.
		if (lData != null && !lData.isAttachedToGetManager) {
			lData = null;
		}
		
		if (onLoad != null) onLoad(data);
	}//---------------------------------------------------;
	
}//-- end --//