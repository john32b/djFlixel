/**
  = FlxMenu
  - Multi-page menu system 
  - Version 0.4 (2020_03)
  ----------------------------------------------
  
  - Every menu page is a datastructure of <MPageData>
  - <MPage> is a sprite group that takes <MPageData> and creates a single page menu based on that data
  - FlxMenu is a system that handles multiple <MPages>
  - Handles calling pages from other pages, menu item callbacks, etc
  
  
  Simple use example :
  --------------------
  
  var menu = new FlxMenu(32, 32, 100, 5);
	menu.createPage("main").addM([
		"New Game|link|new_game",
		"Options|link|@options",
		"Quit|link|#quit|cfm=:yes:no" ]);
	menu.createPage("options","Options").addM([
		"Sound Effects|toggle|id=sound",
		"Graphic Style|list|list=old,new",
		"Back|link|@back" ]);
	menu.onItemEvent = (event, item)->{
		if (event == fire) {
			if (item.data.id == "new_game") do_newgame(); else
			if (item.data.id == "quit") do_quit(); else
			if (item.id=sound) soundengine.set(item.data.c);
		}
	};
	add(menu);
	menu.goto(main);
			
*******************************************************************/



package djFlixel.ui;

import djA.DataT;
import djFlixel.core.Dtext.DTextStyle;
import djFlixel.ui.FlxAutoText;
import djFlixel.ui.menu.MIconCacher;
import djFlixel.ui.menu.MItem;
import djFlixel.ui.menu.MItem.MItemStyle;
import djFlixel.ui.menu.MItemData;
import djFlixel.ui.menu.MPage;
import djFlixel.ui.menu.MPageData;
import djFlixel.ui.IListItem.ListItemEvent;
import djFlixel.ui.VList.VListStyle;
import flixel.FlxSprite;

import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.util.typeLimit.OneOfTwo;


// Menu Events that are sent with <FlxMenu.onMenuEvent>
enum MenuEvent
{
	page;		// A page is shown
	pageCall;	// A new page was requested from a link
	back;		// Went back, either by link or button
	close;		// Menu went off
	open;		// Menu went on
	rootback;	// Back button was pressed while on the first page of the menu (no more pages in history)
	start;		// Start button was pressed
	focus;		// Menu was just focused
	unfocus;	// Menu was just unfocused
}


// --
class FlxMenu extends FlxGroup
{
	public var x(default, null):Float;
	public var y(default, null):Float;
	
	// There are going to be passed to all created MPAGES
	var def_width:Int;
	var def_slots:Int;	
	
	public var isFocused(default, null):Bool = false;
	
	// Pointer to the PageData that is currently on screen
	public var pageActive(default, null):MPageData;	
	
	public var pages(default, null):Map<String,MPageData>;
	
	// Pointer to the current active MenuPage Sprite
	public var mpActive(default, null):MPage;
	
	var history:Array<MPageData>;
	
	var pool_max = 4;
	
	var pool:Array<MPage>;
	
	// An icon generator shared for all Menu Pages
	var iconcache:MIconCacher;
	
	/// DEV: Shortened names for {styleItem, styleList, styleCursor}
	/** USERSET- Set style for the Menu Items. Starts with default values, you can modify fields */
	public var stI:MItemStyle;
	/** USERSET - Set style for the Vertical List. Starts with default values, you can modify fields */
	public var stL:VListStyle;
	/** USERSET - Set style for Menu Cursor, you can modify fields. */
	public var stC:MCursorStyle;
	/** USERSET - Set the textstyle for the Header Text */
	public var stHeader:DTextStyle;
	
	/** Some functionality flags. Set these right after new() */
	public var PARAMS = {
		enable_mouse:true,  		// Enable mouse interaction in general
		start_button_fire:false,	// True will make the start button fire to items
		page_anim_parallel:false,	// Page-on-off will run in parallel instead of waiting
		// --
		header_enable:true,			// Show an animated text title for each menu page
		header_offset_y:0,			// Offset Y position of the header
		header_CPS:18,				// Header Text, CPS for animation 0 for instant
		line_height:1,				// Decorative line color = stHeader.color
		line_time:0.4
	};
	
