package djFlixel.gui;

import djFlixel.gui.FlxAutoText;
import djFlixel.gui.Styles;
import djFlixel.gui.list.VListMenu;
import djFlixel.gui.menu.MItemBase;
import djFlixel.gui.menu.MItemData;
import djFlixel.gui.menu.PageData;
import djFlixel.tool.ArrayExecSync;
import djFlixel.tool.DEST;
import djFlixel.tool.DataTool;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxDestroyUtil;
import flixel.util.typeLimit.OneOfTwo;

/**
 * FlxMenu
 * A multi-page customizable menu system that can hold various Menu Item Types
 * ----------------------------------------------------------------------------
 */
class FlxMenu extends FlxGroup
{
	// -- System ::
	public var x(default, null):Float;
	public var y(default, null):Float;
	public var width(default, null):Int;
	public var height(get, null):Int;
	public var isFocused(default, null):Bool;
	// Check isOpen by checking visible
		
	// How many slots the lists should have, unless overriden by a page.
	var slotsTotal:Int;
	//---------------------------------------------------;

	// *Pointer to the current active VList
	var currentMenu:VListMenu;

	// *Pointer to the previous page, useful for animating
	var previousMenu:VListMenu;
	
	// Pointer to the current loaded page.
	public var currentPage(default, null):PageData;
	
	// Hold all the STATIC PAGES this menu is going to use
	public var pages(default, null):Map<String,PageData>;
	
	// Page history. Linear path from the first page to the current page shown
	// This also stores dynamic pages, in case you want to go back to them
	var history:Array<PageData>;
	
	// Popup close fn, useful to have as global, in case the menu needs to close
	// ALSO: if this is set, it means that a popup is currently active
	var _popupCloseFn:Void->Void;
	
	// Keep a small pool of Pages so it doesn't have to recreate them
	var _pool:Array<VListMenu>;

	// -- HEADER TEXT AND DECORATIVE LINE ::
	// -
	var f_use_header:Bool = true;
	var headerText:FlxAutoText;
	var decoLine:DecoLine;
	
	// -- Animation helper for when animating pages in and out
	var animQ:ArrayExecSync<Void->Void>;
	
	// ===---- USER SETS ---===
	// =----------------------=
	
	// Global list style for all menus, unless a page overrides this
	// NULL to use the default style, Set right after creating
	public var styleMenu:StyleVLMenu;
	
	// The Text Style for the Optional Header
	public var styleHeader:{
		?enable:Bool,		// False to disable header info
		?textS:TextStyle,	// Textstyle to be applied on the header text
							// - autocalculated to reflect the stylemenu style unless overridden
		?offsetText:Int,	// Y Offset for the text only,
		?offset:Int, 		// Y Offset for both the line and text,
		?alignment:String,	// left, right, center -- Will be borrowed from styleMenu.alignment
		?CPS:Int,			// Characters per Second, 0 for instant
		?deco_line:Int,		// If >0 will draw a decorative line with this height between the header and the menu 
							// the line's color will be the same as "color_accent" from the menu items
		?deco_line_time:Float	// Time to complete the line animation 1 for instant, 
								// 0 or null to autocalculate
		
	};

	// When you are going back to menus, remember the position it came from
	public var flag_remember_cursor_position:Bool = true;
	
	// If true, then the start button will fire the selected item
	public var flag_start_button_ok:Bool = false;
	
	// Allow mouse interaction with the menu items
	public var flag_use_mouse:Bool = true;
	
	// Keep X maximum menus in the pool. !! SET THIS RIGHT AFTER NEW() !!
	public var POOLED_MENUS_MAX:Int = 4;
	
	//---------------------------------------------------;
	
	// -- CALLBACKS ::
	// -- Unified function to get all status messages from menuitems andthe menu
	// -------------------
	// callbacks(status,data,item):Void
	// 	- status 	: general status message,
	// 	- data 		: extra data associated with the status, e.g. pagename or itemSID
	// 	- item		: in some cases, an item will be passed
	
