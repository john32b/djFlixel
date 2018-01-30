package djFlixel.gui.menu;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

// PageData
// --------
// Holds a single page data for use in FlxMenu,
// parameters about the page like title, custom styles
// and an array with all the menu items it contains.
// --
class PageData implements IFlxDestroyable
{
	// Auto Incremented everytime a page is generated
	public static var UID_GENERATOR:Int = 0;
	
	// Unique String ID of the page
	public var SID:String;
	
	// Unique Int ID of the page
	public var UID:Int;		
	
	// Optional Menu Title
	public var title:String;
	
	// Optional Menu Description
	public var description:String;
	
	// Data holder, Store the items serially
	public var collection:Array<MItemData>;
	
	// Override the menu's default callbacks with this one
	public var callbacks_override:String->String->MItemData->Void = null;
	
	// The menu will call this in addition to its callbacks
	public var callbacks:String->String->MItemData->Void = null;
	
	// Store some page specific custom parameters
	public var custom:Dynamic;	
	// Things that you can store in the custom object ::
	// These vars are OPTIONAL and will override the FlxMenu defaults for this page.
	// NOTE: You can just set whatever fields you need on the styles, 
	//		 and they will override the FlxMenu Style
	// ------------------------------------------------------------------------------
	// width			Int, Custom page width
	// slots	 		Int, How many slots this page should have for the screen representation
	// styleMenu		Object, custom styleMenu can override parts of the FlxMenu style
	// lockNavigation   Bool, If true the page cannot send a "back" request ( by pressing the back button )
	// cursorStart		SID, the sid of the item to always highlight when going into this menu
	// initFire			Bool, If `true` will fire a `change` event on all menu items whenever this page gets `onScreen`
	// -----------------------------------------------
	// - Fields starting with _ are used internally ::
	// -----------------------------------------------
	// _cursorLastUID   Int, Store the latest cursor position if it's needed later
	// -----------------------------------------------
	
	//====================================================;
	// FUNCTIONS
	//====================================================;
	
	/**
	 * A page data holds multiple menu items.
	 * 
	 * @param	SID Identifier for the page
	 * @param	params { .. }
	 * 		title: optional Title
	 * 		desc:  optional Description
	 */
	public function new(?_SID:String, ?params:Dynamic)
	{
		collection = [];
		custom = { };
		
		UID = UID_GENERATOR++;
		SID = _SID;
		if (SID == null) SID = 'p_$UID';
		
		if (params == null) return; // no need to read params if null	
		
		for (f in Reflect.fields(params)) {
			switch(f) {
				// Those fields apply to the object
				case "title": title = Reflect.field(params, f);
				case "desc": description = Reflect.field(params, f);
				// Map all other custom fields to the data object.
				default: Reflect.setProperty(custom, f, Reflect.field(params, f));
			}
		}
	}//---------------------------------------------------;

	/**
	 * Quick add an item data to this page
	 * 
	 * @param	label The label of the Menu Item
	 * @param	params type:link,slider,oneof,toggle,label | sid:String | see: MItemData.setNewParameters(..) for help
	 * @return The produced MItemData
	 */
	public function add(label:String, ?params:Dynamic):MItemData
	{
		var o = new MItemData(label, params);
		collection.push(o);
		// If you didn't set an SID, it will be set to the item index on the set
		if (o.SID == null) {
			o.SID = '${collection.length}';
		}
		return o;
	}//---------------------------------------------------;
	
	/**
	 * Quickly add a Link
	 * @param label The display name
	 * @param SID Start with "@" to link to page, Start with "!" or "#" to confirm action, "#back" to go back
	 * @param callback If you want to specifically manage callbacks from this item. Otherwise use the global menu callback handler
	 */
	public inline function link(label:String, ?SID:String, ?description:String, ?callback:Void->Void):MItemData
	{
		return add(label, { type:"link", sid:SID, callback:callback, desc:description } );
	}//---------------------------------------------------;

	/**
	 * Quickly add a Label
	 */
	public inline function label(label:String):MItemData
	{
		return add(label, { type:"label" } );
	}//---------------------------------------------------;
	
	
	/**
	 * Quickly add a back button
	 */
	public inline function addBack(?text:String):MItemData
	{
		return add(text!= null?text:"Back", { type:"link", sid:"@back", desc:"Go back" } );
	}//---------------------------------------------------;

	
	/**
	 * Adds a question to the page. Useful in dynamic pages.
	 * @param	text  Question to ask
	 * @param	sid   The results will callback as : "sid_yes", "sid_no"
	 * @param	lockNavigation  Can it send a 'back' trigger
	 */
	public function question(text:String, sid:String, lockNavigation:Bool = false)
	{
		add(text, { type:"label" } );
		link("yes", '${sid}_yes');
		link("no" , '${sid}_no');
		
		custom.lockNavigation = lockNavigation;
		custom.cursorStart = '${sid}_no';
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
	
	/**
	 * Returns the MItemData of the page with target SID.
	 * NULL if nothing is found
	 * @param	sid
	 * @return
	 */
	public function get(sid:String):MItemData
	{
		for (i in collection) if (i.SID == sid) return i; return null;
	}//---------------------------------------------------;
	
	/**
	 * Returns the index of an item with a target field, Returns -1 if nothing found
	 * @param	field String Name of the field to check. (e.g. "SID", "UID .. )
	 * @param	check The value of the field will be checked against this
	 * @return 
	 */
	public function getItemIndexWithField(field:String, check:Dynamic):Int
	{
		var i = 0;
		for (i in 0...collection.length) {
			if (Reflect.field(collection[i], field) == check) {
				return i;
			}
		}
		return -1; // Not found
	}//---------------------------------------------------;
	
	/**
	 * Swap the indexes of two items in place in the collection array
	 * @param	i0 First Index
	 * @param	i1 Second Index
	 */
	public function swap(i0:Int,i1:Int)
	{
		var t = collection[i0];
		collection[i0] = collection[i1];
		collection[i1] = t;
	}//---------------------------------------------------;
	
}//-- end --//