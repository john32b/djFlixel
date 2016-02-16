package djFlixel.gui;


// --
// Manages a collection of MenuOptionData
class PageData
{
	// Unique String ID of the page
	public var SID:String;
	// Unique Int ID of the page
	public var UID:Int;		
	
	// Optional Menu Header Titler
	public var header:String;
	// Optional Menu Description
	public var description:String;
	
	// Data holder, Store the options serially
	public var collection:Array<OptionData>;

	// Store some page specific custom parameters
	public var custom:Dynamic;	
	
	// Things that you can store in custom :
	// -------------------------------------
	// width			 Int, Custom page width
	// slots	 		 Int, How many slots this page should have for the screen representation
	
	// DEPRECATED: divider Int, The percent of the total Width that the divider will go to
	
	// styleXXX 		 Object, Used by the djFlixel menu system for storing menu styles
	// 					 [styleOption, styleList, styleBase]
	// lockNavigation    bool, If true the page cannot send a "back" request
	// cursorStart		 SID, the sid of the option to always highlight when going into this menu
	
	// callbacks_option   override the menu's callback function to this one.
	
	// ====
	// = Fields starting with _ are used by the system =
	// 
	// _cursorLastPos   Int, Store the latest cursor position if it's needed later
	// _condIndexes	    Array<Int> store the indexes of the conditionals
	
	//====================================================;
	// FUNCTIONS
	//====================================================;
	
	/**
	 * A page data holds multiple menu options.
	 * 
	 * @param	SID Identifier for the page
	 * @param	params [ header, description ]
	 */
	public function new(SID:String, ?params:Dynamic)
	{
		collection = [];
		custom = { };
		
		this.SID = SID;
		
		if (params == null) return; // no need to read params if null	
		
		header = Reflect.field(params, "header");		// Header
		description = Reflect.field(params, "desc");	// Description, or subtitle
		
		// - You can set other custom data later, after creating this object
		//	 by directly setting what you need with Page.custom.whatever = whatever;
		//   You can use strings, ints, bools, or objects etc
		
	}//---------------------------------------------------;

	/**
	 * Quick add an option data to a page data
	 * 
	 * @param	label The text that will appear
	 * @param	params { 
	 * 		type: String, ["link", "slider", "oneof", "toggle", "label"]
	 * 		sid:  String,   Give the optionData an ID
	 * 		pool: Dynamic, Data associated with the controller
	 * 		current: Dynamic, Current value of the controller ! Warning: Unsanitized
	 * 		condition: Bool->Void that if true will enable this option
	 * 	confirmation: String, Question
	 * 
	 * @return The produced OptionData
	 */
	public function add(label:String, ?params:Dynamic):PageData
	{
		var o = new OptionData(label, params);
		
		collection.push(o);
		return this;
	}//---------------------------------------------------;
	
	/**
	 * Quick add a Link type to the page
	 * @param label The display name
	 * @param page Start with "@" to link to page, Start with "!" to callback action, "#back" to go back
	 */
	public inline function link(label:String, SID:String, ?description:String):PageData
	{
		return add(label, { type:"link", sid:SID, desc:description } );
	}//---------------------------------------------------;

	
	/**
	 * Quick way to add a back button
	 */
	public inline function addBack(?text:String):PageData
	{
		return add(text != null?text:"Back", { type:"link", sid:"@back", desc:"Go back" } );
	}//---------------------------------------------------;

	
	/**
	 * Adds a question to the page.
	 * @param	text  Question to ask
	 * @param	sid   The results will callback as : "sid_yes", "sid_no"
	 */
	public function question(text:String, sid:String, lockNavigation:Bool = false)
	{
		add(text, { type:"label" } );
		link("yes", '${sid}_yes');
		link("no" , '${sid}_no');
		
		this.custom.lockNavigation = lockNavigation;
		this.custom.cursorStart = '${sid}_no';
	}//---------------------------------------------------;
	
	
	// --
	// Free memory, help the garbage collector?
	public function destroy()
	{
		for (i in collection) {
			i.destroy();
			i = null;
		}
		
		collection = null;
		custom = null;
	}//---------------------------------------------------;

	
}//-- end --//