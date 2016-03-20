package;

import djFlixel.map.TiledLoader.MapEntity;
import entity.EntityTopDown;
import entity.Mummy;
import entity.Player;
import entity.TestEntity;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import entity.Player;
import flixel.tile.FlxTilemap;
import tiles.TileEditor;
import tiles.TileSprites;

class State_Main extends FlxState
{
	var player:Player;	
	var enemies:FlxTypedGroup<EntityTopDown>;

	//====================================================; 
	// --
	override public function create():Void
	{		
		super.create();
		
		Reg.map = new Gamemap();
		Reg.map.OBJECT_LAYER = "objects";
		
		//-- Create the map;
		
		// Checks for maps in the "assets/maps/" dir
		// All maps are required to have the ".tmx" extension
		// So I can just call this: 
		Reg.map.loadLevel("level_01");
		add(Reg.map.layerBG);

		//--
		player = new Player();
		add(player);
		// #if debug add(player.debug_getTileRect()); #end
		player.spawn(Reg.map.player.x, Reg.map.player.y);
		// --
		enemies = new FlxTypedGroup();
		add(enemies);
		
		// --
		var txt = new FlxText(4, 4, 0, '${Reg.NAME} . ${Reg.VERSION}' );
		txt.scrollFactor.set(0, 0);
		add(txt);
		
		Reg.map.camera.follow(player, null, 40);
		
		// --
		// is called whenever an entity needs to spawn
		Reg.map.onStreamEntity = onStreamEntity;
		// is called whenever the camera coords change, to delete objects off screen
		Reg.map.onCameraCoordsChange = onCameraCoordsChange;
		// Immediately load the visible room data
		Reg.map.feedRoomData();
	}//---------------------------------------------------;
	
	
	// --
	override public function destroy():Void
	{
		Reg.map.destroy();
		super.destroy();
	}//---------------------------------------------------;

	// --
	// NOTE:
	// . Streaming entities are checked whenever the player moves
	// 	 ( called from player class )
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		FlxG.collide(player,  Reg.map.layerBG, onCollide_entity_wall);
		FlxG.collide(enemies, Reg.map.layerBG, onCollide_entity_wall);
		FlxG.overlap(player, enemies, onCollide_player_enemy);
		
		#if debug
			// This will reload the all the external files and reset the game on the F12 key
			Reg.OnKeyReloadParamsAndGame();
		#end

	}//---------------------------------------------------;
	
	//====================================================;
	// STREAMING ENTITIES FROM THE MAP 
	//====================================================;
	
	function onStreamEntity(en:MapEntity)
	{
		// TODO:
		// 1. Check to see if THE UID of this entity does not exist on screen
		//		if it does, skip it, If it does not add it
		enemies.forEachAlive(function(e:EntityTopDown) {
			if (e.UID == en.uid) {
				trace("Entity exists, skipping");
			}
		});
				
		if (en.id == TileEditor.MUMMY)
		{
			var m = enemies.recycle(Mummy);
			m.UID = en.uid;
			m.spawn(en.x, en.y);
			enemies.add(m);
		}else if (en.id == TileEditor.TEST)
		{
			var m = enemies.recycle(TestEntity);
			m.UID = en.uid;
			m.spawn(en.x, en.y);
			enemies.add(m);
		}else
		{
			// Streaming Entity is something else. skip.
			return;
		}
		
	}//---------------------------------------------------;
	
	
	// --
	// Gets called on cameracoords change
	function onCameraCoordsChange()
	{
		for (i in enemies) {
			if (Reg.map.entityIsOffScreen(i)) {
				//enemies.remove(i);
				i.kill();
			}
		}
	}//---------------------------------------------------;
	
	
	//====================================================;
	// COLLISION HANDLERS
	//====================================================;
	
	function onCollide_entity_wall(en:EntityTopDown, wall:FlxTilemap)
	{
		en.onCollision_Wall(en, wall);
	}//---------------------------------------------------;
	// --
	function onCollide_player_enemy(pl:Player, en:EntityTopDown)
	{
		en.kill();
		//enemies.remove(en);
	}//---------------------------------------------------;
	

}// --