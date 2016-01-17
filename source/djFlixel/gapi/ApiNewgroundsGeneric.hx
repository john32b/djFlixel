package djFlixel.gapi;

import com.newgrounds.API;
import com.newgrounds.APIEvent;
import com.newgrounds.SaveFile;
import com.newgrounds.SaveGroup;
import com.newgrounds.SaveQuery;
import com.newgrounds.components.MedalPopup;
import flixel.util.FlxTimer;

import flixel.FlxG;
import flash.Lib;
import lime.utils.ByteArray;

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
 *=================================================================*/

@:file("assets/newgrounds.key") class NewgroundsKey extends ByteArray { }
class ApiNewgroundsGeneric extends ApiEmpty
{
	// - Every newgrounds game has an ID String
	var API_ID:String;
	// Override on child
	var trophyMap:Map<String,String>;	// # SET ON CHILD
	// Keep track of which trophies are already got in the runtime
	var trophyGot:Map<String,Bool>;
	// All save files will be saved with this name
	var saveName:String = "data";
	// Currently connected save file
	var savefile:SaveFile = null;
	
	// All save files will go to this group.
	var saveGroupName:String = null; // # SET ON CHILD
	// - Whether or not to show the newgrounds Medal Popup
	var flag_show_popup:Bool = true; // # SET ON CHILD
		
	
	//---------------------------------------------------;
	public function new(apiID:String) 
	{ 
		super();
		SERVICE_NAME = "Newgrounds";
		trophyMap = new Map();
		trophyGot = new Map();
		API_ID = apiID;
		trace('Info: Creating Newgrounds API Handler, API_ID = $API_ID');
		// Override and add trophies!
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
		
		// #if debug
		// API.debugMode = API.DEBUG_MODE_LOGGED_IN;
		// #else
		// API.debugMode = API.RELEASE_MODE;
		// #end
		
		API.addEventListener(APIEvent.API_CONNECTED, onAPIConnected);
		API.connect(Lib.current.root, API_ID, getPrivateKey());
	}//---------------------------------------------------;
	// --
	function onAPIConnected(event:APIEvent)
	{
		if (connectTimer != null) {
			connectTimer.destroy();
		}
		
		API.removeEventListener(APIEvent.API_CONNECTED, onAPIConnected);
		
		if(event.success)
		{
			connectStatus = "ok";
			trace("Warning: The API is connected and ready to use!");
			
			// Add the newgrounds custom popup
			if (flag_show_popup) 
			{
				var popup:MedalPopup = new MedalPopup();
					popup.x = (FlxG.width * FlxG.initialZoom) / 2 - popup.width / 2;
					popup.y = 2;
					popup.alwaysOnTop = "true";
				Lib.current.stage.addChild(popup);
			}
			
			// Try to load the savegame
			if (saveGroupName != null) {
				fetchSave();
			}
			
			isConnected = true;
			if (onConnect != null) onConnect();
		}
		else
		{
			trace("Error: Connecting to the API: " + event.error);
			connectStatus = "fail";
			if (onConnect != null) onConnect();
		}
	}//---------------------------------------------------;

	override public function trophy(trophyID:String) 
	{ 
		if (!isConnected) return;
		
		if (trophyGot.exists(trophyID)) {
			return;
		}
		
		API.unlockMedal(trophyMap.get(trophyID));
		
		trophyGot.set(trophyID, true);
	}//---------------------------------------------------;
	override public function uploadScores() 
	{ 
		// * OVERRIDE THIS AND PUSH SCORES *
		
		// Make sure the table exists
		
		// e.g.
		// ng_score("Score Board Name", 400);
	}//---------------------------------------------------;
	
	private function ng_score(scoreboard:String, score:Int)
	{
		if (!isConnected) {
			trace("Error: Is not connected to API");
			return;
		}
		
		API.postScore(scoreboard, score);
	}//---------------------------------------------------;
	
	// --
	override public function getUser():String 
	{ 
		if (!isConnected) {
			return USERNAME_OFFLINE;
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
		
		// Cancel the transaction after X seconds
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
	override public function destroy()
	{
		trophyGot = null;
		trophyMap = null;
		
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

}// --