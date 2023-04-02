/**
== FlxMenu
  - Multi-page menu system 
  ----------------------------------------------
  
  - It creates and manages <MPages> objects to offer a multi page menu system
  - Offers various events with callbacks. e.g. for when an item was fired or hovered
  - Auto-handles changing between pages, when a page is requested from an item
  
  - <MPage> is a sprite group that takes <MPageData> and creates a single page based on that data
  - To use FLXMenu you must first give it a Page Data with the <MPageData> structure
  - Check <MPageData.hx> and <MItemData.hx> on how to create a page
  - Also check the demo source code examples on how to initialize and use FlxMenu
  
== Very Simple Menu Example
  ------------------------
  
	var menu = new FlxMenu(32,32);
	
	// Haxe supports multi-line strings just fine
	menu.createPage("main").add("
	  -| New Game   | link   | ng 
	  -| Options    | link   |@options
	  -| Quit       | link   | id_q  | ?pop=Really Quit?:Yes:No ");
	 
	menu.createPage("options").add("
		-| Music  | toggle | id_togg
		-| Lives  | range  | id_rang | 1,9
		-| Back   | link   |@back ");
		
	menu.onItemEvent = (event, item) -> {
		if(event == fire) {
			if(item.ID=="ng") start_new_game(); else
			if(item.ID=="id_q") quit_game();
		} else
		if(event == change && item.ID=="id_rang") {
			set_player_lives(item.get());
		}
		// etc, and so on..
	});
	  
	add(menu);
	menu.goto("main"); // Goes to that page and opens the menu
	
	----------------------
	
== More examples on the (demo) project
	
*******************************************************************/

package djFlixel.ui;

import djA.DataT;
import djFlixel.core.Dtext.DTextStyle;
import djFlixel.ui.FlxAutoText;
import djFlixel.ui.IListItem.ListItemEvent;
import djFlixel.ui.UIDefaults;
import djFlixel.ui.menu.MIconCacher;
import djFlixel.ui.menu.MItemData;
import djFlixel.ui.menu.MPage;
import djFlixel.ui.menu.MPageData;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.typeLimit.OneOfTwo;



// Menu Events that are sent to <FlxMenu.onMenuEvent>
// A <String> is also passed with that event
enum MenuEvent
{
	page;		// A page is shown | Par: The pageID that it changed to
	pageCall;	// A new page was requested from a link (Useful for sound effects) | Par: The pageID that got requested, "?pop" "?fs" for questions
	back;		// Went back, either by link or button | Par: The pageID that sent back
	close;		// Menu went off | Par: The pageID that was on before closing
	open;		// Menu went on | Par: The pageID that is displayed when opened
	rootback;	// Back button was pressed while on the first page of the menu (no more pages in history) (Useful for sound effects) | Par: null
	start;		// Start button was pressed | Par: The pageID start was pressed on
	focus;		// Menu was just focused | Par: pageID that got focused
	unfocus;	// Menu was just unfocused | Par: pageID that got unfocused
	it_focus;	// An item was focused | Par: itemID | For more complete item event use onItemEvent
	it_fire;	// An item was fired | Par: itemID | ~~ ^
	it_invalid;	// An item was fired while disabled | Par: itemID | ~~ ^
}


class FlxMenu extends FlxGroup
{
	public var x(default, null):Float;
	public var y(default, null):Float;
	
	public var isFocused(default, null):Bool = false;
	
	/** The PageData of the current Active Page */
	public var pageActive(default, null):MPageData;	
	
	/** FlxMenu can create pages with createPage(), it will store them here for quick retrieval */
	public var pages(default, null):Map<String,MPageData> = [];
	
	/** The Menu Page that is currently on screen,
	 *  if null then the menu is closed nothing is on screen */
	public var mpActive(default, null):MPage;
	
	/** Some functionality flags. Set these right after new() */
	public var PAR = {
		pool_max:4,					// How many MPages to keep in the pool
		enable_mouse:true,  		// Enable mouse interaction in general
		start_button_fire:false,	// True will make the start button fire to items
		page_anim_parallel:false,	// Page-on-off will run in parallel instead of waiting
		camera_lock:true,			// Sets scrollfactor to 0 for all children added here
	};
	
