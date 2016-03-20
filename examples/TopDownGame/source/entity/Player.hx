package entity;

import djFlixel.Controls;
import djFlixel.SimpleCoords;
import entity.Player;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;


class Player extends EntityTopDown
{
	// General purpose int
	var r1:Int;
	//====================================================;
	
	public function new()
	{
		super();
		SPRITE_WIDTH = 16;
		SPRITE_HEIGHT = 16;
		// --
		// Get player params from the file
		Reg.applyParamsInto("player", this);
		loadSprite("assets/sprites.png", [0, 1], [2, 3], [4, 5]);
		//-- 
		stopAndLook(DEFAULT_LOOK);
		
		// Tell the entity to get movements from the user
		moveGenerator = moveGenerator_INPUT;
	}//---------------------------------------------------;

	override function onEntityMove() 
	{
		super.onEntityMove();
		Reg.map.updateCameraAndFeedData();
	}//---------------------------------------------------;
	
	//--
	// Whenever the tile coords of the player have changed, set the old tile as a step
	override function onCoordsChange()
	{
		Reg.map.setStep(lastCoords.x, lastCoords.y, currentMoveDir);
	}//---------------------------------------------------;
	
	// --
	// Custom wall collision, snaps to the nearest Path
	override function onCollision_Wall(a:EntityTopDown, b:FlxTilemap) 
	{
		// BUG FIX:
		x = Std.int(x);
		y = Std.int(y);
		
		animation.paused = true;
		
		switch(currentMoveDir)
		{
			case FlxObject.LEFT:
				if (Reg.map.col_getAt(coords.x - 1, coords.y) == 0) {
					r1 = coords.y * Reg.map.TILEHEIGHT;
					if (r1 > y) y++; else y--;
					animation.paused = false;
				}				
			case FlxObject.RIGHT:
				if (Reg.map.col_getAt(coords.x + 1, coords.y) == 0) {
					r1 = coords.y * Reg.map.TILEHEIGHT;
					if (r1 > y) y++; else y--;
					animation.paused = false;
				}				
			case FlxObject.UP:
				if (Reg.map.col_getAt(coords.x, coords.y - 1) == 0) {
					r1 = coords.x * Reg.map.TILEWIDTH;
					if (r1 > x) x++; else x--;
					animation.paused = false;
				}				
			case FlxObject.DOWN:
				if (Reg.map.col_getAt(coords.x, coords.y + 1) == 0) {
					r1 = coords.x * Reg.map.TILEWIDTH;
					if (r1 > x) x++; else x--;
					animation.paused = false;
				}
		}
	}//---------------------------------------------------;

}// -- //