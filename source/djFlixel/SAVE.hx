/**--------------------------------------------------------
 * SAVE.hx
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
	/**
	 * 
	 * @param	saveName Unique game ID to associate with the game object
	 * @param	maxUserSlots
	 */
	public static function init(saveName:String, maxUserSlots:Int = 1)
	{
		FLASH_SAVE_ID = "djflx" + saveName;
		SAVE_SLOTS = maxUserSlots; if (SAVE_SLOTS > 9) SAVE_SLOTS = 9;
		saveObj = new FlxSave();
		saveObj.bind(FLASH_SAVE_ID);
		setSlot(0);             
	}//---------------------------------------------------;
	/**
	 * Set the current active slot for saving
	 * @param	num The number of slot to set
	 */
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
	/**
	 * Save to the active save slot
	 * @param	key The key of the save
	 * @param	data The save data
	 */
	public static function save(key:String, data:Dynamic)
	{
		Reflect.setField(currentData, key, data);
	}//---------------------------------------------------;
	/**
	 * Load from the active save slot, returns Null if nothing is found
	 * @param	key The key to load from
	 * @return 
	 */
	public static function load(key:String):Dynamic
	{
		return Reflect.getProperty(currentData, key);
	}//---------------------------------------------------;
	/**
	 * Check from the active save slot
	 * @param	key The Key to check
	 * @return
	 */
	public static function exists(key:String):Bool
	{
		return Reflect.hasField(currentData, key);
	}//---------------------------------------------------;
	/**
	 * Call this after a bulk save to force the data to be written
	 * REQUIRED FOR NON FLASH TARGETS ! !
	 */
	public static function flush():Void
	{
		saveObj.flush();
	}//---------------------------------------------------;
	
	/**
	 * Completely delete the save game,
	 * This will delete both the game data and the settings
	 * Use something else if you want to delete just the save game.
	 */
	public static function deleteSave():Void
	{	
		saveObj.erase();
		saveObj.flush();
	}//---------------------------------------------------;
	/**
	 * Delete a save slot entirely.
	 * @param	num The slot no to delete
	 */
	public static function deleteSlot(num:Int)
	{
		Reflect.setProperty(saveObj.data, '$PREFIX_SLOT$num', { } );
		currentData = Reflect.getProperty(saveObj.data, '$PREFIX_SLOT$num');
	}//---------------------------------------------------;
	/**
	 * Save a simple object as Stringified JSON to the active save slot
	 * @param	key Key of the save id
	 * @param	obj
	 */
	public static function saveJsonStr(key:String, obj:Dynamic)
	{
		save(key, Json.stringify(obj));
	}//---------------------------------------------------;
	
	/**
	 * Load a stringified JSOn string from active slot and convert it to an object
	 * @param	(key) Key of the save string
	 * @return
	 */
	public static function loadJsonStr(key:String):Dynamic
	{
		if (!exists(key)) return null;
		return Json.parse(load(key));
	}//---------------------------------------------------;
	
}// --