	/** Menu Callbacks to the user */
	public var onMenuEvent:MenuEvent->String->Void;			// MenuEvent:Page ID
	public var onItemEvent:ListItemEvent->MItemData->Void;	// ItemEvent:ItemData
	
	// :: Text Header
	var headerText:FlxAutoText;
	var decoLine:DecoLine;
	
	// HELPER. Used in goto(); I don't want to add a function parameter.
	var __backreq:Bool = false;	
	
	//====================================================;
	
	
	/**
	   @param	X Screen X
	   @param	Y Screen Y
	   @param	WIDTH 0 To autocalculate based on item length (default) -1 To mirror X to the rest of the screen
	   @param	SLOTS How many vertical slots for items to show. If a menu has more items, it will scroll.
	**/
	public function new(X:Float=0, Y:Float=0, WIDTH:Int=0, SLOTS:Int = 6)
	{
		super();
		x = X; y = Y;
		def_width = WIDTH; def_slots = SLOTS;
		
		history = [];
		pages = [];
		pool_clear();
		
		stI = DataT.copyDeep(MItem.DEFAULT_STYLE);	// STI needs deep copy
		stL = Reflect.copy(VList.DEFAULT_STYLE);
		stC = {};
	}//---------------------------------------------------;
	
	
	override public function destroy():Void 
	{
		if (iconcache != null) iconcache.clear();
		super.destroy();
		pool_clear();	// To destroy these objects as well
	}//---------------------------------------------------;
	
	/** Create a MenuPage, add it and return it */
	public function createPage(id:String, ?title:String):MPageData
	{
		var p = new MPageData(id, title);
		addPage(p);
		return p;
	}//---------------------------------------------------;
	
	/** Add a page to the DB */
	public function addPage(p:MPageData)
	{
		pages.set(p.ID, p);
	}//---------------------------------------------------;
	
	
	/**
	   If this was closed, restore the page and focus it
	   @param hard True will immediately show it with no animation
	**/
	public function open(hard:Bool = false)
	{
		if (pageActive == null){
			trace("Error: No ActivePage set");
			return;
		}
		if (history.length == 0 || mpActive != null || isFocused) return;
		// pageactive should be the same so I can do this:		
		mpActive = pool_get(pageActive);
		add(mpActive);
		mpActive.viewOn(true, hard);	// > always focus the new page.
		headerText_show();
		
		_mev(MenuEvent.open, pageActive.ID);
		_mev(MenuEvent.page, pageActive.ID);
	}//---------------------------------------------------;
	
	/**
	   Close the active page. Restore it with open(). You can also goto()
	   @param	hard True will immediately hide it with no animation
	**/
	public function close(hard:Bool = false)
	{
		if (mpActive != null) // Close it
		{
			pool_put(mpActive);
			mpActive.viewOff((l)->remove(l), hard);
			mpActive = null;
			// DEV: Do not null pageActive, since it is read on open()
		}
		isFocused = false;
		headerText_hide();
		_mev(MenuEvent.close, pageActive.ID);
	}//---------------------------------------------------;
	
	
	public function focus()
	{
		if (isFocused) return;
			isFocused = true;
		if (mpActive != null) {
			mpActive.focus();
		}
		_mev(MenuEvent.focus, pageActive.ID);
	}//---------------------------------------------------;
	
	
	public function unfocus()
	{
		if (!isFocused) return;
			isFocused = false;
		if (mpActive != null) {
			mpActive.unfocus();
		}
		_mev(MenuEvent.unfocus);
	}//---------------------------------------------------;
	
	
	
	/**
	   - Will always focus the new page
	   @param	P Page ID that is already in pages list or a new PageData
	**/
	public function goto(SRC:OneOfTwo<String,MPageData>)
	{
		var pdata:MPageData;
		if (Std.isOfType(SRC, MPageData)) {
			pdata = cast SRC;
		}else{
			pdata = pages.get(cast SRC);
		}

		if (pdata == null){
			throw "USER ERROR: Could not get pagedata from input parameter";
		}
	
		if (pageActive == pdata) {
			// Already there, try to open the page and exit
			open();
			return;
		}
		
		pageActive = pdata;
		isFocused = true;
		
		// Search if this page is in history, if it is remove it and all after it
		var i = history.length;
		while (i--> 0) {
			if (history[i] == pdata) {
				history.splice(i, history.length - i); // Remove from i to end
				break;
			}
		}
		
		history.push(pdata);
		
		if (mpActive != null) // Close it
		{
			pool_put(mpActive);
			
			if (PARAMS.page_anim_parallel){
				mpActive.viewOff((l)->remove(l));
				_on_pageActive();
			}else{
				mpActive.viewOff((l)->{remove(l); _on_pageActive();});
			}
		}else{
			_on_pageActive();
		}
		
	}//---------------------------------------------------;
	

