package djFlixel.gui.list;
import djFlixel.SimpleCoords;
import djFlixel.gui.Styles;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.tweens.misc.VarTween;
import flixel.util.FlxTimer;

import djFlixel.gui.listoption.*;
import djFlixel.gui.Styles.OptionStyle;
import djFlixel.gui.Styles.VListStyle;
import djFlixel.gui.OptionData;
import djFlixel.gui.PageData;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;


 /**
  * VlistMenu, Responsible for just one list,
  * Used by FlxMenu.
  **/	
 
class VListMenu extends VListBase<MenuOptionBase,OptionData>
{
	// Current selected data index. (max = _dataTotal)
//	@:allow(djFlixel.gui.FlxMenu)
//	var _indexData:Int;
	// Current selected slot index
//	var _indexSlot:Int;
	
	// * Pointer to the selected Option Element
//	@:allow(djFlixel.gui.FlxMenu)
//	var option_pointer:IListOption<OptionData>;
	
	// # Calculated and corrected option padding to use
	//   This is checked because the style's padding might be more than
	//	 the window's height.
//	var _pointer_padding:Int;
	
	// Pointer to a page data
	public var page(default, null):PageData;
	
	// ==-- _Conditionals --==
	// This is an early approach
	// .Ver 0.1
	// .In case this menu features conditionals, store their indexes
//	var _condIndexes:Array<Int>;
	
	// Conditional Check Method.
	// How often the conditional options will be checked.
	// once 	: check on creation,
	// onscreen : every time this page gets on screen. (INDEV, not implemented)
//	var _conditional_method:String;
	
	
//	// ==-- Cursor --==
//	// =--------------=
//	var cursor:FlxSprite;
//	var hasCursor:Bool;
//	// Keep the tween in case I want to cancel it
//	var cursorTween:VarTween;
//	var cursorIsAnimating:Bool;
//	
//	// Cursor position is auto-generated
//	var _cursor_x_end:Float;
//	var _cursor_x_start:Float;
//	var _cursor_y_offset:Float; // offset from the current elements's y position
//	var _cursor_tween_time:Float;
	
	// =-- Styles  --= 
	// =-------------=

	// General menu parameters
//	public var styleList:VListStyle;
	// Menu Option Styles, You can customize it.
//	public var styleOption:OptionStyle;
	
	// ==-- User callbacks --==
	// =----------------------=

	// Check FlxMenu for usability, it's almost the same.
//	public var callbacks:String->OptionData->Void;
	
	
//	// -- You can set this at any time
//	// Enables mouse interaction with the optionelements
//	public var flag_use_mouse:Bool = true;
//
//	// Precalculate camera viewport and scrolling for mouse overlap calculations
//	var _camCheckOffset:SimpleCoords;
	
	//====================================================;
	// FUNCTIONS
	//====================================================;
	
	/**
	 * 
	 * @param	X Position on the screen.
	 * @param	Y Position on the screen.
	 * @param	WIDTH Set to 0 to Fill Screen Width with some padding
	 * @param	SlotsTotal How many slots to show on the screen.
	 */
	public function new(X:Float, Y:Float, WIDTH:Int, ?SlotsTotal:Int) 
	{		
		// Because there are more than one types that can be attached to this.		
//		super(MenuOptionBase, X, Y, WIDTH, SlotsTotal);
//		pooling_mode = "reuse";
//		_indexData = -1;
//		_indexSlot = -1;
//		option_pointer = null;
//		_condIndexes = null;
//		_conditional_method = "once";
	}//---------------------------------------------------;
	// --
	override public function destroy():Void 
	{
		super.destroy();
		
//		if (cursorTween != null) {
//			cursorTween.cancel();
//			cursorTween = null;
//		}
//		styleOption = null;
//		option_pointer = null;
	}//---------------------------------------------------;
	
	// --
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
//		if (page.custom.styleList != null) {
//			styleList = page.custom.styleList;
//		}else {
//			// Usually when this is called from an FLXMenu, the style is set there.
//			// but in the case you create a VListMenu solo, it needs to be checked like so:
//			if (styleList == null) 
//				styleList = Styles.default_ListStyle;
//		}
		
//		// Set and check the pointer pad
//		_pointer_padding = styleList.scrollPad;
//		if (_pointer_padding > Math.floor(_slotsTotal / 2)) {
//			_pointer_padding = Math.floor(_slotsTotal / 2);
//			trace('Warning: StylePadding was ${styleList.scrollPad} and is off bounds ' +
//				  'SlotsTotal [$_slotsTotal].. Setting to ($_pointer_padding)');
//		}
//		
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
		
