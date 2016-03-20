package entity;

import djFlixel.Controls;
import djFlixel.map.TiledLoader.MapEntity;
import djFlixel.SimpleCoords;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;

/**
 * Generic TOPDOWN entity, Move freely on a grid.
 * 
 * Version 0.1
 * -----------
 * . Currently supports simple animations.
 * 
 * 
 * Guidelines
 * ------------
 * . For simple animated sprites, One frame wait
 * . SPRITES_SHEET : UP,DOWN,RIGHT, ( left is mirrored )
 * . 
 */

class EntityTopDown extends FlxSprite
{
	// ===
	// You can set these by hand, or call Reg.applyParamsInto to 
	// copy these values from the parameters JSON file
	var ANIMATION_FPS:Int;
	var MOVE_SPEED:Float;
	var WAIT_FRAME_DOWN:Int;
	var WAIT_FRAME_UP:Int;
	var WAIT_FRAME_SIDE:Int;
	// --
	var SPRITE_WIDTH:Int;
	var SPRITE_HEIGHT:Int;
	// -- 
	// What is the default looking direction for entities when spawned
	var DEFAULT_LOOK:Int;
	
	// Hold the current tile coordinates of the entity
	public var coords(default, null):SimpleCoords;

	// Keep the previous coordinates
	var lastCoords:SimpleCoords;
	
	// # Extended class could set this.
	// If this is set, then the next frame will move the entity to this direction
	var futureMoveDir:Int;
	
	// If the entity is currently moving, this is the direction
	// Zero for not moving
	// Prevent re-setting already set moving states. Save some CPU
	public var currentMoveDir(default, null):Int;
	
	// Some entities will be deleted whtn they go off screen by a manager
	public var flag_auto_kill_when_offscreen:Bool; /// TEST
	
	// Same UID as the mapentity, public because its set externally
	public var UID:Int;	
	
	// # USER SET #
	// Set this function to a predefined or new function
	// That sets the futureMoveDir at every cycle.
	// Could be AI or whatever
	var moveGenerator:Void->Void;
	
	//---------------------------------------------------;
	// FLAGS:
	
	// If true, then it gets no user input
	public var noUserInput:Bool;
	
	//====================================================;
	public function new() 
	{
		super();
		//--
		coords = new SimpleCoords();
		lastCoords = new SimpleCoords();
		
		DEFAULT_LOOK = FlxObject.RIGHT;
		
		noUserInput = false;
		
		moveGenerator = function() { };
		
	}//---------------------------------------------------;
	
	
	/**
	 * Spawn an entity at TILE COORDINATES
	 * 
	 * @param	tileX
	 * @param	tileY
	 * @param	lookDir
	 */
	public function spawn(tileX:Int, tileY:Int, ?lookDir:Int)
	{
		x = tileX * Reg.map.TILEHEIGHT; // WARN: Works of if tilesize == spritesize, else needs fixing
		y = tileY * Reg.map.TILEHEIGHT; // 
		
		if (lookDir == null) lookDir = DEFAULT_LOOK;
		
		facing = lookDir;
		stopAndLook(lookDir);
		
		calculateCoords();
		lastCoords.copyFrom(coords);
		
	}//---------------------------------------------------;
	
	
	// --
	// Stops all movement and sets a waiting frame depending on the facing.
	// Future, could upgrade to play an animation on wait.
	function stopAndLook(dir:Int)
	{
		animation.stop();
		// Wait to a specific frame, depending on what the dir you stopped
		animation.frameIndex = switch(dir) {
			case FlxObject.LEFT | FlxObject.RIGHT: WAIT_FRAME_SIDE;
			case FlxObject.DOWN : WAIT_FRAME_DOWN;
			case FlxObject.UP : WAIT_FRAME_UP;
			default: WAIT_FRAME_SIDE;
		}
		
		currentMoveDir = 0;
		futureMoveDir = 0;
		velocity.set(0, 0);
		// facing = dir; Redundant when called from user_input, only spawn() needs it. so call it there
	}//---------------------------------------------------;
	
	// --
	// Be sure to set the sprite parameters before calling this
	function loadSprite(image:String, sideFrames:Array<Int>, downFrames:Array<Int>, upFrames:Array<Int>)
	{
		loadGraphic(image, true, SPRITE_WIDTH, SPRITE_HEIGHT);
		animation.add("side", sideFrames, ANIMATION_FPS);
		animation.add("down", downFrames, ANIMATION_FPS);
		animation.add("up", upFrames, ANIMATION_FPS);
	}//---------------------------------------------------;
	
