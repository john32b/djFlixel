package djFlixel;

/**
 * Fast and simple 2D coordinates
 * ...
 * @author johndimi
 */
class SimpleCoords
{
	public var x:Int;
	public var y:Int;
	
	//---------------------------------------------------;
	public function new(x:Int = 0, y:Int = 0)
	{
		this.x = x;
		this.y = y;
	}//---------------------------------------------------;

	// Adds 2 coordinates together, useful for deltas
	public function add(c:SimpleCoords):SimpleCoords
	{
		this.x += c.x;
		this.y += c.y;
		return this;
	}//---------------------------------------------------;
	
	public function fromStrCoords(str:String):SimpleCoords
	{
		var r = str.split(',');
		this.x = Std.parseInt(r[0]);
		this.y = Std.parseInt(r[1]);
		return this;
	}//---------------------------------------------------;
	
	public function reset()
	{
		x = 0;
		y = 0;
	}//---------------------------------------------------;
	
	public function set(x:Int, y:Int)
	{
		this.x = x;
		this.y = y;
	}//---------------------------------------------------;
	
	public inline function copyFrom(o:SimpleCoords):SimpleCoords
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
	
	public inline function isEqual(o:SimpleCoords):Bool
	{
		return (this.x == o.x && this.y == o.y);
	}//---------------------------------------------------;
	
	public inline function isEqualWith(x:Int, y:Int):Bool
	{
		return(this.x == x && this.y == y);
	}//---------------------------------------------------;
	
}// -- end -- //