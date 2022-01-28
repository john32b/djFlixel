package djA.types;

/**
 * Fast and simple 2D Vector
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

	// --
	public inline function toCSV():String
	{
		return '$x,$y';
	}//---------------------------------------------------;
	
	/** WARNING: This is without Safeguards **/
	public function fromCSV(str:String):SimpleVector
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
		
}// -- end -- //