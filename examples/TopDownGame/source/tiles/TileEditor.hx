package tiles;


// Helper for the editor_obj tiles
class TileEditor
{

	public static var PLAYER:Int;
	public static var MUMMY:Int;
	public static var TEST:Int;
	
	public static function init()
	{
		Reg.applyParamsInto('tileEditor', TileEditor);
	}//---------------------------------------------------;
}