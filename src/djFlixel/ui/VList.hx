/**
 == Vertical List
 
 - A general purpose listbox that handles custom sprites in a vertical scrollable list. 
 - Element highlight and cursor support 
 - Supports Mouse + Keyboard
 
 - Use Example:
 
	var list = new VList<MyListItem,String>(MyListItem);
	add(list);
	list.setInputMode(2);
	list.onItemEvent = (a, b)->{
			trace("Item Event", a, b);
	}
	list.setDataSource([1,2,3,4,5,6......]);
	list.focus();
	
 NOTES:
 
 - VLists start off as unfocused so you must call focus(); to give it keyboard input
 - Call SetInputMode(.) before setting a data source
 - setDataSource(.) makes the list instant visible
 - viewOn/Off() are just for effect, not required to actually show the menu
 
*/
 
 

package djFlixel.ui;

import djA.DataT;
import djFlixel.core.Dcontrols;
import djFlixel.other.StepLoop;
import djFlixel.ui.IListItem;
import djFlixel.ui.UIDefaults;
import flixel.math.FlxMath;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxDestroyUtil;
import flixel.util.typeLimit.OneOfTwo;

import openfl.display.BitmapData;



/**
   Cursor Interface
   VList now supports Cursor Objects
   See <MPageCursor> for an example
**/
interface IVListCursor 
{
	/** Called by VLIST, attaches self to the VLIST | Note, make it hidden here */
	public function attach(v:FlxSpriteGroup):Void;
	
	/**
	   Move the cursor to point to an item, can animate
	   @param	item	The sprite this cursor points to
	   @param	itemX	X final pos of the item
	**/
	public function point(item:FlxSprite, itemX:Float):Void;

	/** Set visible or not */
	public function visible(s:Bool):Void;
	
	/** Called from VLIST, position self to match this Y coordinate */
	public function updateY(ypos:Float):Void;
	
	public function updateX(xpos:Float):Void;
	
}//---------------------------------------------------;



/**
 * Additional List Parameters Object
 * stored in {VList.STL}
 */
typedef VListStyle = {

	// When an item gets focused, use this tween animation data
	// <null> for no movement when items get focused
	?focus_anim:{
		x:Int,					// Where to move in relation to the resting position. (can use negatives)
		y:Int,					// Y axis tween only applies when no items overflow. (can use negatives)
		inEase:EaseFunction,
		inTime:Float,			// Put (0) for instant transition with no tween
		outEase:EaseFunction,	
		outTime:Float			// Put (0) for instant transition with no tween
	},
	
	// Loop at the edges
	loop:Bool,
	
	// Start scrolling the view before reaching the edges by this much.
	// - Applicable when the list has more items than slots -
	scroll_pad:Int,
	
	// How fast to scroll elements when they come in / out of the view when scrolling
	// use 0 for instant scroll.
	scroll_time:Float,	
	
	// How much padding between the elements in pixels. Can use negative values
	item_pad:Int,
	
	// How to align the elements vertically in the List
	// [ left | center | justify ]
	align:String,
	
	// == View Tweens ------------------------------
	// Item Tweens when the menu opens/closes
	
		// Encoded String : "x:y|speed:delay"
		// 	x:y are offsets to start from in relation to the item original position
		// 	speed:delay are times and apply to each item
		// 	e.g. "0:-10|0.13:0.2"
		// 		^ 	start items at x,y (0,-10), Every item takes 0.13 seconds to tween it
		//			and it starts at 0.2 seconds * index from the the moment viewOn() is called
		//  tip: For instant change, use "0:0|0:0"
		vt_IN:String,
		
		// Same as vt_IN but for exiting the view
		vt_OUT:String,
		
		// Name of the ease function found in <FlxEase.hx>
		// e.g : bounceOut, SineIn, backInOut
		vt_in_ease:String,
		
		// Like <vt_in_ease> but for animating OUT
		vt_out_ease:String,
	
	// == Scroll Indicators ---------------------
	// - Arrows at the top and bottom of the list to indicate that there are more items to scroll
	// - Will always use the build-in djFlixel icons (ar_down,ar_up)
	
		sind_size:Int,			 // which icon size to use. Be sure to call D.ui.initIcons(size); beforehand
		sind_anim:String,		 // Type,Steps,Time |  Type(1=repeat,2=loop,3=blink), Steps:Int, Time:Float=Step time | e.g. "2,3,0.2"
		sind_color:Int,		 	 // Colorize the scroll indicator with this color ARGBA format "0xFFE0E0E0"
		sind_offx:Int			 // Offset X axis for the arrows, if you want to adjust the horizontal position
	
}//---------------------------------------------------;



/**
 T: Type Element of Child, must derive (or be) FlxSprite and implement IListItem
 K: Type of Child Data. Can be anything like String,Int or a custom Data Type
 */
class VList<T:IListItem<K> & FlxSprite, K> extends FlxSpriteGroup
{	
	static inline var DEFAULT_SLOTS = 3;
	static inline var DEFAULT_POOL_MAX = 6;
	// ----------------------
		
	/** Some Options Set these right after new()
	 * These are somewhat Advanced and not exposed to the Styling Object
	 * To be used internally by extended objects etc.
	 */
	public var OPT = {
		// Enable mouse interaction in general
		enable_mouse:true,
		
		//  True  : When (pushing fire) on an element it will call callback("fire") immediately
		//  False : pushes the "fire" event to the item itself ( Used in FLXMENU )
		fire_simple:true,
		
		// If true will make the START button fire to the items
		// False will callback a "start" status
		start_button_fire:false,
		
		// Pad the scrolling indicators this much in when "left" alignment
		sc_ind_pad:4,
	};
	
