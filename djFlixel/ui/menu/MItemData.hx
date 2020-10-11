package djFlixel.ui.menu;

/**
  ENCODED STRING GUIDELINES:
  - You can use short encoded string to add menu items on the page
  - Both add() and addM() take these encoded strings
  
  = Links
	"Custom Text|link|linkdata"
	linkData = 
		- Plain string will callback with this string
		- String starts with : Followed with a string
			`@` => Menu will go to pageID e.g. `@pageID`
			`#` => Confirm action using a popup. e.g. `#delete` calls `delete` after confirming
			`!` => Confirm action using a new page. e.g. `#delete` calls `delete` after confirming
		- `@back` will make the menu go back one page
		
	Examples:
	
		"Quit|link|!quit|cfm=Do you really want to quit?:Get me out:Stay",
		"Quit|link|#quit|cfm=:yes:no"	// You can skip the question like so<
		"Fullscreen|toggle|c=false|id="

	
  
**/
  







/**

Data Guidelines
----------------

-link
	link:String		;	Page ID or callback ID
	type:Int		;	Autoset based on the first character of link ;	def = 0
						0:PageCall, 1:Call, 2:Call-ConfirmPopup, 3:Call-ConfirmFullPage
						@ PageCall
						# Popup Confirmation
						! FullPage Confirmation
	
	?cfm:String		;	Confirm before triggering. CSV "Question:YES:NO"
						NULL for default
	
	?tStyle:DTextStyle 	; Used in FLXMENU on Confirmation Pages (popup+fullpage)
						; overrides the text style
						
-range
	range:Array<Float> 	;	[Min to Max]			; must-be-set
	c:Float				;	Current selected number ; def = range[0]
	step:Float			;	Increment steps			; def = 1
	loop:Bool			;	Loop at edges			; def = false
	
	
-list
	list:Array<String>	;	The list of elements	; must-be-set
	c:Int				; 	Current index on list	; def = 0
	loop:Bool			; 	Loop at edges			; def = false
	
	
-toggle
	c:Bool				;	Toggle Status			; def = false
	
-label
	-- no data --

-label2
	text:String			;	The second part of the label
	

*/
	


class MItemData 
{
	inline static var LINK_TAG_GOTO = "@";
	inline static var LINK_TAG_CONF_POPUP  = "#";
	inline static var LINK_TAG_CONF_PAGE   = "!";
	
	// All the available functionality types the menuItem Offers
	public static var AVAILABLE_TYPES(default, never):Array<String> = [
		"link", "range", "list", "toggle", "label", "label2"
	];
	
	// The index of this Menu Item in the Page. Starts at 0
	// public var index:Int;
	
	// General Purpose String ID of the item
	public var ID:String;
	
	// Label text of the menu item, This is the full text, not the rendered one.
	public var label:String;
	
	// Some optional description
	public var description:String;
	
	// If this is false, then this item can't be selected
	// : useful for label texts
	public var selectable:Bool = true;
	
	// A disabled element can't have interactions, but it can be highlighted
	public var disabled:Bool = false;

	// What functionality this MenuItem has. See AVAILABLE_TYPES
	public var type:String = null;
	
	// Holds all the internal data
	// Also can include custom user data in this object
	// ~ Guidelines at the bottom of this file ~
	public var data:Dynamic = {};
	
	public function new(?encStr:String,?O:Dynamic) 
	{
		if (encStr != null) fromStr(encStr);
		if (O != null) fromObj(O);
		finalize_check();
	}//---------------------------------------------------;
	
