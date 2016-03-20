package;

import djFlixel.SimpleCoords;
import djFlixel.tool.DataTool;
import djFlixel.map.MapTemplate;
import tiles.TileSprites;
import flixel.tile.FlxTilemap;


class Gamemap extends MapTemplate
{
	// --
	var TILES_FS:String = "assets/sprites.png";

	// The footsteps tilemap
	public var layerFS:FlxTilemap;
	
	// Collision data of the map, helper object
	var colData:Array<Array<Int>>;
	
	// The player spawn point on the map
	public var player(default,null):SimpleCoords;
	
	//====================================================;
	
	public function new()
	{
		super();
		// Create the footsteps tilemap
		layerFS = new FlxTilemap();
		layerFS.cameras = [camera];
	}//---------------------------------------------------;
	
	// --
	override function reset() 
	{
		super.reset();
		colData = null;
		player = new SimpleCoords();
	}//---------------------------------------------------;
	
	// --
	override public function loadLevel(levelID:String) 
	{
		// This loads the basic background.
		super.loadLevel(levelID);
		
		var fsData:Array<Int> = [for (j in 0...(mapWidth * mapHeight)) 0]; // Zero it out
		layerFS.loadMapFromArray(fsData, mapWidth, mapHeight, 
								TILES_FS, TILEWIDTH, TILEHEIGHT,
								null, 1, 1, 0);

		// -- Fill the collision Data
		colData = DataTool.create2DArray(mapWidth, mapHeight);
		for (xx in 0...mapWidth)
		for (yy in 0...mapHeight) {
			if (layerBG.getTile(xx, yy) >= Reg.JSON.map.BG_COL_START) {
				colData[yy][xx] = 1;
			}else {
				colData[yy][xx] = 0;
			}
		}
		
		// - Don't forget to force redraw
		layerFS.setDirty(true);

	}//---------------------------------------------------;
	
	//====================================================;
	// GAME SPECIFIC 
	//====================================================;
	
	// --
	// Gets called once after a new map is loaded
	// The object layer layer is scanned and for each entry it finds
	// this function is called.
	override function manageEntityAt(x:Int, y:Int, id:Int) 
	{
		if (id == 1)
		{
			player.set(x, y);
		}
	}//---------------------------------------------------;
	
	// -- 
	// Get collision data at a specific tile
	public function col_getAt(x:Int, y:Int):Int
	{
		try {
			return colData[y][x];
		}catch (e:Dynamic) {
			trace("Error: Out of bounds");
			return -1;
		}
	}//---------------------------------------------------;
	
	public function setStep(x:Int, y:Int, direction:Int)
	{
		layerFS.setTile(x, y, TileSprites.getStepTile(direction));
	}//---------------------------------------------------;
	
}// -