	// Go to the previous page on history
	public function goBack()
	{
		// Can go back no more, notify user and return
		if (history.length <= 1) {
			_mev(rootback);
			return;
		}
		
		_mev(back);
		__backreq = true;	// goto() will try to restore the cursor to where it was
		history.pop(); 	// This is the current page on the history. Remove it.
		goto(history.pop()); // This is where I want to go
	}//---------------------------------------------------;
	
	
	// Go to the first page of history queue	
	public function goHome()
	{
		if (history.length <= 1) return;
		__backreq = false;
		goto(history[0]);
	}//---------------------------------------------------;
	
	/**
	   Change an item's data or parameters, (label,disabled)
	   The changes you make to the item will apply immediately on the menus
	   e.g.
			; Make the Second Item toggle the disabled state
	   		menu.item_update(1, (i)->{i.disabled = !i.disabled;});
			
			; In Page "options" select item with id "audio" and set its range value to 0
			menu.item_update("options","audio", (i)->{i.data.c=0;});
			
	   @param	pageID If Null will search the active page
	   @param	idOrIndex Item INDEX starting from 0 or ID
	   @param	fn Alter the item in this function
	**/
	public function item_update(?pageID:String, idOrIndex:OneOfTwo<String,Int>, fn:MItemData->Void)
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
		fn(item);
		
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
	
	
	
	// Called right after a new page
	// - Creates/Updates the header text
	// - Make sure `pageActive` is set
	function headerText_show()
	{
		if (!PARAMS.header_enable) return;
		
		if (headerText == null) // :: Create it
		{
			if (pageActive.title == null) return;	// No need to create it right now
			
			if (stHeader == null) {
				stHeader = {bt:2};	// outline style
			}
			stHeader.a = stL.align; // alignment always copies from list style
			
			if (stHeader.c == null) stHeader.c = stI.col_t.accent;
			if (stHeader.bc == null) stHeader.bc = stI.col_b.accent != null?stI.col_b.accent:stI.col_b.idle;

			headerText = new FlxAutoText(0, 0, mpActive.menu_width, 1);
			headerText.scrollFactor.set(0, 0);
			headerText.style = stHeader;
			headerText.setCPS(PARAMS.header_CPS);
			headerText.textObj.height; // HACK: Forces flxtext regen graphic to get proper height
			add(headerText);
			//--
			decoLine = new DecoLine(0, 0, mpActive.menu_width, PARAMS.line_height, stI.col_t.idle);
			decoLine.scrollFactor.set(0, 0);
			if (PARAMS.line_height > 0) // Hacky way to disable the line if you don't need it
				add(decoLine);
		}
		
		if (pageActive.title == null)
		{
			headerText.visible = decoLine.visible = false;
			return;
		}
		
		headerText.visible = decoLine.visible = true;
		headerText.setText(pageActive.title);
		
		headerText.x = x;
		headerText.y = y - (mpActive.overflows?stL.sind_size:0) - headerText.height + PARAMS.header_offset_y - PARAMS.line_height;
		decoLine.setPosition(x, headerText.y + headerText.height);
		decoLine.start(PARAMS.line_time);
	}//---------------------------------------------------;
	
	function headerText_hide()
	{
		if (!PARAMS.header_enable || headerText == null) return;
		headerText.visible = decoLine.visible = false;
		
	}//---------------------------------------------------;
	
	function on_list_event(msg:String)
	{
		if (msg == "back") {
			if (pageActive != null && pageActive.params.noBack) return;
			goBack(); 
		}
		else if (msg == "start")
		{
			_mev(start);
			return;
		}
	}//---------------------------------------------------;
	
