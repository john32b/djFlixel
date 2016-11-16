/**--------------------------------------------------------
 * classname.hx
 * @author: johndimi, <johndimi@outlook.com> , @jondmt
 * --------------------------------------------------------
 * @Description
 * -------
 * General purpose
 * 
 * @Notes
 * ------
 * There are slots on the SAVE objects.
 * Generally, use slot 0 to save the settings
 * 
 * @usage
 * ------
 * SAVE.setSlot(1);
 * SAVE.save("lives",player.lives);
 * 
 * SAVE.setSlot(2);
 * if(SAVE.exists("ammo")) pl.ammo = SAVE.load("ammo");
 * 
 * 
 * @TODO
 * ------
 * - Gameapi Intergration and automatic saving to APIs that support saving (gamejolt).
 * - Backup save to a file, and option to load file.
 * 
 ========================================================*/
 
package djFlixel;
import flixel.util.FlxSave;
import haxe.Json;


class SAVE
{

	// -- The FlashAPI needs a unique ID for the savegame
	static var FLASH_SAVE_ID:String;	
	// -- How many SAVESLOTS this game will use ( +1 settings slot which is permanent )
	static var SAVE_SLOTS:Int = 1;
	// -- Prefix for the slot fields inside the save.data object
	static inline var PREFIX_SLOT:String = 'slot_';
	
	// The Flash save object, used for the game saves
	public static var saveObj(default, null):FlxSave;
	// 0 is Settings, 1...n are Game Slots
	static var currentSlot:Int = -1;
	// Pointer to a save.data object
	static var currentData:Dynamic;
	//---------------------------------------------------;
	// --
	public static function init(saveName:String, maxUserSlots:Int = 1)
	{
		FLASH_SAVE_ID = "djflx" + saveName;
		SAVE_SLOTS = maxUserSlots; if (SAVE_SLOTS > 9) SAVE_SLOTS = 9;
		saveObj = new FlxSave();
		saveObj.bind(FLASH_SAVE_ID);
		setSlot(0);             
	}//---------------------------------------------------;
	// --
	public static function setSlot(num:Int):Void
	{
		if (currentSlot == num) return;
		
		if (num > SAVE_SLOTS)
		{
			trace('Error: There are [$SAVE_SLOTS] Max slots, requested slot [$num]');
			return;
		}
		
		currentSlot = num;
		
		if (Reflect.hasField(saveObj.data, '$PREFIX_SLOT$num') == false)
		{
			trace('Info: Creating Save Slot [$num]');
			Reflect.setProperty(saveObj.data, '$PREFIX_SLOT$num', { } );
		}
		
		currentData = Reflect.getProperty(saveObj.data, '$PREFIX_SLOT$num');
	}//---------------------------------------------------;
	// --
	// Save to the currently selected slot
	public static function save(key:String, data:Dynamic)
	{
		Reflect.setField(currentData, key, data);
	}//---------------------------------------------------;
	// --
	// Load from the currently selected slot
	// Null if nothing is found
	public static function load(key:String):Dynamic
	{
		return Reflect.getProperty(currentData, key);
	}//---------------------------------------------------;
	// --
	// Check from the currently selected slot
	public static function exists(key:String):Bool
	{
		return Reflect.hasField(currentData, key);
	}//---------------------------------------------------;
	
	// --
	// Call this after a bulk save to save for sure?
	// REQUIRED FOR NON FLASH TARGETS ! !
	public static function flush():Void
	{
		saveObj.flush();
	}//---------------------------------------------------;
	
	// --
	// Completely delete the save game,
	// This will delete both the game data and the settings
	// Use something else if you want to delete just the save game.
	public static function deleteSave():Void
	{	
		saveObj.erase();
		saveObj.flush();
	}//---------------------------------------------------;
	// -- Delete a save slot entirely.
	public static function deleteSlot(num:Int)
	{
		Reflect.setProperty(saveObj.data, '$PREFIX_SLOT$num', { } );
		currentData = Reflect.getProperty(saveObj.data, '$PREFIX_SLOT$num');
	}//---------------------------------------------------;
		
	// --
	// Save a target object as Stringified JSON
	public static function saveStr(key:String, obj:Dynamic)
	{
		save(key, Json.stringify(obj));
	}//---------------------------------------------------;
	
	
	// --
	// Load a stringified string to an object
	// Null if nothing is found
	public static function loadStr(handle:String):Dynamic
	{
		if (!exists(handle)) return null;
		return Json.parse(load(handle));
	}//---------------------------------------------------;
	
	
	
	// -- GAME SPECIFIC LOGIC -- //
	
	// - savegame() -> call all game objects to save
	// - loadgame() -> call all game objects to load??
	
}// --