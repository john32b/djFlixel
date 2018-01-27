package djFlixel.tool;
import djFlixel.gfx.GfxTool;

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
	
	/**
	 * Quickly get a random element from an array
	 */
	inline public static function arrayRandom<T>(ar:Array<T>):T 
	{
		return ar[Std.random(ar.length)];
	}//---------------------------------------------------;
	
	
	/**
	 * Copy an object's fields into target object. Overwrites the target object's fields. 
	 * Can work with Static Classes as well (as destination)
	 * @param	node The Master object to copy fields from
	 * @param	into The Target object to copy fields to
	 * @return	The resulting object
	 */
	public static function copyFields(from:Dynamic, into:Dynamic):Dynamic
	{
		if (from == null)
		{
			// trace("Warning: No fields to copy from source, returning destination object");
			return into;
		}
		
		if (into == null) 
		{
			trace("Warning: No fields on the target, copying source object");
			into = Reflect.copy(from);
		}else
		{
			for (f in Reflect.fields(from)) {
				Reflect.setField(into, f, Reflect.field(from, f));
			}
		}
		
		return into;
	}//---------------------------------------------------;

	/**
	 * Copy All Fields AND translates colors. Overwrites the target object's fields. 
	 *  
	 * - If a field starts with "color" it will automatically convert it to proper INT
	 *    e.g. "0xffffff" or "blue" => (int)0x0000FF
	 * 
	 * - Palettes : Supports Getting colors from Palettes , check GfxTool.palCol(.)
	 *		use the "@" prefix and call normally. 
	 *		e.g. "@A16[3]" => (int)0xFFBE2633 
	 * 
	 * @param	from The Source Object to copy fields from 
	 * @param	into The Destination object, if null it will be created. It is altered in place
	 * @return  The resulting object
	 */
	public static function copyFieldsC(from:Dynamic, ?into:Dynamic):Dynamic
	{
		if (into == null) into = {};
		if (from != null)
		
		for (f in Reflect.fields(from)) 
		{	
			var d:Dynamic = Reflect.field(from, f);
			
			// f is the name of the field
			// d is the field data
			
			// Convert COLOR string and array of strings to INT
			if (f.indexOf("color") == 0) {
				
				if (Std.is(d, Array))
				{
					var ar:Array<Int> = [];
					var arS:Array<String> = d;
					var c:Int = 0;
					while (c < arS.length) ar.push(GfxTool.stringColor(arS[c++]));
					Reflect.setField(into, f, ar);
					continue;
				}
				else if (Std.is(d, String))
				{
					Reflect.setField(into, f, GfxTool.stringColor(d));
					continue;
				}
			}
			
			// Process any object nodes
			if (Reflect.isObject(d) && !Std.is(d, Array) && !Std.is(d, String))
			{	
				if (!Reflect.hasField(into, f)) Reflect.setField(into, f, {});
				copyFieldsC(d, Reflect.field(into, f));	// Recursion ftw
				continue;
			}
			
			// Just copy everything else.
			Reflect.setField(into, f, Reflect.field(from, f));
		}
		
		return into;
	}//---------------------------------------------------;
	
	/**
	 * Copy Missing Fields, Copies the fields from the source object that are 
	 * not present in the destination object. VERY USEFUL to setting default parameters
	 * 
	 * e.g. copyMFields({life:1,attack:2},{other:3,life:2}) =>
	 *				{life:1, attack:2, other:3}
	 * 
	 * @param	from The Source Object to copy fields from 
	 * @param	into The Destination object, if null it will be created. It is altered in place
	 * @return  The resulting object
	 */
	@:deprecated("Use CopyFields and copy the final object to a template")
	public static function copyMFields(from:Dynamic, into:Dynamic):Dynamic
	{
		#if debug
			if (from == null) { trace("ERROR: Source object is null"); return null; }
		#end
		
		if (into == null) into = { }; else into = Reflect.copy(into); // <-- THIS IS VERY IMPORTANT !
		
		for (f in Reflect.fields(from)) {
			if (!Reflect.hasField(into, f)) {
				Reflect.setField(into, f, Reflect.field(from, f));
			}
		}
		return into;
	}//---------------------------------------------------;
	
	
	/**
	 * Pads a string to reach a certain length.
	 * If string is longer it gets trimmed with a ".." at the end
	 * If string is shorter it gets padded with $char
	 * LEFT PAD so "john" => ".....john"
	 */
	public static function padTrimString(str:String, size:Int, char:String = ".", leftPad:Bool = true):String
	{
		if (str.length > size) {
			// Add a couple of chars in the end to indicate that it was truncated
			return str.substr(0, size-2) + "..";
		}
		else if (str.length < size) {
			if(leftPad)
				return StringTools.lpad(str, char, size);
			else
				return StringTools.rpad(str, char, size);
		}else {
			// no need to change it
			return str;
		}
	}//---------------------------------------------------;
	
	// Taken from Franco Ponticelli's THX library:
	// https://github.com/fponticelli/thx/blob/master/src/Floats.hx#L206
	public static function roundFloat(number:Float, ?precision=2): Float
	{
		number *= Math.pow(10, precision);
		return Math.round(number) / Math.pow(10, precision);
	}//---------------------------------------------------;
	
}// -- end --//