	/** (STyle List), it points to the DEFAULT_STYLE*/
	public var STL:VListStyle;
	
	/** Standard menu width, used in mouse collisions and scroll indicator positioning */
	public var menu_width(default, null):Int;
	/** Standard menu height, including all items + padding. ( Calculated upon setData ) Based on slot len */
	public var menu_height(default, null):Int;
	/** This is auto-set after calling setData() */
	public var itemHeight(default, null):Int;
	/** Is it focused */
	public var isFocused(default, null):Bool = false;
	/** (0.0 - 1.0) If not overflowing this will be 0 */
	public var scrollRatio(default, null):Float;
	
	var data:Array<K>;		// This holds the data in an array (e.g. MItemData)	
	var itemSlots:Array<T>;	// All the elements that appear on the menu (slots)
	var itemSlotsX0:Array<Int> = []; // Store the X origin of all item slots | Global Values
	var itemClass:Class<T>;	// The class of Items expected to be set (used in item__createInstance)
	var slotsTotal:Int;		// Max item slots in the list. (set on the constructor)
	var scrollOffset:Int;	// Index of `data` the view starts
	var scrollMax:Int;		// The maximum index `scrollOffset` can get
	var scrollPadding(default, set):Int;// How far from the edges to trigger a scroll. (same as in style but fixed value)
	
	@:allow(djFlixel.ui.FlxMenu)
	var indexItem:T;	// Current highlighted element pointer --> (currentItem)
	var indexData:Int; 	// Current highlighted index on the data array
	var indexSlot:Int;	// Current highlighted slot index
	
	var lastSlot:Int;	// Previously highlighted slot index (useful for tweens)
	
	var tween_slot:Array<VarTween>;			// This is used exclusively for item slots tweens. ViewOn/Scrolling In
	var tween_map:Map<FlxSprite,VarTween>;  // Stores generic tweens. Items being focused, Cursor.
	
	// :: Helpers
	var _itm:T; 		// Temp element pointer
	var _markedItem:T;	// Item to be cleared after scrolling
	var _mcheckpad:Array<Int> = [0, 0];	// Mouse collision check with items, pad left-right
	
	// :: Pooling
	var pool:Array<T>;	
	var pool_keep:Bool; 	// True to (keep mode), false to (recycle mode)
	var pool_max:Int;		// Use poolSet() to specify mode and max
	
	// :: Flags
	var isScrolling:Bool;	// Is it scrolling now
	var alignCenter:Bool;	// For quickers checks against align=="center"
	public var overflows(default, null):Bool;	// More elements than slots
	
	// Interaction level
	// 0:None 1:Scroll Only 2:Cursor | see setInputMode()
	var inputMode:Int;
	
	public var cursor(default, null):IVListCursor;
	var cursor_fix:Float = 0.0;
	
	// - Scroll Indicator vars
	var sind_ty:Int;		// Type 1 Repeat, 2 Loop, 3 Blink
	var sind_loop:StepLoop;
	var sind_el:Array<FlxSprite>;
	
	#if (FLX_MOUSE)
	var oCoords:FlxPoint = FlxPoint.weak();
	#end

	/** This pushes Item Events <ListItemEvent, Item> ::
	 *  ListItemEvent (focus, fire, invalid, change) , check "IListItem.hx"
	 */
	public var onItemEvent:ListItemEvent->K->Void = null;
	
	/** Pushes List related events ::
		focus   : List was focused
		unfocus : List was unfocused
	    back    : Back button pressed
		start   : Start button pressed. Works ONLY IF flag start_button_fire is false
	*/
	public var onListEvent:String->Void = null;
	
	
	// NEW: All events callback at the end of update()
	// DEV: Why? Destroying the list by a callback that is sent   
	//      while iterating through all items is not a good idea.
	var eventQueue:Array<Void->Void> = [];
	
	function queue_itemEvent(e:ListItemEvent):Void {
		eventQueue.push( () -> {
			if (onItemEvent != null) 
				onItemEvent(e, data[indexData]);
		});
	}//---------------------------------------------------;
	function queue_listEvent(e:String) {
		eventQueue.push( () -> {
			if (onListEvent != null)
				onListEvent(e);
		});
	}//---------------------------------------------------;


	
	/**
	 * Create a Basic Vertical List object.
	 * @param	X Screen Pos
	 * @param	Y Screen Pos
	 * @param	MENU_WIDTH 0 To autocalculate right after `setdata()` -1 To autofill to screen width Mostly used for center
	 * @param	SLOTSTOTAL Slots for menuitems 0 for default
	 */
	public function new(ObjClass:Class<T>, X:Float = 0, Y:Float = 0, MENU_WIDTH:Int = 0, SLOTSTOTAL:Int = 0)
	{
		super();
		moves = false;
		x = X; 
		y = Y; 
		menu_width = MENU_WIDTH;
		itemClass = ObjClass;
		slotsTotal = SLOTSTOTAL;
		if (slotsTotal < 1) slotsTotal = DEFAULT_SLOTS;
		
		if (menu_width < 0 ) { 	// Mirrored X padding to the right
			menu_width = Std.int(this.camera.width - (X * 2));
		}

		itemSlots = new Array<T>();
		itemHeight = -1;
		STL = cast UIDefaults.MPAGE;
		inputMode = 0;
		tween_map = [];
		poolSet();	// Set pooling with default parameters
	}//---------------------------------------------------;
	