		// _Conditionals, just store the conditional indexes.
		// 				  in case I want to later recheck the validity
//		_condIndexes = [];
//		var cc:Int = 0;
//		while (cc < page.collection.length) {
//			if (page.collection[cc].data.conditional != null) {
//				_condIndexes.push(cc);
//				trace('Found conditional at index [$cc]');
//			}
//			cc++;
//		}
		
		// _Conditionals, ver 0.1, Just check for conds here
//		if (_conditional_method == "once") {
			// trace("Conditional checking ONCE");
//			_cond_checkAll();
//		}
		
		// -- Set and init the data after getting the styles.
		super.setDataSource(page.collection);
	
		// -- Recalculate the first selected option
		//	  because it might be unselectable.
		
		// - Apply Cursor
//		if (styleList.cursorSymbol != null) {
//			addCursorText(styleList.cursorSymbol);
//		}
		
	}//---------------------------------------------------;
	
//	// --
//	override public function setDataSource(arr:Array<OptionData>) 
//	{
//		trace("ERROR: Don't call this function, use setPageData() instead");
//	}//---------------------------------------------------;
	
	/**
	 * Functionality to move the cursor within boundaries
	 * taking into account a padding value
	 * --
	 * V1.0. Tested and works.
	 *       . when the list is more than full
	 * 		 . when the list is half full
	 * 		 . when the list is exactly full
	 * 
	 * PRE: OptionPointer is not NULL
	 */
//	function checkInput() 
//	{
//		switch(Controls.CURSOR_DIR()) {
//		// =============================== CONTROLS UP   =======;
//		case Controls.UP:
//			if (_indexData == 0) return;
//			
//			r_1 = findNextSelectableIndex(_indexData - 1, -1);
//			if (r_1 == -1) return; // Can't find a selectable element
//		
//			// r_1 is now Delta, Amount to go up
//			r_1 = _indexData - r_1;
//			
//			if (_indexSlot - r_1 >= _pointer_padding) { // No view scroll is needed
//				_indexSlot -= r_1;
//				_indexData -= r_1;
//				_dataIndexChanged();
//			}else
//			{
//				if (r_1 > 1) {
//					trace("Warning: Scrolling more than 1 element is not supported. Hard Scrolling.");
//					setViewIndex(_indexData - r_1);
//					callback_menu("tick");
//					return;
//				}
//		
//				if (isScrolling) return;
//				
//				if (scrollUpOne()) {
//						_indexData--;
//						_dataIndexChanged();
//				}else {
//					// The scroll padding has reached the end
//					if (_indexSlot > 0) {
//						_indexSlot--;
//						_indexData--;
//						_dataIndexChanged();
//					}
//				}
//			}
//		// =============================== CONTROLS DOWN =======;
//		case Controls.DOWN:		
//		// Sometimes when not the entire slots are filled,
//		// prevent scrolling to an empty slot by checking this.
//		if (_indexData == _dataTotal - 1) return;
//		
//		r_1 = findNextSelectableIndex(_indexData + 1, 1);
//		if (r_1 == -1) return;
//		
//		// r_1 is now Delta, Amount to go down
//		r_1 = r_1 - _indexData;
//		
//		if (_indexSlot + r_1 < _slotsTotal - _pointer_padding) { // No view scroll is needed
//			_indexSlot += r_1;
//			_indexData += r_1;
//			_dataIndexChanged();
//		}else
//		{
//			if (r_1 > 1) {
//				trace("Warning: Scrolling more than 1 element is not supported. Hard Scrolling.");
//				setViewIndex(_indexData + r_1);
//				callback_menu("tick");
//				return;
//			}
//			
//			if (isScrolling) return;
//			
//			if (scrollDownOne()) {	
//				_indexData++;
//				_dataIndexChanged();
//			}else
//			{
//				if (_indexData < _dataTotal - 1) {
//					_indexSlot++;
//					_indexData++;
//					_dataIndexChanged();
//				}
//			}
//		}
//		// =============================== CONTROLS LEFT     =======;
//		case Controls.LEFT:
//			option_pointer.sendInput("left");
//		// =============================== CONTROLS RIGHT    =======;
//		case Controls.RIGHT:
//			option_pointer.sendInput("right");
//		}// end switch--
//			
//		// =============================== CONTROLS SELECT   =======;
//		if (Controls.CURSOR_OK())
//		{
//			// The option itself is responsible 
//			// for translating this fire signal
//			option_pointer.sendInput("fire");
//		}else
//		// =============================== CONTROLS BACK     =======;
//		if (Controls.CURSOR_CANCEL())
//		{
//			if (isScrolling) return;
//			
//			if (!page.custom.lockNavigation) {
//				callback_menu("back");
//			}
//		}else
//		// =============================== Start Button     =======;
//		// This could be triggered to close the menu.
//		if (Controls.justPressed(Controls.START)) {
//			if (!page.custom.lockNavigation) {
//				callback_menu("start");
//			}
//		}
		
		
		// -- Check mouse controls ::