	// STATUS MESSAGES :
	// -----------------
	// --- ( Item Related, data = menuitem.sid, item = menuItem)
	// - focus  - A new item has been focused
	// - change - When an item changed value
	// - fire   - An item received a trigger command
	// - invalid- Fired when trying to tigger a disabled item
	// -
	// --- ( Menu Related, data = extra data, item = null )
	// - start   	- Start button was pressed ( useful in pause menus, to close the menu )
	// - back  		- The menu went back a page
	// - rootback 	- When user wants to back out from the root menu
	// - open   	- The menu was just opened
	// - close  	- The menu was just closed
	// - pageOn 	- A page just went on screen, puts page.sid to data
	// - pageOff  	- A page just went off screen, puts puts page.sid to data
	// -
	// --- (The following types are mainly for sound effect handling from the user)
	// -
	// - tick		 - An item was focused, The cursor moved
	// - tick_change - An item value has changed
	// - tick_fire   - An item was selected. ( button )
	// - tick_error  - An item that cant be selected or changed
	// -
	public var callbacks:String->String->MItemData->Void;

	//====================================================;

	/**
	 * Constructor
	 * @param	X Screen X position, You cannot change this later
	 * @param	Y Screen Y position, You cannot change this later
	 * @param	WIDTH 0: Rest of the screen, -1: Center of the screen mirror to X
	 * @param	SlotsTotal Maximum slots for pages, unless overrided by a page
	 */
	public function new(X:Float, Y:Float, WIDTH:Int=0, SlotsTotal:Int = 6)
	{
		super();
		x = X; y = Y; width = WIDTH;
		slotsTotal = SlotsTotal;
		pages = new Map();
		
		// --
		if (width == 0) width = cast FlxG.width - x; else
		if (width < 0) width = cast FlxG.width - (x * 2);
		
		// Default styles, can be overriden later
		styleMenu = Styles.newStyleVLMenu();
		styleHeader = {};
		
		// Default to not visible at start,
		// calling the open will make it visible
		visible = false;
		
		// --
		_pool = [];
		history = [];
		currentMenu = null;
		previousMenu = null;
		currentPage = null;	
		
		// Page Animation Queue
		animQ = new ArrayExecSync<Void->Void>();
		animQ.queue_action = function(fn:Void->Void){fn();};
		_popupCloseFn = null;
	}//---------------------------------------------------;
	
	
	/**
	 * Apply a style to the menu
	 * @param	stMenu This must be a StyleVLMenu compatible object
	 * @param	stHeader This must be a styleHeader compatible object
	 */
	public function applyMenuStyle(stMenu:Dynamic,?stHeader:Dynamic)
	{
		DataTool.copyFieldsC(stMenu, styleMenu);
		if (stHeader != null) DataTool.copyFieldsC(stHeader, styleHeader);
	}//---------------------------------------------------;
	
	
	// --
	override public function destroy():Void 
	{
		super.destroy();
		
		history = null;
		currentMenu = null;
		previousMenu = null;
		currentPage = null;
		
		styleHeader = null;
		styleMenu = null;
		
		animQ.destroy();
		_pool = FlxDestroyUtil.destroyArray(_pool);
		pages = DEST.map(pages); 
		
	}//---------------------------------------------------;
	
	/**
	 * Quick way to create and add a page to the menu
	 * @param	pageSID Give the page a unique string Identifier
	 * @param	params {title:String desc:String } Other data will go to the custom object, Check PageData.hx for more
	 * @return
	 */
	public function newPage(pageSID:String, ?params:Dynamic):PageData
	{
		var p = new PageData(pageSID, params);
		pages.set(pageSID, p);
		return p;
	}//---------------------------------------------------;
	
	/**
	 * Highlight an item with a target SID
	 * @param	sid The SID of the menu item
	 */
	public function item_highlight(sid:String)
	{
		if (currentMenu == null) return;
		currentMenu.item_highlight(sid);
	}//---------------------------------------------------;
	
	
	/**
	 * Retrieve the menu item data from a page, searches the page database for the item
	 * @param	pageSID The PAGE SID the item belongs to
	 * @param	SID	The SID of the item
	 * @return
	 */
	public function item_get(pageSID:String, SID:String):MItemData
	{
		var p = pages.get(pageSID);
		if (p != null) for (i in p.collection) if (i.SID == SID) return i;
		// Could not get the item
		return null;
	}//---------------------------------------------------;
	
