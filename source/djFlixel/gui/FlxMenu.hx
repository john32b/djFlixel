package djFlixel.gui;
import djFlixel.SimpleCoords;
import djFlixel.gui.Styles;
import djFlixel.gui.Styles.OptionStyle;
import djFlixel.gui.Styles.VListStyle;
import djFlixel.gui.list.VListMenu;
import djFlixel.gui.listoption.MenuOptionBase;
import djFlixel.tool.ArrayExecSync;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;

/**
 * FLXMenu
 * ...
 * =- Notes
 * =---------
 * . New version uses VListBase
 * . The height can be variable.
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
	
	// Whether is is going on or off right now
	var isAnimating:Bool;
	
	// How many slots the lists should have, unless overriden by a page.
	var slotsTotal:Int;
	//---------------------------------------------------;

	// *Pointer to the current active VList
	var currentMenu:VListMenu;

	// *Pointer to the previous page, useful for animating
	var previousMenu:VListMenu;
	
	// Hold all the pages data this menu is going to use
	public var pages(default, null):Map<String,PageData>;
	
	// Pointer to the current loaded page.
	var currentPage:PageData;
	
	public var currentPageName(get, null):String;
	
	// A queue of page IDs
	var history:Array<String>;
	
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
	
	// The Header will have the same style as an option
	public var styleHeader:OptionStyle;

	// When you are going back to menus, remember the position it came from
	public var flag_remember_cursor_position:Bool = true;
	
	// If true, then the start button will fire the selected option
	public var flag_start_button_ok:Bool = false;
	
	// Allow mouse interaction with the menu options
	public var flag_use_mouse:Bool = true;
	
	// ==  User callbacks
	// -------------------==

	// optFocus  - A new option has been focused <sends option>
	// optChange - When an option changed value, <sends option>
	// optFire   - An option recieved an action command
	public var callbacks_option:String->OptionData->Void;
	
	// start    - Start button was pressed ( useful in pause menus, to close the menu )
	// back  	- The menu went back a page
	// rootback - When user wants to back out from the root menu
	// open   	- The menu was just opened
	// close  	- The menu was just closed
	// pageOn 	- The page with $param == SID just went on screen
	// pageOff  - The page with $param == SID just went off screen
	
	// The following types are mainly for sound effect handling from the user
	// ------
	// tick		   - An option was focused, The cursor moved.
	// tick_change - An option value has changed.
	// tick_fire   - An option was selected. ( button )
	// tick_error  - An option that cant be selected or changed
	public var callbacks_menu:String->String->Void;
	
	//---------------------------------------------------;
	
	// Popup close fn, useful to have as global, in case the menu needs to close
	var popupCloseFunction:Void->Void;
	
	
	// Keep maximum 4 menus in the pool
	var POOLED_MENUS_MAX:Int = 4;
	// --
	var _pool:Array<VListMenu>;
	
	// -- Header text displayed on top of the list (optional)
	var headerText:FlxText;
	
	// -- Animation helper
	var animQ:ArrayExecSync < (Void->Void)->Void > ;

	//====================================================;

	/**
	 * Constructor
	 * @param	X
	 * @param	Y
	 * @param	WIDTH 0 for auto width
	 * @param	SlotsTotal
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
		
		// - Tweak the font size
		styleHeader.fontSize = 16;
		
		// Default to not visible at start,
		// calling the showpage will autovisible this.
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
	 * Apply a style that is set on the main PARAMS.JSON file
	 * @param styleID Name of the style, Check the examples for formatting.
	 */
	public function applyMenuStyleFromJSON(styleID:String)
	{
		var styleNode = Reflect.getProperty(Reg.JSON, styleID);
		if (styleNode == null) {
			trace('Warning: Can\'t find style "$styleID" in the json file');
			return;
		}
		Styles.applyStyleNodeTo(styleNode.option, styleOption);
		Styles.applyStyleNodeTo(styleNode.list, styleList);
		Styles.applyStyleNodeTo(styleNode.base, styleBase);
		Styles.applyStyleNodeTo(styleNode.header, styleHeader);
	}//---------------------------------------------------;
	
	// Get a style node from the JSON file, and set it to a Page
	// node.list, node.base, node option
	public function applyPageStyleFromJson(styleID:String, page:PageData)
	{
		var styleNode = Reflect.getProperty(Reg.JSON, styleID);

		if (styleNode.option != null) {
			page.custom.styleOption = Styles.newStyle_Option();
			Reg.applyFieldsInto(styleNode.option, page.custom.styleOption);
		}
		
		if (styleNode.list != null) {
			page.custom.styleList = Styles.newStyle_List();
			Reg.applyFieldsInto(styleNode.list, page.custom.styleList);
		}
		
		if (styleNode.base != null) {
			page.custom.styleBase = Styles.newStyle_Base();
			Reg.applyFieldsInto(styleNode.base, page.custom.styleBase);
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
	}//---------------------------------------------------;
	
	// --
	// Quick way to create and add a page to the menu
	public function newPage(pageSID:String,?params:Dynamic)
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
	 * Update the data on an option,
	 * 
	 * @param	pageSID You must provide the pageSID the option is in
	 * @param	SID SID of the option
	 * @param	param New Data, e.g. { label:"NewLabel", disabled:false }
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
	
	// --
	public function showPage(pageSID:String, autofocus:Bool = true)
	{
		if (isAnimating) return;
		
		// trace('Request to show page [$pageSID]');
		
		// Don't show the same page I am currently in
		if (history[history.length - 1] == pageSID) {
			trace("Warning: Can't go to the same page");
			return;
		}
		
		if (pages.exists(pageSID) == false) {
			trace('Error: Page with ($pageSID) does not exist');
			return;
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

		currentPage = pages.get(pageSID);
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
		//	  is going to be autofocused at he end of the animation.
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
	
	// --
	public function close()
	{
		if (visible) {
			visible = false;	
			_mcallback("close");
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

	// --
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
	
	// --
	public function unfocus()
	{
		if (!isFocused) return;
			isFocused = false;
			
		if (currentMenu != null) {
			currentMenu.unfocus();
		}
		
	}//---------------------------------------------------;
	
	// --
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
	
	// --
	// Go to the first page of the history queue
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
		//trace("Pushing Element in the pool");
		_pool.push(el);
		
		if (_pool.length > POOLED_MENUS_MAX) {
			_pool.shift().destroy();
			trace("Info: Destroyed last page element");
		}
		
		// Quick pool check
		// #if debug
			// trace('Pool Length = ${_pool.length}');
			// var d_pages:String = "";
			// for (i in _pool) {
			// 	d_pages += '${i.page.SID} ,';
			// }
			// trace("Pool contents: " , d_pages);
		// #end
	}//---------------------------------------------------;
	
	// --
	// Get a ListMenu object,
	// Search the pool first and get if from there
	// , else create it
	function poolGetOrNew(P:PageData):VListMenu
	{		
		for (i in _pool) {
			if (i.page.SID == P.SID) {
				_pool.remove(i);
				return i;
			}
		}
		
		// -----
		
		// Creating the new page
		// trace('Info: [${P.SID}] does not exist in the pool, creating...');
		// #Style
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
				p.link(o.data.conf_options[0], o.data.link);
				p.link(o.data.conf_options[1], "@back");
				p.custom.cursorStart = 'back'; // Highlight BACK first
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
		// trace('== Initializing Cursor pos for menu [${currentPage.SID}]');
		
		var r1:Int; // Temp INT holder
		
		// If the page needs the cursor to always point to a specific option:
		// This gets priority
		if (currentPage.custom.cursorStart != null) {
			// trace('Cursor, custom start');
			r1 = currentMenu.getOptionIndexWithField("SID", currentPage.custom.cursorStart);
			_sub_SetCursToPos(r1);
			return;
		}
		
		// If the cursor needs to go back to where it was
		if (flag_remember_cursor_position && currentPage.custom._cursorLastUID != null) {
			// trace('Cursor, get last position');
			r1 = currentMenu.getOptionIndexWithField("UID", currentPage.custom._cursorLastUID);
			_sub_SetCursToPos(r1);
		}else {
			// trace('Cursor, from the top');
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
			headerText.fieldWidth = currentMenu.width;	
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
	
	// --
	// Confirm action for currently selected option

	/**
	 * @param	qcallback Callback to this function with a result
	 * @param	question If set it will display this text
	 * @param	options Custom names instead of YES,NO
	 */
	public function popup_YesNo(X:Int, Y:Int, qcallback:Bool->Void, ?question:String, ?yesno:Array<String>):Void
	{
		if (yesno == null) yesno = ["Yes", "No"];
		if (yesno.length != 2) { trace("Error: yesno must have exactly 2 strings"); return; }
		
		if (currentMenu != null) currentMenu.setInputFocus(false);

		// -- Create a list and adjust the style a bit ::
		var list = new VListMenu(X, Y, 0, question != null?3:2);
			list.flag_InitViewAfterDataSet = false;
			list.styleBase = Styles.newStyle_Base();
			list.styleBase.anim_tween_ease = "elastic";
			list.styleBase.anim_total_time = 0.2;
			list.styleOption = Reflect.copy(styleOption);
			list.styleOption.fontSize = Std.int(list.styleOption.fontSize / 2);
			
		var p:PageData = new PageData("question");
			if (question != null) p.add(question, { type:"label" } );
			p.link(yesno[0], "yes");
			p.link(yesno[1], "no");
			
		// --
		list.setPageData(p);
		list.option_highlight("no"); 
		
		// -- Add a small obg
		var bg = new FlxSprite(X - 2, Y - 2);
			bg.makeGraphic(list.width + 4, list.height + 8, list.styleOption.border_color);
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
	//  Small API
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
			case "optFire": _mcallback("tick_fire");
			case "optChange": _mcallback("tick_change");
			case "optInvalid": _mcallback("tick_error"); return;	// do not proceed
		}
		
		if (currentPage.custom.callbacks_option != null){
			currentPage.custom.callbacks_option(s, o);
			return;
		}
		
		if (callbacks_option != null) callbacks_option(s, o);
	}//---------------------------------------------------;
	
	// --
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