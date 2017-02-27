package djFlixel.gapi;

import com.newgrounds.API;
import com.newgrounds.APIEvent;
import com.newgrounds.SaveFile;
import com.newgrounds.SaveGroup;
import com.newgrounds.SaveQuery;
import com.newgrounds.Score;
import com.newgrounds.ScoreBoard;
import com.newgrounds.components.MedalPopup;
import djFlixel.gapi.ApiOffline.Trophy;
import flixel.util.FlxTimer;

import flixel.FlxG;
import flash.Lib;

import flash.utils.ByteArray;

/**
 * Newgrounds API
 * --------------
 * @author: JohnDimi, twitter<@jondmt>
 * 
 * Features:
 * ------------------
 * - Basic intergration
 * - Score upload
 * - Medal/Trophy unlock
 * - Supports 1 string save file.
 * 
 * -----------------------------
 * - HOW TO USE
 * -----------------------------
 * + ADD THESE LINES TO PROJECT.XML
 * 
 * 	<haxedef name="NEWGROUNDS"/>
 *	<haxeflag name="-swf-lib" value="assets/newgrounds/NewgroundsAPI.swc"/>
 *	<haxedef name="as3_native" if="flash"/>
 * 
 * ---------------------
 * - DEV NOTES -
 * 	API reference : https://www.newgrounds.com/wiki/creator-resources/flash-api/reference/api#wiki_toc_31
 * 
 * - Useful
 *	API.logCustomEvent(eventName:String):void -> add custom developer event 
 *=================================================================*/

@:file("assets/newgrounds.key") class NewgroundsKey extends ByteArray { }
class ApiNewgroundsGeneric extends ApiOffline
{
	// - Every newgrounds game has an ID String
	var API_ID:String;
	// All save files will be saved with this name
	var saveName:String = "data";
	// Currently connected save file
	var savefile:SaveFile = null;
	
	// All save files will go to this group.
	var saveGroupName:String = null; // # SET ON CHILD
	// I will just use one scoreboard
	var scoreBoardName:String = null; // # SET ON CHILD
	// - Whether or not to show the newgrounds Medal Popup
	var flag_show_popup:Bool = false; // Auto set when initializing trophy object
	// - General Purpose Score Board
	var scoreBoard:ScoreBoard;
	//---------------------------------------------------;
	/**
	 * Get apiID after creating your Project at Newgrounds.
	 * @param	apiID looks like this "46705:24BCOlS1"
	 */
	public function new(apiID:String) 
	{ 
		super();
		SERVICE_NAME = "Newgrounds";
		API_ID = apiID;
		trace('Info: Creating Newgrounds API Handler, API_ID = $API_ID');
	}//---------------------------------------------------;
	// --
	function getPrivateKey():String
	{
		var bytearray = new NewgroundsKey();
		var keystr = bytearray.readUTFBytes( bytearray.length );
		return keystr;
	}//---------------------------------------------------;
	override public function connect()
	{ 
		if (isConnected) return;
		
		connectTimer = new FlxTimer();
		connectTimer.start(CONNECT_TIMEOUT, function(_) {
			// Disconnect
			API.disconnect();
			connectTimer.destroy();
			isConnected = false;
			connectStatus = "fail";
			if (onConnect != null) onConnect();
		});
		
		connectStatus = "working";
		
		 #if debug
		 API.debugMode = API.DEBUG_MODE_LOGGED_IN;
		 #else
		 API.debugMode = API.RELEASE_MODE;
		 #end
		
		API.addEventListener(APIEvent.API_CONNECTED, onAPIConnected);
		API.connect(Lib.current.root, API_ID, getPrivateKey());
	}//---------------------------------------------------;
	
	/**
	 * You have to call this after flixel is initialized 
	 * DO NOT CALL THIS on the preloader
	 */
	public function initMedal()
	{
		if (!isConnected) {
			trace("Error: Is not connected");
			return;
		}
	
		flag_show_popup = true;
		
		// Add the newgrounds custom popup
		var popup:MedalPopup = new MedalPopup();
			popup.x = (FlxG.width * FlxG.initialZoom) / 2 - popup.width / 2;
			popup.y = 2;
			popup.alwaysOnTop = "true";
		Lib.current.stage.addChild(popup);
	}//---------------------------------------------------;
	