	/**
	 * Update the data on an item, alters Data and updates Visual
	 * The item doesn't have to be on the current page it will search and alter it
	 * in the pages database.
	 * 
	 * @param	pageSID You must provide the pageSID the item is in
	 * @param	SID SID of the item
	 * @param	param New Data, e.g. { label:"NewLabel", disabled:false, current:0 }
	 * 			note: will work with fields inside the item.data as well
	 */
	public function item_updateData(pageSID:String, SID:String, param:Dynamic)
	{
		var a:VListMenu = null; // pointer
		
		// Find the menu list
		if (currentMenu != null && currentMenu.page.SID == pageSID) {
			a = currentMenu;
		}else {
			for (i in _pool) {
				if (i.page.SID == pageSID) { a = i; break; }	
			}
		}
		
		if (a != null) { // If it actually found the menu somewhere
			a.item_updateData(SID, param);
		}else {
			// It is not in the pool,
			// Alter the item data
			if (pages.exists(pageSID)) {
				var o:MItemData = pages.get(pageSID).get(SID);
				if (o != null) {
					o.setNewParameters(param);
				}else {
					trace('Warning: Can\'t find element with SID "$SID" on page "$pageSID"');
				}
			}else {
					trace('Warning: Can\'t find PAGE.SID "$pageSID"');
			}
		}
	}//---------------------------------------------------;
	
	
	/**
	 * Go to a Page. Either a predeclared static page or a new pagedata. Opens the menu but doesn't focus it.
	 * @param	Page	SID of page previously added, or a new PageData object. if PageData make sure the SID is Unique
	 * @param	searchHistory 	if False will append thepage to the history, regardless if it exists already
	 * 							if True will search the history and if found will go back to the page
	 */
	public function goto(Page:OneOfTwo<String,PageData>, searchHistory:Bool = true)
	{	
		if (Std.is(Page, String)) // It's an SID
		{
			var pageSID:String = Page;
			
			// If page on history, go back to it
			if (searchHistory){
				var i = history.length;
				while (i--> 0) {
					if (history[i].SID == pageSID){
						history.splice(i, history.length - i); // Remove from i to end
						break;
					}
				}
			}
			
			if (pages.exists(pageSID)) // Just get the page from the static pages array
			{
				currentPage = pages.get(pageSID);
				
			}else
			{
				trace('Error: Could not find page with SID=$pageSID');
				return;
			}

		}else // It is a dynamic PAGE data
		{
			currentPage = Page;
		}
		
		// Last history entry is always the current page
		history.push(currentPage);	
		
		// -- Change the menu object ::
		
		// currentMenu and previousMenu could be animating
		// It can never happen with normal menu navigation
		// But it could happen e.g. when user force calls a goto during an animation
		if (previousMenu != null) previousMenu.clearTweens();
		
		if (currentMenu != null) {
			if (flag_remember_cursor_position) {
				currentMenu.page.custom._cursorLastUID = currentMenu.getCurrentItemData().UID;
			}
			poolStore(currentMenu);
			currentMenu.clearTweens(); // Just in case
		}
		
		previousMenu = currentMenu;
		currentMenu = poolGetOrNew(currentPage);
		currentMenu.callbacks = _listCallbacks;
		
		// Init cursor position for current menu
		_sub_InitCursorPos();
		
		// Header and deco lone
		_sub_CheckAndSetHeader();
		
		// -- Animate
	
		if (!visible) {
			_q_callback("open");
			visible = true;
		}
		
		animQ.reset();
		switch(currentMenu.styleMenu.pageEnterStyle)
		{
			case "wait":
				animQ.push(animQ_previousOffScreen);
				animQ.push(animQ_currentOnScreen);
			case "parallel":
				animQ_previousOffScreen();
				animQ_currentOnScreen();
			default: // "none":
				animQ.push(animQ_previousRemove);
				animQ.push(animQ_currentOnScreen);
		}
		animQ.next();
		
		//#if debug
		//trace(this);
		//#end
	}//---------------------------------------------------;
	
	
	/**
	 * Open the Menu. If you specify a page it will open that page, if null for page it will try 
	 * to open the last page before close();
	 * @param	page The SID of the page to open
	 * @param	autofocus If true the menu will acquire input focus
	 */
	public function open(?Page:OneOfTwo<String,PageData>, autofocus:Bool = true)
	{	
		if (autofocus) {
			isFocused = true; // Don't call focus(); It will interfere with the process
		}
		
		if (Page == null && currentMenu != null)
		{
			if (!visible) {
				_q_callback("open");
				visible = true;
			}
			animQ_currentOnScreen();	// Animate it in
			_sub_CheckAndSetHeader();
			return;
		}
		
		if (Page == null)
		{
			var p:String = "";
			for (i in pages.keys()) {
				p = i; break;
			}
			if (p == null){
				trace("Error: There are no static pages to open. Specify a page directly");
			}else{
				goto(p);
			}
			return;
		}
	
		// Proceed normally:
		goto(Page);
	
	}//---------------------------------------------------;
	
