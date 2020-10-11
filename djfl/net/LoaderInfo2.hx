package djfl.net;

import openfl.display.Loader;
import openfl.events.HTTPStatusEvent;
import openfl.events.IEventDispatcher;
import openfl.net.URLLoader;

import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;


/**
 * LoaderInfo2 (great name)
 * 
 * Generic wrapper for URLLoader and LoaderInfo objects
 * Automatically creates events and attaches simple callback functions
 *
 * usage:
 * 			
 *		loader = new URlLoader();
 * 		loaderData = new LoaderInfo2(loader);
 * 		loaderData.onLoad = function(_){ .. }
 * 		loaderData.onError = function(_) { .. }
 * 		loader.load( new URLRequest(sourceURL) );
 * 
 * callbacks
 * 
 * 		onLoad();
 * 		onError(ID:int);
 * 		onProgress(percent:Int);
 * 
 * example:
 * 
			var dg = new DataGet(IMAGEURL, function(a){
					addChild(a.getLoader());
				});
 * 
 */
class LoaderInfo2
{
	// onLoad Returns the event object target.
	public var onLoad:Void->Void = null;
	public var onError:Void->Void = null;
	public var onProgress:Int->Void = null;
	public var isLoaded(default, null):Bool;
	
	// Percent loaded [0-100]
	public var percent(default,null):Int;
	public var bytesTotal(default,null):Int;
	public var bytesLoaded(default, null):Int;
	
	// Just in case have a ID system.
	static var UID_GEN:Int = 0;
	public var ID(default,null):Int = 0;
	
	// Will be set once loaded/error
	// public var HTTP_STATUS(default,null):Int = -1;
	
	// Pointer to the event object where events will be fired from
	var info:IEventDispatcher;
	//---------------------------------------------------;
	
	/**
		Progress Report that can be used in 
		a [loader] and a [URLLoader]
		use only ONE!
	**/
	public function new(?inp1:URLLoader,?inp2:Loader)
	{
		ID = ++UID_GEN;
		
		if(inp1!=null)
		{
			info = cast (inp1, URLLoader);
		}else
		{
			if(inp2!=null)
			{
				info = cast (inp2, Loader).contentLoaderInfo;
			}else
			{
				throw "No Loader Set";
			}
		}

		isLoaded = false;	
		percent = 0;
		bytesLoaded = 0;
		bytesTotal = 0;

		info.addEventListener(Event.COMPLETE, _onComplete);
		info.addEventListener(ProgressEvent.PROGRESS, _onProgress);
		info.addEventListener(IOErrorEvent.IO_ERROR, _onError);
		//info.addEventListener(HTTPStatusEvent.HTTP_STATUS, _listen_http);
	}//---------------------------------------------------;

	function kill_listeners():Void
	{
		info.removeEventListener(Event.COMPLETE, _onComplete);
		info.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
		info.removeEventListener(IOErrorEvent.IO_ERROR, _onError);
		//info.removeEventListener(HTTPStatusEvent.HTTP_STATUS, _listen_http);
	}//---------------------------------------------------;
	
	//function _listen_http(e:HTTPStatusEvent)
	//{
		//HTTP_STATUS = e.status;
	//}//---------------------------------------------------;
	
	function _onComplete(e:Event):Void
	{
		isLoaded = true;
		percent = 100;
		bytesLoaded = bytesTotal;
		
		kill_listeners();
		if (onLoad != null) onLoad();
	}//---------------------------------------------------;
	function _onProgress(e:ProgressEvent):Void
	{
		bytesLoaded = Std.int(e.bytesLoaded);
		bytesTotal = Std.int(e.bytesTotal);
		percent = Math.ceil( ((bytesLoaded / bytesTotal) * 100) );
		if (onProgress != null) onProgress(percent);
	}//---------------------------------------------------;
	function _onError(e:IOErrorEvent):Void
	{
		kill_listeners();
		if (onError != null) onError();
	}//---------------------------------------------------;
	
}//-- end --//