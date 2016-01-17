package djFlixel;

/**
 * Fast and simple 2D Vector
 * ...
 * @author johndimi
 */
class SimpleVector
{
	public var x:Float;
	public var y:Float;
	
	//---------------------------------------------------;
	public function new(x:Float = 0, y:Float = 0)
	{
		this.x = x;
		this.y = y;
	}//---------------------------------------------------;

	public function fromStrCoords(str:String):SimpleVector
	{
		var r = str.split(',');
		this.x = Std.parseFloat(r[0]);
		this.y = Std.parseFloat(r[1]);
		return this;
	}//---------------------------------------------------;
	
	public function reset()
	{
		x = 0;
		y = 0;
	}//---------------------------------------------------;
	
	public function set(x:Float, y:Float)
	{
		this.x = x;
		this.y = y;
	}//---------------------------------------------------;
	
	public inline function copyFrom(o:SimpleVector):SimpleVector
	{
		x = o.x;
		y = o.y;
		return this;
	}//---------------------------------------------------;
	
	public inline function toString():String
	{
		return '(x:$x | y:$y)';
	}//---------------------------------------------------;
	
	// -- Useful for using as keys in Hashes
	public inline function CSV():String
	{
		return '$x,$y';
	}//---------------------------------------------------;
	
}// -- end -- //