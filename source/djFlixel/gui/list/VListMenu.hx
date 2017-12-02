package djFlixel.gui.list;

import djFlixel.gui.menu.*;
import djFlixel.gui.Styles;
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
	// NOTE: FlxMenu creates a copy so it's safe to modify it
	public var styleMenu(default, set):StyleVLMenu;
	
	//====================================================;
	// --
	public function new(X:Float, Y:Float, WIDTH:Int = 0, ?SlotsTotal:Int) 
	{
		super(MItemBase, X, Y, WIDTH, SlotsTotal);
		setPoolingMode("reuse");
	}//---------------------------------------------------;
	
	
	// Rather than setting an array with MItemData elements,
	// Directly set a $pageData element, this also
	// gets any custom set parameters from a page
	public function setPageData(Page:PageData)
	{
		page = Page;
		
		// A VListMenu usually exists inside a FlxMenu so styleMenu is already set
		// so , if you create it outside of an FlxMenu get a style
		if (styleMenu == null) {
			styleMenu = Styles.newStyleVLMenu(); 
		}
		
		if (page.custom.styleMenu != null)
		{
			Styles.applyStyleNodeTo(page.custom.styleMenu, styleMenu);
		}
		
		// -- Adjust the scroll Indicator
		// Warning, writing back to the style, but this should be a copy
		
		// Shadow Padding Hack 	, place the down arrow a bit further to compensate for the shadow size
		//						, if an offset is already set this will be ignored and user offset will be used
		var sh:Int = 0;
		if (styleMenu.border_size != null && styleMenu.border_size > 0) {
			sh = styleMenu.border_size;
		}else{
			sh = Math.ceil(styleMenu.fontSize / 8);
		}
		
		styleB.scrollInd = DataTool.defParams(styleB.scrollInd, {
			color:styleMenu.color,
			color_border:styleMenu.color_border,
			padding:[0,sh]
		});
		
		super.setDataSource(page.collection);
		
		/// -- Add a cursor --
		
		if (cursor == null)
		{
			var c = styleMenu.cursor;
			if (c && c.disable) return; // Because there is nothing else to do after the parent if
			
			var cur:FlxSprite;
			
			// Shortcut function ::
			// Append Offsets, Add Cursor, Starting with offsets (a,b)
			function _a(a, b) {
				var co = [a, b];
				if (c && c.offset) {
					co[0] += cast c.offset[0];
					co[1] += cast c.offset[1];	
				}
				cursor_setSprite(cur, co);
			}// --
			
			if (c && c.image) // Using an image cursor
			{
				if(c.frames){
				cur = new FlxSprite(0, 0);
				cur.loadGraphic(c.image, true, c.size, c.size); // be sure (size) is set
				cur.animation.add("main", c.frames, c.fps); 	// be sure (fps) is set
				cur.animation.play("main");
				}else{
				cur = new FlxSprite(0, 0, c.image);					
				}
				if (c.align) _a(0, Math.round(cur.height / 2 - elementHeight / 2));
				else _a(0, 0);
			}
			else // Using a text cursor
			{
				var s = styleMenu.alignment == "right"?"<":">"; // Default symbol
				if (c && c.text) s = c.text;
				var t = new FlxText(0, 0, 0, s);
				Styles.applyTextStyle(t, styleMenu);
				t.color = styleMenu.color_focused; // #COLOR, I am experimenting
				cur = cast t;
				_a(0, 2);	// Compensate for 2 Pixel Gutter above the text, same as MItemBase
			}
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
			case "link"   : new MItemLink(styleMenu,width);
			case "oneof"  : new MItemOneof(styleMenu,width);
			case "toggle" : new MItemToggle(styleMenu,width);
			case "slider" : new MItemSlider(styleMenu,width);
			case "label"  : new MItemLabel(styleMenu,width);
			default: new MItemBase(styleMenu,width);
		}
	}//---------------------------------------------------;
	
	// --
	// Set the style and init
	function set_styleMenu(val:StyleVLMenu):StyleVLMenu
	{
		styleMenu = val;
		styleNav = styleMenu;
		return val;
	}//---------------------------------------------------;
	
}// -- end -- //