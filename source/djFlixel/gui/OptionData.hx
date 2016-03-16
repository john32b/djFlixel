package djFlixel.gui;

// A Menu option holds a label + menu functionality,
// Just the data.
// --
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
	public var data:Dynamic;
	
	//====================================================;
	
	/**
	 * 
	 * @param	label   The label of this option
	 * @param	params [ multiple parameters dynamic obj ]
	 * 
	 * 					current: Depending on type
	 * 					desc: Description
	 * 					pool: Depending on type
	 * 					confirmation: String, Question
	 * 					conditional: Void->Bool, Must check this to be enabled		
	 */		
	public function new(?label:String, ?params:Dynamic)
	{
		if (label != null) this.label = label;
		
		// Info: Actionscript INT MaxSize = 2147483647;
		UID = UID_GENERATOR++;
		
		data = { };
		
		if (params == null) return;
		
		// Optional Parameters
		if (params != null)
		for (f in Reflect.fields(params)) {
			switch(f) {
				// Those fields apply to the object
				case "sid": SID = Reflect.field(params, f);
				case "type": type = Reflect.field(params, f);
				case "desc": description = Reflect.field(params, f);
				case "selectable": selectable = Reflect.field(params, f);
				case "disabled": disabled = Reflect.field(params, f);
				
				// Map all other fields to the data var
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
	// TODO: Stupid name, change it.
	// Call this after setting data
	public function initData()
	{
		// Some Safeguards --
		#if debug
		if (type == null) {
			type == "link";
			label = "(er)" + label;
			trace("Error: Forgot to set a type");
		} 
		#end
		
		// Initialize the types 
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
			#if debug
			if (SID == null || SID.length == 0) {
				// It should be filled with something.
				trace("Error: SID is NULL");
				SID = "null";
			}
			#end
			
			if (SID.charAt(0) == "!") // Confirm before calling
			{
				data.fn = "call";
				data.link = SID.substring(1);
				data.confirm = true;
				
				if (data.confirmation == null) {
					data.confirmation = label + ", Are you sure?";
				}
				
			}else
			if (SID.charAt(0) == "@") 
			{
				data.fn = "page";
				data.link = SID.substring(1);
			}else 
			{
				data.fn = "call";
				data.link = SID;
			}
			
		default:  // ----------------------------- default
			trace('Error: Invalid type ($type) for MenuOptionData');
		}
		
	}//---------------------------------------------------;

	// --
	public function toString():String
	{
		return '[SID:$SID | Label:$label | Type:$type | Data:$data';
	}//---------------------------------------------------;
		
}//-- end --