package djFlixel.gapi;
import djFlixel.gapi.ApiOffline.Trophy;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.util.FlxStringUtil;
#if TROPHIES
	import djFlixel.gapi.TrophyPopup;
#end

/**
 * This class can be overriden to specify a more specific API like newgrounds or gamejolt
 * You can use this class as is for offline achievements.
 * 
 * HAXE DEFINES:
 * ------------------
 * 
 * 		"FLASHONLINE"	// All code related to scores and URL checking, 
 * 		"TROPHIES" 		// Enable trophy functionality
 * 
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
	public var isBlocked:Bool; // Don't use this, check isURLAllowed() instead
	// False when it's GUEST
	public var userLoggedIn:Bool = false;
	//---------------------------------------------------;
	public function new() 
	{ 
		connectStatus = "offline";
		loadStatus = "offline";
		isConnected = false;
		isBlocked = false;
		
		#if TROPHIES
		trophyGot = new Map();
		trophies = new Map();
		trophiesAr = [];
		#end
	}//---------------------------------------------------;
	public function getUser():String 
	{ 
		return "offline";
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
		#if TROPHIES
		trophyGot = null;
		trophies = null;
		#end
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
			fn(); // either "ok" or "fail"
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
	// PROTECTION 
	//====================================================;
	
	#if FLASHONLINE
	
	// !IMPORTANT! : URLs MUST BEGIN WITH the "http://" or "https://" prefix
	// 
	// NOTE : if a URL is "http://gamejolt.com" then allowed are all the subdomains
	//		  e.g. "http://flash.upload.gamejolt.com" IS ALLOWED
	var allowedURLs:Array<String> = null; // # USER SET #
	
	/**
	 * Make sure to set the 'allowedURLs' beforehand
	 * Note that returns FALSE if local play
	 * @return
	 */
	public function isURLAllowed():Bool
	{
		if (allowedURLs == null) return false;
		
		var homeDomain:String = FlxStringUtil.getDomain(FlxG.stage.root.loaderInfo.loaderURL);
		
		for (allowedURL in allowedURLs)
		{
			if (FlxStringUtil.getDomain(allowedURL) == homeDomain)
			{
				return true;
			}
			else if (allowedURL == "local" && homeDomain == "local")
			{
				return false; // NO OFFLINE PLAY!
			}
		}
		return false;
	}//---------------------------------------------------;
	
	#end
	
	#if TROPHIES
	
	//====================================================;
	// ACHIEVEMENTS , TROPHIES
	//====================================================;
	
	// # USER SETS ::
	
	// -- IMPORTANT -- SET THE SPRITE SHEET IF YOU WANT POPUPS AND LISTS TO WORK !
	// 32x32 size
	public var TROPHY_SPRITE_SHEET:String = ""; // Used by trophypopup class
	// If set will play this sound on popup
	public var TROPHY_SOUND:String = null; // Used by trophypopup class
	// [x,y]. See Align.screen()
	// Future: Put this on TrophyPopup ?
	public var TROPHY_ALIGN:String = "left|top"; // Used by trophypopup class
	// Called whenever a trophy is unlocked
	public var onTrophyUnlock:Trophy->Void = null;

	// # PROPERTIES ::
	
	// The entire game trophies,
	// Set on the overrided object
	// <Trophy.SID, Trophy{} >
	public var trophies(default, null):Map<String,Trophy>;	
	// Stores ALL Trophies serially
	public var trophiesAr(default, null):Array<Trophy>;
	// How many trophies there are
	public var trophiesTotal(default, null):Int = 0;
	// How many are unlocked
	public var trophiesUnlocked(default, null):Int = 0;
	// Prevent trophies from being unlocked. Useful when demorunning.
	public var flag_trophies_disable:Bool = false;
	// Enable or disable the flash popup
	public var flag_trophy_popup:Bool = true;
	// Global object displaying the popup
	public var trophyPopup:TrophyPopup;
	// Keep track of which trophies are already got. So I don't unlock them again.
	// <Trophy.SID, unlocked>
	var trophyGot:Map<String,Bool>;
	
	/**
	 * Add a trophy to the DB.
	 */
	public function addTrophy(imIndex_:Int = 0, type_:String, sid_:String, name_:String, desc_:String, uid_:Int = -1)
	
	{
		var t:Trophy = { uid:uid_, sid:sid_, name:name_, desc:desc_, type:type_, imIndex:imIndex_, unlocked:false };
		
		trophies.set(sid_, t);
		trophiesAr.push(t);
		trophiesTotal++;
	}//---------------------------------------------------;

	/**
	 * Unlock a trophy
	 * @param	trophyID
	 */
	public function trophy(trophyID:String) 
	{ 
		if (flag_trophies_disable || trophyGot.exists(trophyID)) {
			return;
		}
		
		if (!trophies.exists(trophyID)){
			trace('Error: Trophy with ID [$trophyID] is not set');
			return;
		}
		
		trophyGot.set(trophyID, true);
		trophiesUnlocked++;
		
		var tr = trophies.get(trophyID);
			tr.unlocked = true;
			
		trace(" Unlocking Trophy : ", tr.name);
		
		// NEW:
		save_trophies();
			
		_onTrophyUnlock(tr); // Push trophy to extended objects
		if (onTrophyUnlock != null) onTrophyUnlock(tr); // Push trophy to user
		
		if (flag_trophy_popup && trophyPopup != null)
		{
			trophyPopup.popup(trophyID);
		}
	}//---------------------------------------------------;
	/**
	 * Internal, Override and handle the trophy
	 * Push to the online API
	 * @param	tr See trophy TypeDef
	 */
	function _onTrophyUnlock(tr:Trophy)
	{
	}//---------------------------------------------------;
		
	/**
	 * Saves the acquired trophies to the master save game
	 */
	public function save_trophies()
	{
		var trophiesGot:Array<String> = [];
		for (i in trophiesAr) {
			if (i.unlocked) trophiesGot.push(i.sid);
		}
		SAVE.setSlot(0);
		SAVE.save("_trophies",trophiesGot.join("|"));
	}//---------------------------------------------------;
	
	/**
	 * Try to load trophies from the master save game
	 * NOTE: If for some reason trophies are corrupted, it resets them to none
	 */
	public function load_trophies()
	{
		SAVE.setSlot(0);
		var ss:String = SAVE.load("_trophies");
		if (ss == null) return;
		var ar:Array<String> = ss.split('|');
		if (ar == null) return;
		trophiesUnlocked = 0;
		
		try {
			for (i in ar) {
				trophyGot.set(i, true);
				trophies.get(i).unlocked = true;
				trophiesUnlocked++;
			}
		
		}catch (e:Dynamic)
		{
			trace(e);
			trace("Problem loading trophies, resetting all");
			delAllTrophies();
		}
	}//---------------------------------------------------;
	/**
	 * Deletes Current trophies AND saved trophies 
	 **/
	public function delAllTrophies()
	{
		for (i in trophiesAr) {
			i.unlocked = false;	
		}
		trophyGot = new Map();
		save_trophies();
		trophiesUnlocked = 0;
		trace("Deleted Trophies");
	}//---------------------------------------------------;
	
		#if debug
		/**
		* For debugging, unlock a random trophy
		*/
		public function addOneAtRandom()
		{
			for (i in trophiesAr) {
				if (i.unlocked == false) { trophy(i.sid); break; }
			}
		}//---------------------------------------------------;
		#end
	
	#else
		public var flag_trophies_disable:Bool;
		public var flag_trophy_popup:Bool;
		public var TROPHY_SOUND:String;
		public var TROPHY_SPRITE_SHEET:String;
		// Skip trophy calls altogether
		public inline function addTrophy(imIndex_:Int = 0, type_:String, sid_:String, name_:String, desc_:String, uid_:Int = -1) { }
		public inline function trophy(trophyID:String) { }
		public inline function save_trophies(){ }
		public inline function load_trophies() { }
		public inline function delAllTrophies() { }
	#end //-----------------------------------------------;
	
	
	//====================================================;
	// SCORING AND LEADERBOARDS
	//====================================================;
	
	// Usually 10 scores to get is OK, you can override this
	var SCORES_TO_GET:Int = 10;
	// You should read this to get scores, nulls of no scores loaded
	public var scores:Array<ScoreApi> = null;
	//---------------------------------------------------;
	// -- Upload score and callback
	public function uploadScore(score:Int, ?callback:Void->Void = null) // # OVERRIDE
	{
		if (callback != null) callback();
	}//---------------------------------------------------;
	// -- Populate the scores array and callback
	public function fetchScores(callback:Void->Void = null) // # OVERRIDE
	{
		if (callback != null) callback();
	}//---------------------------------------------------;
	/**
	 * Does the score makes the TOP TEN?
	 */
	public function scoreMakesLeaderboard(score:Float):Bool
	{
		if (scores == null) return true;
		if (scores.length == 0) return true;
		var minScore = scores[scores.length - 1].score_num; // The scores are sorted.
		return (score >= minScore);
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
	?type:String, // Custom type. e.g. "silver","bronze","gold"..
	?unlocked:Bool, // Used when displaying a trophy
	?imIndex:Int   // Index in the achievements spritesheet
}