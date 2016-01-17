package djFlixel.menu;

/* ==================================================
 * Provide a simple platform independent Menu System.
 * These classes just hold menu DATA.
 * A MenuSystem must implement these.
 * I have chosen to do so, because I want to share the 
 * data handling classes with multiple Haxe targets,
 * like Javascript or OpenFL
 * ================================================== */

// --
// A single Data holder for a menu option
// Holds both the master and slave data
class MenuOptionData
{
	public var UID:Int;
	public var SID:String;
	public var label:String;
	public var slave:MenuSlaveData;		// I could inline this whole class, as it's a 1 to 1 relation
	
	public var isEnabled:Bool = true;	// Grayed out or not
	
	// If this function is occupied, then this must be TRUE
	// for the option to be rendered
	public var conditional:Void->Bool = null;
	
	public function new(?label:String, ?UID:Int)
	{
		if (UID != null) this.UID = UID;
		if (label != null) this.label = label;
		slave = new MenuSlaveData();
	}//---------------------------------------------------;

}//-------------------------------------------------------;


// --
// Hold the functionality type and it's data
class MenuSlaveData
{
	public static var AVAILABLE_TYPES:Array<String> = ["link", "slider", "oneof", "toggle"];
	
	public var type:String; 	//set externally
	public var pool:Dynamic;	//set externally
	public var current:Dynamic;
	
	public function new(?type:String,?pool:Dynamic) 
	{ 
		this.pool = pool;
		if (type != null)
		{
			this.type = type;
			init();
		}
	}//---------------------------------------------------;
	
	public function init()
	{
		switch(type)
		{
			case "oneof":
				if (current == null)
					current = 0;	// Current holds the index
			case "slider":
				if (current == null)
					current = pool[0];
			case "toggle":
				if (current == null)
					current = false;
					
				if (pool == null) {
					// A default toggle situation is "yes","no"
					pool = ["no", "yes"];	// Negative first, ALWAYS!
				}
		}
	}//---------------------------------------------------;	
}//-------------------------------------------------------;





// --
// Manages a collection of MenuOptionData
class MenuPageData
{
	public var SID:String;	// String Unique Name.ID // Preffered
	public var UID:Int;		// Int ID ,// I am not sure that I will be needing an ID system
	
	public var name:String;	// Optional Menu Name
	public var desc:String;	// Optional Menu Description
	
	public var collection:Array<MenuOptionData>; // Store the options serially

	public var custom:Dynamic;	// Store some page specific custom parameters
								// Like X,Y position, Colors, or whatever
	var _lastUID:Int = 0;		// I am not sure that I will be needing an ID system
	
	// Enable custom callbacks for options within pages, in case you
	// want to override the global callback from the menu
	public var optionCallback:String->Dynamic->Void = null;
	
	public function new(SID:String, ?name:String, ?desc:String)
	{
		if (SID != null) this.SID = SID;
		if (name != null) this.name = name;
		if (desc != null) this.desc = desc;
		
		collection = [];
	}//---------------------------------------------------;

	/**
	 * Quick add an option data to a page data
	 * 
	 * @param	label The text that will appear
	 * @param	type One of ["link", "slider", "oneof", "toggle"]
	 * @param	params { 
	 * 					sid:String,   Give the optionData an ID
	 * 					data:Dynamic, Data associated with the controller
	 * 					startValue:Dynamic Starting value of the controller //! Warning: Unsanitized
	 * 					condition: function that if true will enable this option {store page link in data}
	 * @return
	 */
	public function add(label:String, type:String, ?params:Dynamic):MenuOptionData
	{
		var o = new MenuOptionData(label, _lastUID);
			
			o.SID = Reflect.field(params, "sid");
			o.slave.pool = Reflect.field(params, "data");
			o.slave.current = Reflect.field(params, "startValue");
			o.conditional = Reflect.field(params, "condition");
			
			o.slave.type = type;
			o.slave.init();
			
		_lastUID++;
		collection.push(o);
		return o;
	
	}//---------------------------------------------------;

	
	/**
	 * Quick add a LINK
	 * @param label
	 * @param page Start with "@" to link to page, Start with "!" to callback action, "#back" to go back
	 */
	public function link(label:String, page:String, ?sid:String)
	{
		add(label, "link", { data:page, sid:sid } );
	}//---------------------------------------------------;

	// --
	public function removeOptionWithUID(UID:Int)
	{
		for (cc in 0...collection.length)
		{
			if (collection[cc].UID == UID)
			{
				collection.splice(cc, 1);
				return;
			}
		}
	}//---------------------------------------------------;
	
	// --
	// Free memory, help the garbage collector?
	public function destroy()
	{
		for (i in collection)
		{
			i.slave.pool = null;
			i.slave.current = null;
			i.slave = null;
		}
		
		collection = null;
		custom = null;
	}//---------------------------------------------------;
	
}//-------------------------------------------------------;