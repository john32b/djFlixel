package djFlixel.ui.menu;
import djA.DataT;



/** PageData
	--------
	Holds a single page data for use in FlxMenu.
	- Stores `MItemData` serially in an array
	- Some other page customization options
**/
@:dce
class MPageData 
{
	public var ID:String;
	
	// Optional Menu Title
	public var title:String;
	
	// Optional Menu Description
	public var description:String;
	
	// Data holder, Store the items serially
	public var items(default, null):Array<MItemData>;
	
	/** Optional Parameters */
	public var params:Dynamic = {
		width:0,			// Override the FLXMENU width for this page
		slots:0,			// Override the FLXMENU slots for this page
		part1W:0,			// Used in "center2" alignment. The length of the label1 in Mitems.
							// 0 For default menu_width/2
		
		// -- Style Overrides :
		stI:null,	// Can override fields of 'MItemStyle'
		stL:null,	// Can override fields of 'VListStyle'
		
		// -- The following are used internally :
		lastIndex:-1,		// Remember the last selected index when the page becomes unfocused
		noBack:false,		// Do not send a 'back' signal if a back button is pressed
		noPool:false		// Will not pool the MPage, Used in dynamic pages.
	};
	
	/**
	   New page data
	   @param	ID_   Unique ID
	   @param	TITLE Page name/title
	   @param	P override default parameters. you can set some fields
	**/
	public function new(ID_:String, ?TITLE:String, ?P:Dynamic) 
	{
		items = [];
		ID = ID_;
		title = TITLE;
		if (P != null){
			params = DataT.copyFields(P, Reflect.copy(params));
		}
	}//---------------------------------------------------;
	
	/** Encoded String (and/or) Object Parameters. See `MItemData.hx`
	**/
	public function add(?strEnc:String,?o:Dynamic):MPageData
	{
		items.push(new MItemData(strEnc, o));
		return this;
	}//---------------------------------------------------;
	
	/** Add Many, in an Array, Encoded Strings ONLY. `MItemData.hx`
	**/
	public function addM(it:Array<String>):MPageData
	{
		for (i in it) add(i);
		return this;
	}//---------------------------------------------------;
	
	/**
	 * Get an MItemData from ID
	 * NULL if nothing is found */
	public function get(id:String):MItemData
	{
		for (i in items) if (i.ID == id) return i; return null;
	}//---------------------------------------------------;
	
	/** Get the index belonging to an item with ID */
	public function getIndex(id:String):Int
	{
		var i = items.length;
		while (i-->0){
			if (items[i].ID == id) return i;
		}
		return -1;
	}//---------------------------------------------------;
	
	/**
	 * Swap the indexes of two items in the array
	 * @param	i1 Second Index
	 * @param	i0 First Index
	 */
	public function swap(i0:Int,i1:Int) {
		var t = items[i0];
		items[i0] = items[i1];
		items[i1] = t;
	}//---------------------------------------------------;
	
	
	/**
	   Quickly construct a pagedata with the confirmation options of `item`
	   - For use in an FLXMENU
	   @param	item Must be a link type
	**/
	public static function getConfirmationPage(item:MItemData):MPageData
	{
		var P = new MPageData('dyn_conf_${item.data.link}');
		var Q = item.getConfirmation();
		// The question can be empty, and if it is only "yes:no" will be presented
		if (Q.q.length > 0) {
			P.add(Q.q + '|label');
			P.params.slots = 3;
		}else{
			P.params.slots = 2;
		}
		
		P.addM([ 	Q.y + '|link|' + item.data.link,
					Q.n + '|link|@back'] );
		P.params.noBack = true;
		P.params.noPool = true;
		return P;
	}//---------------------------------------------------;
	
}// --