package djFlixel.gui.list;

import djFlixel.gui.Styles.OptionStyle;
import djFlixel.gui.PageData;
import djFlixel.gui.OptionData;
import djFlixel.gui.listoption.*;
import djFlixel.tool.DataTool;
import flixel.FlxSprite;
import flixel.text.FlxText;


/**
 * A Specialized List holding MenuOption elements
 * used by FlxMenu
 */
class VListMenu extends VListNav<MenuOptionBase,OptionData> 
{

	// Pointer to the currently loaded page data
	public var page(default, null):PageData;

	// Style for all the MenuBaseStyles on this page
	public var styleOption:OptionStyle;
	
	//====================================================;
	// --
	public function new(X:Float, Y:Float, WIDTH:Int, ?SlotsTotal:Int) 
	{
		super(MenuOptionBase, X, Y, WIDTH, SlotsTotal);
	}//---------------------------------------------------;
	
	
	// Rather than setting an array with optionData elements,
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
		
		// Option Style from page
		if (page.custom.styleOption != null) {
			styleOption = DataTool.applyFieldsInto(page.custom.styleOption, Reflect.copy(styleOption));
		}else {
			if (styleOption == null) styleOption = Styles.default_OptionStyle;
		}
		// Base Style from page
		if (page.custom.styleBase != null) {
			styleBase = DataTool.applyFieldsInto(page.custom.styleBase, Reflect.copy(styleBase));
		}
		
		// If creating a listMenu outside of the FlxMenu:
		if (styleBase == null) {
			styleBase = Styles.newStyle_Base(); // NOTE: I might not need this, since it's being checked again later?
		}
		
		// -- HACK FIX --
		// Put push the bottom scroll indicator a little further
		hack_bottom_scroll_indicator_nudge = Std.int(2 * (styleOption.size / 8));
		
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
				Styles.styleOptionText(t, styleOption);
				cur = cast t;
			}
			hasCursor = true;
			cursor_setSprite(cur, false);
		}
	}//---------------------------------------------------;

	// --
	// Highlight an option with a target SID
	public function option_highlight(sid:String)
	{
		var ind = getOptionIndexWithField("SID", sid);
		if (ind > -1) {
			setViewIndex(ind);
		}
	}//---------------------------------------------------;
	
	

	// Update data fields of an option, both DATA + VISUAL,
	// Will search in the pool as well.
	public function option_updateData(sid:String, params:Dynamic)
	{
		var ind = getOptionIndexWithField("SID", sid);
		if (ind ==-1) return;
		
		// Overwrite old parameters, set new
		_data[ind].setNewParameters(params);
		
		// -- Data changed. Set visual element to reflect changes
		
		// . Check to see if it's onscreen
			for (i in elementSlots) {
				if (i.isSame(_data[ind])) {
					// trace("FOUND DATA", _data[ind]);
					// trace(i.y);
					i.setData(_data[ind]); // Resets whole option from the start
					// trace(i.y);
					return;
				}
			}		
			
		// . If not found, check to see if the element is pooled.
			if (flag_pool_reuse)
			{
				var b:MenuOptionBase = poolGet(ind); // Guaranteed that it won't be removed from the pool
				if (b != null) b.setData(_data[ind]);
			}
	}//---------------------------------------------------;

	
	/**
	 * Returns the index of an option with a target field, Returns -1 if nothing found
	 * @param	field String Name of the field to check. (e.g. "SID", "UID .. )
	 * @param	check The value of the field will be checked against this
	 * @return 
	 */
	public function getOptionIndexWithField(field:String, check:Dynamic):Int
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
	 * Get the current active option data the cursor is pointing
	 * @return
	 */
	public function getCurrentOptionData():OptionData
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
	override function factory_getElement(dataIndex:Int):MenuOptionBase
	{
		return switch(_data[dataIndex].type) {
			case "link"   : new MenuOptionLink(styleOption);
			case "oneof"  : new MenuOptionOneof(styleOption);
			case "toggle" : new MenuOptionToggle(styleOption);
			case "slider" : new MenuOptionSlider(styleOption);
			case "label"  : new MenuOptionLabel(styleOption);
			default: new MenuOptionBase(styleOption);
		}
	}//---------------------------------------------------;
	
}// -- end -- //