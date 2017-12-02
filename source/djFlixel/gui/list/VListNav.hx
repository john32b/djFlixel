package djFlixel.gui.list;

import djFlixel.gui.Styles;
import djFlixel.gui.list.IListItem;
import djFlixel.tool.DEST;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;

/**
 * == Vertical List Navigatiable ==
 * 
 * Provide element navigation with a cursor on a Basic Vertical List
 * 
 * CURSOR:
 * ----------------
 * 
 * 
 *
 * NOTES:
 * ----------------
 * 
 *  new VListNav<GraphicElement,DataElement>
 * 
 */
class VListNav<T:(IListItem<K>,FlxSprite),K> extends VListBase<T,K>
{
	// When animating the cursor start from this alpha to 1
	static inline var CURSOR_START_ALPHA:Float = 0.5;
	// Cursor tween in time is (Style.el_scroll_time) * this mutliplier
	// NOTE: Needs to be faster then (el_scroll_time) because cursor renders when (isScrolling==true)
	static inline var CURSOR_TWEEN_TIME_MULTIP:Float = 0.9;
	
	// -- DATA ::
	// --
	// Current highlighted index on the data array
	var _index_data:Int;
	// Current highlighted slot index
	var _index_slot:Int;
	
	// Current highlighted element pointer
	public var currentElement(default, null):T;
	
	// What is says, I need it when I need the list to be focused visually, but not interactable
	var inputAllowed:Bool;
	
	// # USER SET::
	// Push status messages involving the menu and menu items
	// back	 : Back Button pressed
	// start : Start Button pressed
	// tick  : Fired when changing elements
	// ..
	// focus : K element was focused
	// __ 	 : K element pushed __
	public var callbacks:String->K->Void = null;
	
	// -- STYLINGS
	// --
	// How far from the edges to trigger a pad. Sanitized styleNav.scrollpad
	var scrollPadding:Int;
	
	// Whenever this is set, styleB is also set and points to this
	public var styleNav(default, set):StyleVLNav;

	
	// -- Sprite Cursor --
	// --
	public var cursor(default, null):FlxSprite;
	
	// Keep the tween in case I want to cancel it
	var cursorTween:VarTween;
	
	// These cursor vars are auto-calculated ::
	var _cursor_tween_time:Float;	// Time the cursor tween lasts
	var _cursor_rest_offset:Float;	// The cursor rests at the beggining/end of each slot +this much padding
	var _cursor_anim_offset:Float;	// Offset X position from the resting position to start animating in
	var _cursor_align_right:Bool;	// If true, places the cursor on the right, inverses anim_x_offset
	
	
	// -- Mouse Related
	// ------------
	
	// -- You can set this at any time
	// Enables mouse interaction with the item elements
	public var flag_use_mouse:Bool = true;
	
	// -- If true will try to scroll up and down using the mouse
	public var flag_mouse_scroll:Bool = true;
	
	// Precalculate camera viewport and scrolling for mouse overlap calculations
	var _camCheckOffset:SimpleCoords;
	
	// -- Tweens
	var slotTweens:Map<T,VarTween>;
	
	//---------------------------------------------------;
	
	public function new(ObjClass:Class<T>, X:Float, Y:Float, WIDTH:Int = 0, ?SlotsTotal:Int) 
	{
		super(ObjClass, X, Y, WIDTH, SlotsTotal);
		_index_data = -1;
		_index_slot = -1;
		currentElement = null;
		scrollPadding = 0;
		inputAllowed = false;
		
		slotTweens = new Map();
	}//---------------------------------------------------;	
	
