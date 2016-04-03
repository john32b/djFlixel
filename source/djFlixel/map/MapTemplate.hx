package djFlixel.map;

import djFlixel.map.TiledLoader;
import entity.StreamableSprite;
import flash.geom.Rectangle;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import entity.EntityTopDown;


/**
 * MAPTEMPLATE
 * ----------
 * + Provides basic TILED map functionality
 * + Extend this class for more control.
 * ---------
 * NOTES : 
 * . Be sure to have some basic info in the PARAMS.JSON file
 * . Call updateCameraAndFeedData() every time the player moves to get new entities
 * 
 */
class MapTemplate implements IFlxDestroyable
{
	// Default paths for the maps:
	public var MAP_DIRECTORY:String = "maps/";
	public var MAP_EXTENSION:String = ".tmx";
	
	// Hold the active map tilesizes
	public var TILEWIDTH:Int;
	public var TILEHEIGHT:Int;
	
	// Sizes
	public var mapWidth:Int; 	// in tiles
	public var mapHeight:Int; 	// in tiles
	public var width:Int;		// in pixels
	public var height:Int;		// in pixels
	
	public var cameraWidth:Int;		// How many tiles fit on the rendering view. Rounded UP
	public var cameraHeight:Int;	// How many tiles fit on the rendering view. Rounded UP
	
	var cameraPos:SimpleCoords; 	// Camera start tile coords
	var cameraPosOld:SimpleCoords;  // Previous var
	
	// Every entity on the map should have a unique ID
	var UIDGEN:Int;
	
	// Default camera
	public var camera:FlxCamera;
	
	// Every map should have a basic background layer
	public var layerBG:FlxTilemap;
	
	// -----------------------------------;
	
	// # USER SET
	// Called whenever the camera tiled coords change
	// . useful to set a function to check for offscreen entities
	// NEW: Internally handled
	// public var onCameraCoordsChange:Void->Void;
	
	// # USER SET - ( MUST BE SET )
	// This will be called with map entities that need to be added to the game
	public var onStreamEntity:MapEntity->Void;
	
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
	public var currentLevel(default,null):String;

	
	// Hold all the onscreen streamable objects
	// * User should push objects here *
	// Objects here are auto-destroyed
	public var streamedObjects:FlxTypedGroup<StreamableSprite>;
	
	
	// -- HELPERS
	// General purpose Ints
	var rx:Int;
	var ry:Int;
	
	// Pre-calculated vars for streaming entities
	var _camVF:Int;
	var _camHF:Int;
	
	//====================================================;
	// --
	public function new() 
	{
		loader = new TiledLoader();
		layerBG = new FlxTilemap();
		
		// -- Read parameters
		TILEWIDTH = Reg.JSON.map.BG_TILEWIDTH;
		TILEHEIGHT = Reg.JSON.map.BG_TILEHEIGHT;
		
		hPadding = Reg.JSON.map.STREAM_PAD_X;
		vPadding = Reg.JSON.map.STREAM_PAD_Y;
		
		// Use the default camera, use setCustomViewport() later
		camera = FlxG.camera;
		camera.bgColor = Reg.JSON.map.BG_COLOR;
		
		// Hold the camera starting point in tile coords
		cameraPos = new SimpleCoords();
		cameraPosOld = new SimpleCoords();
		
		// Optional user function.
		// onCameraCoordsChange = function() { };
		
		// Calculate the camera viewport in tiles
		cameraWidth = Math.ceil(camera.width / TILEWIDTH);
		cameraHeight = Math.ceil(camera.height / TILEHEIGHT);
		
		_camVF = cameraHeight + vPadding;	// Reduce a calculation later at the streaming 
		_camHF = cameraWidth + hPadding;
		
		trace("Camera Area Size", cameraWidth, cameraHeight);
		
		// objects on screen
		streamedObjects = new FlxTypedGroup();
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
		camera.bgColor = Reg.JSON.map.BG_COLOR;
		camera.antialiasing = Reg.ANTIALIASING; // apply the AA status to this cam
		layerBG.cameras = [camera];
		
		// Don't forget to re-set the camera size
		cameraWidth = Math.ceil(camera.width / TILEWIDTH);
		cameraHeight = Math.ceil(camera.height / TILEHEIGHT);
		
		_camVF = cameraHeight + vPadding;	// Reduce a calculation later at the streaming 
		_camHF = cameraWidth + hPadding;
		
		trace("Camera Area Size", cameraWidth, cameraHeight);
	}//---------------------------------------------------;
		
	
	// --
	public function destroy()
	{
		loader = FlxDestroyUtil.destroy(loader);
		camera = FlxDestroyUtil.destroy(camera);
		layerBG = FlxDestroyUtil.destroy(layerBG);
		streamedObjects = FlxDestroyUtil.destroy(streamedObjects);
		dataLayer = null;
	}//---------------------------------------------------;
	
	
	// -- Reset and map elements before reloading a new map.
	function reset()
	{
		// -- Clear the streaming layer
		if (streamingLayer != null) {
			for (i in streamingLayer) {
				i = null;
			}
		}
		
		streamingLayer = null;
		dataLayer = null;
		streamedObjects.clear();
		
	}//---------------------------------------------------;

