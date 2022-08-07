/**
 *  Specialized VLIST to hold MenuItems
 * 
 * - MenuItems can be of various classes, but all deriving from <MItem>
 * - FlxMenu creates MPages to display menus
 * - an <MPage> is a representation of <MPageData>
 * 
 * =========================================== */

package djFlixel.ui.menu;

import djA.DataT;
import djFlixel.ui.FlxMenu;
import djFlixel.ui.UIDefaults;
import djFlixel.ui.VList;
import djFlixel.ui.menu.*;
import djFlixel.ui.menu.MItem.MItemStyle;
import djFlixel.core.Dtext.DTextStyle;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import openfl.display.BitmapData;


/**
   Properties for styling the Cursor
   (The graphic indicator showing which item is selected)
**/
typedef MCursorStyle = {
	
	?text:String,		// Character to use for cursor, uses the same style as the Menu Items
	?icon:String,		// Use a standard D.UI icon string format : "size:name" .e.g. "12:heart" | Auto color and shadow
	?bitmap:BitmapData, // Use this bitmap for a cursor - Will be used as is, no colorization or shadow -
	?color:DTextStyle,	// Colorize the Text/Bitmap with this. valid:{c,bc,bt,so} | null to get MItem Color
	offset:Array<Int>,	// [x,y] Cursor Offset
	tmult:Float,		// Cursor tween time multiplier | 0:Instant tween.
}


/** Parameters/Styles for a MenuPage.
 *  It includes the VList and MItem styles 
 */
typedef MPageStyle = {
	
	> VListStyle,			// Defined in "VList.hx" | Appends all fields of VListStyle
	
	item:MItemStyle,		// Defined in "MItem.hx"
	
	?cursor:MCursorStyle,	// Defined in this file | Null for no cursor
	
	?background:Int			// If set will create a solid color background
	
}



class MPage extends VList<MItem,MItemData>
{
	// Style Page. Includes all the styles. FlxMenu will set this to something
	public var STP:MPageStyle;
	
	// Hold the page data
	public var page(default, null):MPageData;
	
	// This is responsible for creating and caching of icons used in items
	// MItem will access this to get icons
	// FlxMenu will create this item, and share the same item on all MPages
	@:allow(djFlixel.ui.menu.MItem)
	@:allow(djFlixel.ui.FlxMenu)
	var iconcache:MIconCacher;
	
	// Optional Background
	var bg:FlxSprite;
	
	/**
	 * @param	X
	 * @param	Y
	 * @param	MENU_WIDTH 0 for rest of the screen, <0 for mirrored margin from X to the right
	 * @param	SLOTS 0 for default
	 */
	public function new(X:Float, Y:Float, WIDTH:Int = 0, SLOTS:Int = 0)
	{
		super(MItem, X, Y, WIDTH, SLOTS);
		inputMode = 2; // + cursor
		FLAGS.fire_simple = false;
		STP = UIDefaults.MPAGE;
	}//---------------------------------------------------;
	
	
	override public function unfocus() 
	{
		super.unfocus();
		if (indexData >= 0) {
			// The last focused index is auto stashed
			page.PAR.indexStash = indexData;
		}
	}//---------------------------------------------------;
	
	
	public function setPage(p:MPageData)
	{
		if (page != null) {
			throw "Re-setting data not supported";
		}
		
		STL = STP;	// Make VListStyle work with MPageStyle parameters
		page = p;
		
		if (p.PAR.width != 0) menu_width = p.PAR.width;
		if (p.PAR.slots > 0) slotsTotal = p.PAR.slots;	

		// -- Style Overlay
		if (p.STPo != null)
		{
			// FlxMenu gave this a link
			// I need to make a copy
			STP = DataT.copyDeep(STP);
			STP = DataT.copyFields(p.STPo, STP);
		}
		
		//if (p.PAR.part1W == 0) {
			//p.PAR.part1W = Std.int(menu_width / 2);
			//// TODO: Why am I writing back to the Page Style?
		//}
		
		// FLXMenu creates this and passes it to MPage.
		// But for any case where MPage is used elsewhere I must it, before setDataSource()
		if (iconcache == null) {
			trace("Warning: ICONCACHE was not defined, defining now");
			iconcache = new MIconCacher(STP.item);
		}
		
		// Set data and init the items
		setDataSource(page.items);
		
		//====================================================;
		// SET CURSOR if it set in the Style 
		//====================================================;
		
		if (STP.cursor == null) return;
		
		var C:MCursorStyle = STP.cursor;	// Write less
		var b:BitmapData = null;
		var col:DTextStyle;	// Final Cursor color
		
		if (C.color == null) {
			col = Reflect.copy(STP.item.text);
			col.bc = STP.item.col_b.idle;	// modify it a bit to match better
		}else{
			col = C.color;
		}
		
		// -- Is it a bitmap with (direct bitmap) or (icon) ??
		if (C.bitmap != null) {
			b = C.bitmap.clone();
		}else if (C.icon != null) {
			var ic = C.icon.split(':');
			b = D.ui.getIcon(Std.parseInt(ic[0]), ic[1]);	
			b = D.gfx.colorizeBitmapWithTextStyle(b, col);
		}
		
		if (b != null) {
			setCursor(b, C.offset, C.tmult); // DEV: offset can be null OK
			// TODO: Automatic Y offset?, I know both the heights.
		}else {
			setCursor(cast D.text.get(C.text, col), C.offset, C.tmult);
		}
		
		
		// -- Experimental --
		// Check for BG
		// Mostly used for popup questions for now.
		if (STP.background != null )
		{
			// TODO:
			// Make the cursor + focus_nudge fit + some air?
			//  |  MENU ITEM   |
			//  | >> MENU ITEM |
			var CW = (cursor != null)?cursor.width:0;
			bg = new FlxSprite(STP.focus_nudge - CW);
			
			// The width I want = itemWidth + nudge + cursor_width - nudge 
			var W = menu_width + CW;	
			
			bg.makeGraphic(cast W, cast height, STP.background);
			insert(0, bg);
			
			// DEVNOTE:
			// I could make it work with events? Something like:
			// onEvent("viewOn",()->{
			// 		tween_map.set(bg, FlxTween....{ __getInViewAlpha, __ getInViewTimes });
			// ? So that I don't have to override tween_allSlots later?
		}
		
	}//---------------------------------------------------;
	
	// DEVNOTE: All this code just to fade the bg in and out..
	override function tween_allSlots(Alpha:Array<Float>, StartOffs:String, EndOffs:String, times:String, onComplete:Void->Void, ease:String, hardstart:Bool):Void 
	{
		super.tween_allSlots(Alpha, StartOffs, EndOffs, times, onComplete, ease, hardstart);
		if (bg == null) return;
		var tt:Array<Float> = times.split(':').map((s)->Std.parseFloat(s));
		if (tween_map.exists(bg)) { 
			tween_map.get(bg).cancel();
		}
		bg.alpha = Alpha[0];
		tween_map.set(bg, FlxTween.tween( bg, {alpha:Alpha[1]} , tt[0]));
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
	
	
	// Create actual Menu Items based on the MItemData that is stored in the List
	override function item__createInstance(dataIndex:Int):MItem
	{
		return switch(data[dataIndex].type){
			case link  :new MItemLink(this);
			case range :new MItemRange(this, true); // 'True' is a hacky way to check for more icons
			case list  :new MItemList(this);
			case toggle:new MItemToggle(this);
			case label :new MItemLabel(this);
			//case "label2":new MItemLabel2(this);
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