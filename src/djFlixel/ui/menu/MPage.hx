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
import djFlixel.ui.IListItem.ListItemEvent;
import djFlixel.ui.UIDefaults;
import djFlixel.ui.VList;
import djFlixel.ui.menu.*;
import djFlixel.ui.menu.MCursor;
import djFlixel.ui.menu.MCursor.MCursorStyle;
import djFlixel.ui.menu.MItem.MItemStyle;
import djFlixel.core.Dtext.DTextStyle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import openfl.display.BitmapData;



/** Parameters/Styles for a MenuPage.
 *  It includes the VList and MItem styles 
 * 
 *  - If you are coming here to check out how it works:
 *  - Read on <VListStyle> first, it styles a generic VerticalList (which MPage extends)
 *  - Read on <MItemStyle>, it is the style that all menu items will take (menu items, are links, toggles, etc)
 *  - Each FlxMenu holds one <MPageStyle> style object that shares with all the Pages it creates
 */
typedef MPageStyle = {
	
	> VListStyle,			// Defined in "VList.hx" | Appends all fields of VListStyle
	
	item:MItemStyle,		// Defined in "MItem.hx" | Style for Menu Items
	
	?cursor:MCursorStyle,	// Defined in this file | Null for no cursor
	
	?background:{			// If set will create a solid color background
		color:Int,			// color
		padding:Array<Int>	// CSS like (top right bottom left) pad in pixels e.g. [2,2,2,2]
	},
	
	lerp:Float,			// On 'center' aligned items, when they change in width they reposition
						// with a lerp function. This is the multiplier. Give small values
	
	#if (html5)
	// Some fonts in HTML5 don't report their height correctly and they are too tall
	// This TRIES to fix that somewhat. Try to combine it with .item_pad
	item_height_fix:Int,
	#end
	
}



class MPage extends VList<MItem,MItemData>
{
	// When doing lerp to menu items auto-alignment. This should be enough, right?
	public static var LERP_DURATION = 0.4;
	
	// Style Page. Includes all the styles. FlxMenu will set this to something
	public var STP:MPageStyle;
	
	// Hold the actual page data
	public var page(default, null):MPageData;
	
	// This is responsible for creating and caching of icons used in items
	// MItem will access this to get icons
	// FlxMenu will create this item, and share the same item on all MPages
	@:allow(djFlixel.ui.menu.MItem)
	@:allow(djFlixel.ui.FlxMenu)
	var iconcache:MIconCacher;
	
	// Optional Background Sprite, enabled by (STP.background)
	var bg:FlxSprite;
	
	
	// HACK:
	// Items don't calculate their arrows in their .width
	// This is to add some padding to the right, so that the 
	// mouse can overlap with the true visible area (arrow included)
	@:allow(djFlixel.ui.menu.MItem)
	var ghostArrowWidth:Int = 0;
	