//		if (!flag_use_mouse) return;
//		if (isScrolling) return;
//		for (counter in 0..._slotsTotal) {
//			if (elementSlots[counter] != null) {
//				r_el = elementSlots[counter];
//				if (r_el.opt.disabled || !r_el.opt.selectable) continue;
//				if ((FlxG.mouse.screenX + _camCheckOffset.x > r_el.x) && (FlxG.mouse.screenX + _camCheckOffset.x < r_el.x + r_el.width) &&  
//					(FlxG.mouse.screenY + _camCheckOffset.y > r_el.y)  && (FlxG.mouse.screenY + _camCheckOffset.y < r_el.y + elementHeight )) {
//						if (!r_el.isFocused) requestRollOver(counter); else
//						if (FlxG.mouse.justPressed) r_el.sendInput("fire"); else
//						if (FlxG.mouse.wheel < 0) r_el.sendInput("left"); else
//						if (FlxG.mouse.wheel > 0) r_el.sendInput("right");
//					}
//			}// end if not null
//		}// end for
	
//	}//---------------------------------------------------;
	
	
	// --
	// Highlight an option of a target SID
	public function option_highlight(sid:String)
	{
		var ind = getOptionIndexWithField("SID", sid);
		if (ind > -1) {
			setViewIndex(ind);
		}
	}//---------------------------------------------------;
	
	
	// --
	// Enable or disable an option of a target SID
	// Sets DATA and also draws the change
	public function option_setEnabled(sid:String, state:Bool)
	{
		var ind = getOptionIndexWithField("SID", sid);
		
		if (ind > -1) {	
			
			if (data[ind].selectable == state) return;
			
			// . Change the data
			data[ind].selectable = state;
			
			// . Check to see if it's onscreen
			for (i in elementSlots) {
				if (i.isSame(data[ind])) {
					i.updateState();
					return;
				}
			}
			
			// . Check to see if the element is pooled, and update it
			if (flag_pool_reuse)
			{
				var b:MenuOptionBase = poolGet(ind); // Guaranteed that it won't be removed from the pool
				if (b != null) b.updateState();
			}
		}
	}//---------------------------------------------------;
	
//	/**
//	 * Get the next selectable option index, starting and including &fromIndex 
//	 * @param	fromIndex Starting index to search from
//	 * @param	direction >0 to search downwards, <0 to search upwards
//	 * @return
//	 */
//	public function findNextSelectableIndex(fromIndex:Int, direction:Int = 1):Int
//	{
//		while (data[fromIndex] != null)
//		{
//			if (data[fromIndex].selectable) return fromIndex;
//			fromIndex += direction;
//		}
//
//		trace('Warning: Didn\'t find a selectable index, returning -1');
//		return -1;
//	}//---------------------------------------------------;

	
	//--
	// NOTE: To avoid errors, make sure you FOCUS when
	//		 the list is occupied with child elements.
////	override public function focus() 
//	{	
//		if (isFocused) return;
//			isFocused = true;
//
//		if (option_pointer != null) {
//			focusPointerElement();
//		}
//		
//		if (hasCursor) {
//			cursor.alpha = 0;
//			cursor.visible = true;
//			cursorTween = FlxTween.tween(cursor, { alpha:1 }, styleBase.element_scroll_time);
//		}
		
//		if (flag_use_mouse) {
//			if (_camCheckOffset == null) {
//				_camCheckOffset = new SimpleCoords();
//				_camCheckOffset.x = -Std.int( (camera.x / camera.zoom) );
//				_camCheckOffset.y = -Std.int( (camera.y / camera.zoom) );
//				trace(_camCheckOffset);
//			}
//		}
//	}//---------------------------------------------------;
	
	// --
