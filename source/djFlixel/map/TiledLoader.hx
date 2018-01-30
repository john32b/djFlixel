/**
 * Easy Customizable TiledMap Editor Loader.
 * Just the DATA.
 * 
 * NOTES:
 * -----
 * - Assumes ONE image per Layer, else it WILL break.
 * - If EXTERNAL_LOAD flag is set, it will load the map from the disk USE IF FOR DEBUGGING ONLY!
 * 
 * USAGE:
 * -------
 * 
 * 	mapLoader = new TiledLoader();
 *	mapLoader.load("assets/maps/level_01.tmx");
 *	var mapData:Array<Int> = mapLoader.layerTiles.get("tiles");
 * 
 * @author JohnDimi, @jondmt
 */

 package djFlixel.map;

import djFlixel.tool.DynAssets;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.xml.Fast;
import openfl.Assets;


/**
 * Data structure for a floating map entity
 */
typedef MapEntity = {
	x:Int,			// Tile position if it's tile data, Word Pos if object
	y:Int,			// --
	id:Int,			// As it is on the TILED editor
	?type:String,	// Optional and only available in Map Objects
	?uid:Int		// MapTemplate.hx uses it to handle streamingData
};

/**
 * 
 */
class TiledLoader implements IFlxDestroyable
{
	
	// TODO: I might need to change this and put it elsewhere
	static var ASSETS_PATH:String = "assets/";
	
	public var layerTiles:Map<String,Array<Array<Int>>>;	// LayerName=> Array
	public var layerEntities:Map<String,Array<MapEntity>>; 	// LayerName=> Entities
	
	// Store the sizes of all the layers, in case I need them later
	public var tilesetWidths(default, null):Map<String,Int>;
	// Every tileset in the map has a starting GID index. Store for future reference
	public var tilesetFirstGid(default, null):Map<String,Int>;
	
	public var bgColor(default, null):Int = 0xFF000000; // TODO: Load this from the file
	
	public var tileWidth(default, null):Int;
	public var tileHeight(default, null):Int;
	
	public var mapWidth(default, null):Int; 	// in tiles
	public var mapHeight(default, null):Int;	// in tiles

	//---------------------------------------------------;
	public function new() 
	{	
	}//---------------------------------------------------;
	
