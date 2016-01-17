package djFlixel.gapi;
import flixel.util.FlxTimer;

// -- 
// This class can be overriden to specify a generic API.
// If no APIs are used, then this is used as a blank
class ApiEmpty
{
	// How to call the user with tha API is in offline mode
	var USERNAME_OFFLINE:String = "User";
	// Maximum time to wait until connect() and fetchSave() delay, to fail.
	var CONNECT_TIMEOUT:Float = 4;
	// The service it is connected
	public var SERVICE_NAME(default,null):String = "Offline";
	//---------------------------------------------------;
	// Is the API connected
	public var isConnected:Bool;
	// Connecting to the API status - "offline", "working", "ok", "fail"
	public var connectStatus(default, null):String;
	// Loading the game status - "offline", 'empty','working','ok','fail';
	public var loadStatus(default, null):String; 
	// If exists, gets called when the save file is loaded.
	// NOTE: CHECK THE LOAD STATUS!!!!!
	var onLoadgame:Void->Void; 
	// Gets called when the API initialization is complete
	var onConnect:Void->Void = null;
	// Keep the connection timer.
	var connectTimer:FlxTimer;
	//---------------------------------------------------;
	public function new() 
	{ 
		connectStatus = "offline";
		loadStatus = "offline";
		isConnected = false;
	}//---------------------------------------------------;
	public function getUser():String 
	{ 
		return USERNAME_OFFLINE;
	}//---------------------------------------------------;
	public function connect() 
	{ 
		isConnected = false;
		connectStatus = "fail";	// Simulate a fail
		loadStatus = "fail";	// Simulate a fail
		if (onConnect != null) {
			onConnect();
		}
	}//---------------------------------------------------;
	public function destroy() { }
	public function trophy(trophyID:String) { }
	public function uploadScores() { }	
	public function save(data:String) { }
	public function getSaveData():String { return ""; }	
	//--
	// If it's connected, it's called now,
	// else it's called upon connection ( or failure )
	public function callOnConnect(fn:Void->Void)
	{
		if (connectStatus == "working" || connectStatus == "offline") {
			// It is going to callback later
			onConnect = fn;
		}else {
			// It is either "ok" or "fail"
			fn();
		}
	}//---------------------------------------------------;
	// --
	// Called now or later, upon loading the game save
	public function callOnLoadgame(fn:Void->Void)
	{
		if (loadStatus == "offline" || loadStatus == "waiting") {
			// It is going to callback later
			onLoadgame = fn;
		}else {
			// it is either "ok" or "empty"
			fn();
		}
	}//---------------------------------------------------;
}// --