/**
 # MapTemplate.hx
 # -----------------------------------------------------

 FEATURES
 ----------
 
  + Provides a quick solution to load TILED maps
  + Streamable Objects are FlxSprites that are 
    autocreated and autodestroyed as the camera pans
  + Extend this class for more control
  + Reads INFO from the main "params.json" file "map" node
 
  USAGE
  ----------
  . Be sure to have some basic info in the PARAMS.JSON file
  . Call updateCameraAndFeedData() every time the player moves to get new entities
  
  # :: Json Node Example ::
 
	"map" : {
		"STREAM_PAD_X" : 1,  "STREAM_PAD_Y" : 1,
		"BG_TILEWIDTH" : 16, "BG_TILEHEIGHT" : 16,
		"BG_STARTING_INDEX" : 1, "BG_DRAW_INDEX" : 1, "BG_COL_START" : 31,
		"BG_LAYER" : "tiles", "OBJECT_LAYER" : "objects", "DATA_LAYER" : "data",
		"BG_TILES" : "assets/layerBG.png",
		"BG_COLOR" : "0xFF221122"
	}
	
  :: STREAM_PAD_X,Y is the amount of tiles to read ahead on streaming objects ::
  :: Streamable objects must extend the StreamableSprite class
  ::
  
 ================================================== */

 
package djFlixel.map;

import djFlixel.map.TiledLoader;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;

import flash.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

import djFlixel.map.StreamableSprite;

class MapTemplate implements IFlxDestroyable
{
	// Default paths for the maps:
	public var MAP_DIRECTORY:String = "maps/";
	public var MAP_EXTENSION:String = ".tmx";
	
	// Hold the active map tilesizes
	public var TILEWIDTH:Int;
	public var TILEHEIGHT:Int;
	
	// Map size:
	public var mapWidth(default, null):Int; 	// map size in tiles
	public var mapHeight(default, null):Int; 	// --
	public var width(default, null):Int;		// map size in pixels
	public var height(default, null):Int;		// --
	
	public var cameraWidth(default, null):Int;	// How many tiles fit on the rendering view. Rounded UP
	public var cameraHeight(default, null):Int;	// --
	
	var cameraPos:SimpleCoords; 	// Camera start tile coords
	var cameraPosOld:SimpleCoords;  // Previous var
	
	// Every entity on the map should have a unique ID
	var UIDGEN:Int;
	
	// Default camera
	public var camera:FlxCamera;
	
	// Every map should have a basic background layer
	public var layerBG:FlxTilemap;
	
	// -----------------------------------;
	
	// # USER SET - ( MUST BE SET )
	// This will be called with map entities that need to be added to the game
	// DON'T FORGET to push created objects to streamedObjects[]
	public var onStreamEntity:MapEntity->Void = function(m:MapEntity) { };
	
	// # LAYER FOR STREAMING OBJECTS
	// This layer holds data in tile format, not actual drawn tiles.
	// Tiles in this layer will be streamed in and out
	var streamingLayer:Array<Array<MapEntity>>;
	
	// # LAYER FOR DATA OBJECTS
	// This layer holds data in entity format, meaning 
	//	not tile restricted X,Y coords and custom metadata, json parameters
	// Store the map entities with a key of "$xtile,$ytile"
	var dataLayer:Map<String,MapEntity>;
	
	// Search for this much more at the top and bottom for entities
	// A value of 0 will stream in entities just as they scroll into view.
	var vPadding:Int = 0;
	var hPadding:Int = 0;
	
	// Tiled map files data loader
	var loader:TiledLoader;
	
	// Current level name, it's the filename of the level loaded without /assetdir/ and extension
	// e.g. "/assets/maps/" $currentlevel ".tmx"
	public var currentLevel(default, null):String;

	
	// Hold all the onscreen streamable objects
	// Objects here are auto-destroyed when off screen
	// Dead objects should not be in here!
	// * User should push objects here *
	public var streamedObjects:Array<StreamableSprite>;
	
	// Helper var for deletions when iterating streamobjects
	var deleteQueue:Array<StreamableSprite>;
	
	// -- HELPERS
	// General purpose Ints
	var rx:Int;
	var ry:Int;
	
	// Pre-calculated vars for streaming entities
	var _camVF:Int;
	var _camHF:Int;
	
