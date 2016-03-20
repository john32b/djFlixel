package tiles;
import flixel.FlxObject;


class TileSprites
{
	//-- TILE INDEXES:	
	public static var STEP_UP:Int;
	public static var STEP_DOWN:Int;
	public static var STEP_LEFT:Int;
	public static var STEP_RIGHT:Int;
	
	// Quickly get a tile based on FLXOBJECT DIRECTION
	static var stepsMap:Map<Int,Int>;
	
	//====================================================;
	public static function init()
	{
		// Load the tiles from json
		Reg.applyParamsInto('tileSprites', TileSprites);
		
		stepsMap = new Map();
		stepsMap.set(FlxObject.UP, STEP_UP);
		stepsMap.set(FlxObject.DOWN, STEP_DOWN);
		stepsMap.set(FlxObject.LEFT, STEP_LEFT);
		stepsMap.set(FlxObject.RIGHT, STEP_RIGHT);
		stepsMap.set(0, 0); // Just in case
		
	}//---------------------------------------------------;
	
	// Get the corresponding step tile index for a flxObject direction
	inline public static function getStepTile(direction:Int)
	{
		return stepsMap.get(direction);
	}//---------------------------------------------------;

	
}// --