	/** If set will callback for menu Events | fn(MenuEvent, Page_ID) 
	 *  For more info check the <MenuEvent> typedef above */
	public var onMenuEvent:MenuEvent->String->Void;
	
	/** If set will callback for item Events | fn(ItemEvent, itemData) */
	public var onItemEvent:ListItemEvent->MItemData->Void;
	
	/** Page Style, used in all <MPages> 
	 *  For an example on how to initialize it checkout {MPAGE} in "UIDefaults.hx" */
	public var STP:MPageStyle;
	
	// Popup STyle Overlay : If you want to customize the look of popup confirmation boxes
	public var popSTo:Dynamic = null;
	
	
	// Stores the order of the Pages as they open
	// The last element of history is always the current page
	var history:Array<MPageData> = [];
	
	// Stores pooled MenuPages
	var pool:Array<MPage> = [];
	
	// An icon generator shared with all <MPage> objects
	var iconcache:MIconCacher;
	
	// When you are about to GOTO a page. 
	// If this is TRUE, will restore the selected item index or whatever is stored in MPageData property
	var _flag_restore_selected_index:Bool = false;
	
	// There are going to be passed to all created MPAGES
	var def_width:Int;
	var def_slots:Int;	
	
	// Experimental plugins?
	var plugs:Array<IFlxMenuPlug> = [];
	

	/**
	   @param	X Screen X
	   @param	Y Screen Y
	   @param	WIDTH 0 To autocalculate based on item length (default) -1 Rest of screen, mirrored X Margin
				WARNING! do not use 0 with "center" alignment
	   @param	SLOTS How many vertical slots for items to show. If a menu has more items, it will scroll.
	**/
	public function new(X:Float=0, Y:Float=0, WIDTH:Int=0, SLOTS:Int = 6)
	{
		super();
		x = X; 
		y = Y;
		def_width = WIDTH; 
		def_slots = SLOTS;
		STP = DataT.copyDeep(UIDefaults.MPAGE);
	}//---------------------------------------------------;
	
	override public function destroy():Void 
	{
		for (pl in plugs) pl.destroy();
		if (iconcache != null) iconcache.clear();
		super.destroy();
		pool_clear();	// To destroy these objects as well
	}//---------------------------------------------------;
	
	
	/** Use this to overide whatever fields you want
	 *  to the main FlxMenu Style Object (STP)
	 *  Read "MPage.hx" <MPageStyle> for typedef info
	 */
	public function overlayStyle(st:Dynamic)
	{
		STP = DataT.copyFields(st, STP);
	}//---------------------------------------------------;
	
	
	/**
	 * Attach a `plugin`
	 * - Special objects that exist alongside the FlxMenu
	 * - Doing it like this to offload code from this file
	 * - Plugins are automatically destroyed
	 */
	public function plug(pl:IFlxMenuPlug)
	{
		pl.attach(this);
		plugs.push(pl);
	}//---------------------------------------------------;
	
	
	/** This is a Quick Way to create and return a MenuPage 
	 *  plus it gets added to the FlxMenu pages DB 
	 *  - Check in <MPageData> class on how to create a Menu Page */
	public function createPage(id:String, ?title:String):MPageData
	{
		var p = new MPageData(id, title);
		pages.set(id, p);
		return p;
	}//---------------------------------------------------;
	
	
	/**
	   If this was closed, restore the page and focus it
	   @param instant True will immediately show it with no animation
	**/
	public function open(instant:Bool = false)
	{
		if (pageActive == null) {
			trace('Error: No ActivePage set');
			return;
		}
		
		if (history.length == 0 || mpActive != null || isFocused) return;
		
		mpActive = pool_get(pageActive);
		add(mpActive);
		mpActive.viewOn(true, instant);	// > always focus the new page.
		
		//_mev(MenuEvent.focus, pageActive.ID); // DEV: Should it?
		_mev(MenuEvent.open, pageActive.ID);
		_mev(MenuEvent.page, pageActive.ID);	
		//  ^Redundant? However in some cases it is useful 
		//   When you need to sync another object visibility with a menu?
		//   Having only open it would need to listen to "open" and "page" events
		//   now it only has to listen to the "page" event
	}//---------------------------------------------------;
	