	// If you use and data object layer you MUST set the tileset filename here
	// Used to calculate offsets and entity sizes
	public var dataObjectTileset:String;
	
	// Set on override, special occasion when you use same image on multiple layers
	var SKIP_GID_LAYERS:Array<String> = null;
	//====================================================;
	// --
	public function new() 
	{
		loader = new TiledLoader();
		layerBG = new FlxTilemap();
		
		// -- Read parameters
		TILEWIDTH = FLS.JSON.map.BG_TILEWIDTH;
		TILEHEIGHT = FLS.JSON.map.BG_TILEHEIGHT;
		
		hPadding = FLS.JSON.map.STREAM_PAD_X;
		vPadding = FLS.JSON.map.STREAM_PAD_Y;
		
		// Use the default camera, use setCustomViewport() later
		camera = FlxG.camera;
		if (FLS.JSON.map.BG_COLOR != null)
			camera.bgColor = FlxColor.fromString(FLS.JSON.map.BG_COLOR);
		
		// Hold the camera starting point in tile coords
		cameraPos = new SimpleCoords();
		cameraPosOld = new SimpleCoords();
		
		// Calculate the camera viewport in tiles
		cameraWidth = Math.ceil(camera.width / TILEWIDTH);
		cameraHeight = Math.ceil(camera.height / TILEHEIGHT);
		
		_camVF = cameraHeight + vPadding;	// Reduce a calculation later at the streaming 
		_camHF = cameraWidth + hPadding;
		
		trace("Camera Area Size in Tiles", cameraWidth, cameraHeight);
	}//---------------------------------------------------;
	
	
	
	/**
	 * Create a new camera to display the map. Useful if you want a smaller rectangle rendering the game
	 * NOTE: You should manually add the camera to the FLXG.cameras list later
	 * @param	x Screen start
	 * @param	y Screen start
	 * @param	width 
	 * @param	height
	 */
	public function setCustomViewport(x:Int, y:Int, width:Int, height:Int)
	{
		camera = new FlxCamera(x, y, width, height, 0);
		if (FLS.JSON.map.BG_COLOR != null)
			camera.bgColor = FlxColor.fromString(FLS.JSON.map.BG_COLOR);
		camera.antialiasing = FLS.ANTIALIASING; // apply the AA status to this cam
		layerBG.cameras = [camera];
		
		// Don't forget to re-set the camera size
		cameraWidth = Math.ceil(camera.width / TILEWIDTH);
		cameraHeight = Math.ceil(camera.height / TILEHEIGHT);
		
		_camVF = cameraHeight + vPadding;	// Reduce a calculation later at the streaming 
		_camHF = cameraWidth + hPadding;
		
		FlxG.cameras.add(camera);
		
		trace("Camera Area Size in Tiles", cameraWidth, cameraHeight);
	}//---------------------------------------------------;
		
	
	// --
	public function destroy()
	{
		reset();
		loader = FlxDestroyUtil.destroy(loader);
		camera = FlxDestroyUtil.destroy(camera);
		layerBG = FlxDestroyUtil.destroy(layerBG);
		streamedObjects = null;
		deleteQueue = null;
		dataLayer = null;
	}//---------------------------------------------------;
	
	
	// -- Reset and map elements before loading a new map
	// -- # Automatically called
	function reset()
	{
		// -- Clear the streaming layer
		streamingLayer = null;
		dataLayer = null;
		streamedObjects = [];
		deleteQueue = [];
		
	}//---------------------------------------------------;

