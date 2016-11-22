package djFlixel.gapi;
import djFlixel.gapi.ApiOffline.Trophy;
import flixel.FlxG;
import flixel.util.FlxTimer;

// -- 
// This class can be overriden to specify a generic API.
// If no APIs are used, then this is used as a blank

/**
 * Example:
 * ---------------
 * 
 * Api.Connect();
 * Api.callOnConnect(void->void); check connectStatus manually from there
 * Api.callOnLoadgame(void->void); check loadStatus manually from there
 * this.getSaveData():String If Loaded will return the save string.
 * 
 */
class ApiOffline
{
	// useful to have, gets called sometimes
	var officialPage:String = "";
	// Maximum time to wait until API requests until failing.
	var CONNECT_TIMEOUT:Float = 10;
	// The service it is connected. Extended objects change this to "newgrounds" ,"gamejolt" etc
	public var SERVICE_NAME(default,null):String = "Offline";
	//---------------------------------------------------;
	// Is the API connected SUCCESSFULLY!
	public var isConnected:Bool;
	// Connecting to the API status - "offline", "working", "ok", "fail"
	public var connectStatus(default, null):String;
	// Loading the game status - "offline", 'empty','working','ok','fail';
	public var loadStatus(default, null):String; 
	// If exists, gets called when the save file is loaded.
	var onLoadgame:Void->Void = null; // Check the loadStatus there
	// Gets called when the API initialization is complete
	var onConnect:Void->Void = null; // Check the connect status there
	// Keep the connection timer.
	var connectTimer:FlxTimer;
	// If the game runs at an unauthorised place.
	public var isBlocked:Bool;
	// False when it's GUEST
	public var userLoggedIn:Bool = false;
	//---------------------------------------------------;
	public function new() 
	{ 
		connectStatus = "offline";
		loadStatus = "offline";
		isConnected = false;
		isBlocked = false;
		
		trophyGot = new Map();
		trophies = new Map();
	}//---------------------------------------------------;
	public function getUser():String 
	{ 
		return "Offline";
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
	public function destroy() 
	{ 
		trophyGot = null;
		trophies = null;
	}//---------------------------------------------------;
	
	//====================================================;
	// SAVING 
	//====================================================;
	
	public function save(data:String) { } // Override
	public function getSaveData():String { return ""; }	// Override and push correct data
	
	//--
	// If it's connected, it's called now,
	// else it's called upon connection ( or failure )
	/**
	 * Called now or when ready, upon connecting or failing
	 * @param	fn
	 */
	public function callOnConnect(fn:Void->Void)
	{
		if (connectStatus == "working" || connectStatus == "offline") {
			// It is going to callback later
			onConnect = fn;
		}else {
			fn();
		}
	}//---------------------------------------------------;
	/**
	 * Called now or when ready, upon loading the game save or failing
	 * @param	fn Check 'loadStatus' manually
	 */
	public function callOnLoadgame(fn:Void->Void)
	{
		if (loadStatus == "offline" || loadStatus == "working") {
			// It is going to callback later
			onLoadgame = fn;
		}else {
			// it is either "ok" or "empty"
			fn();
		}
	}//---------------------------------------------------;
	
	/**
	 * Call to visit official game site
	 */
	public function openURLGame()
	{
		FlxG.openURL(officialPage);
	}//---------------------------------------------------;
	
	
	//====================================================;
	// ACHIEVEMENTS 
	//====================================================;
	// Keep track of which trophies are already got. So I don't unlock them again.
	// <Trophy.SID, unlocked>
	var trophyGot:Map<String,Bool>;
	
	// The entire game trophies,
	// Set on the overrided object
	// <Trophy.SID, Trophy{} >
	public var trophies(default, null):Map<String,Trophy>;

	// User function, called whenever a trophy is unlocked
	public var onTrophyUnlock:Trophy->Void = null;
	
	#if (!NO_TROPHIES)
	
	/**
	 * Add a trophy. Call this on REG.INIT();
	 */
	public function addTrophy(type_:String, sid_:String, name_:String, desc_:String, uid_:Int = -1)
	{
		trophies.set(sid_, { uid:uid_, sid:sid_, name:name_, desc:desc_, type:type_ } );
	}//---------------------------------------------------;

	/**
	 * Unlock a trophy
	 * @param	trophyID
	 */
	public function trophy(trophyID:String) 
	{ 
		if (trophyGot.exists(trophyID)) {
			return;
		}
		trophyGot.set(trophyID, true);
		
		var tr = trophies.get(trophyID);
		_onTrophyUnlock(tr); // Push trophy to extended objects
		if (onTrophyUnlock != null) onTrophyUnlock(tr); // Push trophy to user
	}//---------------------------------------------------;
	/**
	 * Internal, Override and handle the trophy
	 * Push to the online API
	 * @param	tr See trophy TypeDef
	 */
	function _onTrophyUnlock(tr:Trophy)
	{
	}//---------------------------------------------------;
	
	#else
		// Skip trophy calls altogether
		public inline function addTrophy(type_:String, sid_:String, name_:String, desc_:String, uid_:Int = -1) { }	
		public inline function trophy(trophyID:String) { }
		inline function _onTrophyUnlock(tr:Trophy) { }
	#end //-----------------------------------------------;
	
	
	//====================================================;
	// SCORING AND LEADERBOARDS
	//====================================================;
	
	// Usually 10 scores to get is OK, you can override this
	var SCORES_TO_GET:Int = 10;
	// You should read this to get scores, nulls of no scores loaded
	public var scores:Array<ScoreApi> = null;
	//---------------------------------------------------;
	/**
	 * Override this and upload score
	 * 
	 * @param	score
	 * @param	callback
	 */
	public function uploadScore(score:Int, ?callback:Void->Void = null) 
	{ 
	}//---------------------------------------------------;

	/**
	 * @return Does the score makes the TOP TEN?
	 */
	public function scoreMakesLeaderboard(score:Float):Bool
	{
		if (scores == null) return true;
		if (scores.length == 0) return true;
		var minScore = scores[scores.length - 1].score_num;
		return (score >= minScore);
	}//---------------------------------------------------;
	
	/**
	 * Override and fetch scores to the scores object
	 * @param	callback
	 */
	public function fetchScores(callback:Void->Void = null){ 
	}//---------------------------------------------------;
	
	
	#if debug
	// -- For debugging purposes
	public var scoresFAKE:Array<ScoreApi> = [
		{ rank:1,  user:"northion",	score_str:"45623500",	score_num:45623500},
		{ rank:2,  user:"tintedregional",	score_str:"42615510",	score_num:42615510},
		{ rank:3,  user:"languagecentaurus",	score_str:"40054510",	score_num:40054510},
		{ rank:4,  user:"chidesuccinct",	score_str:"39054510",	score_num:39054510},
		{ rank:5,  user:"westminsterclass",	score_str:"10000000",	score_num:10000000},
		{ rank:6,  user:"cletchdata",	score_str:"7000000",	score_num:7000000},
		{ rank:7,  user:"cadgemap",	score_str:"3005020",	score_num:3005020},
		{ rank:8,  user:"User",	score_str:"200000",	score_num:200000},
		{ rank:9,  user:"journeyfilms",	score_str:"9995",	score_num:9995}
		//{ rank:10, user:"feastcalling",	score_str:"45267",	score_num:45267 }
	];	
	#end
	
}// --


//====================================================;
// TYPEDEFS 
//====================================================;
typedef ScoreApi = {
	rank:Int,
	user:String,
	score_str:String,
	score_num:Float
}

typedef Trophy = {
	?uid:Int,	  // unique int ID, Gamejolt needs this
	sid:String,   // unique String ID, this is globally used.
	name:String,  // Name of the achievement
	?desc:String, // Description
	?type:String  // Custom type. e.g. "silver","bronze","gold"..
}