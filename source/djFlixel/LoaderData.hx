package djFlixel;

import flash.display.Loader;
import flash.events.IEventDispatcher;
import flash.net.URLLoader;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
/**
 * DATA only, 
 * helper for multiLoader class
 * ...
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
	private var eventObj:IEventDispatcher;
	//---------------------------------------------------;
	
	public function new(par:Dynamic) 
	{
		if (Std.is(par, Loader))
		{
			eventObj = cast(par, Loader).contentLoaderInfo;
			attachEvents();
		}else
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

	private function kill_listeners():Void
	{
		// trace("Events killed", 0);
		eventObj.removeEventListener(Event.COMPLETE, _listen_complete);
		eventObj.removeEventListener(ProgressEvent.PROGRESS, _listen_progress);
		eventObj.removeEventListener(IOErrorEvent.IO_ERROR, _listen_ioError);
	}//---------------------------------------------------;
	
	public function attachEvents():Void
	{
		// trace("Events created", 0);
		eventObj.addEventListener(Event.COMPLETE, _listen_complete);
		eventObj.addEventListener(ProgressEvent.PROGRESS, _listen_progress);
		eventObj.addEventListener(IOErrorEvent.IO_ERROR, _listen_ioError);
	}//---------------------------------------------------;
	
	private function _listen_complete(e:Event):Void
	{
		//trace('LoaderData (ID=$ID) load complete.', 0);
		isLoaded = true;
		percent = 100;
		bytesLoaded = bytesTotal;
		kill_listeners();
		if (onLoad != null) onLoad();
	}//---------------------------------------------------;
	private function _listen_progress(e:ProgressEvent):Void
	{
		bytesLoaded = Std.int(e.bytesLoaded);
		bytesTotal = Std.int(e.bytesTotal);
		percent = Math.ceil( ((bytesLoaded / bytesTotal) * 100) );
		//trace("Percent Loaded = " + percent, 0); //Don't spam the logger
		if (onProgress != null) onProgress(percent);
	}//---------------------------------------------------;
	private function _listen_ioError(e:IOErrorEvent):Void
	{
		// trace("Loader " + e.text, 3);
		kill_listeners();
		if (onError != null) onError(ID);
	}//---------------------------------------------------;
	
}//-- end --//