	/**
	 * Load a map file, clears the object automatically before loading
	 * @param	levelID This must be at "assets/maps/" + levelID + "tmx"
	 */
	public function loadLevel(levelID:String)
	{
		reset();
		
		currentLevel = levelID;
		
		loader.loadFile(MAP_DIRECTORY + currentLevel + MAP_EXTENSION, SKIP_GID_LAYERS);
		
		mapWidth = loader.mapWidth;
		mapHeight = loader.mapHeight;
		width = mapWidth * TILEWIDTH;
		height = mapHeight * TILEHEIGHT;
		
		// - Load the basic layer
		layerBG.loadMapFrom2DArray(loader.layerTiles.get(FLS.JSON.map.BG_LAYER),
					FLS.JSON.map.BG_TILES, TILEWIDTH, TILEHEIGHT, null,
					FLS.JSON.map.BG_STARTING_INDEX, 
					FLS.JSON.map.BG_DRAW_INDEX,
					FLS.JSON.map.BG_COL_START);
		
		layerBG.updateBuffers(); // new bug fix
		
		// - Any more layers have to be loaded by an extended class
		// ---> ()
		
		// This sets the worldbounds and the camera bounds:
		camera.setScrollBoundsRect(0, 0, width, height, true);
		camera.onResize();
		
		trace(' .. map loaded [OK] | mapWidth = $mapWidth | mapHeight = $mapHeight');
		
		// Create those objects 
		// Because a data check could be called externally.
		streamingLayer = new Array<Array<MapEntity>>();
		dataLayer = new Map();
		
		// Load those 2 from the JSON, #optional
		var OBJECT_LAYER:String = FLS.JSON.map.OBJECT_LAYER;
		var DATA_LAYER:String = FLS.JSON.map.DATA_LAYER;
		
		// - Streaming entities --
		// - Scan the ENTIRE objects layer to get data:
		if (OBJECT_LAYER != null)
		{			
			UIDGEN = 0;
			for (yy in 0...mapHeight) streamingLayer[yy] = [];
			applyOnTileLayer(OBJECT_LAYER, function(x:Int, y:Int, tile:Int) {
				// Give each entity a unique ID
				streamingLayer[y][x] = { x:x, y:y, id:tile, uid: ++UIDGEN };
				manageTileData(x, y, tile);
			});
			
		}// --
		
		// - Now scan any DATA layer
		if (loader.layerEntities.exists(DATA_LAYER))
		{
			var tileSizeHalf:Int = Std.int(loader.tilesetWidths.get(dataObjectTileset) / 2);
			var tileX:Int;
			var tileY:Int;
			
			// ERROR ::
			// Automatically fix the entity ID offset ??
			// First Tile starts at 1
			var idOffset = loader.tilesetFirstGid.get(dataObjectTileset) - 1;
			
			for (i in loader.layerEntities.get(DATA_LAYER))
			{
				i.id -= idOffset;
				tileX = Std.int((i.x + tileSizeHalf) / TILEWIDTH);
				tileY = Std.int((i.y + tileSizeHalf) / TILEHEIGHT);
				dataLayer.set('$tileX,$tileY', i);
				// Optional handle this entity:
				manageDataAt(tileX, tileY, i);
			}
		}// --
		
		// DEVNOTE: At this point I could free up some memory
		//			by freeing the tileloader ?
		
	}//---------------------------------------------------;

	
	//====================================================;
	// TILE DATA STREAMING
	//====================================================;

	
	// --
	// Check the entire screen area, and callback for entities
	// Feedback for entities on the screen.
	public function feedRoomData()
	{	
		// Just in case.
		if (camera.target != null) {
			camera.snapToTarget();
			camera.updateFollow();
			camera.updateScroll();
		}
		
		cameraPos.x = Std.int(camera.scroll.x / TILEWIDTH);
		cameraPos.y = Std.int(camera.scroll.y / TILEHEIGHT);
		
		// There are cases where this could be < 0  
		if (cameraPos.x < 0) cameraPos.x = 0;
		if (cameraPos.y < 0) cameraPos.y = 0;
		
		cameraPosOld.copyFrom(cameraPos);
		
		// Just in case
		deleteOffScreen();
		
		for (rx in (cameraPos.x - hPadding)...(cameraPos.x + _camHF + 1)) // x axis
		for (ry in (cameraPos.y - vPadding)...(cameraPos.y + _camVF + 1)) // y axis
		{
			feedDataFromCoords(rx, ry);
		}
			
	}//---------------------------------------------------;
		
	// --
	// Check the camera edges and feed discovered entities to the feeder
	// Call this on every update or less.
	public function updateCameraAndFeedData()
	{
		cameraPos.x = Std.int(camera.scroll.x / TILEWIDTH);
		cameraPos.y = Std.int(camera.scroll.y / TILEHEIGHT);
		
		if (!cameraPos.isEqual(cameraPosOld))
		{
			// NEW: Check enemies at a timer, not each time it scrolls
			// deleteOffScreen(); 
			
			// Camera changed tile pos
			feedDataFromRow(cameraPos.y - cameraPosOld.y);
			feedDataFromColumn(cameraPos.x - cameraPosOld.x);
			
			cameraPosOld.copyFrom(cameraPos);
		}
		
	}//---------------------------------------------------;
	
