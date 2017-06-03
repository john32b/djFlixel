package djFlixel.gui.list;
import djFlixel.gui.Styles.VListStyle;
import djFlixel.gui.listoption.IListOption;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;

/**
 * Provide element navigation with a cursor on a VList
 *
 * NOTES:
 * ----------------
 * 
 *  new VListNav<GraphicElement,DataElement>
 * 
 */
class VListNav<T:(IListOption<K>,FlxSprite),K> extends VListBase<T,K>
{
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
	// 
	// tick : 
	// back :
	// start:
	public var callbacks:String->K->Void = null;
	
	// -- STYLINGS
	// --
	// How far from the edges to trigger a pad. Sanitized styleList.scrollpad
	var scrollPadding:Int;
	// General menu parameters
	public var styleList(default,set):VListStyle;
	
	// -- Sprite Cursor
	// --
	public var cursor(default, null):FlxSprite;
	var hasCursor:Bool;
	
	// Keep the tween in case I want to cancel it
	var cursorTween:VarTween;
	
	// Cursor position is auto-generated
	var _cursor_x_end:Float;
	var _cursor_x_start:Float;
	var _cursor_y_offset:Float; // offset from the current elements's y position
	var _cursor_tween_time:Float;
	
	
	// -- Mouse Related
	// ------------
	
	// -- You can set this at any time
	// Enables mouse interaction with the optionelements
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
		setPoolingMode("reuse");
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

