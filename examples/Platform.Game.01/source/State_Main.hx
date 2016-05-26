package ;

import djFlixel.Controls;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTileblock;


/**
 * Platform Example 01
 * Jump on enemies like Super Mario
 * ------------------------------------
 * @ V0.1
 * 	. Behavior can be buggy, but I think the basics are there.
 * 
 * @ Controls
 *  . WASD + JK
 *  . Arrow keys
 *  . 360 controller
 * 
 * 
 * Sprites
 * -------
 *  Author: refreshgames
 * 	Url: http://opengameart.org/content/early-80s-arcade-pixel-art-dungeonsslimes-walls-power-ups-etc
 * 
 */
class State_Main extends FlxState
{

	var p:Player;
	var enemies:FlxGroup;
	var floor:FlxTileblock;
	
	// Helper for collisions against map/floor
	var entities:FlxGroup;
	
	// -- Other
	var startY:Int = 160;
	// --
	override public function create():Void
	{
		super.create();
	
		// -- Player
		p = new Player(64, startY);
		add(p);
		
		// -- Bunch of enemies
		enemies = new FlxGroup();
		add(enemies);
		for (i in 0...6) {
			enemies.add(new Enemy(100 + (i * 32), startY));
		}
		
		// -- Things that will collide with floor
		entities = new FlxGroup();
		entities.add(enemies);
		entities.add(p);
		
		// -- A floor
		floor = new FlxTileblock(0, startY + 20, 320, 64);
		floor.loadTiles("assets/floor.png", 16, 16, 0);
		floor.immovable = true;
		add(floor);

		// -- Some infos
		add(new FlxText(2, 2, 0, "Press Enter to reload."));
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		FlxG.collide(entities, floor);
		FlxG.overlap(p, enemies, onCollide_player_enemy);

		#if debug
			Reg.debug_keys();
		#end
		
		if (FlxG.keys.justPressed.ENTER) {
			FlxG.resetGame();
		}
		
		// Check for gamepad connection
		Controls.poll();
		
		super.update(elapsed);
		
	}//---------------------------------------------------;
	
	
	// --
	function onCollide_player_enemy(p:Player, e:Enemy)
	{
		if (!e.alive || !p.alive) return;
		
		FlxObject.updateTouchingFlags(p, e);
		
		if (e.justTouched(FlxObject.WALL)) { // left or right
			p.hurt(1);
		}
		else if (e.justTouched(FlxObject.UP) && p.isFalling) {
			e.hurt(1);
			p.jumpOffEnemy();
		}
		
	}//---------------------------------------------------;
	
	
}// --