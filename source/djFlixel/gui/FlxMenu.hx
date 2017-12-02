package djFlixel.gui;

import djFlixel.FlxAutoText;
import djFlixel.gui.Styles;
import djFlixel.gui.list.VListMenu;
import djFlixel.gui.menu.MItemBase;
import djFlixel.gui.menu.MItemData;
import djFlixel.gui.menu.PageData;
import djFlixel.tool.ArrayExecSync;
import djFlixel.tool.DEST;
import djFlixel.tool.DataTool;
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
	
	// Hold all the page data this menu is going to use
	public var pages(default, null):Map<String,PageData>;
	
	// --
	public var currentPageName(get, null):String;
	
	// A queue of page IDs
	var history:Array<String>;
	
	// Popup close fn, useful to have as global, in case the menu needs to close
	// ALSO: if this is set, it means that a popup is currently active
	var popupCloseFunction:Void->Void;
	
	// Keep a small pool of Pages so it doesn't have to recreate them
	var _pool:Array<VListMenu>;
	
	// -- Header text displayed on top of the list (optional)
	var headerText:FlxAutoText;
	var f_use_header:Bool = true;
	// --
	var decoLine:DecoLine;
	
	// -- Animation helper for when animating pages in and out
	var animQ:ArrayExecSync<Void->Void>;
	
	// Hold the latest dynamic pages in case it needs to go back to them
	var dynPages:Array<PageData>;
	
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
		?deco_line:Int		// If >0 will draw a decorative line with this height between the header and the menu 
							// the line's color will be the same as "color_accent" from the menu items
		
	};

	// When you are going back to menus, remember the position it came from
	public var flag_remember_cursor_position:Bool = true;
	
	// If true, then the start button will fire the selected item
	public var flag_start_button_ok:Bool = false;
	
	// Allow mouse interaction with the menu items
	public var flag_use_mouse:Bool = true;
	
	// Keep X maximum menus in the pool. !! SET THIS RIGHT AFTER NEW() !!
	public var POOLED_MENUS_MAX:Int = 4;
	
	// Hold this many dynamic pages in the buffer.
	public var dynPagesMax:Int = 8;
	//---------------------------------------------------;
	
	// ==  User callbacks
	// -------------------==
	
	// Callbacks for Menu Items Statuses ::
	//
	// blur   - This item was just unfocused // Unimplemented. need to add it. VListNav
	// focus  - A new item has been focused <sends item>
	// change - When an item changed value, <sends item>
	// fire   - An item received an action command
	public var callbacks_item:String->MItemData->Void;
	
	// Callbacks for Menu Statuses ::
	// 
	// start    - Start button was pressed ( useful in pause menus, to close the menu )
	// back  	- The menu went back a page
	// rootback - When user wants to back out from the root menu
	// open   	- The menu was just opened
	// close  	- The menu was just closed, $param == SID just went off screen
	// pageOn 	- The page with $param == SID just went on screen
	// pageOff  - The page with $param == SID just went off screen
	//
	// The following types are mainly for sound effect handling from the user
	// ------
	// tick		   - An item was focused, The cursor moved.
	// tick_change - An item value has changed.
	// tick_fire   - An item was selected. ( button )
	// tick_error  - An item that cant be selected or changed
	public var callbacks_menu:String->String->Void;

	//====================================================;

	/**
	 * Constructor
	 * @param	X Screen X position, You cannot change this later
	 * @param	Y Screen Y position, You cannot change this later
	 * @param	WIDTH Must set a width
	 * @param	SlotsTotal Maximum slots for pages, unless overrided by a page
	 */
	public function new(X:Float, Y:Float, WIDTH:Int, SlotsTotal:Int = 4)
	{
		super();
		x = X; y = Y; width = WIDTH;
		slotsTotal = SlotsTotal;
		pages = new Map();
		
		// Default styles, can be overriden later
		styleMenu = Styles.newStyleVLMenu();
		styleHeader = {};
		
		// Default to not visible at start,
		// calling the showpage will make it visible
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
		popupCloseFunction = null;
	}//---------------------------------------------------;
	
	
	/**
	 * Apply a style to the menu
	 * @param	stMenu This must be a StyleVLMenu compatible object
	 * @param	stHeader This must be a styleHeader compatible object
	 */
	public function applyMenuStyle(stMenu:Dynamic,?stHeader:Dynamic)
	{
		Styles.applyStyleNodeTo(stMenu, styleMenu);
		if (stHeader != null) Styles.applyStyleNodeTo(stHeader, styleHeader);
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
		dynPages = FlxDestroyUtil.destroyArray(dynPages);
		pages = DEST.map(pages); 
		
	}//---------------------------------------------------;
	
	/**
	 * Quick way to create and add a page to the menu
	 * @param	pageSID Give the page a unique string Identifier
	 * @param	params Check PageData.hx for options
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
	 * @param	param New Data, e.g. { label:"NewLabel", disabled:false, current: }
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
	 * Shows a page that is already on the page map.
	 * Automatically opens the menu if it's closed.
	 * @param	page The SID of the page to open
	 * @param	autofocus If true the menu will acquire input focus
	 */
	public function showPage(Page:OneOfTwo<String,PageData>, autofocus:Bool = true)
	{	
		if (Std.is(Page, String))
		{
			var pageSID:String = Page;
			
			// Don't show the same page I am currently in
			if (history[history.length - 1] == pageSID) {
				trace("Warning: Can't go to the same page");
				return;
			}
			
			// Check to see if it's a dynamic page and retrieve it
			// usually when going back to a dyn page
			if (!pages.exists(pageSID)) 
			{
				var cp:PageData = null;
				if (pageSID.substr(0, 4) == "dyn_" && dynPages != null)
				{
					dynPages.map(function(pg){if (pg.SID == pageSID) cp = pg; });
				}
				
				if (cp == null) {
					trace('Error: Page with SID:"$pageSID" does not exist');
					return;
				}
				
				currentPage = cp;
				
			}else
			{
				currentPage = pages.get(pageSID);
			}
			
		}else{ // It must be PageData
			
			currentPage = Page;
			currentPage.custom._dynamic = true;
			currentPage.SID = 'dyn_${currentPage.UID}';
			
			if (dynPages == null) dynPages = [];
			dynPages.push(currentPage);
			if (dynPages.length > dynPagesMax) dynPages.shift();
		}

		// 1. Set the previous, current values
		previousMenu = currentMenu;
		currentMenu = null;
		
		// 2. Now, call focus, this way it won't actually focus the currentMenu yet		
		if (autofocus) {
			if (!visible) _mcallback("open");
			visible = true;
			isFocused = true; // Don't call focus(); I need a hacky way to do this.
		}
		// 3. Store the cursor position and push the old page to the POOL
		if (previousMenu != null) {
			// Store the cursor position
			if (flag_remember_cursor_position) {
				previousMenu.page.custom._cursorLastUID = previousMenu.getCurrentItemData().UID;
			}
			poolStore(previousMenu);
			_mcallback("pageOff", previousMenu.page.SID);
			// It's going to be removed later, when the transition ends.
		}

		history.push(currentPage.SID);	// Last history entry is always the current page

		// 4. Get the new menu
		currentMenu = poolGetOrNew(currentPage);
		currentMenu.callbacks = _listCallbacks;
		
		// :: Set the cursor Position
		_sub_InitCursorPos();
		
		// :: Header Check 
		//	  Creates the header, but it's not visible yet
		_sub_CheckAndSetHeader();
		
		// :: Animating pages in and out
		//    Figure out the animation type
		//	  If the FlxMenu is focused, then the new menu 
		//	  is going to be autofocused at the end of the animation.
		animQ.reset();
		
		switch(currentMenu.styleMenu.pageEnterStyle)
		{
			case "wait":
				animQ.push(animQ_previousOffScreen);
				animQ.push(function() { _mcallback("pageOn", currentPage.SID); animQ.next(); } );
				animQ.push(animQ_currentOnScreen);
				animQ.next(); // start the queue
				
			case "parallel":
				_mcallback("pageOn", currentPage.SID);
				animQ.push(animQ_previousOffScreen);
				animQ.push(animQ_currentOnScreen);
			default: // "none":
				_mcallback("pageOn", currentPage.SID);
				animQ.push(animQ_previousRemove);
				animQ.push(animQ_currentOnScreen);
		}
		
		animQ.next();
		
	}//---------------------------------------------------;
	
	/**
	 * Closes the menu and loses input focus
	 * @param	flagRememberPos If true, then when you call open() the current selected menu will be selected
	 */
	public function close(flagRememberPos:Bool = false)
	{
		if (!visible) return;
		visible = false;
		
		if (decoLine != null) decoLine.stop();
		if (headerText != null) headerText.stop();
		
		_mcallback("close", currentPage != null?currentPage.SID:null);
		
		if (flagRememberPos && currentPage!=null)
		{
			var d1 = currentMenu.getCurrentItemData();
			if (d1 != null) currentPage.custom._cursorLastUID =	d1.UID;
		}
		
		// Unload current menus
		if (currentMenu != null) {
			currentMenu.clearTweens();	// In some cases the menu is animating with a callback
			currentMenu.visible = false;
			currentMenu.unfocus();
			currentMenu = null;
		}
		
		if (popupCloseFunction != null)
			popupCloseFunction();
		
		currentPage = null;
		history = [];
	}//---------------------------------------------------;

	/**
	 * Input focus
	 */
	public function focus()
	{
		if (isFocused || !visible) return;
		
		// A popup is active. Don't focus the menu
		if (popupCloseFunction != null) return;
		
			isFocused = true;
		
		if (currentMenu != null) {
			// Fix: If called right after a showpage()
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
		if (popupCloseFunction != null) return;
		
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
			trace("Info: No more pages in history");
			_mcallback("rootback");
			return;
		}
	
		_mcallback("back");
		
		// The very last element is the current page, Skip it.
		history.pop();
		showPage(history.pop());
	}//---------------------------------------------------;
	
	/**
	 * Go to the first page of the history queue
	 */
	public function goHome()
	{
		if (popupCloseFunction != null) return;
		
		if (history.length <= 1) {
			trace("Info: No more pages in history");
			return;
		}
		
		var p = history[0];
		pages[p].custom._cursorLastUID = null;
		history = [];
		showPage(p);
	}//---------------------------------------------------;
		
	
	//====================================================;
	// POOL FUNCTIONS 
	//====================================================;
	
	// --
	// Store the menu in the pool for future use
	function poolStore(el:VListMenu)
	{
		_pool.push(el);
		
		if (_pool.length > POOLED_MENUS_MAX) {
			_pool.shift().destroy();
			trace("Info: Destroyed last page element");
		}
	}//---------------------------------------------------;
	
	// --
	// Get a ListMenu object,
	// Search the pool first and get if from there, else create it
	function poolGetOrNew(P:PageData):VListMenu
	{		
		for (i in _pool) {
			if (i.page.SID == P.SID) {
				_pool.remove(i);
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
	// This MItemData triggered a select
	function _listCallbacks(status:String, o:MItemData)
	{	
		// Before sending to the user, filter some calls
		
		// Check the links for internal calls
		if (status == "fire" && o.type == "link")
		{
			if (o.data.fn == "page") 
			{
				if (o.SID == "back") {
					goBack();
				}else {
					_mcallback("tick_fire"); // new
					showPage(o.SID);
				}
				return;
				
			}else if (o.data.fn == "call")
			{
				if (o.data.conf_active) 
				{
					if(o.data.conf_style == "full")
						_sub_confirmFullPage(o);
					else // popup
						_sub_confirmCurrentOption();
					
				}else {
					_ocallback("fire", o);
				}
				return;
			}
		}
		
		// Is this a general request? ( from a button press )
		if (status == "back")
		{
			goBack();
			return;
		}
		
		if (status == "start" && flag_start_button_ok)
		{
			if (currentMenu.currentElement != null)
				currentMenu.currentElement.sendInput("fire");
			return;
		}
		
		// Internal check complete, push calls to the user.
		if (o == null) {
			_mcallback(status);
		}else {
			_ocallback(status, o);
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
		showPage(questionPageID);
	}//---------------------------------------------------;
	
	
	// When a new page is loaded
	// Set the pointing cursor position to whatever it needs to
	// depending on the settings.
	// -- If for any reason it fails, the cursor goes to the first available elem
	// --
	function _sub_InitCursorPos()
	{
		var r1:Int; // Temp INT holder
		
		// If the page needs the cursor to always point to a specific item:
		// This gets priority
		if (currentPage.custom.cursorStart != null) {
			r1 = currentMenu.getItemIndexWithField("SID", currentPage.custom.cursorStart);
			_sub_SetCursToPos(r1); // will check for -1 there
			return;
		}
		
		// If the cursor needs to go back to where it was
		if (currentPage.custom._cursorLastUID != null) {
			r1 = currentMenu.getItemIndexWithField("UID", currentPage.custom._cursorLastUID);
			// Reset the cursorLastUID, because I used it.
			currentPage.custom._cursorLastUID = null;
			_sub_SetCursToPos(r1); // will check for -1 there
		}else {
			currentMenu.setViewIndex(currentMenu.findNextSelectableIndex(0));
		}
		
	}//---------------------------------------------------;
	
	// Quick point cursor to an item with SID
	// --
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
				var ts = DataTool.defParams(styleHeader.textS, {
					font:styleMenu.font,
					fontSize:styleMenu.fontSize,
					color:styleMenu.color_accent, // <<-TODO
					color_border:styleMenu.color_border,
					border_size:-1
				});
				
				styleHeader = DataTool.defParams(styleHeader, {
					enable:true,
					CPS:25, deco_line:1,
					offset:-2,
					offsetText:0,
					alignment: styleMenu.alignment
				}); var sh = styleHeader;
				f_use_header = sh.enable;
				if (!f_use_header) return;
				
				// Where the line should start
				var ystart = y - 2 + sh.offset - sh.deco_line;
				
				// Text --
				headerText = new FlxAutoText(x, 0, width, 1);
				Styles.applyTextStyle(headerText.textObj, ts);
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
			headerText.visible = true;
			
			if (decoLine != null) {
				decoLine.visible = true;
				decoLine.start(styleMenu.stw_el_time * 2);
			}
			
		}else
		{
			if (headerText != null) {
				headerText.clearAndWait();
				headerText.visible = false;
				if (decoLine != null) decoLine.visible = false;
			}
		}
		
	}//---------------------------------------------------;
	
	
	// --
	// Create a popup YESNO question, getting data from the MItemData
	function _sub_confirmCurrentOption()
	{
		if (currentMenu == null) return;
		var opt = currentMenu.getCurrentItemData();
		if (opt == null) return; // with error?
	
		var xpos = currentMenu.currentElement.x + currentMenu.currentElement.width;
		var ypos = currentMenu.currentElement.y;
	
		popup_YesNo(xpos, ypos, function(b:Bool) {
			if (b) { _ocallback("fire", opt); } else { _mcallback("back"); }
		}, opt.data.conf_question, opt.data.conf_options);
		
	}//---------------------------------------------------;
	

	/**
	 * Confirm action for currently selected item
	 * 
	 * @param	qcallback Callback to this function with a result
	 * @param	question If set it will display this text
	 * @param	options Custom names instead of YES,NO
	 */
	@:access(djFlixel.gui.list.VListNav.setInputFocus)
	public function popup_YesNo(X:Float, Y:Float, qcallback:Bool->Void, ?question:String, ?yesno:Array<String>):Void
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
		popupCloseFunction = function() {
			list.offScreen(function() { remove(list); list.destroy(); list = null; } );
			remove(bg); bg.destroy();
			popupCloseFunction = null; // Important to do this
			if (currentMenu != null) currentMenu.setInputFocus(true);
		}
		
		// -- Popup Callbacks
		list.callbacks = function(s:String, o:MItemData) 
		{
			if (s == "fire") {
				popupCloseFunction();
				qcallback((o.SID == "yes"));
				return;
			}
			else if (s == "back") {
				popupCloseFunction();
				_mcallback("back");
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
		
		_mcallback("tick_fire"); // For the sound effect?
	}//---------------------------------------------------;
	
	//====================================================;
	// Getters Setters
	//====================================================;
	
	//--
	// Can return NULL
	public function get_currentElement():MItemBase
	{
		if (currentMenu != null) 
		return currentMenu.currentElement;
		return null;
	}//---------------------------------------------------;
	
	//--
	// Can return Empty String
	public function get_currentPageName():String
	{
		if (currentPage != null) return currentPage.SID; else return "";
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
	
	// --
	function _ocallback(s:String, ?o:MItemData) 
	{
		// new: Call the menu callback as well to handle sounds
		switch(s) {
			case "fire": 
				_mcallback("tick_fire");
				if (o.type == "link" && o.data.callback != null) {
					o.data.callback();
				}
			case "change": _mcallback("tick_change");
			case "invalid": _mcallback("tick_error"); return;	// do not proceed
		}
		
		if (currentPage.custom.callbacks_item != null){
			currentPage.custom.callbacks_item(s, o);
			return;
		}
		
		if (callbacks_item != null) callbacks_item(s, o);
		
	}//---------------------------------------------------;
	
	// -- Quickly check for null and call
	inline function _mcallback(msg:String, ?data:String) 
	{
		if (callbacks_menu != null) {
			callbacks_menu(msg, data);
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
		currentMenu.onScreen(isFocused, animQ.next);
	}//---------------------------------------------------;
	
	// -- Animate off the previous screen
	function animQ_previousOffScreen():Void
	{
		if (previousMenu != null) {
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
		return 	'Pages Total : $np | Dyn Pages Total : ${dynPages.length} |' +
				'History Length : ${history.length} | Pool Length : ${_pool.length} | Current Page : $currentPageName';
	}//---------------------------------------------------;
	#end
	
}// -- end -- //