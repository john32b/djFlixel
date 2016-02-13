package djFlixel.map;

import djFlixel.map.TiledLoader;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.tile.FlxTilemap;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import entity.EntityTopDown;


/**
 * Provides basic TILED map functionality
 * --
 * Extend this class for more control.
 * 
 * NOTE : Be sure to have some basic info in the PARAMS.JSON file
 * 
 */
class MapTemplate implements IFlxDestroyable
{
	// Default paths for the maps:
	public var MAP_DIRECTORY:String = "assets/maps/";
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
	public var onCameraCoordsChange:Void->Void;
	
	// # USER SET - MUST BE SET !!
	// This will be called with map entities that need to be added to the game
	public var onStreamEntity:MapEntity->Void;
	
	// # USER SET
	// this to be the object layer for streaming entities.
	// Set this before loading the level.
	public var OBJECT_LAYER:String;
	

	// Support one streaming data layer
	// Stores the entities to be streamed.
	var streamingLayer:Array<Array<MapEntity>>;
	
	// -- HELPERS
	// General purpose Ints
	var rx:Int;
	var ry:Int;
	// Streaming entities cam temps
	var camhf_:Int;
	var camwf_:Int;
	
	//---------------------------------------------------;
	// Tiled map files data loader
	var loader:TiledLoader;
	
	// Current level name
	public var currentLevel(default,null):String;

	//====================================================;
	// --
	public function new() 
	{
		loader = new TiledLoader();
		layerBG = new FlxTilemap();
		
		// -- Init Camera ( TODO )
		//camera = new FlxCamera( 0, 11, FlxG.width,  
		//camera.bgColor = PALETTE_GB.COL_01;
		//camera.antialiasing = Reg.ANTIALIASING;
		//FlxG.cameras.add(camera);
		//FlxG.cameras.reset(camera);
		camera = FlxG.camera;
		camera.bgColor = Reg.JSON.map.BG_COLOR;
		layerBG.cameras = [camera];
		
		// -- 
		// Now it's a good time to set the TILEWIDTH and TILEHEIGHT
		// It's better to declare them before any map loads
		// Because some objects may rely on these values
		TILEWIDTH = Reg.JSON.map.BG_TILEWIDTH;
		TILEHEIGHT = Reg.JSON.map.BG_TILEHEIGHT;
		
		// Calculate the camera viewport in tiles
		cameraWidth = Math.ceil(camera.width / TILEWIDTH);
		cameraHeight = Math.ceil(camera.height / TILEHEIGHT);
		
		camhf_ = cameraHeight - 1;	// Reduce a calculation later at the streaming 
		camwf_ = cameraWidth - 1;
		
		cameraPos = new SimpleCoords();
		cameraPosOld = new SimpleCoords();
			
		onCameraCoordsChange = function() { };
		
		trace("Camera Area Size", cameraWidth, cameraHeight);
	}//---------------------------------------------------;
	
	// --
	public function destroy()
	{
		loader = FlxDestroyUtil.destroy(loader);
		camera = FlxDestroyUtil.destroy(camera);
		layerBG = FlxDestroyUtil.destroy(layerBG);
	}//---------------------------------------------------;
	
	// -- Reset and map elements before reloading a new map.
	function reset()
	{
		UIDGEN = 0;
		// -- Clear the streaming layer
		if (streamingLayer != null) {
			for (i in streamingLayer) {
				i = null;
			}
		}
		streamingLayer = null;
	}//---------------------------------------------------;

	// --
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
	
		trace('Loaded level "$levelID"');
		trace('mapWidth = $mapWidth');
		trace('mapHeight = $mapHeight');
		