		if (styleList == null) {
			styleList = Styles.default_ListStyle;
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
		// # Safeguard #
		// - Nothing is selected, Check for just in case
		if (_data_length == 0) {
			_index_data = -1;
			_index_slot = -1;
			currentElement = null;
			trace("Error: You need to have at least one element option");
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
	function currentElement_Focus()
	{	
		if (currentElement == null) return;
		
		currentElement.focus();
		
		// :: Try to cancel any previous tween
		if (slotTweens.exists(currentElement)) {
			slotTweens.get(currentElement).cancel();
			// do not remove it will be replaced on set()
		}
		
		slotTweens.set(currentElement, FlxTween.tween(	currentElement, { x:this.x + styleList.focus_nudge }, 
						styleBase.element_scroll_time, { ease:FlxEase.cubeOut } ));
						
		cursor_updatePos();
		
		callback_option("optFocus");
	}//---------------------------------------------------;	
	
	// --
	function currentElement_Unfocus()
	{	
		if (currentElement == null) return;
		currentElement.unfocus();
		// :: Try to cancel any previous tween
		if (slotTweens.exists(currentElement)) {
			slotTweens.get(currentElement).cancel();
			// do not remove it will be replaced on set()
		}
		slotTweens.set(currentElement, FlxTween.tween(currentElement, { x:this.x }, styleBase.element_scroll_time));
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
				// trace("Camera CheckOffset = ", _camCheckOffset);
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
		
		if (!hasCursor) return;
		
		if (inputAllowed)
		{
			cursor.alpha = 0;
			cursor.visible = true;
			allTweens.push(FlxTween.tween(cursor, { alpha:1 }, styleBase.element_scroll_time));
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
	 * PRE: OptionPointer is not NULL
	 */
	function checkInput() 
	{
		switch(Controls.CURSOR_DIR()) {
			case Controls.UP: 		selectionOneUp();
			case Controls.DOWN:		selectionOneDown();
			case Controls.LEFT:		currentElement.sendInput("left");
			case Controls.RIGHT:	currentElement.sendInput("right");
		}// end switch--
		
		// =============================== CONTROLS SELECT   =======;
		if (Controls.CURSOR_START())
		{
			currentElement.sendInput("fire");
		}else
		// =============================== CONTROLS BACK     =======;
		if (Controls.CURSOR_CANCEL()) {
			if (isScrolling) return;
			callback_menu("back");
			
		}else
		// =============================== Start Button     =======;
		// This could be triggered to close the menu.
		if (Controls.justPressed(Controls.START)) {
			if (isScrolling) return;
			callback_menu("start");
		}

		// -- Check mouse controls ::
		if (!flag_use_mouse || isScrolling) return;
		
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
					
					// In the case where this scrolls instantly continue
					// if (isScrolling) return; 
					return;
				
				}
		}// --
	
		
		// -- Check Collision on all slots
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
						//else if (FlxG.mouse.wheel < 0) r_el.sendInput("wdown");
						//else if (FlxG.mouse.wheel > 0) r_el.sendInput("wup");
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
			if (styleList.loop_edge) {
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
			if (styleList.loop_edge) {
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
	 * Get the next selectable option index, starting and including &fromIndex 
	 * @param	fromIndex Starting index to search from
	 * @param	direction >0 to search downwards, <0 to search upwards
	 * @return
	 */
	public function findNextSelectableIndex(fromIndex:Int, direction:Int = 1):Int
	{
		while (_data[fromIndex] != null)
		{
			// if (_data[fromIndex].selectable) return fromIndex;
			return fromIndex;
			fromIndex += direction;
		}

		trace('Warning: Didn\'t find a selectable index, returning -1');
		return -1;
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
	// :: _index_data,_index_slot have changed.
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
		r_el.callbacks = callback_option;
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
	
	// Option related callback
	// Child options are calling this directly
	// NOTE: Only the currently selected option is allowed to push callbacks.
	function callback_option(status:String)
	{
		if (callbacks != null) {
			callbacks(status, _data[_index_data]);
		}
	}//---------------------------------------------------;
	
	
	//====================================================;
	// CURSOR
	//====================================================;
	
	// --
	// Note: elementHeight is known.
	// Note: Apply after setting the DATA SOURCE
	public function cursor_setSprite(s:FlxSprite, centerOrigin:Bool = true, ?_offset:Array<Int>):Void
	{
		if (cursor != null) {
			remove(cursor); cursor.destroy();
		}
		
		var elHeight:Int = Std.int(s.height); // Safeguard?
		
		hasCursor = true;
		cursor = s;
		cursor.scrollFactor.set(0, 0);
		cursor.cameras = [camera];
		cursor.width = 1;
		if (centerOrigin) {	
			cursor.height = 1;
			_cursor_y_offset = elHeight / 2;
		}else {
			_cursor_y_offset = 0;
		}
		cursor.centerOffsets();
		add(cursor);
		
		// SAFEGUARD : elemenSlots[0] can be null 
		if (elementSlots[0] != null) {
			elHeight = elementSlots[0].getOptionHeight();
		}else {
			r_el = factory_getElement(0);
			elHeight = r_el.getOptionHeight();
			r_el.destroy();
		}
	
		// These values only make sense if the cursor is an FlxText
		// If the cursor is a graphic, these won't work well
		_cursor_x_start = this.x - (cursor.frameWidth / 2);
		_cursor_x_end = this.x + styleList.focus_nudge - (cursor.frameWidth / 4);
		_cursor_tween_time = styleBase.element_scroll_time * 1.25;
		
		if (_offset != null) {
			cursor.offset.set( cursor.offset.x - _offset[0], cursor.offset.y - _offset[1]);
		}
		
		if (isFocused && _data.length > 0) {
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
		if (!hasCursor) return; // called on fucus, So I have got to chedk for cursor
		
		// SET x and y position
		cursor.x = _cursor_x_start;
		cursor_AlignVertical();
		
		cursor.alpha = 0.5;
		
		if (cursorTween != null) {
			cursorTween.cancel();
		}
		
		// Tween from left to right now
		// Vertical movement is handled on the update function
		// in case the option has scrolled, I call ALIGNV at the end of this tween
		cursorTween = FlxTween.tween(cursor, { x:_cursor_x_end, alpha:1 }, 
									_cursor_tween_time, { ease: FlxEase.backOut } );
	}//---------------------------------------------------;

	// -- 
	// Quick valign the cursor to it's pointing option
	function cursor_AlignVertical(?f:FlxTween)
	{
		cursor.y = elementSlots[_index_slot].y + _cursor_y_offset;
	}//---------------------------------------------------;
	
	
	// --
	// Set the style and sanitize the scrollPadding
	function set_styleList(val:VListStyle):VListStyle
	{
		styleList = val;
		if (styleList != null) {
			scrollPadding = styleList.scrollPad;
			if (scrollPadding > Math.floor(_slotsTotal / 2)) {
				scrollPadding = Math.floor(_slotsTotal / 2);
			}
		}
		return styleList;
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
			if (isScrolling && hasCursor) {
				cursor_AlignVertical();
			}
		}
		
	}//---------------------------------------------------;
	
	override public function destroy():Void 
	{
		super.destroy();
		for (tw in slotTweens) {
			tw.cancel();
		}
		slotTweens = null;
		
		if (cursorTween != null) {
			cursorTween.cancel();
			cursorTween = null;
		}
		styleList = null;
	}//---------------------------------------------------;
	
	
}// -- end -- //