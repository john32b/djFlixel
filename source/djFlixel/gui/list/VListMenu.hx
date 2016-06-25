package djFlixel.gui.list;

import djFlixel.gui.Styles.OptionStyle;
import djFlixel.gui.PageData;
import djFlixel.gui.OptionData;
import djFlixel.gui.listoption.*;
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
			styleList = page.custom.styleList;
		}
		
		// Option Style from page
		if (page.custom.styleOption != null) {
			styleOption = page.custom.styleOption;
		}else {
			if (styleOption == null) 
				styleOption = Styles.default_OptionStyle;
		}
		// Base Style from page
		if (page.custom.styleBase != null) {
			styleBase = page.custom.styleBase;
		}
		
		// -- HACK FIX --
		//  MenuBaseOptions report a height longer than the textfield itself		
		//  FlxMenu pushes a new Style, but creating a listMenu by itself doesn't
		//  Important: get a new style because I'm going to change it
		if (styleBase == null) {
			styleBase = Styles.newStyle_Base();
		}
		
		// HACK: Specific for menuoption elements
		//       why? becaust text.height are longer than they actually are
		// Try to fix the padding between elements.
		// styleBase.element_padding = -Std.int(styleOption.fontSize * 0.4);
		
		// NOTE V0.3: Conditionals are scrapped.
		
		super.setDataSource(page.collection);
		
		// -- Add a cursor --
		if (!hasCursor) 
		{
			var cur:FlxText = new FlxText(0, 0, 0, ">");
			hasCursor = true;
			Styles.styleOptionText(cur, styleOption);
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
	
	

	// -- Update data fields of an option
	// Both DATA + VISUAL,
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
					i.setData(_data[ind]); // Resets whole option from the start
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

	
	// --
	// Returns the index of the option with target SID,
	// Returns -1 if nothing found
	public function getOptionIndexWithField(field:String, check:Dynamic):Int
	{
		var i = 0;
		for (i in 0..._data_length) {
			if (Reflect.field(_data[i], field) == check) {
				return i;
			}
		}
		// Not found
		return -1;
	}//---------------------------------------------------;
	
	// Get the current active option data, the cursor is pointing
	// --
	public function getCurrentOptionData():OptionData
	{
		if (_index_data < 0) return null;
		return _data[_index_data];
	}//---------------------------------------------------;
	
	
	// --
	// Vertical List NAVS don't have selectable elements.
	// This is only for mouse rolover checks
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