package djFlixel.tool;

/**
 * Various general purpose tools
 * for use in my haxe flixel projects
 * ...
 * Static class
 */
class DataTool
{
	/**
	 * Creates and returns an empty 2D array
	 * NOTE: Access the array like ar[y][x]
	 * @param	width The width of the Array
	 * @param	height The height of the Array
	 */
	public static function create2DArray<T>(width:Int, height:Int):Array<Array<T>>
	{
		#if cpp
			throw "INCOMPATIBLE WITH CPP";
		#end
		
		var r:Array<Array<T>> = [];
		for (y in 0...height) {
			r[y] = [];
		}
		return r;
	}//---------------------------------------------------;
	
	/**
	 * Apply a function to a string of CSV parameters
	 * 
	 * @param	csv The string to parse for data. e.g. "color:blue,speed:100,level:4"
	 * @param	fn The function to apply, takes 2 arguments, field:String and value:String.
	 */
	public static function applyToCSVParams(?csv:String, fn:String->String->Void):Void
	{
		if (csv == null) return;
		
		var pairs:Array<String> = csv.split(',');
		var d:Array<String>;

		for (p in pairs) {
			d = p.split(':');
			fn(d[0], d[1]);
		}
		
	}//---------------------------------------------------;

	/**
	 * Quick way to get a field from a CSV string.
	 * 
	 * @usage CSVGetQuick("file:save.txt,flag:false","file") == "save.txt"
	 * 
	 * @param	csv The CSV string to parse
	 * @param	field The Field of the csv string to get
	 * @return String of the value of the csv, NULL if not found
	 */
	public static function CSVGetQuick(?csv:String, field:String):String
	{
		if (csv == null) return null;
		var pairs:Array<String> = csv.split(',');
		var d:Array<String>;
		for (p in pairs) {
			d = p.split(':');
			if (d[0] == field) return d[1];
		}
		return null;
	}//---------------------------------------------------;

	/** 
	 * Creates and returns a union of 2 arrays
	 * 
	 * !! USE WITH CAUTION !!
	 * 
	 * @IMPORTANT:  Depending on the structure, the arrays might be pointers and not 1:1 copies!!
	 * 				It is safe for basic types such as strings, ints, bools and floats
	 */
	public static function arrayUnion<T>(ar1:Array<T>, ar2:Array<T>):Array<T>
	{
		var n = ar1.copy();
		for (i in ar2)
		{
			if (n.indexOf(i) < 0) n.push(i);
		}
		return n;
	}//---------------------------------------------------;
	
	// --
	public static function arrayRandom<T>(ar:Array<T>):T 
	{
		return ar[Std.random(ar.length)];
	}//---------------------------------------------------;
	
	
	
	
	//-- Quickly set the default parameters of an object
	public static function defParams(obj:Dynamic, target:Dynamic):Dynamic
	{
		if (obj == null) {
			obj = { };
		} else {
			// THIS IS VERY IMPORTANT ::
			obj = Reflect.copy(obj);
		}
		
		for (field in Reflect.fields(target)) {
			if (!Reflect.hasField(obj, field)) {
				Reflect.setField(obj, field, Reflect.field(target, field));
			}
		}
		
		return obj;
	}//---------------------------------------------------;
	
}// -- end --//