	// Handle callbacks from the VLIST, process what is to be processed
	// and then report back to user
	function on_item_event(type:ListItemEvent, it:MItemData)
	{
		if (type == fire && it.type == "link")
		{
			switch(it.data.type) {
				case 0:	// PageCall
					if (it.data.link == "back") {
						goBack(); 
					}else{
						_mev(pageCall, it.data.link);
						goto(it.data.link);
					}
					return;
				case 2:	// Call - Confirm Popup
					mpActive.active = false;
					D.ctrl.flush();	// <-- It is important to flush, otherwise it will register an input immediately
					var P = MPageData.getConfirmationPage(it);
						P.params.stI = {text:DataT.copyFields(it.data.tStyle, Reflect.copy(stI.text))};
					var MP = pool_get(P);	// -> Will create a new page every time, because `noPool=true`
					var CLOSE_MP = ()->{
						D.ctrl.flush(); // prevent key firing again on the menu
						remove(MP);
						MP.destroy();
						mpActive.active = true;
						_mev(back);
					}
					MP.onListEvent = (a)-> { if (a == "back") CLOSE_MP(); };
					MP.onItemEvent = (ev, it2)-> {
						if (ev != fire) return;
						CLOSE_MP();
						if (it2.data.type == 1 && onItemEvent != null) onItemEvent(ev, it2); 
					};
					MP.x = mpActive.indexItem.x + mpActive.indexItem.width;
					MP.y = mpActive.indexItem.y;
					MP.setSelection(P.items.length - 1);	// Select last element, which is "NO"
					MP.focus();
					_mev(pageCall, "#confirmation");
					add(MP);
					return;
				case 3: // Call - Confirm New Page
					var P = MPageData.getConfirmationPage(it);
						P.params.stI = {text:DataT.copyFields(it.data.tStyle, Reflect.copy(stI.text))};
					goto(P);
					_mev(pageCall, "#confirmation");
					return;
				default: // This is normal call, do nothing, will be pushed to user 
			}
		}
		
		// Mirror the event to user
		if (onItemEvent != null) onItemEvent(type, it);
	}//---------------------------------------------------;

	
	

	// HELPER. sub - part of goto()
	// 
	function _on_pageActive()
	{
		mpActive = pool_get(pageActive);
		add(mpActive);
		mpActive.setPosition(x, y);			// in case the menu moved
		// : Get cursor position
		if (__backreq) {
			mpActive.setSelection(pageActive.params.lastIndex);
			__backreq = false;
		}else{
			mpActive.selectFirstAvailable();
		}
		mpActive.viewOn(true);	// > always focus the new page.
		headerText_show();
		_mev(MenuEvent.page, pageActive.ID);
	}//---------------------------------------------------;
	
	// -- HELPER. Quickly call menu event
	function _mev(e:MenuEvent, ?d:String)
	{
		if (onMenuEvent != null) onMenuEvent(e, d);
	}//---------------------------------------------------;
	

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
			iconcache = new MIconCacher(stI);
		}
		
		// - Create a new Page
		p = new MPage(x, y, def_width, def_slots);
		p.cameras = [camera];
		p.FLAGS.enable_mouse = PARAMS.enable_mouse;
		p.FLAGS.start_button_fire = PARAMS.start_button_fire;
		p.styleC = stC;
		p.styleIt = DataT.copyDeep(stI);
		p.style = Reflect.copy(stL);
		p.iconcache = iconcache;
		p.onItemEvent = on_item_event;
		p.onListEvent = on_list_event;
		p.setPage(PD);
		return p;		
	}//---------------------------------------------------;
	
	function pool_put(P:MPage)
	{
		if (P.page.params.noPool) return;
		if (pool.indexOf(P) >-1) return;
		// DEV: The page is guaranteed that does not exist in the pool since
		//      when it was created the pool was checked first.
		pool.push(P);
		if (pool.length > pool_max)
		{
			pool.shift().destroy();
		}
	}//---------------------------------------------------;
	
	function pool_clear()
	{
		if (pool != null) for (i in pool) i.destroy();
		pool = [];
	}//---------------------------------------------------;
	
	
}// --