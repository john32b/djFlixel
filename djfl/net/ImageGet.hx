package djfl.net;

import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.net.URLRequest;

/**
  Load Images from HTTP;
  Supported [ PNG, JPG, GIF ]

  Example:
  
  	var im = new djfl.net.ImageGet(imageURL,(a:ImageGet)->{
			a.data.x = 20; a.data.y = 20;
			addChild(a.data);
		});

 **/

class ImageGet
{
	var obj:Loader;
	// Easy Progress Events:
	public var lData:LoaderInfo2;
	// The url to download from. Can be set later
	public var url:String;
	// Called when data is loaded with parameter the Data Loaded
	public var onLoad:ImageGet->Void = null;	
	// Called when error occured, # passthrough for the ldata.onError
	public var onError:Void->Void = null;
	// Whether this is loaded or not.
	public var isLoaded(default, null):Bool = false;
	// The data loaded, This is the var to read when loader is loaded
	public var data(default, null):DisplayObject;

	//====================================================;
	
	public function new(?_url:String, ?_onLoad:ImageGet->Void, ?_onError:Void->Void)
	{
		url = _url;
		onLoad = _onLoad;
		onError = _onError;
		if (url != null && _onLoad != null) {
			load();
		}
	}//---------------------------------------------------;
	
	/**
		Start loading the image, the URL should be set by now
	**/
	public function load():Void
	{
		#if debug
			if(url==null) throw "No URL set";
		#end

		trace('ImageGet, loading.. "$url"');
		obj = new Loader();
		lData = new LoaderInfo2(obj);
		lData.onLoad = _onLoad;
		lData.onError = onError;
		obj.load(new URLRequest(url));
	}//---------------------------------------------------;
	
	// Auto tries to parse as JSON and returns it, 
	// else returns a string.
	private function _onLoad():Void
	{
		data = obj.content;
		isLoaded = true;
		if (onLoad != null) onLoad(this);
	}//---------------------------------------------------;
	
}//-- end --//