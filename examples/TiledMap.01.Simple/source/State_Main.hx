package;

import djFlixel.Controls;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import djFlixel.map.MapTemplate;
/**
 * Map Example 01
 * =======================
 * 
 * 	+ Basic how to load and display a Tiled Map File
 *  + Use Controls to pan camera
 *  + Uses params.JSON to load basic parameters for the map
 * 
 */
class State_Main extends FlxState
{
	// A map Template is an object containing the layer Object 
	// as well as other info about a level
	var map:MapTemplate;
	// --
	var CAMERA_SPEED:Float = 8;
	//====================================================;
	// --
	override public function create():Void
	{		
		super.create();
		
		// MapTemplate uses parameters stored into the 'assets/data/params.json' file
		// Parameters must be under a "map" root node
		map = new MapTemplate();
		/* 
		 * Explanation of the json parameters ::
		 * Check "assets/data/params.json" for the application example
		{
			# STREAM_PAD_X and STREAM_PAD_Y :
				Affects streamable objects, How much padding from the edge of the screen
				to trigger a spawn.
				
			# BG_COLOR :
				BG color of the camera, tiles with 0 will not be drawn
				
			# BG_TILEWIDTH, BG_TILEHEIGHT :
				Tile width and height in pixels the map uses
				
			# BG_STARTING_INDEX :
				1 means that indexing starts from 1
				
			# BG_DRAW_INDEX :
				Draws all tiles after this index
				
			# BG_COL_START :
				Tiles with index > this, will be collidable
				
			# BG_LAYER :
				Name of the layer of the background tiles
				
			# BG_TILES :
				Path of the tileset 
		}
		*/
	
		// Add the main map layer.
		add(map.layerBG);
		
		// All map files must be in "assets/maps/" 
		// Note: Camera will automatically adjust the scroll bounds according to the map
		map.loadLevel("level_01");
		
		// -- Add some text info on the hud --
		for (c in 0...Reg.JSON.titleText.length) {
			var txt = new FlxText((c), (c * 10), 0, Reg.JSON.titleText[c]);
			txt.setBorderStyle(FlxTextBorderStyle.OUTLINE_FAST, 0xFF111111);
			txt.scrollFactor.set(0, 0);
			add(txt);
		}
	}//---------------------------------------------------;
	
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// Poll for a joystick, applies automatically if discovered
		// Useful when opening flash on a browser
		Controls.poll();
		
		// -- Scroll the map by key input
		// Checks WASD, ARROW KEYS and JOYSTICK
		if (Controls.pressed(Controls.LEFT)) {
			camera.scroll.x -= CAMERA_SPEED;
		}
		else if (Controls.pressed(Controls.RIGHT)) {
			camera.scroll.x += CAMERA_SPEED;
		}
		
		if (Controls.pressed(Controls.UP)) {
			camera.scroll.y -= CAMERA_SPEED;
		}
		else if (Controls.pressed(Controls.DOWN)) {
			camera.scroll.y += CAMERA_SPEED;
		}
	
	}//---------------------------------------------------;
	
	// --
	override public function destroy():Void 
	{
		super.destroy();
		map.destroy();
	}//---------------------------------------------------;

}// --