	// --
	override public function setDataSource(arr:Array<K>) 
	{
		if (arr == null) return;
		
		// Just in case
		if (styleNav == null) {
			styleNav = Styles.newStyleVLNav();
		}
		
		// This will call the setViewIndex back to 0,
		// which will reset the cursor back to top.
		super.setDataSource(arr); 
		
	}//---------------------------------------------------;
	
	
	// -- 
	// Update the view also the pointer position to target element
	// Sets the scroll of the list
	// Takes cursor padding into consideration.
	override public function setViewIndex(R:Int = 0) 
	{
		if (isScrolling) {
			trace('Warning: Setting new scrollview will cause trouble, returning.');
			return;
		}	
		
		// # Safeguard #
		// - Nothing is selected, Check for just in case
		if (_data_length == 0) {
			_index_data = -1;
			_index_slot = -1;
			currentElement = null;
			trace("Error: You need to have at least one element item");
			return;
		}
		
		// Don't go to the same place
		if (_index_data == R) return; // TODO: If you want to replace data, this is a problem.
									 // if (R < 0) R = 0; // ^ Fix for above
		
		if (R >= _data_length) {
			R = _data_length - 1;
		}
		
		/*
		 * Scroll the view and autoposition cursor
		 * --------
		 * Working 
		 *  . R + slots < maxdata
		 *  . R + slots > maxdata
		 * Untested:
		 *  . maxdata < slots_total
		 * 
		 **/
		var _scroll:Int;
		
		// Case it fits
		_scroll = R - scrollPadding;
		_index_slot = scrollPadding;
		_index_data = R;
		
		if (_scroll < 0) {
			_index_slot = R;
			_scroll = 0;
		}
		
		super.setViewIndex(_scroll);
		
		// After setting the data, the list overflowed and scrolled 
		// back to a safe view scroll
		if (_scrollOffset < _scroll)
		{
			// trace("Warning: Overflow at bottom. Fixing.");
			var delta = _scroll - _scrollOffset;
			_index_slot += delta;
		}
		
		// --
		currentElement_Unfocus();
		currentElement = elementSlots[_index_slot];
		
		if (isFocused) {
			currentElement_Focus();
		}
		
	}//---------------------------------------------------;
	
	// --
	// Nudge the selected element a bit, highlight it and also update the cursor position	
	function currentElement_Focus()
	{	
		if (currentElement == null) return;
		
		currentElement.focus();
		
		if (styleNav.focus_nudge != 0) 
		{
			if (slotTweens.exists(currentElement)) { // Cancel any previous tween
				slotTweens.get(currentElement).cancel();
				// Note : do not remove it will be replaced below
			}
			slotTweens.set(currentElement, FlxTween.tween( currentElement, 
				{ x:getStartingXPos(currentElement) + styleNav.focus_nudge }, styleB.el_scroll_time, { ease:FlxEase.cubeOut } ));
		}
		
		cursor_updatePos();
		
		callback_item("focus");
	}//---------------------------------------------------;	
	
	
	// --
	// Nudge the selected element back to where it was and unhighlight it
	function currentElement_Unfocus()
	{	
		if (currentElement == null) return;
		
		currentElement.unfocus();
		
		if (styleNav.focus_nudge != 0) 
		{
			if (slotTweens.exists(currentElement)) { // Cancel any previous tween
				slotTweens.get(currentElement).cancel();
				// Note : do not remove it will be replaced below
			}	
			slotTweens.set(currentElement, FlxTween.tween(currentElement, 
				{ x:getStartingXPos(currentElement) }, styleB.el_scroll_time));
		}
		
	}//---------------------------------------------------;
	
	
	// --
	override public function focus() 
	{	
		if (isFocused) return;
		
		if (_data_length == 0) {
			trace("Error: No elements in the menu");
			return;
		}
		
		isFocused = true;
			
		currentElement_Focus();
		
		setInputFocus(true);
		
		if (flag_use_mouse) {
			if (_camCheckOffset == null) {
				_camCheckOffset = new SimpleCoords();
				_camCheckOffset.x = -Std.int( (camera.x / camera.zoom) );
				_camCheckOffset.y = -Std.int( (camera.y / camera.zoom) );
			}
		}
	}//---------------------------------------------------;
	
