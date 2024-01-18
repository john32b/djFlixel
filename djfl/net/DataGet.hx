package djfl.net;

import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;

/**
	Load TEXT/BINARY data from HTTP
**/
class DataGet
{
	var obj:URLLoader = null;
	// Easy Progress Events:
	public var lData:LoaderInfo2;
	// The url to download from. Can be set later
	public var url:String;
	// Called when data is loaded with parameter the Data Loaded
	public var onLoad:DataGet->Void = null;	
	// Called when error occured, # passthrough for the ldata.onError
	public var onError:Void->Void = null;
	// The data loaded, This is the var to read when loader is loaded
	public var data(default, null):Dynamic;
	// Whether this is loaded or not.
	public var isLoaded(default, null):Bool = false;
	//-- Set to true to force loading a text file as binary
	public var BINARY:Bool = false;
	//====================================================;
	public function new(?_url:String, ?_onLoad:DataGet->Void, ?_onError:Void->Void, ?_forceBin:Bool = false)
	{
		url = _url;
		onLoad = _onLoad;
		onError = _onError;
		BINARY = _forceBin;
		if (url != null && _onLoad != null) {
			load();
		}
	}//---------------------------------------------------;
	
	public function load():Void
	{
		// Proceed to load as text
		obj = new URLLoader();
		if (BINARY) {
			obj.dataFormat = URLLoaderDataFormat.BINARY;
		}
		lData = new LoaderInfo2(obj);
		lData.onLoad = _onLoad;
		lData.onError = onError;
		obj.load(new URLRequest(url));
	}//---------------------------------------------------;
	
	// --
	private function _onLoad():Void
	{
		data = obj.data;
		isLoaded = true;
		if (onLoad != null) onLoad(this);
	}//---------------------------------------------------;
	
}//-- end --//