	/**
	 * Autocalled on api connect or fail
	 * @param	event
	 */
	function onAPIConnected(event:APIEvent)
	{
		if (connectTimer != null) {
			connectTimer.destroy();
		}
		
		API.removeEventListener(APIEvent.API_CONNECTED, onAPIConnected);
		
		if(event.success)
		{
			connectStatus = "ok";
			trace("Info: The API is connected and ready to use!");
			
			// -- Try to load the savegame
			if (saveGroupName != null) {
				trace("Trying to get SaveGroup::", saveGroupName);
				fetchSave();
			}
			
			// -- Try to get scores
			if (scoreBoardName != null) {
				// trace("Trying to get scoreboard", scoreBoardName);
				// I am thinking that scoreboards should be loaded everytime they are requested.
				// So that they are fresh.
				// fetchScores();
			}
			
			isConnected = true;
			if (onConnect != null) onConnect();
		}
		else
		{
			trace("Error: Connecting to the API: " + event.error);
			
			switch(event.error) {
				case APIEvent.ERROR_HOST_BLOCKED:
					isBlocked = true;
				default:
			}
			
			connectStatus = "fail";
			if (onConnect != null) onConnect();
		}
	}//---------------------------------------------------;
	
	// --
	override function _onTrophyUnlock(tr:Trophy) 
	{
		if (!isConnected) return;
		API.unlockMedal(tr.name);
	}//---------------------------------------------------;
	
	// --
	var onScoreUploaded:Void->Void;
	override public function uploadScore(score:Int, ?callback:Void->Void = null) 
	{
		if (!isConnected) {
			trace("Error: Is not connected to API");
			return;
		}
		onScoreUploaded = callback;
		if (onScoreUploaded != null) {
			API.addEventListener(APIEvent.SCORE_POSTED, __onScoreUploaded);
		}
		API.postScore(scoreBoardName, score);
	}//---------------------------------------------------;
	function __onScoreUploaded(e:APIEvent)
	{
		trace("Score Upload success");
		API.removeEventListener(APIEvent.SCORE_POSTED, __onScoreUploaded);
		if (onScoreUploaded != null) onScoreUploaded();
	}//---------------------------------------------------;
	
	// --
	override public function getUser():String 
	{ 
		if (!isConnected) {
			return "offline";
		}
		
		if (API.hasUserSession) 
			return API.username;
		else
			return "Guest";
	}//---------------------------------------------------;
	
	// --
	function __onSave(e:APIEvent)
	{
		if (e.success) 
		{
			trace("Info: Newgrounds, File saved!");
		}
	}//---------------------------------------------------;
	// --
	function __onLoad(e:APIEvent)
	{
		if (e.success) {
			trace("Info: Newgrounds, File Loaded!");
			
			// At this point, the savefile object has been populated
			// with the new loaded data.
			loadStatus = "ok";
			if (onLoadgame != null) {
				onLoadgame();
				onLoadgame = null;
			}
		}else
		{
			trace("Warning: Could not load save file. Clearing.");
			savefile = null;
			loadStatus = "fail";
			if (onLoadgame != null) {
				onLoadgame();				
				onLoadgame = null;
			}
		}
		
	}//---------------------------------------------------;

