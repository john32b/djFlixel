package djFlixel.net;

import flixel.util.typeLimit.OneOfTwo;
import openfl.display.Loader;
import openfl.events.IEventDispatcher;
import openfl.net.URLLoader;

import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;


/**
 * HELPER class for URLLoaders or Loaders
 * Does not actually load anything, but provides
 * a quick set of functions for events.
 *
 * @usage:
 * 			
 *		loader = new URlLoader();
 * 		loaderData = new LoaderData(loader);
 * 		loaderData.onLoad = function(_){ .. }
 * 		loaderData.onError = function(_) { .. }
 * 		loader.load( new URLRequest(sourceURL) );
 * 
 * @callbacks
 * 
 * 		onLoad();
 * 		onError(ID:int);
 * 		onProgress(percent:Int);
 * 
 */
class LoaderData
{
	// -- User Set Callbacks
	
	// onLoad Returns the event object target.
	public var onLoad:Void->Void = null;
	public var onError:Int->Void = null;
	public var onProgress:Int->Void = null;
	
	public var isLoaded(default, null):Bool;
	
	// Is it currently downloading
	//public var isWorking(default, null):Bool; //it's always working???????
	
	// Percent loaded [0-100]
	public var percent(default,null):Int;
	public var bytesTotal(default,null):Int;
	public var bytesLoaded(default, null):Int;
	
	// Just in case have a ID system.
	public var ID:Int = 0;
	
	// The type of data that is to be loaded?
	//public var type:String; //unused

	// Useful to know.
	public var isAttachedToGetManager:Bool = false;

	// Point to the object that will be listened to.
	var eventObj:IEventDispatcher;
	//---------------------------------------------------;
	
	// --
	public function new(par:OneOfTwo<URLLoader,Loader>) 
	{
		// Loader is for SWF and Images
		if (Std.is(par, Loader))
		{
			eventObj = cast(par, Loader).contentLoaderInfo;
			attachEvents();
		}else
		// URLLoader is for text and binaryFiles
		if (Std.is(par, URLLoader))
		{
			eventObj = cast(par, URLLoader);
			attachEvents();
		}
		
		isLoaded = false;
	
		percent = 0;
		bytesLoaded = 0;
		bytesTotal = 0;
	}//---------------------------------------------------;

	function kill_listeners():Void
	{
		eventObj.removeEventListener(Event.COMPLETE, _listen_complete);
		eventObj.removeEventListener(ProgressEvent.PROGRESS, _listen_progress);
		eventObj.removeEventListener(IOErrorEvent.IO_ERROR, _listen_ioError);
	}//---------------------------------------------------;
	
	public function attachEvents():Void
	{
		eventObj.addEventListener(Event.COMPLETE, _listen_complete);
		eventObj.addEventListener(ProgressEvent.PROGRESS, _listen_progress);
		eventObj.addEventListener(IOErrorEvent.IO_ERROR, _listen_ioError);
	}//---------------------------------------------------;
	
	function _listen_complete(e:Event):Void
	{
		//trace('LoaderData (ID=$ID) load complete.', 0);
		isLoaded = true;
		percent = 100;
		bytesLoaded = bytesTotal;
		kill_listeners();
		if (onLoad != null) onLoad();
	}//---------------------------------------------------;
	function _listen_progress(e:ProgressEvent):Void
	{
		bytesLoaded = Std.int(e.bytesLoaded);
		bytesTotal = Std.int(e.bytesTotal);
		percent = Math.ceil( ((bytesLoaded / bytesTotal) * 100) );
		//trace("Percent Loaded = " + percent, 0); //Don't spam the logger
		if (onProgress != null) onProgress(percent);
	}//---------------------------------------------------;
	function _listen_ioError(e:IOErrorEvent):Void
	{
		kill_listeners();
		if (onError != null) onError(ID);
	}//---------------------------------------------------;
	
}//-- end --//