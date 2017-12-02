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
	// callbacks_item   override the menu's callback function to this one.
	// -----------------------------------------------
	// - Fields starting with _ are used internally ::
	// -----------------------------------------------
	// _cursorLastPos   Int, Store the latest cursor position if it's needed later
	// _dynamic			Bool, Dynamic page flag
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
	public function new(?SID:String, ?params:Dynamic)
	{
		collection = [];
		custom = { };
		
		this.UID = UID_GENERATOR++;
		this.SID = SID;
		
		if (params == null) return; // no need to read params if null	
		
		title = Reflect.field(params, "title");		  // Title
		description = Reflect.field(params, "desc");  // Description, or subtitle
		
	}//---------------------------------------------------;

	/**
	 * Quick add an item data to this page
	 * 
	 * @param	label The label of the Menu Item
	 * @param	params { .. } see: MItemData.setNewParameters(..) for help
	 * @return The produced MItemData
	 */
	public function add(label:String, ?params:Dynamic):MItemData
	{
		var o = new MItemData(label, params);
		collection.push(o);
		return o;
	}//---------------------------------------------------;
	
	/**
	 * Quickly add a Link
	 * @param label The display name
	 * @param SID Start with "@" to link to page, Start with "!" or "#" to confirm action, "#back" to go back
	 * @param callback If you want to specifically manage callbacks from this item. Otherwise use the global menu callback handler
	 */
	public inline function link(label:String, SID:String, ?callback:Void->Void):MItemData
	{
		return add(label, { type:"link", sid:SID, callback:callback } );
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

	
}//-- end --//