package tiles;

// Helper for the layerBG tiles
class TileBg
{
	// Which tiles are solid
	public static var SOLID_TILES:Array<Int>;
	//====================================================;
	public static function init()
	{
		// Load the tiles from json
		Reg.applyParamsInto('tileBg', TileBg);
	}//---------------------------------------------------;
	// --
	public static function isSolid(ind:Int):Bool
	{
		return (ind > 18);
	}//---------------------------------------------------;
	
}// --