	/**
	 * Focus the menu,
	 * Starts accepting input
	 */
	override public function unfocus() 
	{
		if (!isFocused) return;
			isFocused = false;
		
		currentElement_Unfocus();
		
		setInputFocus(false);
	}//---------------------------------------------------;
	
	
	/**
	 * Sets the input flag to on or off
	 * Also, adds or remove the cursor
	 * Useful when you want to keep the menu on screen but unfocused?
	 */
	function setInputFocus(state:Bool)
	{
		inputAllowed = state; 
		
		if (cursor == null) return;
		
		if (inputAllowed)
		{
			cursor.alpha = 0;
			cursor.visible = true;
			allTweens.push(FlxTween.tween(cursor, { alpha:1 }, styleB.el_scroll_time));
			cursor_updatePos();
			
		}else {
			cursor.visible = false;
		}
	}//---------------------------------------------------;
	
	
	
	/**
	 * Functionality to move the cursor within boundaries
	 * taking into account a padding value
	 * --
	 * V1.0. Tested and works.
	 *       . when the list is more than full
	 * 		 . when the list is half full
	 * 		 . when the list is exactly full
	 * 
	 * PRE: Item Pointer is not NULL
	 */
	function checkInput() 
	{
		switch(Controls.CURSOR_DIR()) {
			case Controls.UP: 		selectionOneUp();
			case Controls.DOWN:		selectionOneDown();
			case Controls.LEFT:		currentElement.sendInput("left");
			case Controls.RIGHT:	currentElement.sendInput("right");
		}// end switch--
		
		if (isScrolling) return;
		
		// =============================== CONTROLS SELECT   =======;
		if (Controls.CURSOR_OK()) {
			currentElement.sendInput("fire");
		}else
		// =============================== CONTROLS BACK     =======;
		if (Controls.CURSOR_CANCEL()) {
			callback_menu("back");
			
		}else
		// =============================== Start Button     =======;
		// This could be triggered to close the menu.
		if (Controls.justPressed(Controls.START)) {
			callback_menu("start");
		}

		// -- Check mouse controls ::
		if (!flag_use_mouse) return;

		// :: Check for mouse scrolling
		if (flag_mouse_scroll && (FlxG.mouse.wheel < 0 || FlxG.mouse.wheel > 0))
		{
			if ((FlxG.mouse.screenX + _camCheckOffset.x > this.x) && (FlxG.mouse.screenX + _camCheckOffset.x < this.x + this.width) &&  
				(FlxG.mouse.screenY + _camCheckOffset.y > this.y) && (FlxG.mouse.screenY + _camCheckOffset.y < this.y + this.height )) {
					
					if (FlxG.mouse.wheel < 0) 
					{
						if (scrollDownOne()) {	
							_index_data++;
							_dataIndexChanged();
							
						}
					}
					else
					{
						 if (scrollUpOne()) {
							_index_data--;
							_dataIndexChanged();
						 }
					}
					
					return;
				}
		}// --
	
		
		// -- Check Mouse Collision on all slots
		// TODO: it works but it could be better
		for (counter in 0..._slotsTotal) 
		{
			if (elementSlots[counter] != null) 
			{
				r_el = elementSlots[counter]; // Readability
				// if (r_el.opt.disabled || !r_el.opt.selectable) continue;
				if ((FlxG.mouse.screenX + _camCheckOffset.x > r_el.x) && (FlxG.mouse.screenX + _camCheckOffset.x < r_el.x + r_el.width) &&  
					(FlxG.mouse.screenY + _camCheckOffset.y > r_el.y)  && (FlxG.mouse.screenY + _camCheckOffset.y < r_el.y + elementHeight )) {
						if (!r_el.isFocused) requestRollOver(counter); else
						if (FlxG.mouse.justPressed) r_el.sendInput("click");
						//if (FlxG.mouse.justReleasedRight) r_el.sendInput("clickR"); else
						//if (FlxG.mouse.wheel < 0 && FlxG.keys.pressed.CONTROL) r_el.sendInput("left"); else
						//if (FlxG.mouse.wheel > 0 && FlxG.keys.pressed.CONTROL) r_el.sendInput("right");
					}
			}//--
		}//--

	}//---------------------------------------------------;
	

	
	/**
	 * Move the cursor one position up
	 */
	function selectionOneUp()
	{
		if (_index_data == 0) {
			if (styleNav.loop_edge) {
				setViewIndex(_data_length - 1); callback_menu("tick");
			}
			return;
		}
		
		r_1 = findNextSelectableIndex(_index_data - 1, -1);
		if (r_1 == -1) return; // Can't find a selectable element
	
		// r_1 is now Delta, Amount to go up
		r_1 = _index_data - r_1;
		
		if (_index_slot - r_1 >= scrollPadding) { // No view scroll is needed
			_index_slot -= r_1;
			_index_data -= r_1;
			_dataIndexChanged();
		}else
		{
			if (r_1 > 1) {
				// trace("Warning: Scrolling more than 1 element is not supported. Hard Scrolling.");
				setViewIndex(_index_data - r_1);
				// callback_menu("tick");
				return;
			}
	
			if (isScrolling) return;
			
			if (scrollUpOne()) {
					_index_data--;
					_dataIndexChanged();
			}else {
				// The scroll padding has reached the end
				if (_index_slot > 0) {
					_index_slot--;
					_index_data--;
					_dataIndexChanged();
				}
			}
		}
	}//---------------------------------------------------;
	
