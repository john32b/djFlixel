package entity;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.tile.FlxTilemap;
import entity.EntityTopDown;

class Mummy extends EntityTopDown
{
	
	// Hold all directions here
	public static var DIRECTIONS:Array<Int> = [
		FlxObject.UP, FlxObject.RIGHT, FlxObject.DOWN, FlxObject.LEFT
	];
	
	// Up to 3 tiles into the edges to load/delete this object.
	public var STREAM_OFFSET:Int = 3; /// unused
	
	//--
	public function new() 
	{
		super();
		SPRITE_WIDTH = 16;
		SPRITE_HEIGHT = 16;
		// --
		// Get enemy params from the file
		Reg.applyParamsInto("enemy", this);
		
		loadSprite("assets/sprites.png", [6, 7], [8, 9], [10, 11]);
	}//---------------------------------------------------;
	
	// --
	override public function spawn(tileX:Int, tileY:Int, ?lookDir:Int) 
	{
		super.spawn(tileX, tileY, lookDir);
		
		futureMoveDir = getRandomDir();
	}//---------------------------------------------------;
	
	// --
	override function onCoordsChange() 
	{
		return; // debug, never delete??
		if (Reg.map.entityIsOffScreen(this)) {
			kill();
		}
	}//---------------------------------------------------;
	
	// --
	// Autocalled whenever it collides with a wall
	override public function onCollision_Wall(a:EntityTopDown, b:FlxTilemap) 
	{
		// Eveytime it collides, turn left or right at random.
		if(FlxG.random.bool())
			futureMoveDir = getTurnLeftDir(currentMoveDir);
		else
			futureMoveDir = getTurnRightDir(currentMoveDir);
	}//---------------------------------------------------;
	
	// --
	// Return the next direction when turning right
	function getTurnRightDir(dir:Int):Int
	{
		return switch(dir) {
			case FlxObject.UP: FlxObject.RIGHT;
			case FlxObject.RIGHT: FlxObject.DOWN;
			case FlxObject.DOWN: FlxObject.LEFT;
			case FlxObject.LEFT: FlxObject.UP;
			default: 0;
		}
	}//---------------------------------------------------;
	// --
	// Return the next direction when turning left
	function getTurnLeftDir(dir:Int):Int
	{
		return switch(dir) {
			case FlxObject.UP: FlxObject.LEFT;
			case FlxObject.LEFT: FlxObject.DOWN;
			case FlxObject.DOWN: FlxObject.RIGHT;
			case FlxObject.RIGHT: FlxObject.UP;
			default: 0;
		}
	}//---------------------------------------------------;
	
	// --
	function getRandomDir():Int
	{
		return DIRECTIONS[Std.random(DIRECTIONS.length)];
	}//---------------------------------------------------;
	
}// --;