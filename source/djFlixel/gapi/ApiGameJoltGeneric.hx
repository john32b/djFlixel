package djFlixel.gapi;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.addons.api.FlxGameJolt;
import lime.utils.ByteArray;

// --
// -- Gamejolt API
// 

@:file("assets/gamejolt.key") class GamejoltKey extends ByteArray { }

class ApiGameJoltGeneric extends ApiEmpty
{

	// -- Every gamejolt game has an ID number
	static var GAME_ID:Int = 0;
	
	// Ping every 30 seconds
	static inline var PING_FREQUENCY:Float = 30;
	// --
	var timer_ping:FlxTimer = null;
	// Useful to ping with extra
	var gameFocus:Bool = true;
	
	// PARENT VARS:
	// Is the API connected
	// public var isConnected:Bool = false;
	// Gets called when the API initialization is complete
	// public var onConnect:Void->Void = null;	
	//---------------------------------------------------;
	
	// OVERRIDE ON CHILD
	var trophyMap:Map<String,Int>;
	// Keep track of which trophies are already got in the runtime
	var trophyGot:Map<String,Bool>;
	
	//====================================================;
	// FUNCTIONS 
	//====================================================;

	public function new(gameID:Int)
	{ 
		super();
		trace('Info: Creating GameJolt API Handler, GameId = $gameID');
		SERVICE_NAME = "GameJolt";
		GAME_ID = gameID;
		trophyMap = new Map();
		trophyGot = new Map();
		// -- OVERRIDE and populate trophyMap
	}//---------------------------------------------------;
	
	// --
	function getPrivateKey():String
	{
		var bytearray = new GamejoltKey();
		var keystr = bytearray.readUTFBytes( bytearray.length );
		return keystr;
	}//---------------------------------------------------;
	
	// -- Call this once
	//
	override public function connect()
	{
		if (isConnected) return;
		
		#if debug
		FlxGameJolt.verbose = true;
		#end
		FlxGameJolt.init(GAME_ID, getPrivateKey(), true, null, null, _onInit);
	}//---------------------------------------------------;
	
	// --
	// Called when the GameJolt API initializes
	function _onInit(result:Bool)
	{
		if (result)
		{
			trace("Warning: Gamejolt connected");
			// Start a session and start pinging every XX seconds
			FlxGameJolt.openSession(_onOpenSession);
			connectStatus = "ok";
			isConnected = true;
			if (onConnect != null) onConnect();
		}else
		{
			connectStatus = "fail";
			isConnected = false;
			trace("Warning: Gamejolt CANNOT connect");
		}
	}//---------------------------------------------------;
	
	// --
	// Called when the session opens
	function _onOpenSession(map:Map<String,String>)
	{
		timer_ping = new FlxTimer();
		timer_ping.start(PING_FREQUENCY, function(e:FlxTimer) {
				FlxGameJolt.pingSession(gameFocus);
		},0); // note: 0 to loop forever
		
		// On Focus gain and lost
		FlxG.signals.focusGained.add(function() {
			gameFocus = true;
		});
		FlxG.signals.focusLost.add(function() {
			gameFocus = false;
		});
	}//---------------------------------------------------;
		
	// -- 
	// Cleanup
	override public function destroy()
	{
		if (timer_ping != null) {
			timer_ping.destroy();
			timer_ping = null;
		}
		
		trophyGot = null;
		trophyMap = null;
		FlxGameJolt.closeSession();
	}//---------------------------------------------------;
	
	// --
	override public function trophy(trophyID:String)
	{
		if (!isConnected) return;
		
		if (trophyGot.exists(trophyID)) {
			return;
		}
		
		FlxGameJolt.addTrophy(trophyMap.get(trophyID), function(res:Map<String,String>) {
			if (res.get("success") == "true") {
				trophyGot.set(trophyID, true);
			}
		});
	}//---------------------------------------------------;
	
	// -- Either gameover or game complete?
	override public function uploadScores()
	{
		// * OVERRIDE THIS AND PUSH SCORES *
		
		// Make sure the table exists
		
		// e.g.
		// gamejoltScore("1000",1000,null,true);
	}//---------------------------------------------------;
	
	
	function gamejoltScore(Score:String, Sort:Float, ?TableID:Int, AllowGuest:Bool = false, ?GuestName:String):Void
	{
		if (!isConnected) {
			trace("Error: Is not connected to API");
			return;
		}

		FlxGameJolt.addScore(Score, Sort, TableID, AllowGuest, GuestName);
	}//---------------------------------------------------;
	
	override public function getUser():String 
	{
		if (!isConnected) return USERNAME_OFFLINE;
		return FlxGameJolt.username;	
	}//---------------------------------------------------;
}// --