	/**
	   Close the active page. Restore it with open(). You can also goto()
	   @param	hard True will immediately hide it with no animation
	**/
	public function close(instant:Bool = false)
	{
		if (mpActive != null) // Close it
		{
			pool_put(mpActive);
			mpActive.viewOff((l)->remove(l), instant);
			mpActive = null;
			// DEV: Do not null pageActive, since it is read on open()
			
			//_mev(MenuEvent.unfocus, pageActive.ID); // DEV: Should it?
			_mev(MenuEvent.close, pageActive.ID);
		}
		
		isFocused = false;
	}//---------------------------------------------------;
	
	/** Focus the Menu, gives keyboard focus, visual feedback */
	public function focus()
	{
		if (isFocused) return;
			isFocused = true;
		if (mpActive != null) {
			mpActive.focus();
		}
		_mev(MenuEvent.focus, pageActive.ID);
	}//---------------------------------------------------;
	
	/** Unfocus the Menu, removes keyboard focus, visual feedback */
	public function unfocus()
	{
		if (!isFocused) return;
			isFocused = false;
		if (mpActive != null) {
			mpActive.unfocus();
		}
		_mev(MenuEvent.unfocus, pageActive.ID);
	}//---------------------------------------------------;
	
	
	/**
	   Open a page and give it focus. Can goto an already created page
	   that was previously pushed to the pages Map with `createPage()`
	   or you can give a new external PageData (e.g. on-the-fly created Pages with Dynamic Data)
	   @param _src  Page ID or Page Object
	   @param _open If it is closed, also open it the menu?
	**/
	public function goto(_src:OneOfTwo<String, MPageData>, _open:Bool = true)
	{
		var pdata:MPageData;
		if (Std.isOfType(_src, MPageData)) {
			pdata = cast _src;
		}else{
			pdata = pages.get(cast _src);
		}

		if (pdata == null) {
			FlxG.log.error("Could not get pagedata");
			return;
		}
	
		if (pageActive == pdata && _open) {
			// Already there, try to open the page and exit
			open();
			return;
		}
		
		// Search if this page is in history, if it is remove it and everything after
		var i = history.length;
		while (i--> 0) {
			if (history[i] == pdata) {
				history.splice(i, history.length - i); // Remove from i to end
				break;
			}
		}
		
		pageActive = pdata;		
		history.push(pdata);	// DEV: Yes, even dynamic pages go here
		
		if (!_open) return;
		
		isFocused = true;
		
		if (mpActive != null) // Close it
		{
			pool_put(mpActive);
			
			if (PAR.page_anim_parallel){
				mpActive.viewOff((l)->remove(l));
				_add_pageActive();
			}else{
				mpActive.viewOff((l)->{remove(l); _add_pageActive();});
			}
		}else{
			// This is the first call of goto(), so send a "open" event
			_mev(MenuEvent.open, pageActive.ID);
			_add_pageActive();
		}
		
	}//---------------------------------------------------;
	

	/** Go to the previous page in history */
	public function goBack()
	{
		// Can go back no more, notify user and return
		if (history.length <= 1) {
			_mev(rootback);
			return;
		}
		
		_mev(back, pageActive.ID);
		_flag_restore_selected_index = true;	// goto() will try to restore the cursor to where it was
		history.pop(); 	// This is the current page on the history. Remove it.
		goto(history.pop()); // This is where I want to go
	}//---------------------------------------------------;
	
	
	/** Go to the furst page of the history queue,
	 * Useful when you are in a nested menu and want to go to the root */
	public function goHome()
	{
		if (history.length <= 1) return;
		_flag_restore_selected_index = false;
		goto(history[0]);
	}//---------------------------------------------------;
	