	/**
	 * Move the cursor one position down
	 */
	function selectionOneDown()
	{
		// Sometimes when not the entire slots are filled,
		// prevent scrolling to an empty slot by checking this.
		if (_index_data == _data_length - 1) {
			if (styleNav.loop_edge) {
				setViewIndex(0); callback_menu("tick");
			}
			return;
		}
		
		r_1 = findNextSelectableIndex(_index_data + 1, 1);
		if (r_1 == -1) return;
		
		// r_1 is now Delta, Amount to go down
		r_1 = r_1 - _index_data;
		
		if (_index_slot + r_1 < _slotsTotal - scrollPadding) { // No view scroll is needed
			_index_slot += r_1;
			_index_data += r_1;
			_dataIndexChanged();
		}else
		{
			if (r_1 > 1) {
				// trace("Warning: Scrolling more than 1 element is not supported. Hard Scrolling.");
				setViewIndex(_index_data + r_1);
				// callback_menu("tick");
				return;
			}
			
			if (isScrolling) return;
			
			if (scrollDownOne()) {	
				_index_data++;
				_dataIndexChanged();
			}else
			{
				if (_index_data < _data_length - 1) {
					_index_slot++;
					_index_data++;
					_dataIndexChanged();
				}
			}
		}
	}//---------------------------------------------------;
					
	
	
	/**
	 * Get the next selectable item index, starting and including &fromIndex 
	 * @param	fromIndex Starting index to search from
	 * @param	direction >0 to search downwards, <0 to search upwards
	 * @return
	 */
	public function findNextSelectableIndex(fromIndex:Int, direction:Int = 1):Int
	{
		// -- OVERRIDE THIS --
		// Currently is being overriden in VListMenu and it checks for MenuItems
		// Generic elements are all selectable
		return fromIndex;
	}//---------------------------------------------------;
	
	// --
	// Request a mouse rollover
	// ASSURED: newSlot exists.
	function requestRollOver(newSlot:Int)
	{
		if (_index_slot == newSlot) return;
		
		_index_data += newSlot - _index_slot;
		_index_slot = newSlot;
		
		_dataIndexChanged();
	}//---------------------------------------------------;
	
	// -- 
	// Cursor data has changed, reflect to visual
	// :: _index_data, _index_slot have changed.
	// # Called when the input moves the cursor
	function _dataIndexChanged()
	{
		currentElement_Unfocus();
		currentElement = elementSlots[_index_slot];
		currentElement_Focus();
		callback_menu("tick");
	}//---------------------------------------------------;	
	
	
	// --
	// Override this to set the callback function
	override function getNewElement(index:Int):T 
	{
		r_el = super.getNewElement(index);
		r_el.callbacks = callback_item;
		return r_el;
	}//---------------------------------------------------;
	
	
	//====================================================;
	// Callbacks from children elements
	//====================================================;
	
	// Menu related callback
	function callback_menu(status:String)
	{
		if (callbacks != null) {
			callbacks(status, null);
		}
	}//---------------------------------------------------;
	
