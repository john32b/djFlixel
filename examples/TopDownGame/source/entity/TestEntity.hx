package entity;
import flixel.FlxObject;



// = Barebones empty entity,
// . Does not move
// . For testing streaming in and out
class TestEntity extends EntityTopDown
{

	
	// Hold all directions here
	public static var DIRECTIONS:Array<Int> = [
		FlxObject.UP, FlxObject.RIGHT, FlxObject.DOWN, FlxObject.LEFT
	];
	
	public function new() 
	{
		super();
		SPRITE_WIDTH = 16;
		SPRITE_HEIGHT = 16;
		
		Reg.applyParamsInto("enemy", this);
		loadSprite("assets/sprites.png", [6, 7], [8, 9], [10, 11]);
		
		moveGenerator = move_generator;
		
		//-- 
	}//---------------------------------------------------;
	
	
	// This is automatically called every update.
	// Set the futureMoveDir var
	function move_generator()
	{
		futureMoveDir = getRandomDir();
	}//---------------------------------------------------;
	
	// --
	function getRandomDir():Int
	{
		return DIRECTIONS[Std.random(DIRECTIONS.length)];
	}//---------------------------------------------------;
	
}// --