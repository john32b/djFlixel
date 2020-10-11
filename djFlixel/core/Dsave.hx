package djFlixel.core;

import flixel.util.FlxSave;
import haxe.Json;

/**
   General purpose Save Manager, using slots
   - Accessible from D.save
   - 9 Save Slots
   
   - Usage:
	  D.save.setSlot(1);
	  D.save.save("lives",player.lives);
	  
	  D.save.setSlot(2);
	  if(D.save.exists("ammo")) pl.ammo = D.save.load("ammo");
	  
   - Future:
	  . Gameapi Intergration and automatic saving to APIs that support saving (gamejolt).
      . Backup save to a file, and option to load file.
**/

@:dce
class Dsave
{
	// -- Prefix for the slot fields inside the save.data object
	static inline var PREFIX_SLOT:String = 'slot_';
	static inline var PREFIX_SAVEID:String = 'djflx';
	
	// -- The FlashAPI needs a unique ID for the savegame
	var FLASH_SAVE_ID:String;	
	
	// -- How many SAVESLOTS this game will use ( +1 settings slot which is permanent )
	var SAVE_SLOTS:Int = 9;
	
	// The Flash save object, used for the game saves
	public var saveObj(default, null):FlxSave;
	
	// 0 is Settings, 1...n are Game Slots
	var currentSlot:Int = -1;
	
	// Pointer to a save.data object
	var currentData:Dynamic;
	
	/* 
	 * @param	saveName Unique game ID to associate with the game object
	 * @param	maxUserSlots
	 */
	public function new(saveName:String)
	{
		FLASH_SAVE_ID = PREFIX_SAVEID + saveName;
		saveObj = new FlxSave();
		saveObj.bind(FLASH_SAVE_ID);
		setSlot(0);             
	}//---------------------------------------------------;
	
	
	/**
	 * Set the current active slot for saving
	 * @param	num The number of slot to set
	 */
	public function setSlot(num:Int)
	{
		if (currentSlot == num) return;
		
		if (num > SAVE_SLOTS) {
			trace('Error: There are [$SAVE_SLOTS] Max slots, requested slot [$num]');
			return;
		}
		
		currentSlot = num;
		
		if (Reflect.hasField(saveObj.data, '$PREFIX_SLOT$num') == false) {
			trace('Info: Creating Save Slot [$num]');
			Reflect.setProperty(saveObj.data, '$PREFIX_SLOT$num', { } );
		}
		
		currentData = Reflect.getProperty(saveObj.data, '$PREFIX_SLOT$num');
	}//---------------------------------------------------;
	
	
	/**
	 * Save to the active save slot
	 * @param	key The key of the save
	 * @param	data The save data
	 */
	public function save(key:String, data:Dynamic)
	{
		Reflect.setField(currentData, key, data);
	}//---------------------------------------------------;
	
	
	/**
	 * Load from the active save slot, returns Null if nothing is found
	 * @param	key The key to load from
	 * @return 
	 */
	public function load(key:String):Dynamic
	{
		return Reflect.getProperty(currentData, key);
	}//---------------------------------------------------;
	
	
	/**
	 * Check from the active save slot
	 * @param	key The Key to check
	 * @return
	 */
	public function exists(key:String):Bool
	{
		return Reflect.hasField(currentData, key);
	}//---------------------------------------------------;
	
	/**
	 * Call this after a bulk save to force the data to be written
	 * REQUIRED FOR NON FLASH TARGETS ! !
	 */
	public function flush():Void
	{
		saveObj.flush();
	}//---------------------------------------------------;
	
	
	/**
	 * Completely delete the save game,
	 * This will delete both the game data and the settings
	 * Use something else if you want to delete just the save game.
	 */
	public function deleteSave():Void
	{	
		if (!saveObj.erase()) trace("ERROR: Cannot delete save?");
		saveObj.flush();
	}//---------------------------------------------------;
	
	
	/**
	 * Delete a save slot entirely.
	 * @param	num The slot no to delete
	 */
	public function deleteSlot(num:Int)
	{
		Reflect.setProperty(saveObj.data, '$PREFIX_SLOT$num', { } );
		currentData = Reflect.getProperty(saveObj.data, '$PREFIX_SLOT$num');
		flush();
	}//---------------------------------------------------;
	
	
	/**
	 * Save a simple object as Stringified JSON to the active save slot
	 * @param	key Key of the save id
	 * @param	obj
	 */
	public function saveJsonStr(key:String, obj:Dynamic)
	{
		save(key, Json.stringify(obj));
	}//---------------------------------------------------;
	
	/**
	 * Load a stringified JSOn string from active slot and convert it to an object
	 * @param	(key) Key of the save string
	 * @return
	 */
	public function loadJsonStr(key:String):Dynamic
	{
		if (!exists(key)) return null;
		return Json.parse(load(key));
	}//---------------------------------------------------;
	
}// --