	/**
	 * @param	X
	 * @param	Y
	 * @param	MENU_WIDTH 0 for rest of the screen, <0 for mirrored margin from X to the right
	 * @param	SLOTS 0 for default
	 */
	public function new(X:Float, Y:Float, WIDTH:Int = 0, SLOTS:Int = 0)
	{
		super(MItem, X, Y, WIDTH, SLOTS);
		inputMode = 2; // Mode 2 = selectable items + cursor
		OPT.fire_simple = false;
		STP = UIDefaults.MPAGE;
	}//---------------------------------------------------;
	
	
	override public function unfocus() 
	{
		super.unfocus();
		if (indexData >= 0) {
			// The last focused index is auto stashed
			page.PAR.cindex = indexData;
		}
	}//---------------------------------------------------;
	
	
	public function setPage(p:MPageData)
	{
		if (page != null) {
			throw "Re-setting data not supported";
		}
		
		page = p;
		
		_mcheckpad = [2, 2];
		
		if (p.PAR.isPopup) menu_width = 0;	// Force Auto width for popups, helping the background box dimensions.
		if (p.PAR.width != 0) menu_width = p.PAR.width;
		if (p.PAR.slots > 0) slotsTotal = p.PAR.slots;

		// -- Style Overlay
		if (p.STPo != null)
		{
			// STP is a link to something (FlxMenu.pool_get())
			// I need to make a copy so I can modify it
			STP = DataT.copyDeep(STP);
			STP = DataT.copyFields(p.STPo, STP);
		}
		
		// Make VListStyle work with MPageStyle parameters
		STL = STP;	
		
		// FlxMenu creates this and passes it to MPage
		// if not create it before setDataSource()
		if (iconcache == null) {
			trace("Warning: ICONCACHE was not defined, defining now");
			iconcache = new MIconCacher(STP.item);
		}
		
		// Set data and init the items
		setDataSource(page.items);
		
		// :: NEW : All cursor logic is in its own place
		// TODO, Cache the cursor object to be reusable?
		if (STP.cursor != null)
		{
			cursor_set( new MCursor(STP) );
		}
		
		
		// :: Experimental ::
		// Background solid color
		if (STP.background != null )
		{
			var a = STP.background.padding;
			var W:Int = menu_width + a[1] + a[3];
			var H:Int = cast ((overflows?menu_height:height) + a[0] + a[2]);
			bg = new FlxSprite();
			bg.makeGraphic(W, H, STP.background.color);
			bg.x -= a[3];
			bg.y -= a[2];
			insert(0, bg);
		}
		
		
		// :: NEW - Custom positioning based on MPageData
		// Applied here, after `setDataSource` so that menu_height and items are initialized
		
		
		if (page.PAR.pos == 'abs')
		{
			this.x = page.PAR.x;
			this.y = page.PAR.y;
		}
		
		else if (page.PAR.pos.indexOf('screen') == 0)
		{
			var xy = page.PAR.pos.split(',').splice(1, 2);
			var y1:Float = 0;
			if (scind != null && ('tb'.indexOf(xy[1]) >= 0) )
				y1 = STL.sind_size + 2;
				
			D.align.screen(this, xy[0], xy[1], y1);	// DEV: I know this is not perfect, as unwanted X padding could occur
			this.x += page.PAR.x;
			this.y += page.PAR.y;
			
		}
		
		else if (page.PAR.pos == 'rel')
		{
			this.x += page.PAR.x;
			this.y += page.PAR.y;
		}
		
	}//---------------------------------------------------;
	
	
	// DEVNOTE: All this code just to fade the bg in and out..
	override function tween_allSlots(Alphas:Array<Float>, StartOffs:String, EndOffs:String, Times:String, onComplete:Void->Void, ease:String, hardstart:Bool):Void 
	{
		super.tween_allSlots(Alphas, StartOffs, EndOffs, Times, onComplete, ease, hardstart);
		if (bg == null) return;
		var tt:Array<Float> = Times.split(':').map((s)->Std.parseFloat(s));
		
		// ARBITRARY? About half the time it takes everything to come in/out
		var totaltime = (tt[0] + (tt[1] * slotsTotal)) * 0.5;
		
		if (tween_map.exists(bg)) { 
			tween_map.get(bg).cancel();
		}
		
		if (totaltime > 0) {
			bg.alpha = Alphas[0];
			tween_map.set(bg, FlxTween.tween( bg, {alpha:Alphas[1]} , totaltime));
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
	
	
	// Create actual Menu Items based on the MItemData that is stored in the List
	override function item__createInstance(dataIndex:Int):MItem
	{
		return switch(data[dataIndex].type){
			case link  :new MItemLink(this);
			case range :new MItemRange(this, true); // 'True' is a hacky way to check for more icons
			case list  :new MItemList(this);
			case toggle:new MItemToggle(this);
			case label :new MItemLabel(this);
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
	
	// --
	override function slot_focus(num:Int):Void 
	{
		super.slot_focus(num);
		lerp = 0;
		if (this.OPT.enable_mouse) {
			switch (data[indexData].type) {
				case range | list:
					_mcheckpad[1] = ghostArrowWidth + 2;
				default:
					_mcheckpad[1] = 2;	// Arbitrary! [2,2] is the default mouse check
			}
		}
		
	}//---------------------------------------------------;
	
	
	var lerp:Float = 0;
	var lerpDest:Float = 0;
	override function on_itemCallback(e:ListItemEvent):Void 
	{
		if (e == ListItemEvent.change) {
			
			// Recalculate the width table which the Mouse Check reads
			itemSlotsX0[indexSlot] = Std.int(this.x + get_itemStartX(indexItem));
			
			if (alignCenter) {
				lerp = LERP_DURATION;
				lerpDest = itemSlotsX0[indexSlot];
			}
		}
		
		super.on_itemCallback(e);
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		// -- This piece of code is to LERP the item back to its baseline X pos
		if (lerp > 0 && indexItem != null) {
			
			lerp -= elapsed;
			indexItem.x = FlxMath.lerp(indexItem.x, lerpDest, STP.lerp);
			
			if (cursor != null) {
				cursor.updateX(indexItem.x - (STL.focus_anim == null?0:STL.focus_anim.x));
			}	
		}
		
		super.update(elapsed); // Leave VLIST update last, because of the event system
	}//---------------------------------------------------;
	
}// --