	// --
	override public function destroy():Void 
	{
		clear_tween_slot();
		clear_tween_map();
		data = null;
		STL = null;
		itemSlots = null;
		FlxDestroyUtil.destroyArray(pool);
		super.destroy();
	}//---------------------------------------------------;
	
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// I am doing this with a timer to match the cursor to the active element Y
		// because this is more convenient than calling it at every cycle also
		// using if(isScrolling) does not work for some reason.
		if ((cursor_fix -= elapsed) > 0)
		{
			cursor.updateY(itemSlots[indexSlot].y);
		}
		

		if (isFocused)
		{
			if (sind_loop != null) sind_loop.update(elapsed);
			
			// DEV: There is a bug? here, If processInput() callbacks to user and user
			//      destroys the menu, then processmouse() will get called but it will throw
			//      because the menu has beeen destroyed!!! I need to work on this.
			
			if (! (inputMode == 0 || isScrolling) )
				processInput();
				
			#if (FLX_MOUSE)
			if (OPT.enable_mouse)
				processMouse();
			#end
		}
		
		while (eventQueue.length > 0)
		{
			eventQueue.shift()();
		}
		
	}//---------------------------------------------------;
	
	public function focus()
	{
		if (isFocused || isScrolling) return;
		isFocused = true;
		queue_listEvent("focus");
		
		if (inputMode == 2) 
		{
			currentItem_Focus(); // > this handles cursor
		}
		
		scroll_ind_update();
		if (sind_loop != null) sind_loop.start();
			
	}//---------------------------------------------------;
	
	public function unfocus()
	{
		if (!isFocused) return;
		isFocused = false;
		
		lastSlot = indexSlot;
		
		queue_listEvent("unfocus");
		
		currentItem_Unfocus();
		if (cursor != null) cursor.visible(false);
		
		if (sind_loop != null)
		{
			sind_loop.stop();
			sind_el[0].visible = sind_el[1].visible = false;
		}
		
	}//---------------------------------------------------;	
	
	/** Animates the menu to viewOn
	 */
	public function viewOn(?onComplete:VList<T,K>->Void, focusAfter:Bool = true, instant:Bool = false)
	{
		if (isFocused) return;
		active = true;
		if (sind_el != null){
			sind_el[0].visible = sind_el[1].visible = false;
		}
		// DEV: Put in an Array [ offset_str , time_str ] e.g. [ "2:3" ,"3.4:2"]
		var vt_IN = STL.vt_IN.split('|');
		tween_allSlots([0, 1], vt_IN[0], "0:0", instant?"0:0":vt_IN[1],
						()->{
							if (focusAfter) focus();
							if (onComplete != null) onComplete(this); 
						}, STL.vt_in_ease, true);
	}//---------------------------------------------------;
	
	/** Animates the menu to viewOff
	 */
	public function viewOff(?onComplete:VList<T,K>->Void, instant:Bool = false)
	{
		unfocus();
		on_scrollComplete(null); // For when if the list is currently scrolling, 
		var vt_OUT = STL.vt_OUT.split('|');
		tween_allSlots([0.9, 0], "0:0", vt_OUT[0], instant?"0:0":vt_OUT[1],
						()->{
							active = false;
							if (onComplete != null) onComplete(this); 
						}, STL.vt_out_ease, false);
	}//---------------------------------------------------;
	
	
	/**
	   0 : Accept No Input.
	   1 : Input scrolls the list. No active element
	   2 : Selectable elements with a cursor
	**/
	public function setInputMode(m:Int)
	{
		if (inputMode == m) return;
		inputMode = m;	
		if (m < 2)	
		{
			// Either no input or just scroll, I don't need a cursor here
			currentItem_Unfocus();
			if (cursor != null) cursor.visible(false);
			
		}else
		if (m == 2)
		{
			if (isFocused) {
				currentItem_Focus();
			}
		}
	}//---------------------------------------------------;
	
	
	// Attach/Set a Cursor object
	public function cursor_set(c:IVListCursor)
	{
		cursor = c;
		cursor.attach(this);	// DEV: makes it hidden
	
		if (isFocused && indexItem != null) {
			cursor_point();
		}
	}//---------------------------------------------------;
	

	// Point cursor to the active focused item
	public function cursor_point()
	{
		if (cursor != null)
		{
			// This will also make cursor visible
			cursor.point(indexItem, itemSlotsX0[indexSlot]);
			
			if (isScrolling) {
				// hack fix. Make the cursor follow the current item when scrolling
				cursor_fix = STL.scroll_time + 0.1; // Handled at update()
			}		
		
		}
	}//---------------------------------------------------;
	
	
	/**
	   Sets a new data source AND INITIALIZES
	   Be sure to have any initialization of styles done up to this point
	**/
	public function setDataSource(arr:Array<K>)
	{
		if (arr == null) return;
		
		alignCenter = STL.align == "center";
		
		poolClear();
		clear_tween_slot();	
		
		indexData = -1;		// Nothing is selected
		indexSlot = -1;		// Nothing is selected
		lastSlot  = -1;
		indexItem = null;   // Nothing is selected
		
		data = arr;
		scrollPadding = STL.scroll_pad;	// I set this here to trigger the setter
		scrollRatio = 0;
		scrollOffset = -1;	// -1 needed for setScroll to work
		scrollMax = data.length - slotsTotal;
		overflows = data.length > slotsTotal;
		
		// Get Child Height if not already
		// Creates a single item, assuming that all items share the same height
		if (itemHeight < 0) {
			_itm = item__createInstance(0);
			itemHeight = Std.int(_itm.height) + STL.item_pad;
			_itm.destroy();
			menu_height = (slotsTotal * itemHeight) - STL.item_pad;
		}
		
		if (inputMode == 2) {
			setSelection(get_nextSelectableIndex(0, 1));
		}else{
			setScroll(0);
		}
		
		// -- AutoWidth
		// This just gets the widest element and sets that for menu_width 
		// DEV: Works best if the menu is not overflowing.
		if (menu_width == 0) {
			for (i in itemSlots) {
				if (i.width > menu_width) menu_width = Std.int(i.width);
			}
		}
		
		scroll_ind_create(overflows);
		
	}//---------------------------------------------------;
	
	/**
	   Sets the current selected item to an index. Alters the scrolling accoringly.
	   - You can call this if this menu isn't focused, and the selected index will be selected once it is focused
	**/
	public function setSelection(ind:Int = 0)
	{
		if (isScrolling || ind == indexData || data.length == 0) {
			return;
		}	

		if (ind >= data.length) {
			ind = data.length - 1;
		}
		
		currentItem_Unfocus();
		
		// Try to place the view index above the cursor , with the scrollpad.
		var _scroll = ind - scrollPadding; 
		lastSlot  = indexSlot;
		indexSlot = scrollPadding;
		indexData = ind;
		
		// If no more space make everything 0, to top
		if (_scroll < 0) {
			indexSlot = ind;
			_scroll = 0;
		}
		
		setScroll(_scroll); // <<------
		
		// Now the real scroll could be different than `_scroll`
		if (scrollOffset < _scroll)
		{
			// The view overflowed too much at the end, 
			// calculating the delta and fixing the index_slot
			var delta = _scroll - scrollOffset;
			indexSlot += delta;
		}
		
		// --
		indexItem = itemSlots[indexSlot];
		if (isFocused) {
			currentItem_Focus();
		}
	}//---------------------------------------------------;
	
	
	/**
	   Hard scroll the view to an index.
	   If the index is off bounds it will be corrected
	   @param	ind 0 is the first element
	**/
	public function setScroll(ind:Int = 0)
	{
		if (isScrolling || (ind == scrollOffset) || (data.length == 0))
			return;
		
		// - Remove all visible elements
		for (i in 0...slotsTotal) {
			if (itemSlots[i] != null) {	
				remove(itemSlots[i]);
				poolPut(itemSlots[i]);
				itemSlots[i] = null;
			}
		}
		
		// - Hard scroll to target index
		if (ind > 0 && ind + slotsTotal > data.length) {
			ind = data.length - slotsTotal;
			if (ind < 0) ind = 0;
			//trace('Debug: Generated index out of bounds, setting to [$ind]');
		}
		
		scrollOffset = ind;
	
		for (i in 0...slotsTotal) {
			if (data[i + ind] != null) {
				itemSlots[i] = item_getAndPlace(i, i + ind);
				itemSlots[i].alpha = 1;
			}else {	
				// trace("Info: No more data to fill into slots");
				break;
			}
		}
		
		scroll_ind_update();
	}//---------------------------------------------------;
	function processInput()
	{
		if (D.ctrl.timePress(UP)) {  // UP
			if (inputMode == 2){
				selectionUp1();
			}else{
				scrollUp1();
			}
		}else 
		
		if (D.ctrl.timePress(DOWN)) {	// DOWN
			if (inputMode == 2){
				selectionDown1();
			}else{
				scrollDown1();
			}
		}else
		
		if (inputMode == 1) return;	else	// Scroll Mode, is only UP/DOWN which were just checked
		// So this is input mode 2 ::
		
		if (D.ctrl.timePress(LEFT, 0.7, 0.08, 0.02)) {
			indexItem.onInput(left);
		}else
		
		if (D.ctrl.timePress(RIGHT, 0.7, 0.08, 0.02)) {
			indexItem.onInput(right);
		}else
		
		if (D.ctrl.justPressed(A)) {
			if (OPT.fire_simple)
				queue_itemEvent(fire);
			else
				indexItem.onInput(fire);
		}else
		
		if (D.ctrl.justPressed(X)) {
			queue_listEvent("back");
		}else
		
		if (D.ctrl.justPressed(START)) {
			if (OPT.start_button_fire)
				indexItem.onInput(fire);
			else
				queue_listEvent("start");
		}
		
	}//---------------------------------------------------;
	
	
	// Check if point overlaps with an item
	// DEV: Note that I am not checking for the actual item rectangle
	//      since the item could be scrolled to the side. I am checking
	//		the position the item should be when idle
	function _pointOverlapsWithSlot(cX:Float, cY:Float, cSlot:Int):Bool
	{
		_itm = itemSlots[cSlot];
		if (_itm == null) return false;
		
		if (indexSlot == cSlot)
		// Focused items
		return (
			cY >= _itm.y && cY < (_itm.y + _itm.height + STL.item_pad) &&
			cX >= _itm.x - _mcheckpad[0] &&
			cX <= _itm.x + _itm.width + _mcheckpad[1]);
			
		// Unfocused Items
		return ( 
			cY >= _itm.y && cY < (_itm.y + _itm.height + STL.item_pad) &&
			cX >= itemSlotsX0[cSlot] - _mcheckpad[0] &&
			cX <= itemSlotsX0[cSlot] + _itm.width + _mcheckpad[1]);
			
	}//---------------------------------------------------;
	
	function processMouse()
	{
		// DEV: Just checking X is enough to know that this menu is locked
		var mCoords:FlxPoint;
		if (this.scrollFactor.x == 0) {
			mCoords = FlxG.mouse.getPositionInCameraView(this.camera);
		}else{
			mCoords = FlxG.mouse.getWorldPosition(this.camera);
		}
		
		var mouseMoved = !mCoords.equals(oCoords);
		if (mouseMoved) {
			oCoords.put();
			oCoords = mCoords;
		}else {
			mCoords.put();
		}
		
		// :: Check mouse Scroll - 
		//  Anywhere on the screen for now
		if (overflows && inputMode > 0) 
		{
			if (FlxG.mouse.wheel < 0 && scrollDown1()) 
			{
				if(inputMode==2) {
					indexData++;
					on_dataIndexChange();
				}
				return;
			}
		
			if (FlxG.mouse.wheel > 0 && scrollUp1()) 
			{
				if(inputMode==2) {
					indexData--;
					on_dataIndexChange(); 
				}
				return;
			}
		}// --
		
		// :: Check for item interaction
		if (inputMode < 2) return;
		
		// :: Rollover, Clicks check
		for (slot in 0...slotsTotal) 
		{
			if (_pointOverlapsWithSlot(mCoords.x, mCoords.y, slot))
			{
				if (FlxG.mouse.justPressed) 
				{
					_itm.onInput(click(Std.int(mCoords.x - _itm.x), Std.int(mCoords.y - _itm.y)));
					continue;
				}
				
				if (!mouseMoved) continue;
				
				if (!_itm.isFocused) 
				{
					if(item_isSelectable(_itm))
					{
						indexData += slot - indexSlot;	// Point to correct data
						lastSlot = indexSlot;
						indexSlot = slot;
						on_dataIndexChange();
					}
				}
				
				break;	// No need to check anything else. An element was triggered
			}
			
		}// --
		
	}//---------------------------------------------------;
	
	/**
	 * Scroll the entire list down by one element
	 * :: Reveals the bottom! the elements actually will go up
	 */
	function scrollDown1():Bool
	{	
		if (isScrolling || (!get_hasMoreDown()))
			return false;

		_markedItem = itemSlots[0]; // Item that goes off-list
		
		var _cnt = 0;
		while (_cnt < slotsTotal)
		{
			if (STL.scroll_time==0) {
				itemSlots[_cnt].y -= itemHeight;
			}else {
				var pr = { y:itemSlots[_cnt].y - itemHeight };
				if (_cnt == 0) Reflect.setField(pr, "alpha", 0); // Fade the first element only
				tween_slot.push(FlxTween.tween(itemSlots[_cnt], pr, STL.scroll_time));
			}
			itemSlots[_cnt] = itemSlots[_cnt + 1];
			itemSlotsX0[_cnt] = itemSlotsX0[_cnt + 1];
			_cnt++;
		}
		
		_cnt--; // Point to the last slot
		
		if (STL.scroll_time == 0) {
			_itm = item_getAndPlace(_cnt , scrollOffset + _cnt + 1);
			_itm.alpha = 1;
			scrollOffset++;
			itemSlots[_cnt] = _itm;
			on_scrollComplete(null);
			
		}else {
			// _cnt is now +1;
			_itm = item_getAndPlace(_cnt , scrollOffset + _cnt + 1, 1);	
			_itm.alpha = 0;
			scrollOffset++;
			itemSlots[_cnt] = _itm;
			isScrolling = true;
			tween_slot.push(FlxTween.tween(_itm, { alpha:1, y:_itm.y - itemHeight }, STL.scroll_time, 
					{ onComplete:on_scrollComplete } ));
		}

		return true;
	}//---------------------------------------------------;

	/**
	 * Scrolls entire list up by one element
	 * :: Reveals the top! the elements actually will go down
	 */
	function scrollUp1():Bool
	{
		if (isScrolling || (!get_hasMoreUp()))
			return false;
			
		var _i1 = slotsTotal - 1; // For quick reference, the last element
		
		_markedItem = itemSlots[_i1];

		var _cnt = _i1; // last index
		while (_cnt >= 0) {
			if (STL.scroll_time==0) {
				itemSlots[_cnt].y += itemHeight; // itemHeight includes padding
			}else {
				var pr = { y:itemSlots[_cnt].y + itemHeight };
				if (_cnt == _i1) Reflect.setField(pr, "alpha", 0);
				tween_slot.push(FlxTween.tween(itemSlots[_cnt], pr, STL.scroll_time));
			}
			itemSlots[_cnt] = itemSlots[_cnt - 1];
			itemSlotsX0[_cnt] = itemSlotsX0[_cnt - 1];	// last iteration will fetch [-1], but its ok.
			_cnt--;
		}
		
		_cnt++; // Fix count to point to the new slot
		
		if (STL.scroll_time==0)
		{
			_itm = item_getAndPlace(_cnt, scrollOffset - 1);
			_itm.alpha = 1;
			scrollOffset--;
			itemSlots[0] = _itm;
			on_scrollComplete(null);
		}else
		{
			_itm = item_getAndPlace(_cnt, scrollOffset - 1, -1);
			_itm.alpha = 0;
			scrollOffset--;
			itemSlots[0] = _itm;
			isScrolling = true;
			tween_slot.push(FlxTween.tween(_itm, { alpha:1, y:_itm.y + itemHeight }, 
				STL.scroll_time, { onComplete:on_scrollComplete } ));
		}
		
		return true;
	}//---------------------------------------------------;
	
	/** Move the cursor one position up
	 */
	function selectionUp1()
	{
		if (indexData == 0) {
			if (STL.loop) {
				lastSlot = indexSlot;
				setSelection(data.length - 1); 
			}
			return;
		}
		
		var r_1 = get_nextSelectableIndex(indexData - 1, -1);
		if (r_1 < 0) return; // Can't find a selectable item
		lastSlot = indexSlot;
	
		// r_1 is now Delta, Amount to go up
		r_1 = indexData - r_1;
		
		if (indexSlot - r_1 >= scrollPadding) { // No view scroll is needed
			indexSlot -= r_1;
			indexData -= r_1;
			on_dataIndexChange();
		}else
		{
			if (r_1 > 1) {
				setSelection(indexData - r_1);
				return;
			}
	
			if (isScrolling) return;
			
			if (scrollUp1()) {
					indexData--;
					on_dataIndexChange();
			}else {
				// The scroll padding has reached the end
				if (indexSlot > 0) {
					indexSlot--;
					indexData--;
					on_dataIndexChange();
				}
			}
		}
	}//---------------------------------------------------;
	
	/** Move the cursor one position down
	 */
	function selectionDown1()
	{
		// Sometimes when not the entire slots are filled,
		// prevent scrolling to an empty slot by checking this.
		if (indexData == data.length - 1) {
			if (STL.loop) {
				lastSlot = indexSlot;
				setSelection(0);
			}
			return;
		}
		
		var r_1 = get_nextSelectableIndex(indexData + 1, 1);
		if (r_1 == -1) return;
		
		lastSlot = indexSlot;
		
		r_1 = r_1 - indexData; // r_1 is now Delta, Amount to go down
		
		if (indexSlot + r_1 < slotsTotal - scrollPadding) { // No view scroll is needed
			indexSlot += r_1;
			indexData += r_1;
			on_dataIndexChange();
		}else
		{
			if (r_1 > 1) {
				// trace("Warning: Scrolling more than 1 element is not supported. Hard Scrolling.");
				setSelection(indexData + r_1);
				return;
			}
			
			if (isScrolling) return;
			
			if (scrollDown1()) {
				indexData++;
				on_dataIndexChange();
			}else
			{
				if (indexData < data.length - 1) {
					indexSlot++;
					indexData++;
					on_dataIndexChange();
				}
			}
		}
	}//---------------------------------------------------;
	
	
	/** Animates current item, according to the STYLE rules
	 *  Also triggers the cursor if any
	**/
	function currentItem_Focus()
	{
		if (indexItem == null) return;
		indexItem.focus();
		
		if (STL.focus_anim != null)
		{
			currentItem_Tween(
				indexItem,
				x + get_itemStartX(indexItem) + STL.focus_anim.x,
				overflows ? null : (y + (indexSlot * itemHeight) + STL.focus_anim.y),
				STL.focus_anim.inTime,
				STL.focus_anim.inEase
			);	
		}
		
		cursor_point();
	}//---------------------------------------------------;	
		
	/**
	 * Put the current item back in its resting position
	**/
	function currentItem_Unfocus()
	{	
		if (indexItem == null) return;
		indexItem.unfocus();
		
		if (STL.focus_anim != null)
		{
			currentItem_Tween(
				indexItem,
				x + get_itemStartX(indexItem),
				overflows ? null : (y + (lastSlot * itemHeight) ),
				STL.focus_anim.outTime,
				STL.focus_anim.outEase
			);
		}
		
	}//---------------------------------------------------;
	
	
	// -- Helper tool
	// Either instant move an item, or create a tween
	function currentItem_Tween(_it:FlxSprite, _x:Float, _y:Null<Float>, _time:Float, _ease:EaseFunction)
	{
		if (tween_map.exists(_it)) {
			tween_map.get(_it).cancel();
		}
		
		if (_time == 0)
		{
			_it.x = _x;
			if (_y != null) _it.y = _y;
			return;
		}
		
		var values:Dynamic = { x : _x };
		if (_y != null) values.y = _y;
		
		tween_map.set(_it, 
			FlxTween.tween(_it, values, _time, {ease:_ease})
		);
	}//---------------------------------------------------;
	
	
	/**
	 * Called after any scroll change, Checks/Updates if scroll inds should be visible
	 */
	function scroll_ind_update()
	{
		if (!overflows || sind_el == null) return;
		scrollRatio = scrollOffset / scrollMax;
		
		sind_el[0].visible = get_hasMoreUp();
		sind_el[1].visible = get_hasMoreDown();
	}//---------------------------------------------------;
	
	// Refresh scroll indicator Y Position
	function scroll_ind_tick(v:Int)
	{
		if (sind_ty < 3) {
			sind_el[0].y = this.y - STL.sind_size - v;
			sind_el[1].y = this.y + menu_height + v;
		}else{
			if (get_hasMoreDown()) sind_el[1].visible = ! sind_el[1].visible;
			if (get_hasMoreUp())   sind_el[0].visible = ! sind_el[0].visible;
		}
	}//---------------------------------------------------;
	
	/** Create/Remove the scrolling indicators */
	function scroll_ind_create(create:Bool = true)
	{
		if (create)
		{
			function cs(name) {
				var a = new FlxSprite(0, 0, D.bmu.replaceColor(D.ui.getIcon(STL.sind_size, name), 0xFFFFFFFF, STL.sind_color));
				a.active = false;
				a.offset.x = -STL.sind_offx;
				return a;
			};
			if (sind_el != null) return;	
			var s = STL.sind_anim.split(',');	// Read the CSV data
				sind_ty = Std.parseInt(s[0]);	// Type
				sind_el = [ cs('ar_up'), cs('ar_down') ];
				sind_el[0].x = sind_el[1].x = switch(STL.align) {
					case "center", "justify" : (menu_width / 2) - (sind_el[0].width / 2);
					case _: OPT.sc_ind_pad;
				};
			sind_el[0].y = -STL.sind_size;
			sind_el[1].y = menu_height;
			add(sind_el[0]); add(sind_el[1]);
			sind_loop = new StepLoop(sind_ty, Std.parseInt(s[1]), Std.parseFloat(s[2]), scroll_ind_tick);
			sind_loop.fire();	// Force a tick to position on the Y axis NOW			
		}else{
			if (sind_el == null) return;
			remove(sind_el[0]); remove(sind_el[1]); 
			sind_el = FlxDestroyUtil.destroyArray(sind_el);
			sind_loop = null;
		}
	}//---------------------------------------------------;
	
	// --
	// All item callbacks are handled here
	// DEV: This is extended by MPage, that's why.
	function on_itemCallback(e:ListItemEvent)
	{
		queue_itemEvent(e);
	}//---------------------------------------------------;
	
	// -- 
	// Cursor data has changed, reflect to visual
	// :: indexData, indexSlot have changed.
	// - Called from ( selectionDownUp1 )
	function on_dataIndexChange()
	{
		currentItem_Unfocus();
		indexItem = itemSlots[indexSlot];
		currentItem_Focus();
	}//---------------------------------------------------;	
	
	// - Called on every scroll-by-one tween complete
	function on_scrollComplete(?t:FlxTween)
	{
		clear_tween_slot();
		if (_markedItem != null) {
			remove(_markedItem); // from the scene
			poolPut(_markedItem);
		}
		_markedItem = null;
		
		// DEV: I am checking this, because the menu could unfocus while it was scrolling.
		if(isFocused){
			scroll_ind_update();
		}
	}//---------------------------------------------------;		
	
	
	

	//====================================================;
	
	// If has more elements above the view window
	inline function get_hasMoreUp():Bool 
	{
		return (scrollOffset > 0);
	}//---------------------------------------------------;
	
	// If has more elements below the view window
	inline function get_hasMoreDown():Bool
	{
		return (scrollOffset + slotsTotal < data.length);
	}//---------------------------------------------------;
	
	/** Utility, goes through all viewOn items and returns the maximum width found */
	@:deprecated("Relic of an old version. Seems unused")
	function get_maxItemWidthInView():Float
	{
		var m:Float = 0;
		for (i in itemSlots){
			if (i != null && (i.width > m)) m = i.width;	
		}
		return m;
	}//---------------------------------------------------;
	/**
	   This is to determine the X position of the Items relative to List Start
	   - This is so I can implement left/center align
	**/
	function get_itemStartX(el:T):Float
	{	
		if (alignCenter) {
			return (menu_width - el.width) / 2;
		}else {
			return 0;
		}
	}//---------------------------------------------------;
	
	/** -- Mainly for FLXMenu/MPage --
	 * Get the next selectable item index, starting and including &fromIndex 
	 * @param	fromIndex Starting index to search from
	 * @param	direction >0 to search downwards, <0 to search upwards
	 * @return
	 */
	function get_nextSelectableIndex(fromIndex:Int, direction:Int = 1):Int
	{
		// -- OVERRIDE THIS --
		return fromIndex;
	}//---------------------------------------------------;
	
	
	
	/** = Animates all slots 
	   Mainly used for the viewOn,viewOff animations
	   NOTE :	- Starting offsets from current pos ( will directly move the elements there )
	    		- Ending offsets from the initial positions (so 0,0 will end at init pos)
				
		@param hardstart Place/Snap the elements at the starting offset and go from there
	**/
	function tween_allSlots(	Alphas:Array<Float>, StartOffs:String, EndOffs:String, Times:String,
								onComplete:Void->Void, easeID:String, hardstart:Bool )
	{
		if (itemSlots.length == 0) {
			trace("Warning: the list was not initialized, initializing now");
			setScroll(0);
		}
		
		var tt:Array<Float> = Times.split(':').map((s)->Std.parseFloat(s));
		
		#if hl
			var off0:Array<Int> = [for (i in StartOffs.split(':')) Std.parseInt(i)];
			var off1:Array<Int> = [for (i in EndOffs.split(':')) Std.parseInt(i)];
		#else
			// BUG: Send a report, this does not work in Hl and it should?
			var off0:Array<Int> = StartOffs.split(':').map((s)->Std.parseInt(s));
			var off1:Array<Int> = EndOffs.split(':').map((s)->Std.parseInt(s));		
		#end

		clear_tween_slot();
		clear_tween_map();
		
		if (tt[0] == 0 && tt[1] == 0) // Instant
		{
			isScrolling = false;
			return onComplete();
		}
		
		if (tt[0] == 0) tt[0] = FlxG.elapsed; // Fix a bug?
		
		var easeFn:Float->Float = Reflect.field(FlxEase, easeID);
		
		var i:Int = 0;
		while (itemSlots[i] != null)
		{
			_itm = itemSlots[i];
			var sx = x + (get_itemStartX(_itm));
			var sy = y + (i * itemHeight);
			if (hardstart) {
				_itm.x = sx + off0[0];
				_itm.y = sy + off0[1];
			}
			_itm.alpha = Alphas[0];
			tween_slot.push(FlxTween.tween(itemSlots[i], { x:sx + off1[0], y:sy + off1[1], alpha:Alphas[1] },
				tt[0], { startDelay:(i * tt[1]), ease:easeFn } ));
			i++;
		} // --
		
		isScrolling = true;
		// Get the last tween put a callback to it
		tween_slot[tween_slot.length - 1].onComplete = (_)->{
			clear_tween_slot();
			onComplete();
		}
		
	}//---------------------------------------------------;
	
	function clear_tween_slot()
	{
		D.dest.tweenAr(tween_slot);
		tween_slot = [];
		isScrolling = false;
	}//---------------------------------------------------;
	
	function clear_tween_map()
	{
		for (tw in tween_map) tw.cancel();	// Note this is a MAP
	}//---------------------------------------------------;
	
	
	// Sanitize the scrollpad, to not exceed the middle
	function set_scrollPadding(val:Int)
	{
		if (val > Math.floor(slotsTotal / 2)) {
			val = Math.floor(slotsTotal / 2);
		}
		return scrollPadding = val;
	}//---------------------------------------------------;
	
	
	
	/** This is separate because MPAGE has elements that can't be focused */
	function item_isSelectable(it:T):Bool
	{
		return true;
	}//---------------------------------------------------;
	
   /**
	* Get a Recycled or New Item Element
	* put it into a screen slot, and set it with data
	* # Adds it to the stage
	* @param	ySlot 		, 0 is the first slot
	* @param	dataIndex	, The index of the data array to pass
	* @param	offsetSlot	, Used for positioning, -1,0,+1
	*/
	function item_getAndPlace(slotNum:Int, dataIndex:Int, offsetSlot:Int = 0):T
	{
		_itm = poolGet(dataIndex);
		_itm.visible = true; // Just in case
		_itm.y = (slotNum + offsetSlot) * itemHeight;
		_itm.x = get_itemStartX(_itm);
		_itm.unfocus(); // Element might be focused or just created. Just in case to default?
		add(_itm);
		itemSlotsX0[slotNum] = Math.round(_itm.x);	// after (add) so it gets global coords
		// Note: At this point the alpha could be anything because of recycle
		// Set the desired alpha after getting this.
	   return _itm;
	}//---------------------------------------------------;
	

	
	/** I need this to be in a separate function so that I can override this
	    e.g. VListMenu overrides and returns different class objects.
	**/
	function item__createInstance(dataIndex:Int):T
	{
		return Type.createInstance(itemClass, []);
	}//---------------------------------------------------;
	
	/**
	   Set pool mode and max size. Call this right after new()
	   @param	keep TRUE to keep elements in memory (for multiclass ITEMS), FALSE to recycle (for same class ITEMS)
	   @param	size Max Size of the Pool
	**/
	public function poolSet(_keep:Bool = true, size:Int = DEFAULT_POOL_MAX)
	{
		pool_keep = _keep;
		pool_max  = size;
	}//---------------------------------------------------;
	
	public function poolClear()
	{
		if (pool != null) for (i in pool) i.destroy();
		pool = [];
	}//---------------------------------------------------;
	
	function poolPut(el:T)
	{
		//trace('Pool PUT | len:${pool.length}, size:${pool_max}');
			  
		// Do I need this one??
		if (pool_keep && pool.indexOf(el) >= 0) return;
		
		pool.push(el);
		if (pool.length > pool_max) {
			_itm = pool.shift();
			_itm.destroy();
			_itm = null;
		}
	}//---------------------------------------------------;
	
	/**
	   Get an item from pool, or if not possible
	   Generate a new item.
	   @param	ind Data index to get (0 -> data.length-1)
	**/
	function poolGet(ind:Int):T
	{
		if (pool_keep) {
			for (i in 0...pool.length) {
				if (pool[i].isSame(data[ind])){
					_itm = pool[i];
					pool.splice(i, 1);
					return _itm;
				}
			}
		}else{
			if (pool.length > 0){
				_itm = pool.shift();
				_itm.setData(data[ind]);
				return _itm;
			}
		}
		// Did not find anything in the pool (keep or recycle)
		// Create a new one, also initialize some fields
		_itm = item__createInstance(ind);
		_itm.setData(data[ind]);
		_itm.moves = false;
		_itm.callback = on_itemCallback;
		return _itm;
	}//---------------------------------------------------;
	
	// - Move the FlxSpriteGroup without breaking it
	override function set_x(Value:Float):Float 
	{
		var delta = Math.round(Value - x);
		for (i in 0...itemSlotsX0.length) {
			itemSlotsX0[i] += delta;
		}
		return super.set_x(Value);
	}//---------------------------------------------------;
	
	
}// -- end //