	/**
	   Push data based on a special formated string:
		"label|type|loop=true|c=3"
	   - NO SAFEGUARDS - STRINGS MUST BE CORRECT !
	   - Separate fields with `|`, do not end or start with it, no whitespace (labels are ok)
	   - Field (1) MUST be Label
	   - Field (2) MUST be Type, ["link", "range", "list", "toggle", "label", "label2"]
	   - Fields 3 and on are optional
	   - Valid fields:
			id=String | desc=description | range=min,max | list=a,b,v | loop=Bool | c=Int | step=Float
			cfm=Question:yes:no // for links
			Any other field will be stored in data as string e.g. |custom=one| => data.custom = "one"
			Links can have a field with no '=' and it will count as link data e.g. `@options`
	**/
	function fromStr(s:String)
	{
		var pairs = s.split('|');
		label = pairs.shift();
		type = pairs.shift();
		
		// ^ Get the first 2 fields that are standard
		// Then check what the other fields are and set values
			
		for (i in pairs)
		{
			var ar = i.split('=');
			
			switch(ar[0])
			{
				case 'range':
					var _n = ar[1].split(',');
					data.range = [
						Std.parseFloat(_n[0]),
						Std.parseFloat(_n[1]),
					];
				case 'list':
					data.list = ar[1].split(',');
				case 'loop':
					data.loop = (ar[1] == "true");
				case 'label2':
					data.text = ar[1];
				case 'c':
					switch(type) {
						case "range": data.c = Std.parseFloat(ar[1]);
						case "list": data.c = Std.parseInt(ar[1]);
						case "toggle": data.c = (ar[1] == "true");
						default: data.c = ar[1];
					}					
				case 'step':
					data.step = Std.parseFloat(ar[1]);
				case 'id':
					ID = ar[1];
				case 'desc':
					description = ar[1];
					
				case a if (ar.length == 1):
					if (type == "link") {
						data.link = a;
					}else
					if (type == "label2") {
						data.text = a;
					}else 
						throw "Invalid Format : " + s;
					
				
				case _:
					Reflect.setField(data, ar[0], ar[1]);
					
			}// end switch
			
		}// end for
		
	}//---------------------------------------------------;
	
	
	/**
	   You can set these fields
	   id, type, desc, label, disabled, selectable
	   Other fields will be copied to data{}
	**/
	function fromObj(o:Dynamic)
	{
		for (f in Reflect.fields(o)) 
		{
			switch(f)
			{
				case "id": ID = o.id;
				case "type": type = o.type;
				case "desc": description = o.desc;
				case "label": label = o.label;
				case "disabled": disabled = o.disabled;
				case "selectable": selectable = o.selectable;
				default:
					// Other fields copy directly to the data object
					Reflect.setField(data, f, Reflect.field(o, f));
			}
		}
	}//---------------------------------------------------;
	
	function finalize_check()
	{
		if (label == null)
			throw "No label for " + this;
			
		if (type == null)
			throw "Null type for " + this;
			
		// Initialize the types
		switch(type) {
			case "label":
				selectable = false;
			case "label2":
				if (ID == null) ID = data.text;	// Special case, it is more useful this way
				
			case "link":
				if (data.link == null) throw "Link not set " + this;
				var a:String = data.link; 
				var a1 = a.charAt(0);
				if (a1 == LINK_TAG_GOTO){
					data.type = 0;
					data.link = a.substr(1);
				}else if (a1 == LINK_TAG_CONF_POPUP){
					data.type = 2;
					data.link = a.substr(1);
				}else if (a1 == LINK_TAG_CONF_PAGE){
					data.type = 3;
					data.link = a.substr(1);
				}else{
					_datadef('type', 1);	// (1=FunctionCall)
				}
				
				if (ID == null) ID = data.link;	// Special case, it is more useful this way
				
			case "range":
				if (data.range == null) throw "Range not set" + this;
				_datadef('c', data.range[0]);
				_datadef('loop', false);
				_datadef('step', 1);
				
			case "list":
				if (data.list == null) throw "List not set" + this;
				_datadef('c', 0);
				_datadef('loop', false);
				
			case "toggle":
				_datadef('c', false);
				
			default:
				throw "Invalid type for " + this;
		}
	
	}//---------------------------------------------------;
	
	// Check if a value is set on the data{} object, if not set value
	function _datadef(field:String, val:Dynamic)
	{
		if (!Reflect.hasField(data,field)){
			Reflect.setField(data, field, val);
		}
	}//---------------------------------------------------;
	
	
	/**
	   If this item is LINK and has a CONFIRMATION type, then
	   return the question:yes:no strings into an object {q,y,n}
	**/
	public function getConfirmation()
	{
		var o = {
			q:"Are you sure?",
			y:"Yes",
			n:"No"
		};
		
		if (data.cfm == null)
		{
			return o;
		}
		
		var a = cast(data.cfm, String).split(':');
		o.q = a[0];
		if (a[1] != null) o.y = a[1];
		if (a[2] != null) o.n = a[2];
		
		return o;
	}//---------------------------------------------------;
	
	
	
	public function get():Any
	{
		return switch(type){
			case "list"  : data.list[data.c];
			case "link"  : data.link;
			case "toggle": data.c;
			case "range" : data.c;
			default: 0;
		}
	}//---------------------------------------------------;
		
	
	// -- Debugging
	public function toString():String
	{
		return 'ID:$ID | Label:$label | Type:$type | Data:$data';
	}//---------------------------------------------------;

}// --


