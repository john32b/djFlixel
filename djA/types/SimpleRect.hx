package djA.types;

/**
 * A less advanced rect than (openfl.geom.rectangle)
 * Hold dimensions and position in INTEGERS
 */
class SimpleRect
{
	public var x:Int;
	public var y:Int;
	public var w:Int;
	public var h:Int;

	public function new(X:Int = 0, Y:Int = 0, W:Int = 0, H:Int = 0)
	{
		x = X; y = Y; w = W; h = H;
	}//---------------------------------------------------;
	
	public inline function toCSV():String
	{
		return '$x,$y,$w,$h';
	}//---------------------------------------------------;
	
	/** WARNING: This is without Safeguards **/
	public function fromCSV(str:String):SimpleRect
	{
		var r = str.split(',');
		x = Std.parseInt(r[0]);
		y = Std.parseInt(r[1]);
		w = Std.parseInt(r[2]);
		h = Std.parseInt(r[3]);
		return this;
	}//---------------------------------------------------;
	
	public function set(X:Int, Y:Int, W:Int, H:Int):SimpleRect
	{
		x = X; y = Y; w = W; h = H; return this;
	}//---------------------------------------------------;
	
	public function clone():SimpleRect
	{
		return new SimpleRect(x, y, w, h);
	}//---------------------------------------------------;
	
	public static function get(X:Int = 0, Y:Int = 0, W:Int = 0, H:Int = 0):SimpleRect
	{
		return new SimpleRect(X, Y, W, H);
	}//---------------------------------------------------;
	
	public function x1() return x + w;
	
	public function y1() return y + h;
	
	public function toString() return 'x:$x,y:$y,w:$w,h:$h';
	
}// --