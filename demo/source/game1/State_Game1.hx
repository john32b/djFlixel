/**
 * Quick Game
 * Jump on enemies like Super Mario
 * ------------------------------------
 * 
 * Sprites
 * -------
 *  Author: refreshgames
 * 	Url: http://opengameart.org/content/early-80s-arcade-pixel-art-dungeonsslimes-walls-power-ups-etc
 * 
 * This is from a really old version, I don't know if it offers anything, but it is fun
 * 
 ******************************************************************************/

package game1;

import djFlixel.D;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTileblock;
import game1.GameSprites;



class State_Game1 extends FlxState
{
	var p:Player;
	var enemies:FlxGroup;
	var floor:FlxTileblock;
	
	// Helper for collisions against map/floor
	var entities:FlxGroup;
	
	// -- Other
	var startY:Int = 160;
	
	override public function create():Void
	{
		super.create();
		
		bgColor = 0xFF222255;
	
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
		floor.loadTiles("im/g_fl.png", 16, 16, 0);
		floor.immovable = true;
		add(floor);
		
		// DEV: This should be an InfoBox...
		D.align.pInit(0, 0, FlxG.width, 120);
		D.align.PLACE_ADD = true;
		D.align.pT("~$Arrows/Wasd$:Move $(K)$:Jump - $Gamepad$ supported");
		D.align.pT("Hold Jump when jumping on enemies to gain height");
		D.align.pT("~#[1]# to Restart");
		D.align.pT("~#[2]# to Exit");
		
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		FlxG.collide(entities, floor);
		FlxG.overlap(p, enemies, onCollide_player_enemy);
		
		if (FlxG.keys.justPressed.ONE)
		{
			FlxG.resetState();
		}else
		if (FlxG.keys.justPressed.TWO)
		{
			Main.create_add_8bitLoader(0.7, State_Menu1);
		}
		// Keep checking for a gamepad
		D.ctrl.gamepad_poll();
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