		// - Streaming entities --
		// - Scan the ENTIRE objects layer to get data:
		if (OBJECT_LAYER != null)
		{			
			UIDGEN = 0;
			streamingLayer = new Array<Array<MapEntity>>();
			for (yy in 0...mapHeight) streamingLayer[yy] = [];
			scanTileLayer(OBJECT_LAYER, function(x:Int, y:Int, tile:Int) {
				UIDGEN++;
				var en:MapEntity = { x:x, y:y, id:tile, uid:UIDGEN };
				streamingLayer[y][x] = en;
				manageEntityAt(x, y, tile);
			});
			
			// DEVNOTE: At this point I could free up some memory
			//			by freeing the tileloader ?
		}
		
	}//---------------------------------------------------;

	
	//====================================================;
	// TILE DATA STREAMING
	//====================================================;
	
	// --
	// Check the entire screen area, and callback for entities
	// Feedback for entities on the screen.
	public function feedRoomData()
	{	
		cameraPos.x = Std.int(camera.scroll.x / TILEWIDTH);
		cameraPos.y = Std.int(camera.scroll.y / TILEHEIGHT);
		cameraPosOld.copyFrom(cameraPos);
		
		trace("= feedRoomData()");
		trace('x0', cameraPos.x - 1);
		trace('x1', cameraPos.x + cameraWidth);
		trace('y0', cameraPos.y - 1);
		trace('y1', cameraPos.y + cameraHeight);
	
		for (rx in (cameraPos.x)...(cameraPos.x + cameraWidth)) // x axis
		for (ry in (cameraPos.y)...(cameraPos.y + cameraHeight)) // y axis
		{
			try{
				feedDataFromCoords(rx, ry);
			}catch (e:Dynamic) { } // do nonthing.
		}
			
	}//---------------------------------------------------;
		
	// --
	// Check the camera edges and feed discovered entities to the feeder
	public function updateCameraAndFeedData()
	{
		cameraPos.x = Std.int(camera.scroll.x / TILEWIDTH);
		cameraPos.y = Std.int(camera.scroll.y / TILEHEIGHT);
		
		if (!cameraPos.isEqual(cameraPosOld))
		{
			trace("+ Camera coords", cameraPos);
			
			onCameraCoordsChange(); // Check for offscreen entities elsewhere
			
			// Camera changed tile pos
			try{
				feedDataFromRow(cameraPos.y - cameraPosOld.y);
				feedDataFromColumn(cameraPos.x - cameraPosOld.x);
			}catch (e:Dynamic) { } // continue normally;
			
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
			for (rx in (cameraPos.x + camwf_)...(cameraPos.x + camwf_ + delta)) {
				trace("Checking column", rx);
				for (ry in (cameraPos.y)...(cameraPos.y + cameraHeight)) 
					feedDataFromCoords(rx, ry);
			}
		} 
		else {
			for (rx in (cameraPos.x)...(cameraPos.x - delta)) {
				trace("Checking column", rx);
				for (ry in (cameraPos.y)...(cameraPos.y + cameraHeight))
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
			for (ry in (cameraPos.y + camhf_)...(cameraPos.y + camhf_ + delta)) {
				trace("Checking row", ry);
				for (rx in (cameraPos.x)...(cameraPos.x + cameraWidth))
					feedDataFromCoords(rx, ry);
				}
			}
		else {
			for (ry in (cameraPos.y)...(cameraPos.y - delta)) {
				trace("Checking row", ry);
				for (rx in (cameraPos.x)...(cameraPos.x + cameraWidth)) 
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
	inline function feedDataFromCoords(x:Int, y:Int)
	{
		if (streamingLayer[y][x] != null) {
			onStreamEntity(streamingLayer[y][x]);
		}
	}//---------------------------------------------------;

	// --
	// Quick way to figure out if an entity is offscreen
	// Tile based
	public function entityIsOffScreen(en:EntityTopDown)
	{
		return (en.coords.x < cameraPos.x ||
				en.coords.y < cameraPos.y ||
				en.coords.x > cameraPos.x + cameraWidth  - 1 ||
				en.coords.y > cameraPos.y + cameraHeight - 1 );
	}//---------------------------------------------------;
	
	
	// # USER CODE #
	// -- OVERRIDE THIS --
	// The object layer is always scanned for data
	// Manage specific entities here, like the player spawn point, etc
	function manageEntityAt(x:Int, y:Int, id:Int)
	{
		
	}//---------------------------------------------------;
	
	 /**
	  * Scan a layer and for each tile it finds process it.
	  * Useful to get player spawn points, enemies, etc.
	  * @param	layerName The name of the layer is it is in the TILED editor
	  * @param	handler callback :: function(coordsX,coordsY,tileID);
	  */
	public function scanTileLayer(layerName:String, handler:Int->Int->Int->Void)
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