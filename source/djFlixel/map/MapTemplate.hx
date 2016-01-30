package djFlixel.map;

import djFlixel.map.TiledLoader;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.tile.FlxTilemap;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

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
	
	public var mapWidth:Int; 	// in tiles
	public var mapHeight:Int; 	// in tiles
	public var width:Int;		// in pixels
	public var height:Int;		// in pixels

	// Default camera
	public var camera:FlxCamera;

	// Every map should have a basic background layer
	public var layerBG:FlxTilemap;

	
	// Tiled maps 
	var loader:TiledLoader;

	// --
	var currentLevel:String;

	//====================================================;
	
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
	}//---------------------------------------------------;
	
	
	public function loadLevel(levelID:String)
	{
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
		camera.scroll.set(0, 0); // 
	}//---------------------------------------------------;
	
	// --
	public function destroy()
	{
		loader = FlxDestroyUtil.destroy(loader);
		camera = FlxDestroyUtil.destroy(camera);
		layerBG = FlxDestroyUtil.destroy(layerBG);
	}//---------------------------------------------------;

}// -