//	override public function unfocus() 
//	{
//		if (!isFocused) return;
//			isFocused = false;
//			
//		unfocusPointerElement();
//		
//		if (hasCursor) {
//			cursor.visible = false;
//		}
//		
//	}//---------------------------------------------------;
	
	
//	// -- 
//	// Update the view also the pointer position to target element
//	// Sets the scroll of the list
//	// Takes cursor padding into consideration.
//	override public function setViewIndex(R:Int = 0) 
//	{
//		// # Safeguard #
//		// - Nothing is selected, Check for just in case
//		if (_dataTotal == 0) {
//			_indexData = -1;
//			_indexSlot = -1;
//			option_pointer = null;
//			trace("Error: You need to have at least one element option");
//			return;
//		}
//
//		// Don't go to the same place
//		if (_indexData == R) return;
//		
//		// trace('Info: Requesting pointer to ($R)');
//		
//
//		if (R >= _dataTotal) {
//			R = _dataTotal - 1;
//		}
//		
//		/*
//		 * Scroll the view and autoposition cursor
//		 * --------
//		 * Working 
//		 *  . R + slots < maxdata
//		 *  . R + slots > maxdata
//		 * Untested:
//		 *  . maxdata < slots_total
//		 * 
//		 **/
//		var _scroll:Int;
//		
//		// Case it fits
//		_scroll = R - _pointer_padding;
//		_indexSlot = _pointer_padding;
//		_indexData = R;
//		
//		if (_scroll < 0) {
//			_indexSlot = R;
//			_scroll = 0;
//		}
//		
//		super.setViewIndex(_scroll);
//		
//		// After setting the data, the list overflowed and scrolled 
//		// back to a safe view scroll
//		if (_scrollOffset < _scroll)
//		{
//			trace("Warning: Overflow at bottom. Fixing.");
//			var delta = _scroll - _scrollOffset;
//			_indexSlot += delta;
//		}
//		
//		// --
//		unfocusPointerElement();
//		option_pointer = elementSlots[_indexSlot];
//		
//		if (isFocused) {
//			focusPointerElement();
//		}
//		
//	}//---------------------------------------------------;
//	
	
	

	

//	// --
//	// PRE: option_pointer IS NOT NULL
//	function focusPointerElement()
//	{
//		option_pointer.focus();
//		FlxTween.tween(	option_pointer, { x:this.x + styleList.focus_nudge }, styleBase.element_scroll_time,
//						{ease:FlxEase.cubeOut } );
//
//		// Update the cursor now.
//		updateCursorPos();
//		
//		// Callback which option data was just focused
//		callback_option("optFocus");
//	}//---------------------------------------------------;
//	
//	// --
//	// If any option is focused, unfocus it with an animation
//	function unfocusPointerElement()
//	{
//		if (option_pointer == null) return;
//		option_pointer.unfocus();
//		FlxTween.tween(option_pointer, { x:this.x }, styleBase.element_scroll_time);
//	}//---------------------------------------------------;
	

	
//	// --
//	// Note: elementHeight is known.
//	// TODO: make public and usable
//	function addCursorSymbol(s:FlxSprite)
//	{
//		hasCursor = true;
//		cursor = s;
//		cursor.scrollFactor.set(0, 0);
//		cursor.cameras = [camera];
//		
//		add(cursor);
//
//		// These values only make sense if the cursor is an FlxText
//		// If the cursor is a graphic, these won't work well
//		_cursor_y_offset = 0;
//		_cursor_x_start = this.x - cursor.width;
//		_cursor_x_end = this.x + styleList.focus_nudge - (cursor.width * 0.66); // #BROKEN
//		_cursor_tween_time = styleBase.element_scroll_time * 1.25;
//	
//		cursorIsAnimating = false;
//		
//		if (isFocused) {	
//			updateCursorPos();
//		}else {
//			cursor.visible = false;
//		}
//	}//---------------------------------------------------;
//		
//	// --
//	public function addCursorText(symbol:String = ">")
//	{
//		var text = new FlxText(0, 0, 0, symbol, styleOption.fontSize);
//		Styles.styleOptionText(text, styleOption);
//		addCursorSymbol(cast text);
//	}//---------------------------------------------------;
//	
//	// -- 
//	// Start the cursor appearing Animation
//	function updateCursorPos()
//	{
//		if (!hasCursor) return;
//		cursor.x = _cursor_x_start;
//		__cursorAlignVertical();
//		
//		cursorIsAnimating = true;
//		cursor.alpha = 0.5;
//		
//		if (cursorTween != null) {
//			cursorTween.cancel();
//		}
//		
//		// Tween from left to right now
//		// Vertical movement is handled on the update function
//		// in case the option has scrolled, I call ALIGNV at the end of this tween
//		cursorTween = FlxTween.tween(cursor, { x:_cursor_x_end, alpha:1 }, 
//									_cursor_tween_time, { ease: FlxEase.backOut } );
//	}//---------------------------------------------------;
//
//	// -- 
//	// Quick valign the cursor to it's pointing option
//	function __cursorAlignVertical(?f:FlxTween)
//	{
//		cursor.y = elementSlots[_indexSlot].y + _cursor_y_offset;
//	}//---------------------------------------------------;
	
