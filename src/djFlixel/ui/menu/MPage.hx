/**
 * Specialized VLIST to hold MenuItems
 * 
 * - MenuItems can be of various classes, but all deriving from `MItem`
 * - FlxMenu creates MPages to display menus
 * 
 * =========================================== */


package djFlixel.ui.menu;

import djA.DataT;
import djFlixel.ui.VList;
import djFlixel.ui.menu.*;
import djFlixel.ui.menu.MItem.MItemStyle;
import djFlixel.core.Dtext.DTextStyle;
import flixel.util.typeLimit.OneOfTwo;

import flixel.FlxSprite;
import openfl.display.BitmapData;


// If not set will default to a text cursor
typedef MCursorStyle = {
	
	?disable:Bool,		// Do not use a cursor graphic at all
	?icon:String,		// Use a standard D.UI icon. CSV : "size:name" .e.g. "12:heart"
	?text:String,		// Character to use for cursor, uses same style as MItemStyle
	?bitmap:BitmapData, // Use this white bitmap for a cursor, will be colorized according to MItemStyle
	?color:DTextStyle,	// Colorize the Text/Bitmap with this. valid:{c,bc,bt,so}
	?offset:Array<Int>,	// [x,y] Cursor Offset (x+ moves right, y+ moves down)
	?tmult:Float,		// Cursor tween time multiplier. 0 for no animation	
}



class MPage extends VList<MItem,MItemData>
{
	static inline var DEFAULT_CURSOR_TEXT_OFFX = 3;	// Only applies to TEXT cursor, if offset is not set
	static inline var DEFAULT_CURSOR_SYMB = '>';
	//====================================================;
	
	// Hold the page data
	public var page(default, null):MPageData;
	
	// Optional Cursor style 
	public var styleC:MCursorStyle;
	
	// This is the style to use for all children elements
	// WARNING: No field override here, make sure you copy the default style <MItem.DEFAULT_STYLE>
	public var styleIt:MItemStyle;
	
	// This is responsible for creating and caching of icons used in items
	// MItem will access this to get icons
	// FlxMenu will create this item, and share the same item on all MPages
	@:allow(djFlixel.ui.menu.MItem)
	@:allow(djFlixel.ui.FlxMenu)
	var iconcache:MIconCacher;
	