	/**
	 * Closes the menu and loses input focus
	 * @param	rememberState If true, then when you call open() the current selected item will be selected, also the history will not be erased
	 */
	public function close(rememberState:Bool = false)
	{
		if (!visible) return;
		
		// Fade Off
		if (decoLine != null) {
			Gui.tween(decoLine, {alpha:0}, styleMenu.stw_el_time * 2);
			decoLine.stop();
		}
		
		if (headerText != null) {
			Gui.tween(headerText.textObj, {alpha:0}, styleMenu.stw_el_time * 2);
			headerText.stop();
		}
		
		_q_callback("close", currentPage != null?currentPage.SID:null);
		
		if (rememberState && currentPage!=null)
		{
			var d1 = currentMenu.getCurrentItemData();
			if (d1 != null) currentPage.custom._cursorLastUID =	d1.UID;
		}
		
		if (!rememberState){
			currentPage = null;
			history = [];
		}
		
		// Unload current menus
		if (currentMenu != null) {
			currentMenu.clearTweens();	// In some cases the menu is animating with a callback
			currentMenu.offScreen(function(){
				visible = false;
				currentMenu.visible = false;
			});
		}
		
		if (_popupCloseFn != null)
			_popupCloseFn();
			
		// Note: I am keeping currentPage open();
	}//---------------------------------------------------;

	/**
	 * Input focus
	 */
	public function focus()
	{
		if (isFocused || !visible) return;
		
		// A popup is active. Don't focus the menu
		if (_popupCloseFn != null) return;
		
			isFocused = true;
		
		if (currentMenu != null) {
			// Fix: If called right after a open()
			//	    And the menu is animating, it can't be focused BUG
			if(!currentMenu.isScrolling)	
				currentMenu.focus();
		}
	}//---------------------------------------------------;
	
	/**
	 * Lose input focus
	 */
	public function unfocus()
	{
		if (!isFocused) return;
		if (_popupCloseFn != null) return;
		
		isFocused = false;
			
		if (currentMenu != null) {
			currentMenu.unfocus();
		}
	}//---------------------------------------------------;
	
	/**
	 * Displays the previous page on history
	 */
	public function goBack()
	{
		// Goes back one page
		if (history.length <= 1) {
			//trace("Info: No more pages in history");
			_q_callback("rootback");
			return;
		}
	
		_q_callback("back");
		
		// The very last element is the current page, Skip it.
		history.pop();
		
		// Set a Useful Flag, Let  GOTO() know that this is a page I am going back to
		var p = history.pop();
		goto(p);
	}//---------------------------------------------------;
	
	/**
	 * Go to the first page of the history queue
	 */
	public function goHome()
	{
		if (_popupCloseFn != null) return;
		
		if (history.length <= 1) {
			//trace("Info: No more pages in history");
			return;
		}
		
		var p1 = history[0];
			p1.custom._cursorLastUID = null;
		history = [];
		goto(p1);
	}//---------------------------------------------------;
		
	
	//====================================================;
	// POOL FUNCTIONS 
	//====================================================;
	
	// --
	// Store the menu in the pool for future use
	function poolStore(el:VListMenu)
	{
		if (_pool.indexOf(el) >-1) {
			return;
		}
		_pool.push(el);
		
		if (_pool.length > POOLED_MENUS_MAX) {
			_pool.shift().destroy();
		}
	}//---------------------------------------------------;
	
	// --
	// Get a ListMenu object,
	// Search the pool first and get if from there, else create it
	function poolGetOrNew(P:PageData):VListMenu
	{		
		for (i in _pool) {
			if (i.page == P) {
				_pool.remove(i);
				// trace('Info: [${P.SID}] get from POOL');
				return i;
			}
		}
		
		// trace('Info: [${P.SID}] does not exist in the pool, creating...');
		
		var m = new VListMenu(x, y, 
					P.custom.width != null ? P.custom.width : width,
					P.custom.slots != null ? P.custom.slots : slotsTotal);
					
			m.flag_InitViewAfterDataSet = false;
			m.flag_use_mouse = flag_use_mouse;
			m.styleMenu = Reflect.copy(styleMenu);	// Safest to copy, since Page.customStyle could write over
			m.cameras = [camera];
			m.setPageData(P);
		
		return m;
		
	}//---------------------------------------------------;
	
	
	//====================================================;
	// Callback Handler 
	//====================================================;
	
