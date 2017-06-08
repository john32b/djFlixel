package djFlixel.gui;
import djFlixel.SimpleCoords;
import djFlixel.gui.Styles;
import djFlixel.gui.Styles.OptionStyle;
import djFlixel.gui.Styles.VListStyle;
import djFlixel.gui.list.VListMenu;
import djFlixel.gui.listoption.MenuOptionBase;
import djFlixel.tool.ArrayExecSync;
import djFlixel.tool.DataTool;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.typeLimit.OneOfTwo;

/**
 * FlxMenu
 * A multi-page customizable menu system that can hold various element types
 * -------
 * 
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
	
	// Whether is is going on or off right now
	var isAnimating:Bool;
	
	// How many slots the lists should have, unless overriden by a page.
	var slotsTotal:Int;
	//---------------------------------------------------;

	// *Pointer to the current active VList
	var currentMenu:VListMenu;

	// *Pointer to the previous page, useful for animating
	var previousMenu:VListMenu;
	
	// Hold all the page data this menu is going to use
	public var pages(default, null):Map<String,PageData>;
	
	// Pointer to the current loaded page.
	var currentPage:PageData;
	
	// --
	public var currentPageName(get, null):String;
	
	// A queue of page IDs
	var history:Array<String>;
	
	// Popup close fn, useful to have as global, in case the menu needs to close
	var popupCloseFunction:Void->Void;
	
	// Keep a small pool of Pages so it doesn't have to recreate them
	var _pool:Array<VListMenu>;
	
	// -- Header text displayed on top of the list (optional)
	var headerText:FlxText;
	
	// -- Animation helper
	var animQ:ArrayExecSync < (Void->Void)->Void > ;
	
	// Hold the latest dynamic pages in case it needs to go back to them
	var dynPages:Array<PageData>;
	
	// Hold this many dynamic pages in the buffer.
	public var dynPagesMax:Int = 3;
	
	// ===---- USER ----===
	// =------------------=
	
	// Global list style for all menus, unless a page overrides this
	// NULL to use the default style, Set right after creating
	public var styleList:VListStyle;
	
	// Global option list style for all optionMenus, unless a page overrides this
	// NULL to use the default style, Set right after creating
	public var styleOption:OptionStyle;
	
	// Global option list style for all optionMenus, unless a page overrides this
	// NULL to use the default style, Set right after creating
	public var styleBase:VBaseStyle;
	
	// The Header defaults to the style as an option
	public var styleHeader:OptionStyle;

	// When you are going back to menus, remember the position it came from
	public var flag_remember_cursor_position:Bool = true;
	
	// If true, then the start button will fire the selected option
	public var flag_start_button_ok:Bool = false;
	
	// Allow mouse interaction with the menu options
	public var flag_use_mouse:Bool = true;
	
	// Keep X maximum menus in the pool. !! SET THIS RIGHT AFTER NEW() !!
	public var POOLED_MENUS_MAX:Int = 4;
	
	//---------------------------------------------------;
	
	
	// ==  User callbacks
	// -------------------==
	
	// optBlur   - This option was just unfocused // Unimplemented. need to add it. VListNav
	// optFocus  - A new option has been focused <sends option>
	// optChange - When an option changed value, <sends option>
	// optFire   - An option recieved an action command
	public var callbacks_option:String->OptionData->Void;
	
	// start    - Start button was pressed ( useful in pause menus, to close the menu )
	// back  	- The menu went back a page
	// rootback - When user wants to back out from the root menu
	// open   	- The menu was just opened
	// close  	- The menu was just closed, $param == SID just went off screen
	// pageOn 	- The page with $param == SID just went on screen
	// pageOff  - The page with $param == SID just went off screen
	
	// The following types are mainly for sound effect handling from the user
	// ------
	// tick		   - An option was focused, The cursor moved.
	// tick_change - An option value has changed.
	// tick_fire   - An option was selected. ( button )
	// tick_error  - An option that cant be selected or changed
	public var callbacks_menu:String->String->Void;

	//====================================================;

	/**
	 * Constructor
	 * @param	X Screen X position, You cannot change this later
	 * @param	Y Screen Y position, You cannot change this later
	 * @param	WIDTH 0 for auto width
	 * @param	SlotsTotal Maximum slots for pages, unless overrided by a page
	 */
	public function new(X:Float, Y:Float, WIDTH:Int, SlotsTotal:Int = 4)
	{
		super();
		x = X; y = Y; width = WIDTH;
		slotsTotal = SlotsTotal;
		pages = new Map();
		
		// Default styles, can be overriden later
		styleOption = Styles.newStyle_Option();
		styleList   = Styles.newStyle_List();
		styleBase   = Styles.newStyle_Base();
		styleHeader = Styles.newStyle_Option();
		
		// - Tweak the font size, User can change it later
		styleHeader.size = 16;
		
		// Default to not visible at start,
		// calling the showpage will make it visible
		visible = false;
		
		// --
		_pool = [];
		history = [];
		currentMenu = null;
		previousMenu = null;
		currentPage = null;	
		
		animQ = new ArrayExecSync<(Void->Void)->Void>();
		animQ.queue_complete = animQ_onComplete;
		animQ.queue_action = function(fn:(Void->Void)->Void) { fn(animQ.next); };
		popupCloseFunction = null;
	}//---------------------------------------------------;
	

	/**
	 * Apply a style to the menu
	 * @param	node An object containing 4 optional nodes { .option .list .base .header }
	 */
	public function applyMenuStyle(node:Dynamic)
	{
		Styles.applyStyleNodeTo(node.option, styleOption);
		Styles.applyStyleNodeTo(node.list, styleList);
		Styles.applyStyleNodeTo(node.base, styleBase);
		Styles.applyStyleNodeTo(node.header, styleHeader);
	}//---------------------------------------------------;
	
	/**
	 * Apply a style that is set on the main PARAMS.JSON file
	 * @param styleID Name of the style, Check the examples for formatting.
	 */
	@:deprecated("Use ApplyMenuStyle instead")
	public function applyMenuStyleFromJSON(styleID:String)
	{
		var styleNode = Reflect.getProperty(FLS.JSON, styleID);
		if (styleNode == null) {
			trace('Warning: Can\'t find style "$styleID" in the json file');
			return;
		}
		applyMenuStyle(styleNode);
	}//---------------------------------------------------;
	

	/**
	 * Apply a custom style to a page, nodes will overwrite the default style
	 * @param	node An object containing {.list .base .option} styles
	 * @param	page The page to apply the style to
	 */
	@:deprecated("This function is useless, Just set the overrides directly in the page.custom object")
	public function applyPageStyle(styleNode:Dynamic, page:PageData)
	{
		if (styleNode.option != null) {
			page.custom.styleOption = Styles.newStyle_Option();
			DataTool.applyFieldsInto(styleNode.option, page.custom.styleOption);
		}
		
		if (styleNode.list != null) {
			page.custom.styleList = Styles.newStyle_List();
			DataTool.applyFieldsInto(styleNode.list, page.custom.styleList);
		}
		
		if (styleNode.base != null) {
			page.custom.styleBase = Styles.newStyle_Base();
			DataTool.applyFieldsInto(styleNode.base, page.custom.styleBase);
		}
	}//---------------------------------------------------;
	
	
	// --
	override public function destroy():Void 
	{
		super.destroy();
		
		history = null;
		currentMenu = null;
		previousMenu = null;
		currentPage = null;
		
		styleBase = null;
		styleHeader = null;
		styleList = null;
		styleOption = null;
		
		for (e in _pool) {
			e.destroy();
			e = null;
		}
		_pool = null;
		
		for (i in pages) {
			i.destroy();
			i = null;
		}
		pages = null;
		
		for (p in dynPages) p.destroy();
	}//---------------------------------------------------;
	
	// --
	// Quick way to create and add a page to the menu
	public function newPage(pageSID:String, ?params:Dynamic):PageData
	{
		var p = new PageData(pageSID, params);
		pages.set(pageSID, p);
		return p;
	}//---------------------------------------------------;
	
	// --
	// Highlight an option of a target SID
	public function option_highlight(sid:String)
	{
		if (currentMenu == null) return;
		currentMenu.option_highlight(sid);
	}//---------------------------------------------------;
	
	/**
	 * Update the data on an option, alters Data and updates Visual
	 * 
	 * @param	pageSID You must provide the pageSID the option is in
	 * @param	SID SID of the option
	 * @param	param New Data, e.g. { label:"NewLabel", disabled:false, current: }
	 * 			note: will work with fields inside the option.data as well
	 */
	public function option_updateData(pageSID:String, SID:String, param:Dynamic)
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
			a.option_updateData(SID, param);
		}else {
			// It is not in the pool,
			// Alter the option data
			if (pages.exists(pageSID)) {
				var o:OptionData = pages.get(pageSID).get(SID);
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
			
			if (!pages.exists(pageSID)) 
			{
				var cp:PageData = null;
				// Check if its a dynamic page
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

		// -- ORDERING IS IMPORTANT
		// 1. Set the previous, current values
		previousMenu = currentMenu;
		currentMenu = null;

		// 2. Now, call focus, this way it won't actually focus the currentMenu yet		
		if (autofocus) {
			focus();	
		}
		
		// 3. Store the cursor position and push the old page to the POOL
		if (previousMenu != null) {
			// Store the cursor position
			if (flag_remember_cursor_position) {
				previousMenu.page.custom._cursorLastUID = previousMenu.getCurrentOptionData().UID;
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
		
		switch(currentMenu.styleBase.anim_style)
		{
			case "sequential":
				animQ.push(animQ_previousOffScreen);
				animQ.push(function(fn:Void->Void) { _mcallback("pageOn", currentPage.SID); fn(); } );
				animQ.push(animQ_currentOnScreen);
				animQ.next(); // start the queue
				
			case "parallel":
				_mcallback("pageOn", currentPage.SID);
				animQ_previousOffScreen(_NL);
				animQ_currentOnScreen(animQ_onComplete);				
			default: // "none":
				_mcallback("pageOn", currentPage.SID);
				animQ_previousRemove(_NL);
				animQ_currentOnScreen(animQ_onComplete);
		}
		
		if (!visible)
		{
			visible = true;
			_mcallback("open");
		}
		
	}//---------------------------------------------------;
	
	/**
	 * Closes the menu and loses input focus
	 * @param	flagRememberPos If true, then when you call open() the current selected menu will be selected
	 */
	public function close(flagRememberPos:Bool = false)
	{
		if (visible) {
			visible = false;
			_mcallback("close", currentPage != null?currentPage.SID:null);
		}else return; // Already closed
		
		if (flagRememberPos && currentPage!=null)
		{
			var d1 = currentMenu.getCurrentOptionData();
			if (d1 != null) currentPage.custom._cursorLastUID =	d1.UID;
		}
		
		// Unload current menus
		if (currentMenu != null) {
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
		if (isFocused) return;
			isFocused = true;
		
		if (!visible)
		{
			visible = true;
			_mcallback("open");
		}
		
		if (currentMenu != null) {
			// Fix: If called right after a showpage()
			//	    And the menu is animating, it can't be focused due bugs.
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
			m.styleList = styleList;
			m.styleOption = styleOption;
			m.styleBase = styleBase;
			m.cameras = [camera];
			m.setPageData(P);

		return m;
		
	}//---------------------------------------------------;
	
	
	//====================================================;
	// Callback Handler 
	//====================================================;
	
	// --
	// This optiondata triggered a select
	function _listCallbacks(status:String, o:OptionData)
	{	
		// Before sending to the user, filter some calls
		
		// Check the links for internal calls
		if (status == "optFire" && o.type == "link")
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
					_ocallback("optFire", o);
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
	function _sub_confirmFullPage(o:OptionData)
	{
		var questionPageID:String = "_conf_" + o.SID;
		if (!pages.exists(questionPageID)) {
			var p:PageData = new PageData(questionPageID);
				p.add(o.data.conf_question, { type:"label" } );
				p.link(o.data.conf_options[0], o.SID);
				p.link(o.data.conf_options[1], "@back");
				p.custom.cursorStart = 'back'; // Highlight BACK first
				if (o.data.styleOption != null) p.custom.styleOption = o.data.styleOption;
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
		
		// If the page needs the cursor to always point to a specific option:
		// This gets priority
		if (currentPage.custom.cursorStart != null) {
			r1 = currentMenu.getOptionIndexWithField("SID", currentPage.custom.cursorStart);
			_sub_SetCursToPos(r1); // will check for -1 there
			return;
		}
		
		// If the cursor needs to go back to where it was
		if (currentPage.custom._cursorLastUID != null) {
			r1 = currentMenu.getOptionIndexWithField("UID", currentPage.custom._cursorLastUID);
			// Reset the cursorLastUID, because I used it.
			currentPage.custom._cursorLastUID = null;
			_sub_SetCursToPos(r1); // will check for -1 there
		}else {
			currentMenu.setViewIndex(currentMenu.findNextSelectableIndex(0));
		}
		
	}//---------------------------------------------------;
	
	// Quick point cursor to an option with SID
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
		if (currentPage.header != null) {
			
			// Create the header if it's not already
			if (headerText == null)
			{
				headerText = new FlxText();
				headerText.x = x;
				headerText.cameras = [camera];
				headerText.scrollFactor.set(0, 0);
				Styles.styleOptionText(headerText, styleHeader);
				// Header styling is a WIP
				headerText.color = styleHeader.color_default;
				add(headerText);
			}
			
			// Set this now because it could be autogenerated
			// headerText.fieldWidth = currentMenu.width;	// Remove width restriction?
			headerText.text = currentPage.header;
			headerText.y = this.y - headerText.height;
			headerText.visible = true;
		}else
		{
			if (headerText != null)
			{
				headerText.text = "";
				headerText.visible = false;
			}
		}
		
	}//---------------------------------------------------;
	
	
	// --
	// Create a popup YESNO question, getting data from the optionData
	function _sub_confirmCurrentOption()
	{
		if (currentMenu == null) return;
		var opt:OptionData = currentMenu.getCurrentOptionData();
		if (opt == null) return; // with error?
	
		var xpos:Int = cast currentMenu.currentElement.x + currentMenu.currentElement.width;
		var ypos:Int = cast currentMenu.currentElement.y;
	
		popup_YesNo(xpos, ypos, function(b:Bool) {
			if (b) { _ocallback("optFire", opt); } else { _mcallback("back"); }
		}, opt.data.conf_question, opt.data.conf_options);
		
	}//---------------------------------------------------;
	

	/**
	 * Confirm action for currently selected option
	 * 
	 * @param	qcallback Callback to this function with a result
	 * @param	question If set it will display this text
	 * @param	options Custom names instead of YES,NO
	 */
	@:access(djFlixel.gui.list.VListNav.setInputFocus)
	public function popup_YesNo(X:Int, Y:Int, qcallback:Bool->Void, ?question:String, ?yesno:Array<String>):Void
	{
		if (yesno == null) yesno = ["Yes", "No"];
		if (yesno.length != 2) { trace("Error: yesno must have exactly 2 strings"); return; }
		
		if (currentMenu != null) currentMenu.setInputFocus(false);

		// -- Create a list and adjust the style a bit ::
		var list = new VListMenu(X, Y, 0, question != null?3:2);
			list.flag_InitViewAfterDataSet = false; // because option_highlight() is called
			list.styleBase = Styles.newStyle_Base();
			list.styleBase.anim_tween_ease = "elastic";
			list.styleBase.anim_total_time = 0.2;
			list.styleOption = Reflect.copy(styleOption);
			list.styleOption.size = Std.int(list.styleOption.size / 2);
			
		var p:PageData = new PageData("question");
			if (question != null) p.add(question, { type:"label" } );
			p.link(yesno[0], "yes");
			p.link(yesno[1], "no");
			
		// --
		list.setPageData(p);
		list.option_highlight("no"); 
		
		// -- Add a small bg
		var bg:FlxSprite = new FlxSprite(X - 2, Y - 2);
		#if neko
			trace("Warning, Neko throws error when puting vars to makeGraphic");
			bg.makeGraphic(100, 40, list.styleOption.borderColor);
		#else
			bg.makeGraphic(list.width + 4, list.height + 8, list.styleOption.borderColor);
		#end
			bg.scrollFactor.set(0, 0);
		add(bg);
		
		// short call
		popupCloseFunction = function() {
			list.offScreen(function() { remove(list); list.destroy(); list = null; } );
			remove(bg);
			popupCloseFunction = null;
			if (currentMenu != null) currentMenu.setInputFocus(true);
		}
		
		// callback
		list.callbacks = function(s:String, o:OptionData) {
			// -- check the callbacks
			if (s == "optFire") {
				popupCloseFunction();
				qcallback((o.SID == "yes"));
				return;
			}else
			if (s == "back") {
				popupCloseFunction();
				_mcallback("back");
				return;
			}else
			if (s == "start") return;	// no start button
			
			// pass through all others
			_listCallbacks(s, o);
		};

		// -
		add(list);
		list.onScreen();
		_mcallback("tick_fire"); // For the sound effect?
	}//---------------------------------------------------;
	
	//====================================================;
	// Getters Setters
	//====================================================;
	
	//--
	// Can return NULL
	public function get_currentElement():MenuOptionBase
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
	function _ocallback(s:String, ?o:OptionData) 
	{
		// new: Call the menu callback as well to handle sounds
		switch(s) {
			case "optFire": 
				_mcallback("tick_fire");
				if (o.type == "link" && o.data.callback != null) {
					o.data.callback();
				}
			case "optChange": _mcallback("tick_change");
			case "optInvalid": _mcallback("tick_error"); return;	// do not proceed
		}
		
		if (currentPage.custom.callbacks_option != null){
			currentPage.custom.callbacks_option(s, o);
			return;
		}
		
		if (callbacks_option != null) callbacks_option(s, o);
		
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
	// --
	// -- These small functions only work with the animQ 
	//	  object. Meaning, that each function is responsible
	//	  for advancing the queue when finished

	// -- Animate on the current screen
	// --
	function animQ_currentOnScreen(then:Void->Void)
	{
		add(currentMenu);
		currentMenu.onScreen(isFocused, then);
	}//---------------------------------------------------;
	
	// -- Animate off the previous screen
	function animQ_previousOffScreen(then:Void->Void):Void
	{
		if (previousMenu != null) {
			previousMenu.offScreen(function() { 
				remove(previousMenu);
				then();
			});
		}
		else
		{
			then();
		}

	}//---------------------------------------------------;
	// -- Sudden remove the previous page
	function animQ_previousRemove(then:Void->Void)
	{
		if (previousMenu != null) {	
			previousMenu.unfocus();
			remove(previousMenu);
			previousMenu = null;
		}
		then();
	}//---------------------------------------------------;

	// --
	function animQ_onComplete():Void
	{
	}//---------------------------------------------------;
	
	// --
	function _NL():Void
	{
		// helper, send this to functions that require a callback
		// when you don't need a callback
	}//---------------------------------------------------;
	
}// -- end -- //