	// --
	// Helper,
	// Figure out the current coordinates based on the position
	inline function calculateCoords()
	{
		// Calculate new Coordinates
		coords.x = Std.int((x + 8) / Reg.map.TILEWIDTH); // FIXME (8) = spritewidth / 2 
		coords.y = Std.int((y + 8) / Reg.map.TILEHEIGHT);	
		
		#if debug
		if (tileRect != null) {	
			tileRect.x = coords.x * Reg.map.TILEWIDTH;
			tileRect.y = coords.y * Reg.map.TILEWIDTH;	
		}
		#end
	}//---------------------------------------------------;

	// --
	override public function update(elapsed:Float):Void 
	{
		moveGenerator();
		updateMovement();
		super.update(elapsed);
	}//---------------------------------------------------;
	
	
	// Move the entity based on the futureMoveDir
	// FutureMoveDir is set by the extended objects
	// and handled there. Player uses user input, 
	// Enemies use AI	
	function updateMovement()
	{
		switch(futureMoveDir)
		{
			case FlxObject.UP:
				velocity.set(0, -MOVE_SPEED);
				if (currentMoveDir != FlxObject.UP) {
					facing = FlxObject.UP;
					currentMoveDir = FlxObject.UP;
					animation.play("up", true);
				}
				onEntityMove();
			case FlxObject.DOWN:
				velocity.set(0, MOVE_SPEED);
				if (currentMoveDir != FlxObject.DOWN) {
					currentMoveDir = FlxObject.DOWN;
					facing = FlxObject.DOWN;
					animation.play("down", true);
				}
				onEntityMove();
			case FlxObject.LEFT:
				velocity.set( -MOVE_SPEED, 0);
				if (currentMoveDir != FlxObject.LEFT) {
					currentMoveDir = FlxObject.LEFT;
					facing = FlxObject.LEFT;
					animation.play("side", true);
					flipX = true;
				}
				onEntityMove();
			case FlxObject.RIGHT:
				velocity.set(MOVE_SPEED, 0);
				if (currentMoveDir != FlxObject.RIGHT) {
					currentMoveDir = FlxObject.RIGHT;
					facing = FlxObject.RIGHT;
					animation.play("side", true);
					flipX = false;
				}
				onEntityMove();
			default: // no movement
				if (currentMoveDir != 0) 
					stopAndLook(currentMoveDir);
				
		}
		
	}//---------------------------------------------------;
			
	//====================================================;
	// TEMPLATED MOVEMENT GENERATORS
	//====================================================;
	
	/**
	 * Reads the keyboard and requests movements
	 * . You must set the moveGenerator to this function at object creation
	 */
	function moveGenerator_INPUT()
	{
		if (noUserInput) return;
		
		if (Controls.pressed(Controls.UP)) {
			futureMoveDir = FlxObject.UP;
		}
		else if (Controls.pressed(Controls.DOWN)) {
			futureMoveDir = FlxObject.DOWN;
		}
		else if (Controls.pressed(Controls.LEFT)) {
			futureMoveDir = FlxObject.LEFT;
		}
		else if (Controls.pressed(Controls.RIGHT)) {
			futureMoveDir = FlxObject.RIGHT;
		}else {
			futureMoveDir = 0;
		}
	}//---------------------------------------------------;

	
	// This is called whenever the entity has moved,
	// Updates TILE coordinates and last TILE coords
	function onEntityMove()
	{
		calculateCoords();
		
		// If the tile pos change, put a step there on the map
		if (!coords.isEqual(lastCoords)) {
			onCoordsChange();
			lastCoords.copyFrom(coords);
		}
	}//---------------------------------------------------;
	
	
	// -- OVERRIDE THIS --
	// Called whenever the TILE coordinates of the sprite have changed
	function onCoordsChange()
	{
	}//---------------------------------------------------;
	
	
	// # Called externally on collision checks
	// -- OVERRIDE THIS --
	// Wall collisions should be sent and handled here:
	public function onCollision_Wall(a:EntityTopDown, b:FlxTilemap)
	{
	}//---------------------------------------------------;
	
	
	

	//====================================================;
	// Some DEBUGGING functionality
	//====================================================;
	#if debug
	// Visual rect of the current Rect
	var tileRect:FlxSprite = null;
	// --
	public function debug_getTileRect():FlxSprite
	{
		if (tileRect == null) {
			tileRect = new FlxSprite();
			tileRect.makeGraphic(SPRITE_WIDTH, SPRITE_HEIGHT, 0xFFFF0000);
			tileRect.alpha = 0.5;
		}
		return tileRect;
	}//---------------------------------------------------;
	#end
	
}// ---