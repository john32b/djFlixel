package djFlixel.gui.list;

import djFlixel.gui.menu.*;
import djFlixel.gui.Styles.MItemStyle;
import djFlixel.tool.DataTool;
import flixel.FlxSprite;
import flixel.text.FlxText;

/**
 * A Specialized List holding MenuItem elements
 * used by FlxMenu
 */
class VListMenu extends VListNav<MItemBase,MItemData> 
{
	// Pointer to the currently loaded page data
	public var page(default, null):PageData;

	// Style for all the MenuBaseStyles on this page
	public var styleMItem:MItemStyle;
	
	//====================================================;
	// --
	public function new(X:Float, Y:Float, WIDTH:Int, ?SlotsTotal:Int) 
	{
		super(MItemBase, X, Y, WIDTH, SlotsTotal);
	}//---------------------------------------------------;
	
	
	// Rather than setting an array with MItemData elements,
	// Directly set a $pageData element, this also
	// gets any custom set parameters from a page
	public function setPageData(Page:PageData)
	{
		page = Page;
		
		// Get and set the styles 
		// ----------------------
		// 1. If a style exists on the page, apply it ELSE
		// 2. If FLXMenu has set a style, apply that ELSE
		// 3. Get the default style
		
		// List style
		if (page.custom.styleList != null) {
			styleList = DataTool.applyFieldsInto(page.custom.styleList, Reflect.copy(styleList));
		}
		
		// MItem Style from page
		if (page.custom.styleMItem != null) {
			styleMItem = DataTool.applyFieldsInto(page.custom.styleMItem, Reflect.copy(styleMItem));
		}else {
			if (styleMItem == null) styleMItem = Styles.default_MItemStyle;
		}
		// Base Style from page
		if (page.custom.styleBase != null) {
			styleBase = DataTool.applyFieldsInto(page.custom.styleBase, Reflect.copy(styleBase));
		}
		
		// If creating a listMenu outside of the FlxMenu:
		if (styleBase == null) {
			styleBase = Styles.newStyle_Base(); // NOTE: I might not need this, since it's being checked again later?
		}
		
		// Put push the bottom scroll indicator a little further
		moreArrow.paddingDown = Std.int(2 * (styleMItem.size / 8));
		moreArrow.shadowColor = styleMItem.borderColor;
		moreArrow.color = styleMItem.color_default;
		
		super.setDataSource(page.collection);
		
		// -- Add a cursor, it's mandatory as of yet.
		if (!hasCursor) 
		{
			var cur:FlxSprite;
			if (styleList.cursor_image != null) {
				// BUG:
				// It doesn't align well
				cur = new FlxSprite(0, 0, styleList.cursor_image);                                                                                                                   
			}else {
				var t = new FlxText(0, 0, 0, ">");
				Styles.styleMItemText(t, styleMItem);
				cur = cast t;
			}
			hasCursor = true;
			cursor_setSprite(cur, false);
		}
	}//---------------------------------------------------;

	// --
	// Highlight an item with a target SID
	public function item_highlight(sid:String)
	{
		var ind = getItemIndexWithField("SID", sid);
		if (ind > -1) {
			setViewIndex(ind);
		}
	}//---------------------------------------------------;
	
	

	// Update data fields of an item, both DATA + VISUAL,
	// Will search in the pool as well.
	public function item_updateData(sid:String, params:Dynamic)
	{
		var ind = getItemIndexWithField("SID", sid);
		if (ind ==-1) return;
		
		// Overwrite old parameters, set new
		_data[ind].setNewParameters(params);
		
		//  Data changed. Set visual element to reflect changes
		
		//  Check to see if it's onscreen
			for (i in elementSlots) {
				if (i.isSame(_data[ind])) {
					i.setData(_data[ind]); // Resets whole item from the start
					return;
				}
			}		
			
		// If not found, check to see if the element is pooled.
			if (flag_pool_reuse)
			{
				var b:MItemBase = poolGet(ind); // Guaranteed that it won't be removed from the pool
				if (b != null) b.setData(_data[ind]);
			}
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
		for (i in 0..._data_length) {
			if (Reflect.field(_data[i], field) == check) {
				return i;
			}
		}
		return -1; // Not found
	}//---------------------------------------------------;
	
	/**
	 * Get the current active item data the cursor is pointing
	 * @return
	 */
	public function getCurrentItemData():MItemData
	{
		if (_index_data < 0) return null;
		return _data[_index_data];
	}//---------------------------------------------------;
	
	
	// --
	// Vertical List NAVS don't have selectable elements.
	// This is only for mouse rollover checks
	override function requestRollOver(newSlot:Int) 
	{
		if (elementSlots[newSlot].opt.selectable)
			super.requestRollOver(newSlot);
	}//---------------------------------------------------;
	
	// --
	override public function findNextSelectableIndex(fromIndex:Int, direction:Int = 1):Int 
	{
		while (_data[fromIndex] != null) {
			if (_data[fromIndex].selectable) return fromIndex;
			fromIndex += direction;
		}
		return -1;
	}//---------------------------------------------------;
	
	
	// --
	override function factory_getElement(dataIndex:Int):MItemBase
	{
		return switch(_data[dataIndex].type) {
			case "link"   : new MItemLink(styleMItem);
			case "oneof"  : new MItemOneof(styleMItem);
			case "toggle" : new MItemToggle(styleMItem);
			case "slider" : new MItemSlider(styleMItem);
			case "label"  : new MItemLabel(styleMItem);
			default: new MItemBase(styleMItem);
		}
	}//---------------------------------------------------;
	
}// -- end -- //