package djFlixel.gui.menu;

/**
 * Just the data of menu item that goes inside an FlxMenu 
 * Types of what this Item can be:
 * 
 * - Label		;	Just text, can
 * - Link		;	Fires a function or goes to another page
 * - Checkbox	;	On/Off
 * - Slider		;	Selects integers from a range
 * - OneOf		;	Selects strings from a selection
 * 
 */
class MItemData
{
	// A simple incremental UID Generator
	static var UID_GENERATOR:Int = 0;
	
	// General Purpose Int ID of the item
	public var UID:Int;
	
	// General Purpose String ID of the item
	public var SID:String;
	
	// Label text of the menu item, This is the full text, not the rendered one.
	public var label:String;
	
	// Some optional description
	public var description:String;
	
	// If this is false, then this item can't be selected
	// : useful for label texts
	public var selectable:Bool = true;
	
	// A disabled element can't have interactions
	public var disabled:Bool = false;
	
	// All the available functionality types the menuItem Offers
	public static var AVAILABLE_TYPES(default, never):Array<String> = [
		"link", "slider", "oneof", "toggle", "label"
	];
	
	// What functionality this MenuItem has
	// : must be one of the available types
	public var type:String;
	
	// Holds all the internal data
	// Also can include custom user data in this object
	public var data:Dynamic;
	
	//====================================================;
	
	/**
	 * Constructor
	 * @param	label   The label of this item
	 * @param	params {..} see: MItemData.setNewParameters(..) for help
	 */
	public function new(?label:String, ?params:Dynamic)
	{
		// Info: Actionscript INT MaxSize = 2147483647;
		UID = UID_GENERATOR++;
		data = { };		
		this.label = label;
		setNewParameters(params);
	}//---------------------------------------------------;
	
	/**
	 * Sets and initializes new data
	 * NOTE: I need this to be a separate function, don't merge with the constructor
	 * @param params { .. } 
	 * 
	 * 		type: String, 	["link", "slider", "oneof", "toggle", "label"]
	 * 		desc: String,	Description
	 * 		sid:  String,   Give the itemData an unique ID. String starting with :
	 * 							# = popup confirmation, open a small popup
	 * 							! = fullpage confirmation before firing the callback
	 * 							@ = goto target page, e.g. "@options" will go to the page with SID="options"
	 * 
	 * 		pool: Dynamic, 		Data associated with the controller, depends on type
	 * 		current: Dynamic,	Current value of the controller, depends on type
	 * 
	 * 		conf_question: 	String, Question to present if a confirmation check is required
	 * 		conf_options:Array<String>: Anything other instead of YES / NO
	 * 	
	 *		styleItem: Applicable in some occations like a full confirmation page
	 * 		callback: If it's a link, this (void->void) will be called
	 */
	public function setNewParameters(?params:Dynamic)
	{
		if (params == null) return;
		
		for (f in Reflect.fields(params)) {
			switch(f) {
				// Those fields apply to the object
				case "sid": SID = Reflect.field(params, f);
				case "type": type = Reflect.field(params, f);
				case "desc": description = Reflect.field(params, f);
				case "label": label = Reflect.field(params, f);
				case "disabled": disabled = Reflect.field(params, f);
				case "selectable": selectable = Reflect.field(params, f);
				// Map all other custom fields to the data object.
				default: Reflect.setProperty(data, f, Reflect.field(params, f));
			}
		}
		
		// -- Some Safeguards
		if (type == null) {
			type == "label";
			label = "(null)" + label;
			trace("Error: Forgot to set a type", this);
		}
		
		if ((type != "label") && (SID == null || SID.length == 0)) {
			// It should be filled with something in most cases.
			trace("Warning: SID is NULL", this);
			SID = "null";
		}
		
		if (label == null) {
			label = "(null)";
		}
		
		// Initialize the types
		// --
		switch(type) {
			
		case "label": // ------------------------------ label
			selectable = false;
			
		case "oneof": // ------------------------------ oneof 
			// Current is the index
			if (data.current == null) 
				data.current = 0; 
			#if debug
			if (data.pool == null || data.pool.length == 0) {
				trace("Error: Data Pool is empty. Filling with dummy data.");
				data.pool = ["one", "two"];
			}
			#end
		
		case "toggle":	// ---------------------------- toggle 
			if (data.current == null)
				data.current = false;
				
		case "slider": // ----------------------------- slider
			// Current shows actual value
			#if debug
			if (data.pool == null) {
				trace("Error: dataPool is NULL. Setting to [1,10]");
				data.pool = [1, 10];
				data.current = 1; 
				return;
			}
			#end
			if (data.current == null)
				data.current = data.pool[0];	
				
		case "link":  // ----------------------------- link
			
			if (SID.charAt(0) == "#") // Confirm before calling, POPUP STYLE
			{
				data.fn = "call";
				SID = SID.substring(1);
				data.conf_active = true;
				data.conf_style = "popup";
				// If a question is missing, it won't be presented
				// data.conf_question, defaults are at FLXMENU
				// data.conf_options , defaults are at FLXMENU
			}
			else if (SID.charAt(0) == "!")
			{
				data.fn = "call";
				SID = SID.substring(1);
				data.conf_active = true;
				data.conf_style = "full";
				if (data.conf_options == null)
					data.conf_options = ["Yes", "No"];
				if (data.conf_question == null)
					data.conf_question = label + ", Are you sure?";
			}
			else if (SID.charAt(0) == "@") 
			{
				data.fn = "page";
				SID = SID.substring(1);
			}
			else {
				data.fn = "call";
			}
			
		default:  // If not null but something else
			trace('Error: Invalid type ($type) for MItemData');
		}// -- end switch
	}//---------------------------------------------------;
	
	// --
	public function destroy()
	{
		if (data.pool != null) data.pool = null;
		if (data.current != null) data.current = null;
		data = null;
	}//---------------------------------------------------;
	
	// -- Debugging
	public function toString():String
	{
		return '[SID:$SID | Label:$label | Type:$type | Data:$data';
	}//---------------------------------------------------;
		
}//-- end --