	/**
	   Change an item's data or parameters e.g. (label, disabled)
	   The changes you make to the item will apply immediately on the menus
	   e.g.
			- Make the Second Item (index 1) toggle its disabled state
	   		menu.item_update(1, (i)->{i.disabled = !i.disabled;});
			
			- In Page "options" select item with id "audio" and set its range value to 0
			menu.item_update("options","audio", (i)->{i.data.c=0;});
			
		This function gets the item you need and passes it to a function, 
		so you must modify it from there. 
			
	   @param	pageID If Null will search the active page
	   @param	idOrIndex Item INDEX starting from 0 or ID
	   @param	modifyFN Alter the item in this function
	**/
	public function item_update(?pageID:String, idOrIndex:OneOfTwo<String,Int>, modifyFN:MItemData->Void)
	{
		// :: Get pagedata
		var pg:MPageData;
		if (pageID == null) pg = pageActive; else pg = pages.get(pageID);
		if (pg == null){
			trace('Error: Could not find pagedata $pageID');
			return;
		}
		
		// :: Get ItemData
		var item:MItemData;
		if (Std.isOfType(idOrIndex, String)){
			item = pg.get(cast idOrIndex);
		}else{
			item = pg.items[cast idOrIndex];
		}
		if (item == null){
			trace('item_update: Could not find Item in page', pg.ID, idOrIndex);
			return;
		}
		
		// :: User manipulation
		modifyFN(item);
		
		// -- Search created MPages for this page/item
		
		// :: Is it the active page.
		if (pg == pageActive)
		{
			mpActive.item_update(item);
			return;
		}
		
		// :: Search Pooled Pages
		for (p in pool)
		{
			if (p.page == pg)
			{
				p.item_update(item);
				return;
			}
		}
		
		// :: Not found anywhere,
		//    Do nothing, whenever a MPage will create the sprite, it will read the new data
			
	}//---------------------------------------------------;
	
	

	/** Called by MPage.onListEvent 
	 **/
	function on_list_event(msg:String)
	{
		if (msg == "back") {
			if (pageActive != null && pageActive.PAR.isPopup) return;
			goBack(); 
		}
		else if (msg == "start")
		{
			_mev(start, pageActive.ID);
			return;
		}
	}//---------------------------------------------------;
	
	/** Called by MPage.onItemEvent 
	 * DEV:
	 * fire on links is being overriden. A true `fire` link event will be sent
	 * only when it is a direct call, not when going back, or selecting a confirmation
	 **/
	function on_item_event(type:ListItemEvent, it:MItemData)
	{
		if (type == fire && it.type == link)
		{
			switch (it.P.ltype) {
				
				case 0:	// PageCall
					if (it.P.link == "back") {
						goBack(); 
					}else{
						_mev(pageCall, it.P.link);	
						// DEV: ^ Not redundant. Useful for sound effects based on menu events
						goto(it.P.link);
					}
					return;
					
				case 2:	// Call - Confirm Popup
					create_popup_from_item(it);
					_mev(pageCall, "?pop");
					return;
					
				case 3: // Call - Confirm New Page
					var P = MPageData.getConfirmationPage(it);
						_flag_restore_selected_index = true;	// Use the custom index 
						goto(P);
					_mev(pageCall, "?fs");
					return;
					
				default: 
					_mev(it_fire, it.ID);
			}
			
		}else{
			
			// Links got processed OK
			// Transform everything else to menu events
			switch (type)
			{
				case focus: _mev(it_focus, it.ID);
				case fire: _mev(it_fire, it.ID);
				case invalid: _mev(it_invalid, it.ID);
				default:
			}
		}
		
		// Mirror the event to user
		// DEV: link events have been transformed
		if (onItemEvent != null) onItemEvent(type, it);
	}//---------------------------------------------------;

	

	// HELPER. sub - part of goto()
	// -
	function _add_pageActive()
	{
		mpActive = pool_get(pageActive);
		add(mpActive);
		mpActive.setPosition(x, y);			// in case the menu moved
		// : Get cursor position
		if (_flag_restore_selected_index) {
			mpActive.setSelection(pageActive.PAR.cindex);
			_flag_restore_selected_index = false;
		}else{
			mpActive.selectFirstAvailable();
		}
		mpActive.viewOn(true);	// > always focus the new page.
		_mev(MenuEvent.page, pageActive.ID);
	}//---------------------------------------------------;
	
