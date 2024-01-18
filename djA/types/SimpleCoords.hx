package djA.types;

/**
 * Fast and simple 2D coordinates
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
	
	// --
	public inline function toCSV():String
	{
		return '$x,$y';
	}//---------------------------------------------------;
	
	/** WARNING: This is without Safeguards **/
	public function fromCSV(str:String):SimpleCoords
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
	
	
	public inline function isEqual(o:SimpleCoords):Bool
	{
		return (this.x == o.x && this.y == o.y);
	}//---------------------------------------------------;
	
	public inline function isEqualWith(x:Int, y:Int):Bool
	{
		return(this.x == x && this.y == y);
	}//---------------------------------------------------;
	
}// -- end -- //