	// Check a column at the edge of the viewport for entities
	// Positive delta checks down, negative checks up
	// 
	// #inline as it it called once.
	inline function feedDataFromColumn(delta:Int)
	{
		if (delta == 0) return;
		
		if (delta > 0) {
			for (rx in (cameraPos.x + _camHF - delta + 1)...(cameraPos.x + _camHF + 1)) {
				//trace("Checking column", rx);
				for (ry in (cameraPos.y - vPadding)...(cameraPos.y + _camVF + 1)) 
					feedDataFromCoords(rx, ry);
			}
		} 
		else {
			for (rx in (cameraPos.x - hPadding)...(cameraPos.x - delta - hPadding)) {
				//trace("Checking column", rx);
				for (ry in (cameraPos.y - vPadding)...(cameraPos.y + _camVF + 1))
					feedDataFromCoords(rx, ry);
			}
		}
		
	}//---------------------------------------------------;
	
	// Check a row at the edge of the viewport for entities
	// Positive delta checks down, negative checks up
	//
	// #inline as it is called once, make it a bit faster?
	inline function feedDataFromRow(delta:Int)
	{
		if (delta == 0) return;
		
		if (delta > 0) {
			for (ry in (cameraPos.y + _camVF - delta + 1)...(cameraPos.y + _camVF + 1)) {
				//trace("Checking row", ry );
				for (rx in (cameraPos.x - hPadding)...(cameraPos.x + _camHF + 1))
					feedDataFromCoords(rx, ry);
				}
			}
		else {
			for (ry in (cameraPos.y - vPadding)...(cameraPos.y - delta - vPadding)) {
				//trace("Checking row", ry);
				for (rx in (cameraPos.x - hPadding)...(cameraPos.x + _camHF + 1)) 
					feedDataFromCoords(rx, ry);
			}
		}
	}//---------------------------------------------------;
	
	// --	
	// Check for offscreen entities and delete them.
	// Usually called from a timer or in feedRoomData();
	public function deleteOffScreen() 
	{
		// Check for offscreen entities and kill them.
		// --
		for (i in streamedObjects) {
			if (entityIsOffScreen(i)) {
				deleteQueue.push(i);
				i.kill(); 
				// trace("- KILLED OFF SCREEN");
			}
		}
		for (i in deleteQueue) {
			FlxArrayUtil.fastSplice(streamedObjects, i);
		}
		
		deleteQueue = [];	
	}//---------------------------------------------------;
	

	/**
	 * Scan all the layers and callback to user to handle map entities
	 * 
	 * @param	x tile coords
	 * @param	y tile coords
	 */
	function feedDataFromCoords(x:Int, y:Int)
	{
		try {
		
			if (streamingLayer[y][x] == null) return;
			
			for (i in streamedObjects) {
				if (i.exists && streamingLayer[y][x].uid == i.UID) {
					// trace("Already exists", streamingLayer[y][x]);
					return;
				}
			}
			
			// Call to user function to handle the entity
			onStreamEntity(streamingLayer[y][x]);
			
		}catch (e:Dynamic)
		{
			// do nothing;
			// trace("Feed Data off bounds!", x, y);
		}
	}//---------------------------------------------------;

	// --
	// Quick way to figure out if an entity is offscreen
	// Tile based
	// New: Apply some padding
	public inline function entityIsOffScreen(en:StreamableSprite):Bool
	{
		return (en.coords.x + en.offscreen_kill_pad < cameraPos.x - hPadding ||
				en.coords.y + en.offscreen_kill_pad < cameraPos.y - vPadding ||
				en.coords.x - en.offscreen_kill_pad > cameraPos.x + _camHF   ||
				en.coords.y - en.offscreen_kill_pad > cameraPos.y + _camVF );
	}//---------------------------------------------------;
	
