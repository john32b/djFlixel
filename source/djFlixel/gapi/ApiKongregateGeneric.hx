package djFlixel.gapi;
import flixel.addons.api.FlxKongregate;

// -- 
// Kongregate API
//
// #Override this class
class ApiKongregateGeneric extends ApiOffline
{
	
	// Override on child
	var trophyMap:Map<String,String>;
	// Keep track of which trophies are already got in the runtime
	var trophyGot:Map<String,Bool>;
	
	//---------------------------------------------------;
	public function new()
	{ 
		super();
		trace('Info: Creating Kongregate API Handler');
		
		SERVICE_NAME = "Kongregate";
		
		trophyMap = new Map();
		trophyGot = new Map();
		// OVERRIDE and populate trophyMap
	}//---------------------------------------------------;
	// --
	override public function connect() 
	{ 
		FlxKongregate.init(_onInit);
	}//---------------------------------------------------;
	
	function _onInit()
	{
		isConnected = true;
		connectStatus = "ok";
		
		if (onConnect != null) {
			onConnect();
		}
		
		trace("Warning: Kongregate connected");
	}//---------------------------------------------------;
	
	override public function destroy() 
	{ 
		trophyGot = null;
		trophyMap = null;
	}//---------------------------------------------------;
	override public function trophy(trophyID:String) 
	{ 
		if (!isConnected) return;
		
		if (trophyGot.exists(trophyID)) {
			return;
		}
		
		FlxKongregate.submitStats(trophyMap.get(trophyID), 1);
		trophyGot.set(trophyID, true);
	}//---------------------------------------------------;
	override public function uploadScores() 
	{ 
		if (!isConnected) {
			trace("Error: Is not connected to API");
			return;
		}
		
		// -- OVERRIDE THIS AND PUSH SCORES --
		//FlxKongregate.submitStats("HighScore", HUD.score);
	}//---------------------------------------------------;
	
	override public function getUser():String 
	{
		if (!isConnected) return .USERNAME_OFFLINE;;
		return FlxKongregate.getUserName();
	}//---------------------------------------------------;
	
}// --