	// Items related callback
	// Child items are calling this directly
	// NOTE: Only the currently selected item is allowed to push callbacks.
	function callback_item(status:String)
	{
		if (callbacks != null) {
			callbacks(status, _data[_index_data]);
		}
	}//---------------------------------------------------;
	
	
	//====================================================;
	// CURSOR
	//====================================================;
	
	// --
	/**
	 * Create and start using a cursor. You must manually center it
	 * @param	s the Sprite to set as a sprite
	 * @param	centerOrigin If true then the bounding box will be a dot at the center of the sprite
	 * @param	Offset [x,y] Resting Offset.
	 */
	public function cursor_setSprite(s:FlxSprite, ?Offset:Array<Int>):Void
	{
		#if debug
		if (elementHeight == -1)
		{
			trace("Error : Currently, you need to set a cursor after calling setDataSource(..)");
			return;
		}
		#end
		
		if (cursor != null) {
			remove(cursor); cursor.destroy();
		}
				
		cursor = s;
		cursor.scrollFactor.set(0, 0);
		cursor.cameras = [camera];
		add(cursor);
		
		// It can be 0, then the tween will render instantly
		_cursor_tween_time = styleB.el_scroll_time * CURSOR_TWEEN_TIME_MULTIP;
		
		if(styleB.alignment=="right") {
			_cursor_align_right = true;
			_cursor_rest_offset = styleNav.focus_nudge;
			_cursor_anim_offset = cursor.width;
		}else{
			_cursor_align_right = false;
			// Offset from slot.x to place cursor.
			_cursor_rest_offset = -cursor.width + styleNav.focus_nudge;
			// Start from there ( offset from rest offset )
			_cursor_anim_offset = -cursor.width;
		}
		
		// User manual centering fix
		if (Offset != null) {
			cursor.offset.add(Offset[0], Offset[1]);
		}
		
		if (isFocused && currentElement != null) {
			cursor_updatePos();
		}else {
			cursor.visible = false;
		}
	}//---------------------------------------------------;

	
	// -- 
	// Start the cursor appearing Animation
	// Update Cursor X and Y
	// Animate Cursor from Left to Right
	function cursor_updatePos():Void
	{
		if (cursor == null) return; // called on fucus, So I have got to chedk for cursor
		
		// SET x and y position	
		cursor.x = getStartingXPos(currentElement) + _cursor_rest_offset + _cursor_anim_offset;
		cursor.y = elementSlots[_index_slot].y;
		cursor.alpha = CURSOR_START_ALPHA;
		
		if (_cursor_align_right) {
			cursor.x += width; // WORKS because child elements should have full width
		}
		
		if (cursorTween != null) {
			cursorTween.cancel();
		}
		
		// NOTE: Vertical movement is handled on the update function
		cursorTween = FlxTween.tween(cursor, { x:cursor.x - _cursor_anim_offset, alpha:1 },
											_cursor_tween_time, { ease: FlxEase.backOut });
	}//---------------------------------------------------;

	
	// --
	// Set the style and init
	function set_styleNav(val:StyleVLNav):StyleVLNav
	{
		styleNav = val;
		styleB = styleNav;
		
		if (styleNav != null) {
			scrollPadding = styleNav.scrollPad;
			if (scrollPadding > Math.floor(_slotsTotal / 2)) {
				scrollPadding = Math.floor(_slotsTotal / 2);
			}
		}
		
		return styleNav;
	}//---------------------------------------------------;
	
	
	//====================================================;
	// FLIXEL
	//====================================================;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (inputAllowed) 
		{
			checkInput();
			
			// Prevent choppy cursor animation when the cursor 
			// is pointing to a a scrolling element
			if (isScrolling && cursor != null) {
				cursor.y = elementSlots[_index_slot].y;
			}
		}
		
	}//---------------------------------------------------;
	
	override public function destroy():Void 
	{
		super.destroy();
		
		for (tw in slotTweens) { // Note: This is a MAP
			tw.cancel();
		}
		slotTweens = null;
		
		cursorTween = DEST.tween(cursorTween);
		styleNav = null;
	}//---------------------------------------------------;
	
	
}// -- end -- //