	// --
	// Handle MenuItem callbacks from VListMenus
	function _listCallbacks(status:String, item:MItemData)
	{	
		// Before sending to the user, filter some calls
		
		if (status == "fire" && item.type == "link")
		{
			if (item.data.callback != null)
			{
				_q_callback("tick_fire");
				item.data.callback();
			}
			
			else if (item.data.fn == "page") 
			{
				if (item.SID == "back") {
					goBack();
				}else {
					_q_callback("tick_fire");
					goto(item.SID);
				}
				
			}
			
			else if (item.data.fn == "call")
			{
				if (item.data.conf_active) 
				{
					if(item.data.conf_style == "full")
						_sub_confirmFullPage(item);
					else // popup
						_sub_confirmCurrentItem();
					
				}else {
					_q_callback("fire", item);
				}
			}
		} 
		
		// Is this a general request? ( from a button press )
		else if (status == "back")
		{
			goBack();
		}
		
		else if (status == "start" && flag_start_button_ok)
		{
			if (currentMenu.currentElement != null)
				currentMenu.currentElement.sendInput("fire");
		}
		
		else {
		
			// Internal check complete, push calls to the user.
			_q_callback(status, item);
			
		
		}
		
	}//---------------------------------------------------;
	
	
	//====================================================;
	// SUBFUNCTIONS
	// ------------
	// When a new page is loaded or to be shown
	//====================================================;
	
	// --
	// Called when a link requires confirmation, it creates
	// or retrieves the pagedata to call
	function _sub_confirmFullPage(o:MItemData)
	{
		var questionPageID:String = "_conf_" + o.SID;
		if (!pages.exists(questionPageID)) {
			var p:PageData = new PageData(questionPageID);
				p.add(o.data.conf_question, { type:"label" } );
				p.link(o.data.conf_options[0], o.SID);
				p.link(o.data.conf_options[1], "@back");
				p.custom.cursorStart = 'back'; // Highlight BACK first
				if (o.data.conf_p_style != null) p.custom.styleMenu = o.data.conf_p_style;
			pages.set(questionPageID, p);
		}
		goto(questionPageID);
	}//---------------------------------------------------;
	
	
	// Sets the pointing cursor position to whatever it needs to depending on pagedata.
	// If for any reason it fails, the cursor goes to the first available item
	function _sub_InitCursorPos()
	{
		var r1:Int; // Temp INT holder
		
		// If the page needs the cursor to always point to a specific item:
		// This gets priority over the next check :
		if (currentPage.custom.cursorStart != null) {
			r1 = currentPage.getItemIndexWithField("SID", currentPage.custom.cursorStart);
			_sub_SetCursToPos(r1); // will check for -1 there
			return;
		}
		
		// If the cursor needs to go back to where it was
		if (currentPage.custom._cursorLastUID != null) {
			r1 = currentPage.getItemIndexWithField("UID", currentPage.custom._cursorLastUID);
			// Reset the cursorLastUID, because I used it.
			currentPage.custom._cursorLastUID = null;
			_sub_SetCursToPos(r1); // will check for -1 there
		}else {
			currentMenu.setViewIndex(currentMenu.findNextSelectableIndex(0));
		}
		
	}//---------------------------------------------------;
	
	// --
	// Quick point cursor to an item with SID
	function _sub_SetCursToPos(pos:Int)
	{
		if (pos >= 0) {	
			currentMenu.setViewIndex(pos);
		}else {
			trace('Warning: Can\'t return cursor to pos=$pos. Setting to top');
			currentMenu.setViewIndex(currentMenu.findNextSelectableIndex(0));
		}
		return;
	}//---------------------------------------------------;
	
