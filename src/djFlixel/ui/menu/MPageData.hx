/** 
	PageData
	--------
	- Holds multiple <MItemData> items
	- Handled my <MPages> which is the Group Sprite of a Menu Page
	- Offers some extra page customization options
	- You can use add(..) to create Items in a Page
	
************************************************/

package djFlixel.ui.menu;
import djA.DataT;
import djFlixel.ui.menu.MItemData;
import haxe.macro.Expr.Var;

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
	
	/** Optional Parameters */
	public var PAR:Dynamic = {
		width:0,			// Override the FLXMENU width for this page
		slots:0,			// Override the FLXMENU slots for this page
		part1W:0,			// Used in "center2" alignment. The length of the label1 in Mitems.
							// 0 For default menu_width/2
		
		// -- Style Overrides :
		stI:null,	// Object, Can override fields of 'MItemStyle' | e.g. { text:{f:"pixel8.ttf", s:16, bt:2} }
		stL:null,	// Object, Can override fields of 'VListStyle' | e.g. { loop:true }
		
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
	**/
	public function add(STR:String):MPageData
	{
		var S = STR.split('-|').map((i)->StringTools.trim(i)).filter((i)->i.length > 0);
		for (s in S) {
			items.push(new MItemData(s));
		}
		return this;
	}//---------------------------------------------------;

	/**
	 * Get an MItemData from ID
	 * <null> if nothing is found */
	public function get(id:String):MItemData
	{
		for (i in items) if (i.ID == id) return i; return null;
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
	   @param	item Must be a link type
	**/
	public static function getConfirmationPage(item:MItemData):MPageData
	{
		var P = new MPageData('dyn_conf_${item.P.link}');	// construct a dynamic ID
		var Q = item.P.ask;
		
		// DEV: 
		// If I don't add the |.| the label will get `ID=U` :-(
		if (Q[0].length > 0) {
			P.add('${Q[0]}|label|.|U');
		}
		
		P.add(' ${Q[1]}|link|${item.P.link} -|${Q[2]}|link|@back');
		P.PAR.noBack = true;
		P.PAR.noPool = true;
		return P;
	}//---------------------------------------------------;
	
}// --