	/**
	 * @param	X
	 * @param	Y
	 * @param	MENU_WIDTH 0 for rest of the screen, <0 for mirrored padding from X to the right
	 * @param	SLOTS 0 for default
	 */
	public function new(X:Float, Y:Float, WIDTH:Int = 0, SLOTS:Int = 0)
	{
		super(MItem, X, Y, WIDTH, SLOTS);
		scrollFactor.set(0, 0);
		inputMode = 2;
		FLAGS.fire_simple = false;
		
	}//---------------------------------------------------;
	
	
	override public function unfocus() 
	{
		super.unfocus();
		if (indexData >= 0) {
			page.params.lastIndex = indexData;
		}
	}//---------------------------------------------------;
	
	
	// 
	public function setPage(p:MPageData)
	{
		if (iconcache == null) {
			trace("Error: ICONCACHE was not defined, defining now");
			iconcache = new MIconCacher(MItem.DEFAULT_STYLE);
		}
		
		if (page != null) {
			throw "Re-setting data not supported";
		}
		
		// Rare, because FLXMENU will always provide styles
		if (styleIt == null) styleIt = Reflect.copy(MItem.DEFAULT_STYLE);
		if (styleC == null) styleC = {};
		
		if (p.params.width != 0) menu_width = p.params.width;
		if (p.params.slots > 0) slotsTotal = p.params.slots;
		
		if (p.params.stI != null)
		{
			// Note styleIT is already a unique
			styleIt = DataT.copyFields(p.params.stI, styleIt);
		}
		
		if (p.params.stL != null)
		{
			// Note style is already a unique
			style = DataT.copyFields(p.params.stL, style);
		}
		
		if (p.params.part1W == 0) {
			p.params.part1W = Std.int(menu_width / 2);
		}
		
		page = p;
		
		// :: Set data and init the items
		setDataSource(page.items);
		
		if (styleC.disable) return;
		
		var b:BitmapData = null;
		
		// :: Cursor init
		if (styleC.bitmap != null) {
			b = styleC.bitmap.clone();
		}else if (styleC.icon != null) {
			var ic = styleC.icon.split(':');
			b = D.ui.getIcon(Std.parseInt(ic[0]), ic[1]);	
		}
		
		if (b != null) {
			b = D.gfx.colorizeBitmapWithTextStyle(b, styleC.color); // .color can be null
			// TODO. automatic Y offset?, I know both the heights.
			setCursor(b, styleC.offset); // .offset can be null 
		}else
		{
			// Make the cursor text style the same as the items
			if (styleC.color == null) {
				// WARNING: I might want a deepcopy here, but I don't know 
				styleC = Reflect.copy(styleC);
				styleC.color = Reflect.copy(styleIt.text);
				styleC.color.bc = styleIt.col_b.idle;
			}
			
			// Text Cursor is default
			var char = DataT.existsOr(styleC.text, DEFAULT_CURSOR_SYMB);
			var offs = DataT.existsOr(styleC.offset, [ DEFAULT_CURSOR_TEXT_OFFX, 0]);
			var tmult = DataT.existsOr(styleC.tmult, -1);	// -1 is for default value
			setCursor(cast D.text.get(char, styleC.color), offs, tmult);
		}
		
	}//---------------------------------------------------;
	
	
	// Initializes the emenu, and focuses the first available
	public function selectFirstAvailable()
	{
		setSelection(get_nextSelectableIndex(0, 1));
	}//---------------------------------------------------;
	
	
	/**Focus an item, Moves the cursor to that item, scrolls the view if needed
	   @param  id ID of the Item
	   @return Success
	**/
	public function item_moveCursorTo(id:String):Bool
	{
		var i = page.getIndex(id);
		if (i >-1){
			setSelection(i);
			return true;
		}
		return false;
	}//---------------------------------------------------;
	

	/**
	  Check if itemData is visible/pooled, and refreshes the sprite to match the new data
	**/
	public function item_update(item:MItemData)
	{
		if (page == null) return;
		
		// :: Search onscreen slots
		for (i in itemSlots) {
			if (i.isSame(item)) {
				i.setData(item);
				return;
			}
		}
		
		// :: Search `_markedItem` in case the list is scrolling??
		if (_markedItem != null && _markedItem.isSame(item)) {
			_markedItem.setData(item);
			return;
		}
		
		// :: Search Pool (for offscreen items)
		if (pool_keep) {
			for (i in pool){
				if (i.isSame(item)){
					i.setData(item);
					return;
				}
			}
		}
	}//---------------------------------------------------;
	
	/** Get the current active item data the cursor is pointing
	 */
	public function item_getCurrent():MItemData
	{
		if (indexData < 0) return null;
		return data[indexData];
	}//---------------------------------------------------;
	
	
	override function item_isSelectable(it:MItem):Bool
	{
		return it.data.selectable;
	}//---------------------------------------------------;
	
	
	// --
	override function item__createInstance(dataIndex:Int):MItem
	{
		return switch(data[dataIndex].type){
			case "link":new MItemLink(this);
			case "range":new MItemRange(this, true); // 'True' is a hacky way to check for more icons
			case "list":new MItemList(this);
			case "toggle":new MItemToggle(this);
			case "label":new MItemLabel(this);
			case "label2":new MItemLabel2(this);
			default: new MItem(this);
		}
	}//---------------------------------------------------;
	
	// --
	override function get_nextSelectableIndex(fromIndex:Int, direction:Int = 1):Int 
	{
		while (data[fromIndex] != null) {
			if (data[fromIndex].selectable) return fromIndex;
			fromIndex += direction;
		}
		return -1;
	}//---------------------------------------------------;
	
}// --