	public function destroy()
	{
		layerTiles = null;
		layerEntities = null;
		tilesetWidths = null;
	}//---------------------------------------------------;


	
	/**
	 * Load a . map file
	 * @param	file The file to load
	 * @param	skipGIDIncrement If any layer shares an image with another layer, put the name of the layer here. #offset correction hack
	 */
	public function loadFile(file:String, ?skipGIDIncrement:Array<String>)
	{
		trace('Info: Getting map "$file"');
		
		layerTiles = new Map();
		layerEntities = new Map();
		tilesetWidths = new Map();
		tilesetFirstGid = new Map();

		if (skipGIDIncrement == null) skipGIDIncrement = [];
		
		var root:Fast;
		
		// This objects supports Dynamic Files with the "DynAssets.hx' class
		// If a dynamic load fails, it will try to load from embedded
		
		#if (EXTERNAL_LOAD)
			if (DynAssets.files.exists(file)) {
				trace(" .. from dynamic Assets");
				root = new Fast(Xml.parse(DynAssets.files.get(file))).node.resolve("map");
			}else {	
				trace('Warning: Can\'t load "$file" dynamically. Push it to the dynamic file list.');
		#end
		
		// #If not EXTERNAL_LOAD ::
			trace(" .. from embedded Assets");
			root = new Fast(Xml.parse(Assets.getText(ASSETS_PATH + file))).node.resolve("map");
			
		#if (EXTERNAL_LOAD)
			}
		#end
			
		
		if (root == null) {
			throw 'Fatal: Can\'t load map file $file';
		}

		mapWidth   = Std.parseInt(root.att.resolve("width"));
		mapHeight  = Std.parseInt(root.att.resolve("height"));
		tileWidth  = Std.parseInt(root.att.resolve("tilewidth"));
		tileHeight = Std.parseInt(root.att.resolve("tileheight"));

		// Helper vars
		var tnode:Fast;
		var layerName:String;
		var layers_firstGID:Array<Int> = [];
		var layers_tileCounts:Array<Int> = [];
		var c:Int = -1;
		
		// 1: Read layer infos
		for (tnode in root.nodes.tileset)
		{
			layers_firstGID.push(Std.parseInt(tnode.att.resolve("firstgid")));
			layers_tileCounts.push(Std.parseInt(tnode.att.resolve("tilecount")));
			tilesetWidths.set(tnode.att.name, Std.parseInt(tnode.att.tilewidth));
			tilesetFirstGid.set(tnode.att.name, layers_firstGID[layers_firstGID.length - 1]);
		}
		
		
		// 2: Read the layers
		// Note: The layers are read in order. From Bottom To top.
		// 		 Make sure the tileset order matches the layer order
		for (tnode in root.nodes.layer)
		{
			 layerName = tnode.att.resolve("name");
			
			if (skipGIDIncrement.indexOf(layerName) != -1) {	
				if (c == -1) {
					throw 'ERROR: Layer "$layerName" should not be the first layer if you want to skip GID offset';					
				}
				// do nothing. do not increment [c]
			}else {	
				c++;
			}
			
			trace("Reading layer -- " + layerName);
			layerTiles.set(layerName, readCSVLayer(tnode.node.data.innerData, layers_firstGID[c], layers_tileCounts[c]));			
		}
		
		// 3: Read the Entities
		for (tnode in root.nodes.objectgroup)
		{
			layerName = tnode.att.resolve("name");

			var tempArray:Array<MapEntity> = readObjectLayer(tnode);
			
			if (tempArray != null)
			{
				trace("Reading Object layer -- " + layerName);
				layerEntities.set(layerName, tempArray);
			}
		}
	}//---------------------------------------------------;
	
	
	// --
	// Quickly read an object layer and return an array containing it's data
	// NEW: Do not apply any offsets. User should do this manually.
	function readObjectLayer(dataNode:Fast):Array<MapEntity>
	{
		if (!dataNode.hasNode.object)
		{
			trace("Warning: Entity layer contains NO entities");
			return null;
		}
		
		// - Check to see if it's a geom layer
		if (dataNode.node.object.hasNode.polyline)
		{
			trace("This is a polygon layer, skipping [X]");
			return null;
		}
		
		var ar = new Array<MapEntity>();
		var node:Fast;
		var read_type:String;
		
		for (node in dataNode.nodes.object)
		{
			try {
				read_type = node.att.type;
			} catch (error:String) {
				read_type = null;
			}
			
			ar.push ({ 	x:Std.parseInt(node.att.x),
						y:Std.parseInt(node.att.y) - Std.parseInt(node.att.height), // Fix the pivot point to my liking.
						id:Std.parseInt(node.att.gid),
						type:read_type
					});
		}
		
		return ar;
	}//---------------------------------------------------;
	
	
	
	
	/**
	 * Read the CSV string from the map and convert it to a 2D Array
	 * @param	csv The Data
	 * @param	firstGID The offset, will be auto-corrected
	 * @param	tileCount Max tilecount for the layer. Debugging purposes. Will check if any tile is off bounds.
	 * @return
	 */
	function readCSVLayer(csv:String, firstGID:Int, tileCount:Int):Array<Array<Int>>
	{
		var ar_final = new Array<Array<Int>>();
		var ar_csv = csv.split(',');
		
		var r1:Int;
		var seqRead:Int = 0;
		
		// This will be subtracted from the tileids. Save one calculation :-/
		var negativeOffset:Int = firstGID - 1;
		
		for (yy in 0...mapHeight)
		{
			ar_final[yy] = [];
			
			for (xx in 0...mapWidth)
			{
				r1 = Std.parseInt(ar_csv[seqRead++]);
				
				if (r1 > 0) {
					r1 -= negativeOffset;
				}
				
				// # Check for out of bounds
				// # User errors on the map 
				#if debug
				if (r1 < 0 || r1 > tileCount) {
					trace(' Error: Map Tile out of bounds, at (x:$xx,y:$yy)');
					r1 = 0;
				}
				#end
				
				ar_final[yy][xx] = r1;
			}
		}

		return ar_final;
	}//---------------------------------------------------;
	
	

	
	
}//-- end class --//