package djFlixel.gfx;


/**
 * The Arne16 Color Palette, static class
 * ---
 * http://androidarts.com/palette/16pal.htm
 */
class Palette_Arne16
{
	// All the colors of the palette
	public static var COL(default, never):Array<Int> = [
		0xFF000000,
		0xFF9D9D9D,
		0xFFFFFFFF,
		0xFFBE2633,
		0xFFE06F8B,
		0xFF493C2B,
		0xFFA46422,
		0xFFEB8931,
		0xFFF7E26B,
		0xFF2F484E,
		0xFF44891A,
		0xFFA3CE27,
		0xFF1B2632,
		0xFF005784,
		0xFF31A2F2,
		0xFFB2DCEF
	];
	
	// How many colors
	public inline static var length:Int = 16;
	
	/**
	 * Return a random color, but not black!
	 * @return
	 */
	public static function random():Int
	{
		return COL[1 + Std.random(COL.length - 2)];
	}//---------------------------------------------------;
	
}// -- end -- //