	// DEV: This is the only onMenuEvent user callback caller
	// -
	function _mev(e:MenuEvent, ?d:String)
	{
		for (pl in plugs) {
			pl.onMEvent(e, d);
		}
		if (onMenuEvent != null) onMenuEvent(e, d);
	}//---------------------------------------------------;
	
	
	/** Tries to get from POOL, and if it can't 
		it will create a new MPage object and return that
	**/
	function pool_get(PD:MPageData):MPage
	{
		// - Does it exist in the pool?
		var p:MPage;
		for (i in 0...pool.length) {
			if (pool[i].page == PD){
				p = pool[i];
				pool.splice(i, 1);
				return p;
			}
		}
		
		// - Init iconcacher if it is not already
		if (iconcache == null) {
			iconcache = new MIconCacher(STP.item);
		}
		
		// - Create a new Page
		p = new MPage(x, y, def_width, def_slots);
		p.OPT.enable_mouse = PAR.enable_mouse;
		p.OPT.start_button_fire = PAR.start_button_fire;
		p.STP = STP;
		p.iconcache = iconcache;
		p.onItemEvent = on_item_event;
		p.onListEvent = on_list_event;
		p.setPage(PD);
		return p;		
	}//---------------------------------------------------;
	
	function pool_put(P:MPage)
	{
		if (P.page.PAR.noPool) return;
		if (pool.indexOf(P) >-1) return;
		
		pool.push(P);
		
		if (pool.length > PAR.pool_max) {
			pool.shift().destroy();
		}
	}//---------------------------------------------------;
	
	function pool_clear()
	{
		if (pool != null) for (i in pool) i.destroy();
		pool = [];
	}//---------------------------------------------------;
	
	
	override public function add(Object:FlxBasic):FlxBasic 
	{
		if (PAR.camera_lock && Std.isOfType(Object, FlxSprite) )
		{
			cast (Object, FlxSprite).scrollFactor.set(0, 0);
		}
		return super.add(Object);
	}//---------------------------------------------------;
	
	/** 
	 * Create, Add and Handle a popup question coming from an Item 
	 * TODO: Pause Animated Cursor if any??
	 **/
	function create_popup_from_item(it:MItemData)
	{
		
		// DEV: It is important to flush, otherwise it will register an input immediately after
		D.ctrl.flush();	
		
		mpActive.active = false;
		
		var P = MPageData.getConfirmationPage(it);
			P.PAR.isPopup = true;
			
			// Apply user style or use some defaults
			if (popSTo != null)
				P.STPo = popSTo;
			else
			{
				P.STPo = {	// some styling
					background:{
						color: 0xBB000000, 
						padding:[2,2,2,2]
					}
				};
			}
			
		Reflect.setField(P.STPo, 'loop', false);
		
		var MP = pool_get(P);
		
		var CLOSE_MP = ()->{
			D.ctrl.flush(); // Prevent key firing again on the menu
			remove(MP);
			MP.destroy();
			mpActive.active = true;
			_mev(back);
		}
			
		// DEV: The. on__Events are already set from (pool_get) I need to override
		MP.onListEvent = (a)->a=="back"?CLOSE_MP():0;
			
		MP.onItemEvent = (ev, it2)-> {
			if (ev != fire) return;
			CLOSE_MP();
			if (it2.P.ltype == 1 && onItemEvent != null)
				onItemEvent(ev, it2);
		};
		
		MP.x = mpActive.indexItem.x + mpActive.indexItem.width + (STP.focus_anim != null?STP.focus_anim.x:0);
		MP.y = mpActive.indexItem.y;
		add(MP);
		
		MP.setSelection(P.PAR.cindex);
		MP.viewOn();
	}//---------------------------------------------------;
	
	
}// -- end class



// -- Experimental
// - Used to attach things to a menu
// - Handles menu events
interface IFlxMenuPlug extends IFlxDestroyable
{
	@:allow(djFlixel.ui.FlxMenu)
	private function attach(m:FlxMenu):Void;
	@:allow(djFlixel.ui.FlxMenu)
	private function onMEvent(ev:MenuEvent, pid:String):Void;
}