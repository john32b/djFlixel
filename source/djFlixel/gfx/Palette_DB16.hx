package djFlixel.gfx;


/**
 * The DB16 color palette
 * Static Class Helper
 * -----
 * @info http://pixeljoint.com/forum/forum_posts.asp?TID=12795
 * 
 */
 class Palette_DB16
{
	// In the order they are in Aseprite
	public static var COL:Array<Int> = [
		0xff140c1c,
		0xff442434,
		0xff30346d,
		0xff4e4a4e,
		0xff854c30,
		0xff346524,
		0xffd04648,
		0xff757161,
		0xff597dce,
		0xffd27d2c,
		0xff8595a1,
		0xff6daa2c,
		0xffd2aa99,
		0xff6dc2ca,
		0xffdad45e,
		0xffdeeed6
	];
	
	// --
	public inline static function getRandomColor():Int
	{
		return COL[Std.random(COL.length)];
	}//---------------------------------------------------;
	
}// -- end -- //

