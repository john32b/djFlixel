/**
 * General Purpose Data Helpers
 * = ALL TARGETS 
 *
 */

package djA;


@:dce
class DataT 
{
	
	/**
	 * - Old Way - does not work Recursively, Is here in case anything breaks. 
	 * - TODO - Make sure copyFields works and delete this one
	 * Copy an object's fields into target object. Overwrites the target object's fields. 
	 * Can work with Static Classes as well (as destination)
	 * NOTE: You need to assign the final object for this to work
	 * @param	node The Master object to copy fields from
	 * @param	into The Target object to copy fields to
	 * @return	The resulting object
	 */
	@:deprecated("Use copyFields")
	public static function copyFields0(from:Dynamic, into:Dynamic):Dynamic
	{
		if (from == null)
		{
			// trace("Warning: No fields to copy from source, returning destination object");
			return into;
		}
		
		if (into == null) 
		{
			into = Reflect.copy(from);
		}else
		{
			for (f in Reflect.fields(from)) 
			{
				Reflect.setField(into, f, Reflect.field(from, f));
			}
		}
		
		return into;
	}//---------------------------------------------------;
	
	/**
	 * - NEW - RECURSIVE - 
	 * - Copy an object's fields into target object. Overwrites the target object's fields. 
	 * - Works Recursively for objects inside objects
	 * - Can work with Static Classes as well (as destination)
	 * - You need to assign the returned object for this to work
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
			into = Reflect.copy(from);
		}else
		{
			for (f in Reflect.fields(from)) {
				if (Reflect.isObject(Reflect.field(from, f)) &&
					Type.getClass(Reflect.field(from, f)) == null) {
						Reflect.setField(into, f, copyFields(Reflect.field(from, f), Reflect.field(into, f)));
					}else{
						Reflect.setField(into, f, Reflect.field(from, f));
					}
			}
		}
		
		return into;
	}//---------------------------------------------------;	
	
	
	/**
	   Return a deep copy of an anonymous object. Meaning will copy all sub-objects as well
	   @param	o
	   @return
	**/
	public static function copyDeep(o:Dynamic):Dynamic
	{
		var N = {};
		for (f in Reflect.fields(o)) {
			if (Reflect.isObject(Reflect.field(o, f)) &&
				Type.getClass(Reflect.field(o, f)) == null) {
					Reflect.setField(N, f, copyDeep(Reflect.field(o, f)));
				}else{
					Reflect.setField(N, f, Reflect.field(o, f));
				}
		}
		return N;
	}//---------------------------------------------------;

	public static function intOrZeroFromStr(str:String):Int
	{
		if (str == null) return 0;
		var RES = Std.parseInt(str);
		if (RES == null) return 0;
		return RES;
	}//---------------------------------------------------;
	
	
	public static function floatOrZeroFromStr(str:String):Float
	{
		if (str == null) return 0.0;
		var RES = Std.parseFloat(str);
		if (Math.isNaN(RES)) return 0.0;
		return RES;
	}//---------------------------------------------------;
	
	/**
	   Useful to get default values from object fields.
	   @param	a Object Fields
	   @param	v Default Value
	   @return
	**/
	public static function existsOr(a:Dynamic, v:Any):Any
	{
		if (a == null) return v; return a;
	}//---------------------------------------------------;
	
	
	/**
	   Convert a CSV string to HashTable. 
	   - NEW: Support for flags,  {type:10,glowing}. Check with .exists()
	   -      Support for whitespace, { type  : 20,  lives   : 40}  
	   Values as strings
	   e.g. "getCSVTable("lives:10,speed:30") ==> [ 'lives'=>'10', 'speed'=>'30' ]
	   @param	csv Format "id:value,id2:value..."
	   @return 
	**/
	public static function getCSVTable(csv:String):Map<String,String>
	{
		if (csv == null) return null;
		var M:Map<String,String> = [];
		var pairs = csv.split(',');
		for (p in pairs) {
			p = StringTools.trim(p);
			var d = p.split(':');
			if (d.length == 1){
				M.set(d[0], "");
			}else{
				M.set(d[0], d[1]);
			}
		}
		return M;
	}//---------------------------------------------------;
	
	/**
	   Convert a CSV string to an Dynamic Object
	   Values as strings
	   e.g. "getCSVObj("lives:10,speed:30") ==> { lives:'10', speed:'30' }
	   @param	csv
	   @return
	**/
	public static function getCSVObj(csv:String):Dynamic
	{
		if (csv == null) return null;
		var O:Dynamic = {};
		var pairs = csv.split(',');
		for (p in pairs) {
			var d = p.split(':');
			Reflect.setField(O, d[0], d[1]);
		}
		return O;
	}//---------------------------------------------------;
	
	
	// Taken from Franco Ponticelli's THX library:
	// https://github.com/fponticelli/thx/blob/master/src/Floats.hx#L206
	public static function roundFloat(number:Float, ?precision=2): Float
	{
		number *= Math.pow(10, precision);
		return Math.round(number) / Math.pow(10, precision);
	}//---------------------------------------------------;
	
	
	/**
	 * Get a random element from an array
	 */
	inline public static function randAr<T>(ar:Array<T>):T 
	{
		return ar[Std.random(ar.length)];
	}//---------------------------------------------------;

    /** Get the last element of an array
     */
    inline public static function lastAr<T>(ar:Array<T>):T
    {
        return ar[ar.length - 1];
    }//---------------------------------------------------;

	/**
	 * Pads a string to reach a certain length.
	 * If string is longer it gets trimmed with a ".." at the end
	 * If string is shorter it gets padded with $char
	 * e.g. padTrimString("hello",10,".") == ".....hello"
	 * @param str String to pad
	 * @param len New length
	 * @param char Character to add when trimmind/padding
	 * @param leftPad If true will trim/pad to the left
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
	
	
	/**
	   https://github.com/jdegoes/stax/blob/master/src/main/haxe/haxe/util/Guid.hx
	   @return
	**/
	 public static function getGUID(): String 
	 {
		var result = "";
		for (j in 0...32) {
		if ( j == 8 || j == 12 || j == 16 || j == 20) { result += "-"; }
		result += StringTools.hex(Math.floor(Math.random() * 16)); }	
		return result.toUpperCase();
	}//---------------------------------------------------;
	
	/**
	 * Converts bytes to megabytes. Useful for creating readable filesizes.
	 * 
	 * @param	bytes Number of bytes to convert
	 * @return  The converted bytes to string format.
	 */
	public static function bytesToMBStr(bytes:Int):String {
		return Std.string( Math.ceil( bytes / (1024 * 1024)));
	}//---------------------------------------------------;
	
}// --