	// Check to see if the page has header text,
	// And if so, show it
	// --
	function _sub_CheckAndSetHeader()
	{
		if (f_use_header && currentPage.title != null) {
			
			// Create the header if it's not already
			if (headerText == null)
			{
				// Text Style, if anything is set, keep that, else default value
				var ts = DataTool.copyFields(styleHeader.textS, {
					font:styleMenu.font,
					fontSize:styleMenu.fontSize,
					color:styleMenu.color_accent, // NOTE: Is this color ok?
					color_border:styleMenu.color_border,
					border_size:-1
				});
				
				styleHeader = DataTool.copyFields(styleHeader, {
					enable:true,
					deco_line_time: styleMenu.stw_el_time * 3, // Arbitrary, looks good.
					CPS:25, deco_line:1, 
					offset:-2,
					offsetText:0,
					alignment: styleMenu.alignment
				}); 
				var sh = styleHeader;
				f_use_header = sh.enable;
				if (!f_use_header) return;
				
				// Where the line should start
				var ystart:Float = y - 2 + sh.offset - sh.deco_line;
				
				// Text --
				headerText = new FlxAutoText(x, 0, width, 1);
				headerText.style = ts;
				headerText.textObj.wordWrap = false;
				headerText.textObj.alignment = sh.alignment;
				headerText.cameras = [camera];
				headerText.scrollFactor.set(0, 0);
				headerText.MIN_TICK = 0.06;	// Faster 
				headerText.setCPS(sh.CPS);
				headerText.y = ystart - headerText.textObj.height + 2 + sh.offsetText;
				add(headerText);
				
				// Create the Deco Line --
				if (sh.deco_line > 0) {
					decoLine = new DecoLine(x, ystart, width, sh.deco_line, styleMenu.color);
					add(decoLine);
				}
				
			}// --
			
			headerText.start(currentPage.title);
			Gui.tween(headerText.textObj);
			headerText.visible = true;
			headerText.textObj.alpha = 1; // in case it was faded to off
			
			if (decoLine != null) {
				Gui.tween(decoLine);
				decoLine.visible = true;
				decoLine.alpha = 1; // in case it was faded to off
				decoLine.start(styleHeader.deco_line_time);
			}
			
		}else // Not using header text
		{
			if (headerText != null) {
				headerText.clearAndWait();
				headerText.visible = false;
				if (decoLine != null) decoLine.visible = false;
			}
		}
		
	}//---------------------------------------------------;
	
	
	/**
	 * Show a popup [YES,NO] question next to the currently highlighted menu item
	 */
	function _sub_confirmCurrentItem()
	{
		if (currentMenu == null) return;
		var item = currentMenu.getCurrentItemData();
		if (item == null) return;
	
		var xpos = currentMenu.currentElement.x + currentMenu.currentElement.width;
		var ypos = currentMenu.currentElement.y;
	
		// Push a fire of the actual menuItem if selected YES
		popup_YesNo(xpos, ypos, function(b:Bool) {
			if (b) { _q_callback("fire", item); } else { _q_callback("back"); }
		}, item.data.conf_question, item.data.conf_options);
		
	}//---------------------------------------------------;
	

