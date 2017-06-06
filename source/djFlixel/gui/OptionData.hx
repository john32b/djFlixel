package djFlixel.gui;

/**
 * Just the data of menu element
 */
class OptionData
{
	// A simple incremental UID Generator
	// Possible bugs after 32bit values??
	static var UID_GENERATOR:Int = 0;
	
	// General Purpose Int ID of the option
	// # auto set #
	public var UID:Int;
	// General Purpose String ID of the option
	public var SID:String;
	// Label text of the menu option, This is the full text, not the rendered one.
	public var label:String;
	// Some optional description
	public var description:String;
	
	// == Functionality ==
	// ===================
	
	// If this is false, then this option can't be selected
	// Useful for label text
	public var selectable:Bool = true;
	
	// A disabled element cant have interactions.
	public var disabled:Bool = false;
	
	// All the available functionality types the menuOption Offers
	public static var AVAILABLE_TYPES(default, never):Array<String> = [
		"link", "slider", "oneof", "toggle", "label"
	];
	
	// What functionality this MenuOption has
	// :: Must be one of the available types
	public var type:String;
	
	// Hold all the internal data
	// Also can include custom user data in this object
	public var data:Dynamic;
	
	//====================================================;
	
	/**
	 * 
	 * @param	label   The label of this option
	 * @param	params [ multiple parameters dynamic obj ]
	 * 
	 * 					current: Depending on type
	 * 					desc: Description
	 * 					type: "link", "slider", "oneof", "toggle", "label"
	 * 					sid: starting with
	 * 							#, popup confirmation
	 * 							!, fullpage confirmation
	 * 							@, goto target page
	 * 					pool: Depending on type
	 * 					conf_question: String, Question, optional
	 * 					conf_options:  Array<String>, instead of YES NO
	 * 					callback: If it's a link, this (void->void) will be called
	 * 					styleOption : Applicable in some occations like a full confirmation page
	 * 
	 */		
	public function new(?label:String, ?params:Dynamic)
	{
		// Info: Actionscript INT MaxSize = 2147483647;
		UID = UID_GENERATOR++;
		data = { };		
		this.label = label;
		setNewParameters(params);
	}//---------------------------------------------------;
	
	// --
	// Set and initialize new data
	public function setNewParameters(?params:Dynamic)
	{
		if (params == null) return;
		
		for (f in Reflect.fields(params)) {
			switch(f) {
				// Those fields apply to the object
				case "sid": SID = Reflect.field(params, f);
				case "label": label = Reflect.field(params, f);
				case "type": type = Reflect.field(params, f);
				case "desc": description = Reflect.field(params, f);
				case "selectable": selectable = Reflect.field(params, f);
				case "disabled": disabled = Reflect.field(params, f);
				// Map all other custom fields to the data object.
				default: Reflect.setProperty(data, f, Reflect.field(params, f));
			}
		}
		
		initData();
	}//---------------------------------------------------;
	
	// --
	public function destroy()
	{
		if (data.pool != null) data.pool = null;
		if (data.current != null) data.current = null;
		data = null;
	}//---------------------------------------------------;
	
	// --
	// Call this after setting data to initialize it
	function initData()
	{
		// -- Some Safeguards
		if (type == null) {
			type == "label";
			label = "(null)" + label;
			trace("Error: Forgot to set a type",this);
		}
		if ((type != "label") && (SID == null || SID.length == 0)) {
			// It should be filled with something in most cases.
			trace("Warning: SID is NULL",this);
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
			trace('Error: Invalid type ($type) for MenuOptionData');
		}
		
	}//---------------------------------------------------;

	
	// --
	public function toString():String
	{
		return '[SID:$SID | Label:$label | Type:$type | Data:$data';
	}//---------------------------------------------------;
		
}//-- end --