//	// --
//	// -- Quick way to align the cursor with the moving element
//	override public function update(elapsed:Float):Void 
//	{
//		super.update(elapsed);
//		
//		if (cursorIsAnimating) {
//			__cursorAlignVertical();
//		}
//	}//---------------------------------------------------;
//	
	// Request to set the cursor to the first entry
	// It's faster than setting the view again.
	/// UNTESTED , UNUSED !!
	public function resetPointerToTop()
	{
		if (_indexData == 0) return; // already selected
		
		if (_scrollOffset > 0) setViewIndex(0); // needs to scroll
		
		// Just change the slot
		_indexData = 0;
		_indexSlot = 0;
		
		unfocusPointerElement();
		option_pointer = elementSlots[0];
		
		if (isFocused) {
			focusPointerElement();
		}
		
	}//---------------------------------------------------;
	
	// --
	// Returns the index of the option with target SID,
	// Returns -1 if nothing found
	public function getOptionIndexWithField(field:String, check:Dynamic):Int
	{
		var i = 0;
		for (i in 0...data.length) {
			if (Reflect.field(data[i], field) == check) {
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
		if (_indexData < 0) return null;
		return data[_indexData];
	}//---------------------------------------------------;
	
	// -- 
	// Cursor data has changed, reflect to visual
	// :: _indexSlot,_indexData have changed.
	// # Called when the input moves the cursor
//	function _dataIndexChanged()
//	{
//		unfocusPointerElement();
//		option_pointer = elementSlots[_indexSlot];
//		focusPointerElement();
//		callback_menu("tick");
//	}//---------------------------------------------------;
	// --
	override function factory_getElement(dataIndex:Int):MenuOptionBase
	{
		switch(data[dataIndex].type)
		{
			case "link" : return new MenuOptionLink(this);
			case "oneof" : return new MenuOptionOneof(this);
			case "toggle": return new MenuOptionToggle(this);
			case "slider" : return new MenuOptionSlider(this);
			case "label" : return new MenuOptionLabel(this);
			default: return new MenuOptionBase(this);
		}
		
		return null;
	}//---------------------------------------------------;
	

	// --
	// Check all conditional options again.
	function _cond_checkAll()
	{		
		var res:Bool;
		for (i in _condIndexes) {
			res = page.collection[i].data.conditional();
			if (page.collection[i].selectable != res) {
				trace('Conditional CHANGE to [$res] for OPTION with sid [' + page.collection[i].SID + ']');
				page.collection[i].selectable = res;
			}
		}
	}//---------------------------------------------------;
	
	// --
//	@:allow(djFlixel.gui.listoption.MenuOptionBase)
//	function requestRollOver(newSlot:Int)
//	{
//		if (_indexSlot == newSlot) return;
//		
//		_indexData += newSlot - _indexSlot;
//		_indexSlot = newSlot;
//		
//		_dataIndexChanged();
//	}//---------------------------------------------------;
	
	
	//====================================================;
	// Callbacks from children elements
	//====================================================;
	
//	// Menu related callback
//	function callback_menu(status:String)
//	{
//		if (callbacks != null) {
//			callbacks(status, null);
//		}
//	}//---------------------------------------------------;
//	
//	// Option related callback
//	// Child options are calling this directly.
//	@:allow(djFlixel.gui.listoption)
//	function callback_option(status:String)
//	{
//		if (callbacks != null) {
//			callbacks(status, data[_indexData]);
//		}
//	}//---------------------------------------------------;

}//-- end -- //