	// --
	// Saves or overwrites the save with "savename" with "data"
	override public function save(data:String)
	{
		if (!isConnected) return;
		
		if (saveGroupName == null) return;
		
		if (savefile == null)
		{
			savefile = API.createSaveFile(saveGroupName);	
			savefile.name = saveName;
			savefile.addEventListener(APIEvent.FILE_SAVED, __onSave);
			savefile.addEventListener(APIEvent.FILE_LOADED, __onLoad);
		}
		
		savefile.description = "Created on " + Date.now().toString();
		savefile.data = data;
		savefile.save(); // Will trigger the event listener (__onSave)
	}//---------------------------------------------------;
	// --
	override public function getSaveData():String
	{
		if (savefile != null && loadStatus == "ok") {
			return savefile.data;
		}
		return null;
	}//---------------------------------------------------;
	// --
	// Try to get the savefile from the savegroup
	function fetchSave()
	{
		// Create a saveQuery and load by NAME, search name to be savegame.		
		var query:SaveQuery = API.createSaveQueryByName(saveGroupName, saveName, true);
			query.addEventListener(APIEvent.QUERY_COMPLETE, _queryLoadComplete);
		
		// Cancel the transaction after X seconds and set the loadstatus to FAIL
		connectTimer = new FlxTimer();
		connectTimer.start(CONNECT_TIMEOUT, function(_) {
			if (query != null){
				query.removeEventListener(APIEvent.QUERY_COMPLETE, _queryLoadComplete);
				query = null;
			}
			loadStatus = "fail";
			if (onLoadgame != null) {
				onLoadgame();
				onLoadgame = null;
			}
			connectTimer.destroy();
		});
				
		loadStatus = "working";
		query.execute();
		
	}//---------------------------------------------------;	
	// --
	// Called when requesting to view the loadfiles
	// Usually it's only one file I need.
	function _queryLoadComplete(e:APIEvent)
	{
		// Stop timing for a timeout.
		if (connectTimer != null) {
			connectTimer.destroy();
		}
		
		if (e.data.files.length == 0)
		{
			// Create the save file?
			trace("Warning: No savefile found");
			savefile = null;
			loadStatus = "empty";
			if (onLoadgame != null) {
				onLoadgame();
				onLoadgame = null;
			}
		}
		else
		{
			trace("Info: Got savefile, Getting Data..");
			savefile = e.data.files[0];
			savefile.addEventListener(APIEvent.FILE_SAVED, __onSave);
			savefile.addEventListener(APIEvent.FILE_LOADED, __onLoad);
			savefile.load();
		}
		
	}//---------------------------------------------------;
	// --
	public function hasSaveFile():Bool
	{
		return (savefile != null);
	}//---------------------------------------------------;

	// --
	public function log(s:String)
	{
		API.logCustomEvent(s);
	}//---------------------------------------------------;
	
	// --
	override public function destroy()
	{
		if (isConnected && savefile != null )
		{
			savefile.removeEventListener(APIEvent.FILE_SAVED, __onSave );
			savefile.removeEventListener(APIEvent.FILE_LOADED, __onLoad);
		}		
		
		if (connectTimer != null) {
			connectTimer.destroy();
			connectTimer = null;
		}
	}//---------------------------------------------------;

	// --
	override public function openURLGame() 
	{
		if (isConnected) 
			API.loadOfficialVersion();
		else
			super.openURLGame();
	}//---------------------------------------------------;
	
	/**
	 * This can be called by the user also.
	 * Check the 'scores' object on the callback. Check for null also.
	 */
	var onScoreLoad:Void->Void = null;
	override public function fetchScores(callback:Void->Void = null)
	{
		onScoreLoad = callback;
		if (!isConnected) {
			if (onScoreLoad != null) onScoreLoad();
			return;
		}
		API.addEventListener(APIEvent.SCORES_LOADED, __onScoreLoad);
		scoreBoard = API.loadScores(scoreBoardName, ScoreBoard.ALL_TIME, 1, SCORES_TO_GET);
	}//---------------------------------------------------;
	// --
	function __onScoreLoad(e:APIEvent)
	{
		// -
		API.removeEventListener(APIEvent.SCORES_LOADED, __onScoreLoad);
		
		if (e.success) {
			scores = [];
			for (sc in scoreBoard.scores) {
				trace("-- Scores loaded --");
				var ss = { rank:sc.rank, user:sc.username, score_str:sc.score, score_num:sc.numericValue };
				scores.push(ss);
				trace(ss);
			}
			
		}else {
			trace("-- Failed to load scores --");
			scores = null;
		}
		
		if (onScoreLoad != null) onScoreLoad();
	}//---------------------------------------------------;
	
}// --