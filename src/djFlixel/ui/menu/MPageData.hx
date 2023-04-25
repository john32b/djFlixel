/** 
	PageData
	--------
	- Holds multiple <MItemData> items
	- Handled by <MPages> which is responsible of displaying the menu items
	- You can use add(..) to create Items in a Page
	
************************************************/

package djFlixel.ui.menu;
import djA.DataT;
import djFlixel.ui.menu.MItemData;

@:dce
class MPageData 
{
	// Unique ID
	public var ID:String;
	
	// Optional Menu Title
	public var title:String;
	
	// Optional Menu Description
	public var info:String;
	
	// Data holder, Store the items serially
	public var items(default, null):Array<MItemData>;
	
	/** MPage STP overlay. Set this to override fields of the MPage style */
	public var STPo:Dynamic;
	
	/** Optional Parameters (Anonymous struct with autocompletion) */
	public var PAR = {
		pos:'rel',			// rel : Relative to root FlxMenu (x,y) pos
							// abs : Fixed world/screen coordinates
							// screen,X,Y : align to screen edges
							// 	X: l c r
							//  Y: t c b  ; uses Dalign.screen() identifiers
							
							//   e.g. 	"screen,t,l" 	-- position menu to top-left center of the screen
							//			"screen,c,c" 	-- position menu to screen center
							
		x:0,				// Override FlxMenu x for pos:(rel,abs). OR padding for pos (screen,x)
		y:0,				// Override FlxMenu y for pos:(rel,abs). OR padding for pos (screen,y)
		width:0,			// Override FlxMenu width
		slots:0,			// Override FlxMenu slots

		// -- The following are used internally :
		
		cindex:-1,			// Remembers cursor index. Helps FlxMenu remember selected 
							// indexes when going back() | Also used on some other cases.
							
		noPool:false,		// Will not pool the MPage, Used in dynamic pages.
		isPopup:false		// True for confirmation popups.
	};
	
	/**
	   New page data
	   @param	ID_   Unique ID
	   @param	TITLE Page name/title
	   @param	P override default parameters. you can set some fields
	**/
	public function new(_ID:String, ?_TITLE:String, ?_P:Dynamic) 
	{
		items = [];
		ID = _ID;
		title = _TITLE;
		if (_P != null){
			PAR = DataT.copyFields(_P, Reflect.copy(PAR));
		}
	}//---------------------------------------------------;
	
	/** 
		Add one or multiple <MItemData> using the special String Encoding
		See <MItemData.hx> for more info on the expected encoded string
		- FOR Multiple Items, use a single string with `-|` as separator between items
		  example: (and note, this is a single string, haxe supports this)
			add( " -| New Game | link | ng+
				   -| Options | link |@options
				   -| Quit | link | quit | ?pop=Really Quit:Yes:No " );
				   
		- for single elements just do
			.add( "Player Lives | range | idlives | 1,9 | c=4 ");
		  it will be appended to the items Array of this page
		@param STR The encoded string that constructs the item
		@param at The index to add the new items to | -1 (default) add at the end 
	**/
	public function add(STR:String, at:Int =-1):MPageData
	{
		var S = STR.split('-|').map((i)->StringTools.trim(i)).filter((i)->i.length > 0);
		for (s in S) {
			var it = new MItemData(s);
			if (at >= 0) {
				items.insert(at++, it);
			}else{
				items.push(it);
			}
		}
		return this;
	}//---------------------------------------------------;

	
	/** Quickly modify the PARameters object
	 *  @param p Override fields of PAR
	 */
	public function par(p:Dynamic):MPageData
	{
		PAR = DataT.copyFields(p, PAR);
		return this;
	}//---------------------------------------------------;
	
	/** Quickly add overrides to the STPo object
	 */	
	public function stl(p:Dynamic):MPageData
	{
		STPo = DataT.copyFields(p, STPo);
		return this;
	}//---------------------------------------------------;
	
	
	/**
	 * Get an MItemData from ID
	 * <null> if nothing is found */
	public function get(id:String):MItemData
	{
		return items.filter(i->i.ID == id)[0];
	}//---------------------------------------------------;
	
	/** Get the index belonging to an item with ID 
	 *  <MPage> uses this to jump to slots*/
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
	   Quickly construct a pagedata with the confirmation options of the Link Item
	   - For use in an FLXMENU
	   - The MPAGE that is created has an id of "ask:link_id
	   - It can generate multiple labels from the Ask string
			ask="Line1|Line2";  | is the separator
	   @param	item Must be a link type
	**/
	public static function getConfirmationPage(item:MItemData):MPageData
	{
		var P = new MPageData('ask:${item.P.link}');
		var Q = item.P.ask;
		
		// Split \n to multiple labels
		if (Q[0].length > 0) {
			var str:String = Q[0];
			for (l in str.split('\n')) {
				P.add('${l}|label|.|U');	// DEV: I need to add a |.| as an ID
			}
		}
		
		P.add(' ${Q[1]}|link|${item.P.link} -|${Q[2]}|link|@back');
		P.PAR.noPool = true;
		P.PAR.slots = P.items.length;
		P.PAR.cindex = P.items.length - 1;	// Highlight the last one by default
		return P;
	}//---------------------------------------------------;
	
}// --