	/**
	 * Check if a sprite is off screen using REAL WOLRD coordinates
	 * @param	sprite
	 * @return
	 */
	@:deprecated("Use FlxSprite.onscreen()")
	public inline function spriteIsOffScreen(sprite:FlxSprite):Bool
	{
		return false;
		//return (	sprite.x < camera.scroll.x ||
					//sprite.x > camera.scroll.x + camera.width ||
					//sprite.y < camera.scroll.y ||
					//sprite.y > camera.scroll.y + camera.height );
	}//---------------------------------------------------;
	
	
	//====================================================;
	// MAP DATA RELATED: 
	//====================================================;
	
	
	// Returns the mapEntity on the DATA layer
	// , If nothing is found, returns NULL
	public inline function getDataObjectAt(x:Int, y:Int):MapEntity
	{
		return dataLayer.get('$x,$y');
	}//---------------------------------------------------;
	public function getDataObjectStrAt(x:Int, y:Int):String
	{
		var obj = getDataObjectAt(x, y);
		if (obj != null) return obj.type; else return "";
	}//---------------------------------------------------;
	public function getDataObjectIdAt(x:Int, y:Int):Int
	{
		var obj = getDataObjectAt(x, y);
		if (obj != null) return obj.id; else return -1;
	}//---------------------------------------------------;	
	
	// --
	// Read a tile from the streaming layer.
	public function getStreamingTileAt(x:Int, y:Int):Int
	{
		if (streamingLayer[y][x] != null)
			return streamingLayer[y][x].id;
		else
			return -1;
	}//---------------------------------------------------;
	
	// --
	public inline function getStreamingEntity(x:Int, y:Int):MapEntity
	{
		return streamingLayer[y][x];
	}//---------------------------------------------------;

	// --
	// Set a new tile at the streaming layer
	public function setStreamingTileAt(x:Int, y:Int, tile:Int, ?type:String):MapEntity
	{
		streamingLayer[y][x] = { x:x, y:y, id:tile, uid: ++UIDGEN, type:type };
		return streamingLayer[y][x];
	}//---------------------------------------------------;
	
	// --
	// x,y :: Tile Coordinates
	public function removeEntityFromMap(x:Int, y:Int, sprite:StreamableSprite)
	{
		streamingLayer[y][x] = null;
		// #if debug
		// if (streamedObjects.indexOf(sprite) < 0) {
		//		trace("Error: Sprite does not exist in array");
		// }
		// #end
		FlxArrayUtil.fastSplice(streamedObjects, sprite);
	}//---------------------------------------------------;
	
	/// This is automatically called on map load
	// -- OVERRIDE THIS --
	// The object layer is always scanned for data
	// Manage specific entities here, like the player spawn point, etc
	function manageTileData(x:Int, y:Int, id:Int)
	{
	}//---------------------------------------------------;
	
	/// This is automatically called on map load
	// -- OVERRIDE THIS --
	// The entity layer is always scanned once for data
	// You can check for things here
	function manageDataAt(x:Int, y:Int, en:MapEntity)
	{
		// x, y is TileSize
		// en.x en.y are world values
	}//---------------------------------------------------;
	
	// -- Scan the BG layer and callback (xpos,ypos,tileid)
	function scanBGLayer(fn:Int->Int->Int->Void)
	{
		var tile:Int;
		for (yy in 0...mapHeight) 
		for (xx in 0...mapWidth) {
			tile = layerBG.getTile(xx, yy);
			if (tile > 0) {
				fn(xx, yy, tile);
			}
		}
	}//---------------------------------------------------;
	
	
	
	
	 /**
	  * Scan a layer and for each tile it finds, call a function 
	  * Useful to get player spawn points, enemies, etc.
	  * @param	layerName The name of the layer is it is in the TILED editor
	  * @param	handler callback :: function(coordsX,coordsY,tileID);
	  */
	function applyOnTileLayer(layerName:String, handler:Int->Int->Int->Void)
	{
		var tiles:Array<Array<Int>> = loader.layerTiles.get(layerName);
		var t:Int;	// temp tile
		for (xx in 0...mapWidth)
		for (yy in 0...mapHeight)
		{
			t = tiles[yy][xx];
			
			if (t > 0) {
				handler(xx, yy, t);
			}
		}
		
	}//---------------------------------------------------;

}// -