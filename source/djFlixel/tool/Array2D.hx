package djFlixel.tool;

/**
 * Fixed size 2D Array
 */
class Array2D<T>
{
	var vec:Array<T>;
	public var width(default, null): Int; 
	public var length(default, null):Int;
	// --
	public function new(x: Int, y: Int, zeroOut:T) {
		length = x * y;
        width = x; 
        vec = new Array<T>();
		for (i in 0...length) { vec[i] = zeroOut; }
    }//---------------------------------------------------;
    public function get(x: Int, y: Int):T {
        return vec[y * width + x];
    }//---------------------------------------------------;
	public function set(x:Int, y:Int, value:T) {
		vec[y * width + x] = value;
	}//---------------------------------------------------;
	public function destroy() {
		if (vec != null) {
			vec.splice(0, length);
			vec = null;
		}
	}//---------------------------------------------------;
}