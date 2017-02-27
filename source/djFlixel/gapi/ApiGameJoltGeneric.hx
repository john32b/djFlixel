package djFlixel.gapi;

import djFlixel.gapi.ApiOffline.ScoreApi;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flash.utils.ByteArray;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import haxe.Json;
import haxe.crypto.Md5;
import djFlixel.gapi.ApiOffline.Trophy;

#if flash
import flash.Lib;
#end
/**
 * GameJolt API
 * ------------
 * 
 *  + Automatically starts a session when connected
 * 
 * # HOW TO USE:
 * --------------
 * 
 * 	. Put the key on "assets/gamejolt.key"
 *  . Extend this class and on the constructor call super() with the gameID
 * 
 * 
 */
@:file("assets/gamejolt.key") class GamejoltKey extends ByteArray { }
class ApiGameJoltGeneric extends ApiOffline
{
	// -- Every gamejolt game has an ID number
	static var GAME_ID:Int = 0;
	// Ping every 30 seconds
	static inline var PING_FREQUENCY:Float = 30;
	// Timer to Ping the Session
	var timer_ping:FlxTimer = null;
	// -- Set on extended
	var scoreBoardID:Int = -1;
	
	//====================================================;
	// FUNCTIONS 
	//====================================================;
	/**
	 * Create a game on GameJolt and get the id from there
	 * @param	gameID looks like this "20657"
	 */
	public function new(gameID:Int)
	{ 
		super();
		trace('Info: Creating GameJolt API Handler, GameId = $gameID');
		SERVICE_NAME = "GameJolt";
		GAME_ID = gameID;
		
		flag_https = FlxG.stage.root.loaderInfo.loaderURL.indexOf("https:") == 0;
		verbose('Using HTTPS : $flag_https');
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
		_connect(getPrivateKey(), _onApiConnected);
	}//---------------------------------------------------;
	
	/**
	 * Auto called when the api connects
	 */
	function _onApiConnected(d:Dynamic)
	{
		if (d!=null)
		{
			trace("Gamejolt connect - OK -");
			// Start a session and start pinging every XX seconds
			openSession(_onOpenSession);
			connectStatus = "ok";
			isConnected = true;
		}else
		{
			trace("Gamejolt connect - ERROR - ");
			verbose(d);
			connectStatus = "fail";
			isConnected = false;
		}
		
		if (onConnect != null) onConnect();
	}//---------------------------------------------------;
	
	// --
	// Called when the session opens
	@:access(flixel.FlxGame._lostFocus)
	function _onOpenSession(_)
	{
		verbose("Openning Session");
		timer_ping = new FlxTimer();
		timer_ping.start(PING_FREQUENCY, function(e:FlxTimer) {
				pingSession(!FlxG.game._lostFocus);
		},0); // note: 0 to loop forever
		
	}//---------------------------------------------------;
		
	// -- 
	// Cleanup
	override public function destroy()
	{
		if (timer_ping != null) {
			timer_ping.destroy();
			timer_ping = null;
		}
		closeSession(null);
	}//---------------------------------------------------;

	// --
	override function _onTrophyUnlock(tr:Trophy) 
	{
		_addTrophy(tr.uid, function(_) {
			trace('Info: Trophy ${tr.name} pushed successfully');
		});
	}//---------------------------------------------------;
	
	/**
	 * Returns the username if connected
	 * @return
	 */
	override public function getUser():String 
	{
		if (!isConnected) return "Offline";

		if (userLoggedIn) 
			return _userName;
		else 
			return "Guest";
	}//---------------------------------------------------;
	
	
	//====================================================;
	// SCORING SYSTEM 
	//====================================================;
	/**
	 * Populates the scores array 
	 */
	override public function fetchScores(callback:Void->Void = null) 
	{
		if (!isConnected) {
			if (callback != null) callback();
			return;
		}
		
		// Everyone can get scores
		_fetchScores(10, function(o:Dynamic) {
			if (o != null)
			if (o.success == "true") {
				trace("-- Scores loaded --");
				scores = [];
				var SCORES:Array<Dynamic> = o.scores;
				var cc:Int = 0;
				for (sc in SCORES) 
				{
					var ss:ScoreApi = { 	
						rank:(++cc), 
						user:sc.user, 
						score_str:sc.score, 
						score_num:Std.parseFloat(sc.sort) 
					};
					scores.push(ss);
				}
				verbose(scores);
			}else {
				trace("-- Failed to get scores --");
				// Note : Don't zero out the leaderboards! use any previous values
			}
			if (callback != null) callback();
		});
	}//---------------------------------------------------;
	/**
	 * Uploads score to the scoreboard. You should set the scoreboard ID at api creation 
	 * @param	score
	 * @param	callback
	 */
	override public function uploadScore(score:Int, ?callback:Void->Void = null) 
	{
		addScore('$score', score, scoreBoardID, null, function(_) {
			if (callback != null) callback();
		});
	}//---------------------------------------------------;
	
	
	//====================================================;
	// RE-WRITE THE GAMEJOLT API
	// -- it's a mini verion of flixel.tools.FlxGameJolt.hx
	// -- but with json returns instead.
	//====================================================;
	static inline var URL_API:String = "gamejolt.com/api/game/v1/";
	static inline var RETURN_TYPE:String = "?format=json";
	static inline var URL_GAME_ID:String = "&game_id=";
	static inline var URL_USER_NAME:String = "&username=";
	static inline var URL_USER_TOKEN:String = "&user_token=";
	
	var flag_https:Bool;
	// -------
	var _verbose:Bool = true; // set to true to debug URL requests and results
	// -------
	var _privateKey:String = "";
	var _userName:String = "";
	var _userToken:String = "";
	// -------
	var _idURL:String; // Hold a commonly used STRING 
	var _loader:URLLoader;
	var _loaderCallback:Dynamic->Void = null;
	//---------------------------------------------------;
	