	/**
	 * Confirm action for currently selected item
	 * 
	 * @param	qcallback Callback to this function with a result
	 * @param	question If set it will display this text
	 * @param	options Custom names instead of YES,NO
	 */
	@:access(djFlixel.gui.list.VListNav.setInputFocus)
	private function popup_YesNo(X:Float, Y:Float, qcallback:Bool->Void, ?question:String, ?yesno:Array<String>):Void
	{
		if (yesno == null) yesno = ["Yes", "No"];
		
		#if debug // Do I really need this check?
		if (yesno.length != 2) { trace("Error: yesno must have exactly 2 strings"); return; }
		#end
				
		if (currentMenu != null) currentMenu.setInputFocus(false);
		
		// Menu padding inside the box at X,Y axis
		var pad = [2, 4];

		// -- Create a list and adjust the style a bit ::
		var list = new VListMenu(X + pad[0], Y + pad[1], 0, question != null?3:2);
			list.flag_InitViewAfterDataSet = false; // It gets inited with (item_highlight) below
			list.styleMenu = Reflect.copy(styleMenu);
		var s = list.styleMenu;
			s.fontSize = Std.int(s.fontSize / 2); if (s.fontSize < 8) s.fontSize = 8; // MIN
			s.stw_el_ease = "elasticOut";
			s.stw_el_time = s.el_scroll_time = 0.1;
			s.stw_el_EnterOffs = [0, Std.int( -s.fontSize / 2)];
			s.focus_nudge = cast s.fontSize / 4;
			s.cursor = {disable:true};
			
		// --
		var p:PageData = new PageData("popup_question");
			if (question != null) p.add(question, { type:"label" } );
			p.link(yesno[0], "yes");
			p.link(yesno[1], "no");
			
		// --
		list.setPageData(p);
		list.item_highlight("no"); 
		
		// -- Add a small bg
		var bg:FlxSprite = new FlxSprite(X, Y);
		var W = list.getMaxElementWidthFromView() + s.focus_nudge;
		bg.makeGraphic(cast W + pad[0] * 2, cast list.height + pad[1] * 2, s.color_border);
		bg.scrollFactor.set(0, 0);
				
		// -- Setup a close function so that it can be accessed from everywhere
		//	  in case the menu needs to close. Also this acts like a popup status
		_popupCloseFn = function() {
			list.offScreen(function() { remove(list); list.destroy(); list = null; } );
			remove(bg); bg.destroy();
			_popupCloseFn = null; // Important to do this
			if (currentMenu != null) currentMenu.setInputFocus(true);
		}
		
		// -- Popup Callbacks
		list.callbacks = function(s:String, o:MItemData) 
		{
			if (s == "fire") {
				_popupCloseFn();
				qcallback((o.SID == "yes"));
				return;
			}
			else if (s == "back") {
				_popupCloseFn();
				_q_callback("back");
				return;
			}
			else if (s == "start") return;	// no start button
			
			// pass through all others
			_listCallbacks(s, o);
		};

		// -
		// If I just ADD sometimes it doesn't go to the top, so force it to the top
		insert(members.length, bg);
		insert(members.length, list);
		
		list.onScreen();
		
		_q_callback("tick_fire"); // For the sound effect?
	}//---------------------------------------------------;

	
	//====================================================;
	//  Helpers
	//====================================================;

	function get_height():Int
	{
		if (currentMenu != null) {
			return currentMenu.height;
		}else {
			return 0;
		}
	}//---------------------------------------------------;

	
	// Helper: Quickly check for callback and push status and data	
	function _q_callback(status:String, ?msg:String, ?item:MItemData)
	{
		// - Generate 'tick' statuses on menu items
		if (item != null) 
		{
			msg = item.SID;
			
			switch(status) {
				case "fire": 	_q_callback("tick_fire");
				case "change": 	_q_callback("tick_change");
				case "invalid": _q_callback("tick_error");
			}
		}
		
		if (currentPage.callbacks_override != null){
			currentPage.callbacks_override(status, msg, item);
			return;
		}
				
		if (currentPage.callbacks != null) {
			currentPage.callbacks(status, msg, item);
		}
		
		if (callbacks != null){
			callbacks(status, msg, item);
		}
	}//---------------------------------------------------;
	
	//====================================================;
	// Animation Helpers
	//====================================================;
	// -- These small functions only work with the animQ 
	//	  object. Meaning, that each function is responsible
	//	  for advancing the queue when finished

	// -- Animate on the current screen
	// --
	function animQ_currentOnScreen()
	{
		add(currentMenu);
		_q_callback("pageOn", currentPage.SID);
		currentMenu.onScreen(isFocused, animQ.next);
	}//---------------------------------------------------;
	
	// -- Animate off the previous screen
	function animQ_previousOffScreen():Void
	{
		if (previousMenu != null) {
			_q_callback("pageOff", previousMenu.page.SID);
			previousMenu.offScreen(function() { 
				remove(previousMenu);
				animQ.next();
			});
		}
		else
		{
			animQ.next();
		}

	}//---------------------------------------------------;
	// -- Sudden remove the previous page
	function animQ_previousRemove()
	{
		if (previousMenu != null) {
			_q_callback("pageOff", previousMenu.page.SID);
			previousMenu.unfocus();
			remove(previousMenu);
			previousMenu = null;
		}
		animQ.next();
	}//---------------------------------------------------;

	
	#if debug
	// Write some debugging ingo
	override public function toString():String 
	{
		var np = 0; for (i in pages.keys()) np++; // Count Pages
		return 	'Static Pages : $np | History: '+ [for (i in history) i.SID ] + '| Pool Length : ${_pool.length} | Current Page : ${currentPage.SID}';
	}//---------------------------------------------------;
	#end
	
}// -- end -- //