	/**
	 * Load a map file and init all layers
	 * @param	levelID This must be at "assets/maps/" + levelID + "tmx"
	 */
	public function loadLevel(levelID:String)
	{
		reset();
		
		currentLevel = levelID;
		
		loader.load(MAP_DIRECTORY + currentLevel + MAP_EXTENSION);
		
		mapWidth = loader.mapWidth;
		mapHeight = loader.mapHeight;
		width = mapWidth * TILEWIDTH;
		height = mapHeight * TILEHEIGHT;
		
		// - Load the basic layer
		layerBG.loadMapFrom2DArray(loader.layerTiles.get(Reg.JSON.map.BG_LAYER),
					Reg.JSON.map.BG_TILES, TILEWIDTH, TILEHEIGHT, null,
					Reg.JSON.map.BG_STARTING_INDEX, 
					Reg.JSON.map.BG_DRAW_INDEX,
					Reg.JSON.map.BG_COL_START);
		
		layerBG.setDirty(true);
		
		// - Any more layers have to be loaded by an extended class
		// ---> ()
		
		// - Cameras and world. Default is to fix scrolling to edges
		FlxG.worldBounds.set(0, 0, width, height);
		
		// NOTE: camera.setScrollBounds is broken currently.
		camera.minScrollX = 0;
		camera.minScrollY = 0;
		camera.maxScrollX = width;
		camera.maxScrollY = height;
		camera.scroll.set(0, 0);
	
		trace('** Loaded level "$levelID" | mapWidth = $mapWidth | mapHeight = $mapHeight');
		
		// Create those objects 
		// Because a data check could be called externally.
		streamingLayer = new Array<Array<MapEntity>>();
		dataLayer = new Map();
		
		// Load those 2 from the JSON, #optional
		var OBJECT_LAYER = Reg.JSON.map.OBJECT_LAYER;
		var DATA_LAYER = Reg.JSON.map.DATA_LAYER;
		
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
			var tileSizeHalf:Int = Std.int(loader.tilesetWidths.get(DATA_LAYER) / 2);

			var tileX:Int;
			var tileY:Int;
			
			for (i in loader.layerEntities.get(DATA_LAYER))
			{
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
			camera.updateFollow();
		}
		
		cameraPos.x = Std.int(camera.scroll.x / TILEWIDTH);
		cameraPos.y = Std.int(camera.scroll.y / TILEHEIGHT);
		
		// There are cases where this could be <0  
		if (cameraPos.x < 0) cameraPos.x = 0;
		if (cameraPos.y < 0) cameraPos.y = 0;
		
		cameraPosOld.copyFrom(cameraPos);
		
		//#if debug
		//trace("= feedRoomData() checking entities from and to");
		//trace(' x[ ${cameraPos.x - hPadding}, ${cameraPos.x + _camHF} ]');
		//trace(' y[ ${cameraPos.y - vPadding}, ${cameraPos.y + _camVF} ]');
		//#end
		
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
			// Check for offscreen entities here:
			// --
			for (i in streamedObjects) {
				if (entityIsOffScreen(i)) {
					i.kill();
					// trace("KILLING ENTITY");
				}
			}
			
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
			for (rx in (cameraPos.x + _camHF)...(cameraPos.x + _camHF + delta)) {
				// trace("Checking column", rx);
				for (ry in (cameraPos.y - vPadding)...(cameraPos.y + _camVF + 1)) 
					feedDataFromCoords(rx, ry);
			}
		} 
		else {
			for (rx in (cameraPos.x - hPadding)...(cameraPos.x - delta - hPadding)) {
				// trace("Checking column", rx);
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
			for (ry in (cameraPos.y + _camVF)...(cameraPos.y + _camVF + delta)) {
				// trace("Checking row", ry);
				for (rx in (cameraPos.x - hPadding)...(cameraPos.x + _camHF + 1))
					feedDataFromCoords(rx, ry);
				}
			}
		else {
			for (ry in (cameraPos.y - vPadding)...(cameraPos.y - delta - vPadding)) {
				// trace("Checking row", ry);
				for (rx in (cameraPos.x - hPadding)...(cameraPos.x + _camHF + 1)) 
					feedDataFromCoords(rx, ry);
			}
		}
	}//---------------------------------------------------;
	

	/**
	 * Scan all the layers and callback for any map entity found
	 * @inline makes it a bit faster because this is called frequently
	 * @param	x tile coords
	 * @param	y tile coords
	 */
	function feedDataFromCoords(x:Int, y:Int)
	{
		try {
			
			if (streamingLayer[y][x] == null) return;
			
			for (i in streamedObjects) {
				if (i.alive && i.exists && streamingLayer[y][x].uid == i.UID) {
					// trace("Already exists", streamingLayer[y][x]);
					return;
				}
			}
			
			// ok to add :
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
	
	
	//====================================================;
	// MAP DATA RELATED: 
	//====================================================;
	
	
	// Returns the mapEntity on the DATA layer
	// , If nothing is found, returns NULL
	public function getDataObjectAt(x:Int, y:Int):MapEntity
	{
		return dataLayer.get('$x,$y');
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
	// Set a new tile at the streaming layer
	public function setStreamingTileAt(x:Int, y:Int, tile:Int, ?type:String):MapEntity
	{
		streamingLayer[y][x] = { x:x, y:y, id:tile, uid: ++UIDGEN, type:type };
		return streamingLayer[y][x];
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