	/**
	 * Set the connect to true ONLY IF the user is registered
	 */
	function _connect(PrivateKey:String,?callback_:Dynamic)
	{
		if (isConnected) return;
		verbose("Requesting Connect");
		_privateKey = PrivateKey;
		identifyUser(callback_);
	}//---------------------------------------------------;
	
	/**
	 * Currently only works for ONLINE FLASH
	 * @param	Callback
	 */
	function identifyUser(?Callback:Dynamic):Void
	{				
		#if flash
		var parameters = Lib.current.loaderInfo.parameters;
		if (parameters.gjapi_username != null) {
			_userName = parameters.gjapi_username;
		}
		if (parameters.gjapi_token != null) {
			_userToken = parameters.gjapi_token;
		}
		#else
			throw "Need to get username and token"; // TODO
		#end
		
		verbose('Gamejolt: Getting User');
		verbose('_username : $_userName | token:$_userToken');
	
		// Only send initialization request to GameJolt if user name and token were found or passed.
		_idURL = URL_GAME_ID + GAME_ID + URL_USER_NAME + _userName + URL_USER_TOKEN + _userToken;
		sendLoaderRequest("users/auth/" + RETURN_TYPE + _idURL, function(o:Dynamic) {
			if (o != null) {
				if (o.success == "true") {
					userLoggedIn = true;
				}else {
					userLoggedIn = false;
				}
				verbose('User Logged in : $userLoggedIn');
			}
			if (Callback != null) Callback(o);
		});
	}//---------------------------------------------------;
	
	/**
	 * 
	 * @param	URLString The portion after the URL_API
	 * @param	Callback
	 */
	function sendLoaderRequest(URLString:String, ?Callback:Dynamic):Void
	{
		URLString = URL_API + URLString;
		var finalURL = (flag_https ? "https://" : "http://") + URLString + 
						"&signature=" + encryptURL("http://" + URLString);
		
		var request:URLRequest = new URLRequest(finalURL);
		request.method = URLRequestMethod.POST;
		
		_loaderCallback = Callback;
		
		if (_loader == null)
			_loader = new URLLoader();
		
		verbose("API SEND : " + request.url);
		
		_loader.addEventListener(Event.COMPLETE, _onURLData);
		_loader.load(request);
	}//---------------------------------------------------;
	function encryptURL(Url:String):String
	{
		return Md5.encode(Url + _privateKey);
	}//---------------------------------------------------;
	function _onURLData(e:Event)
	{
		_loader.removeEventListener(Event.COMPLETE, _onURLData);
		if (Std.string(e.currentTarget.data) == "")
		{
			verbose("Gamejolt: Received no data back. This is probably because one of the values it was passed is wrong.");
			if (_loaderCallback != null) _loaderCallback(null); // Push that I got NO DATA
			return;
		}
		
		var obj:Dynamic = Json.parse(e.currentTarget.data);
	
		verbose(obj.response);
		
		if (_loaderCallback != null) _loaderCallback(obj.response);
	}//---------------------------------------------------;
	
	function _fetchScores(?Limit:Int, ?Callback:Dynamic):Void
	{
		var tempURL = "scores/" + RETURN_TYPE + URL_GAME_ID + GAME_ID;
		
		if (Limit == null)
		{
			tempURL += "&limit=10";
		}
		else
		{
			tempURL += "&limit=" + Std.string(Limit);
		}
		
		sendLoaderRequest(tempURL, Callback);
	}//---------------------------------------------------;
	
	// --
	function openSession(?Callback:Dynamic)
	{
		if (!userLoggedIn) return;
		sendLoaderRequest("sessions/open/" + RETURN_TYPE + _idURL, Callback);
	}//---------------------------------------------------;
	
	// --
	function closeSession(?Callback:Dynamic)
	{
		if (!userLoggedIn) return;
		sendLoaderRequest("sessions/close/" + RETURN_TYPE + _idURL, Callback);
	}//---------------------------------------------------;
	function  pingSession(Active:Bool = true, ?Callback:Dynamic):Void
	{
		if (!userLoggedIn) return;
		var tempURL:String = "sessions/ping/" + RETURN_TYPE + _idURL + "&active=" + (Active?"active":"idle");
		sendLoaderRequest(tempURL, Callback);
	}//---------------------------------------------------;
	function _addTrophy(TrophyID:Int, ?Callback:Dynamic):Void
	{
		if (!userLoggedIn) return;
		sendLoaderRequest("trophies/add-achieved/" + RETURN_TYPE + _idURL + "&trophy_id=" + TrophyID, Callback);
	}//---------------------------------------------------;
	// --
	function addScore(Score:String, Sort:Float, ?TableID:Int, ?ExtraData:String, ?Callback:Dynamic):Void
	{
		if (!userLoggedIn) return;
	
		// TO ALLOW GUEST, CHECK THE ORIGINAL FILE AND EDIT THIS.
		
		var tempURL = "scores/add/" + RETURN_TYPE + "&game_id=" + GAME_ID + "&score=" + Score + "&sort=" + Std.string(Sort);
		
		tempURL += URL_USER_NAME + _userName + URL_USER_TOKEN + _userToken;
		
		if (ExtraData != null && ExtraData != "") {
			tempURL += "&extra_data=" + ExtraData;
		}
		
		if (TableID != null && TableID != 0) {
			tempURL += "&table_id=" + TableID;
		}
		
		sendLoaderRequest(tempURL, Callback);
	}//---------------------------------------------------;
	
	// -- 
	inline function verbose(log:Dynamic):Void
	{
		#if debug
		if (_verbose) trace(log);
		#end
	}//---------------------------------------------------;
	
}// --