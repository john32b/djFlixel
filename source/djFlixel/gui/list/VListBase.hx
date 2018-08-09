package djFlixel.gui.list;

import djFlixel.gfx.GfxTool;
import djFlixel.gui.list.IListItem;
import djFlixel.gui.BlinkSprite;
import djFlixel.gui.Styles;
import djFlixel.tool.DEST;
import djFlixel.tool.DataTool;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.util.FlxDestroyUtil;

/**
 * == Basic Vertical List ==
 * 
 * A general purpose listbox that handles custom sprites in a vertical scrollable list. 
 * This base class supports only presenting and scrolling of the elements.
 * Extra functionality is implemented in the extended VListNav class.
 * 
 * # Purpose is to be extended into a more specific class
 *   or you can use it as a bare element scroller
 * 
 * # Children must have a standard Height and implement <IListItem>
 * 
 * # It's is used like a HUD element and is fixed on the screen. (scrolloffset=0)
 * 
 * T: Type Element of Child, must be or derive from FlxSprite and implement IListItem
 * K: Type of Child Data
 * 
 */
#if (haxe_ver >= "4.0.0")
class VListBase<T:IListItem<K> & FlxSprite, K> extends FlxGroup
#else
class VListBase<T:(IListItem<K>,FlxSprite),K> extends FlxGroup
#end
{	
	
	// -- Some Static Defaults ::
	// --
	static inline var DEF_SLOTS:Int = 3;
	static inline var DEF_POOL_REUSE_MAX:Int = 8;
	static var DEF_POOL_MODE:String = "recycle"; // [off, reuse, recycle], see below for explanation

	// -- User Set Object Variables::
	// --
	// If true, then the elements are initialized right after setting data
	// e.g. FLXMenu doesn't need that to happen.
	public var flag_InitViewAfterDataSet:Bool = true;
		
	// Custom Styling and parameters
	public var styleB:StyleVLBase;
		
	// -- System ::
	
	// Positioning, Size and some states :
	public var x(default, null):Float;
	public var y(default, null):Float;
	public var width(default, null):Int;
	public var height(default, null):Int;			// The height is autoset on initialization based on the slot length
	public var isFocused(default, null):Bool;
	public var isScrolling (default, null):Bool;	// True if any sort of tweening is in effect
	
	var _elementClass:Class<T>;	// The class of Items expected to be set
	
	// Keep all the tweens applied to this object, so that I can remove them
	var allTweens:Array<VarTween>;
	
	// Start positioning the elements from this Y offset from the top
	var posOffsetY:Int = 0;
	
	// Current pooling mode [ off | recycle | reuse ]
	var pooling_mode:String;
	
	// It is quicker to read BOOLS than compare STRINGS, so I have those:
	var flag_pool_recycle:Bool;
	var flag_pool_reuse:Bool;
	
	var _pool:Array<T> = null;
	var _pool_length:Int;
	var _pool_max_size:Int;
	
	// Have objects become available to get recycled after their animation is complete.
	var markedForRemoval:Array<T>;
	
	// -- Elements ::
	// --
	var elementSlots:Array<T>;	// As the elements that appear on the menu (slots)
	var elementHeight:Int; 		// INCLUDES PADDING !!
	
	
	// -- Data ::
	// --
	var _data:Array<K>;		// This holds the data in an array (e.g. MItemData)
	var _data_length:Int;	// Total data elements
	var _scrollOffset:Int;	// What data Index is on the top slot
	var _slotsTotal:Int;	// Or Total slots that fit on the menu

	
	// -- Helpers
	// Quick element pointer
	var r_el:T;
	// Quick Int
	var r_1:Int;
	// Quick Int 
	var counter:Int;
		
	
	// - Scrolling Indicators --  
	//	When there are more elements above or below 
	//	You can style the indicators from (StyleB.scrollInd)
	var scInd:Array<BlinkSprite> = null;
	
	
	// There are more elements than there are slots
	public var flag_overflow(default, null):Bool;
	// ===================================================;
	// ===================================================;
	
	/**
	 * Create a Basic Vertical List object.
	 * @param	X Position on the screen.
	 * @param	Y Position on the screen.
	 * @param	WIDTH 0 for rest of the screen, <0 for mirrored padding from X to the right
	 * @param	SlotsTotal How many slots to show on the screen (has a default if 0)
	 */
	public function new(ObjClass:Class<T>, X:Float = 0, Y:Float = 0, WIDTH:Int = 0, SlotsTotal:Int = 0)
	{
		super();
		x = X; y = Y; width = WIDTH;
		_elementClass = ObjClass;
		
		_slotsTotal = SlotsTotal;
		if (_slotsTotal < 1) _slotsTotal = DEF_SLOTS;
		
		if (width == 0) {
			// Rest of the screen
			width = cast FlxG.width - x;
		}else if (width < 0 ) {
			// Mirrored X padding to the right
			width = cast FlxG.width - (x * 2);
		}
		
		// -- Other Data
		r_el = null;
		elementHeight = -1;	// Set Later
		elementSlots = new Array<T>();
		
		isScrolling = false;
		isFocused = false;
		markedForRemoval = [];
		_data = null;
		_data_length = 0;
		_scrollOffset = -1; // -1 allows it to be initialized because it's going to be checked if 0
				
		allTweens = [];
		pooling_mode = null;
		
		
	}//---------------------------------------------------;
	
	/**
	 * Call this after any scroll change. Creates and updates the more arrows
	 * These are indicators that blink and show that are are more elements in that direction
	 */
	function updateScrollIndicator()
	{
		if (_data_length <= _slotsTotal) return; // No need to create
		
		if (scInd == null) 
		{
			// Default Style :
			var c = DataTool.copyFields(styleB.scrollInd, {
				size:Gui.getApproxIconSize(Std.int(elementHeight * 0.7)),
				color:0xFFEEEEEE,
				color_border:0xFF333333,
				alignment:styleB.alignment,
				offset:[0, 0],
				blinkRate:0.3
			});
			
			scInd = [];

			for (i in 0...2)
			{
				scInd[i] = new BlinkSprite();
				scInd[i].blinkRate = c.blinkRate;
				scInd[i].scrollFactor.set(0, 0);
				scInd[i].loadGraphic(Gui.getIcon( ["ar_up", "ar_down"][i], c.size, null, c.color_border, 0, cast c.size / 8));
				scInd[i].replaceColor(0xFFFFFFFF, c.color);
				insert(i, scInd[i]);
				// Position at X Axis
				switch(c.alignment) {
					case "right":
						scInd[i].x = x + width - elementHeight; //YES, HEIGHT, puts it a bit further
					case "justify", "center":
						scInd[i].x = x + (width / 2) - (scInd[i].width / 2);
					default: // "left"
						scInd[i].x = x + elementHeight; //YES, HEIGHT, puts it a bit further
				}

			}// end loop
			
			
			// Position at Y axis:
			// A 2 pixel extra padding seems to work and avoid overlapping in most occasions
			
			// I want nothing above the 0.0 horizontal line, so push everything down
			// to compensate for the scroll indicator
			// Arrows are half the frame height
			
			posOffsetY = Math.ceil(c.size / 2) + 2;
			posOffset(0, posOffsetY);
			height += posOffsetY;
			scInd[0].y = y - Math.ceil(c.size / 2) + c.offset[0];
			scInd[1].y = y + height + styleB.el_padding + c.offset[1] + 2;
			
		} // --
		
		scInd[0].set(hasMoreAbove());
		scInd[1].set(hasMoreBelow());
		scInd[0].sync(); scInd[1].sync();
	}//---------------------------------------------------;
	
	
	// Sets a new data source AND INITIALIZES
	// Be sure to have any initialization or styles done up to this point
	public function setDataSource(arr:Array<K>)
	{
		// - Some checks for safeguarding
		if (arr == null) {
			trace("Error: Array is null"); return;
		}

		_data = arr;
		_data_length = _data.length;
		flag_overflow = _data_length > _slotsTotal;
		// trace('Info: Added data source with [$_data_length] number of elements');
		
		// Ready this to accept new data
		clearTweens();
		
		// Get the default style if it's not set already. (rare)
		if (styleB == null) {
			styleB = Styles.DEF_STYLEVLBASE;
		}
		
		// Removed Width init
		// --
		
		// Get Child Height if not already
		// Also :: Set the starting positions of all the slots ::
		if (elementHeight < 0) {
			r_el = factory_getElement(0);
			elementHeight = Std.int(r_el.height) + styleB.el_padding;
			r_el.destroy();
			height = (_slotsTotal * elementHeight) - styleB.el_padding;
		}
		
		// Pooling?
		if (pooling_mode == null)
			setPoolingMode(DEF_POOL_MODE);
			
		// It's going to be called upon the first open
		if (flag_InitViewAfterDataSet) {
			_scrollOffset = -1;
			setViewIndex(0);
		}
		
	}//---------------------------------------------------;
	
	// -- Helper
	public function clearTweens()
	{
		DEST.tweenAr(allTweens);
		allTweens = [];
	}//---------------------------------------------------;
	
	// --
	override public function destroy():Void 
	{
		super.destroy();
	
		clearTweens();
		
		_data = null;
		elementSlots = null;
		markedForRemoval = null;
		styleB = null;
		
		_pool = FlxDestroyUtil.destroyArray(_pool);
		
	}//---------------------------------------------------;
	
	/**
	 * Scroll the entire list down by one element
	 * :: Reveals the bottom! the elements actually will go up
	 * @return
	 */
	public function scrollDownOne():Bool
	{	
		#if debug
			if (isScrolling) {
				trace("Error: Was animating and it should not. Cancelling request to scroll.");
				return false;
			}
		#end
		
		if (hasMoreBelow()) {
			// - Do operations, [0] is Guaranteed to exist
			// - First one gets deleted
			markedForRemoval.push(elementSlots[0]);
			
			counter = 0;
			while (counter < _slotsTotal)
			{
				if (styleB.el_scroll_time==0) {
					elementSlots[counter].y -= elementHeight;
				}else
				{
					var pr = { y:elementSlots[counter].y - elementHeight };
					if (counter == 0) Reflect.setField(pr, "alpha", 0); // Fade the first element only
					allTweens.push(FlxTween.tween(elementSlots[counter], pr, styleB.el_scroll_time));
				}

				elementSlots[counter] = elementSlots[counter + 1];
				counter++;
			}
			
			if (styleB.el_scroll_time == 0) {
				
				r_el = getNewElementIntoPos(counter - 1 , _scrollOffset + counter);
				_scrollOffset++;
				elementSlots[counter - 1] = r_el;
				__scrollComplete(null);
				
			}else {
				// At this point counter points to the index that isn't there
				// New element at the bottom;
				r_el = getNewElementIntoPos(counter , _scrollOffset + counter);
				_scrollOffset++;
				elementSlots[counter - 1] = r_el;
				isScrolling = true;

				r_el.alpha = 0;
				allTweens.push(FlxTween.tween(r_el, { alpha:1, y:r_el.y - elementHeight }, styleB.el_scroll_time, 
						{ onComplete:__scrollComplete } ));
			}

			return true;
			
		}else {
			// trace("Can't go down more");
			return false;
		}
	}//---------------------------------------------------;

	/**
	 * Scrolls entire list up by one element
	 * :: Reveals the top! the elements actually will go down
	 * @return
	 */
	public function scrollUpOne():Bool
	{
		if (isScrolling) {
			trace("Error: Was animating and it should not. Cancelling request to scroll.");
			return false;
		}
		
		if (hasMoreAbove()) {
			// It is guaranteed that the view has more than maxslots elements
			
			// For quick reference, the last element
			r_1 = _slotsTotal - 1;
			
			// - Last one gets deleted
			markedForRemoval.push(elementSlots[r_1]);

			counter = r_1; // last index
			while (counter >= 0)
			{
				if (styleB.el_scroll_time==0) {
					elementSlots[counter].y += elementHeight; // elementHeight includes padding
				}else {
					var pr = { y:elementSlots[counter].y + elementHeight };
					if (counter == r_1) Reflect.setField(pr, "alpha", 0);
					allTweens.push(FlxTween.tween(elementSlots[counter], pr, styleB.el_scroll_time));
				}
			
				elementSlots[counter] = elementSlots[counter - 1];
				counter--;
			}
			
			if (styleB.el_scroll_time==0)
			{
				// Counter is now -1;
				r_el = getNewElementIntoPos(counter + 1, _scrollOffset - 1);
				_scrollOffset--;
				elementSlots[0] = r_el;
				__scrollComplete(null);
			}else
			{
				// Counter is now -1;
				r_el = getNewElementIntoPos(counter, _scrollOffset - 1);
				_scrollOffset--;
				r_el.alpha = 0;
				elementSlots[0] = r_el;
				
				isScrolling = true;

				allTweens.push(FlxTween.tween(r_el, { alpha:1, y:r_el.y + elementHeight }, 
					styleB.el_scroll_time, { onComplete:__scrollComplete } ));
			}
			
			return true;
		}else {
			// trace("Can't go up more");
			return false;	
		}
		
	}//---------------------------------------------------;
	
	
	// #Override to add functionality
	public function focus()
	{
		isFocused = true;
	}//---------------------------------------------------;
	
	// #Override to add functionality
	public function unfocus()
	{
		isFocused = false;
		if (scInd[0] != null) {
			scInd[0].set(false);
			scInd[1].set(false);
		}
	}//---------------------------------------------------;
	
	
	//====================================================;
	// 
	//====================================================;
	
	// --
	// Mainly used for the onScreen,offScreen animations
	// Animates all slots 
	// NOTE :	- Starting offsets from current pos ( will directly move the elements there )
	// 			- Ending offsets from the initial positions (so 0,0 will end at init pos)
	function animateAllSlots(	Alpha:Array<Float>, StartOffs:Array<Int>,
								EndOffs:Array<Int>, onComplete:Void->Void) 
								
	{
				
		// if easeFn is null, then the animation is going to be linear
		var easeFn:EaseFunction = Reflect.field(FlxEase, styleB.stw_el_ease);

		clearTweens();
		
		var i:Int = 0;
		while (elementSlots[i] != null)
		{
			r_el = elementSlots[i];
			r_el.alpha = Alpha[0];
			r_el.x += StartOffs[0];
			r_el.y += StartOffs[1];
			
			allTweens.push(FlxTween.tween(elementSlots[i], {
				x:getStartingXPos(r_el) + EndOffs[0], 	// Ending at init pos + offset
				y:y + (i * elementHeight) + posOffsetY + EndOffs[1], // -- same --
				alpha:Alpha[1] }, styleB.stw_el_time,
				{ startDelay:(i * styleB.stw_el_wait), ease:easeFn } 
				));
	
			i++;
		}
		
		isScrolling = true;
		
		// Get the oldest tween and put a callback to it
		allTweens[allTweens.length - 1].onComplete = function(?tw:FlxTween){
			isScrolling = false;
			clearTweens();
			onComplete();
		}
		
	}//---------------------------------------------------;
	
	
	/**
	 * Animates the menu to onScreen
	 * @param	focusAfter
	 * @param	onComplete
	 */
	public function onScreen(focusAfter:Bool = true, ?onComplete:Void->Void)
	{
		visible = true;
		animateAllSlots([0, 1], styleB.stw_el_EnterOffs, [0, 0],
						function() {
							if (focusAfter) focus();
							if (onComplete != null) onComplete(); 
						});
	}//---------------------------------------------------;
	/**
	 * Animates the menu to offScreen
	 * @param	onComplete
	 */
	public function offScreen(?onComplete:Void->Void)
	{
		unfocus();
		animateAllSlots([0.9, 0], [0, 0], styleB.stw_el_ExitOffs,
						function() {
							visible = false;
							if (onComplete != null) onComplete(); 
						});
	}//---------------------------------------------------;

	// Sets a new view index and resets the elements
	// to reflect the new data.
	public function setViewIndex(ind:Int = 0)
	{
		if (isScrolling) {
			trace('Warning: Setting new scrollview will cause trouble, returning.');
			return;
		}	
		
		if (ind == _scrollOffset) {
			// trace('Warning: Requested to set view to same index [$ind], Skipping.');
			return;
		}
		
		if (_data_length == 0){
			trace('Warning: This list is empty');
			return;
		}
		
		// - Remove all visible elements
		for (i in 0..._slotsTotal) {
			if (elementSlots[i] != null) {	
				remove(elementSlots[i]);
				poolPut(elementSlots[i]);
				elementSlots[i] = null;
			}
		}
		
		// - Hard scroll to target index
		if (ind > 0 && ind + _slotsTotal > _data_length) {
			ind = _data_length - _slotsTotal;
			if (ind < 0) ind = 0;
			// trace('Debug: Generated index out of bounds, setting to [$ind]');
		}
		
		_scrollOffset = ind;
	
		for (i in 0..._slotsTotal) {
			if (_data[i + ind] != null) {
				elementSlots[i] = getNewElementIntoPos(i, i + ind);
				elementSlots[i].alpha = 1;
			}else {	
				// trace("Info: No more data to fill into slots");
				break;
			}
		}
		
		updateScrollIndicator();
	}//---------------------------------------------------;
	
	
	// Utility, goes through all onscreen items and returns the maximum width found
	public function getMaxElementWidthFromView():Float
	{
		var m:Float = 0;
		for (i in elementSlots){
			if (i != null && (i.width > m)) m = i.width;	
		}
		return m;
	}//---------------------------------------------------;
	
	
	//====================================================;
	// HELPERS
	//====================================================;
	
	// If has more elements above the view window
	inline function hasMoreAbove():Bool 
	{
		return (_scrollOffset > 0);
	}//---------------------------------------------------;
	// If has more elements below the view window
	inline function hasMoreBelow():Bool
	{
		return (_scrollOffset + _slotsTotal < _data_length);
	}//---------------------------------------------------;
	
	// --
	function __scrollComplete(?t:FlxTween)
	{
		clearTweens();
		isScrolling = false;
		
		// When the scrolling animation is complete,
		// Either destroy the old elements or recycle them.
		for (i in markedForRemoval) {
			remove(i); // from the scene
			poolPut(i);
		}
		
		markedForRemoval.splice(0, markedForRemoval.length);
		
		updateScrollIndicator();
	}//---------------------------------------------------;	
	
	
	// --
	// # OVERRIDE THIS, to get custom typed elements if you need them
	function factory_getElement(dataIndex:Int):T
	{
		return Type.createInstance(_elementClass, []);
	}//---------------------------------------------------;
	
	
   /**
	* Get a Recycled or New Item Element
	* put it into a screen slot, and set it with data
	* # Adds it to the stage
	* @param	ySlot 		, 0 is the first slot, NOTE this could be -1 or +1
	* @param	dataIndex	, The index of the data array to pass
	*/
	function getNewElementIntoPos(ySlot:Int, dataIndex:Int):T
	{
		r_el = poolGet(dataIndex);
		r_el.visible = true; // Just in case
		r_el.y = y + (ySlot * elementHeight) + posOffsetY;
		r_el.x = getStartingXPos(r_el);
		r_el.unfocus(); // Element might be focused or just created. Just in case to default?
		add(r_el);
		// Note: At this point the alpha could be anything because of recycle
		// Set the desired alpha after getting this.
	   return r_el;
	}//---------------------------------------------------;
	
	
	// I need this for the item alignments
	function getStartingXPos(el:T):Float
	{
		// Currently only "center" does anything, anything else puts at 0
		// So I can skip a switch case and use an if
		if (styleB.alignment == "center")
		{
			return x + (width - el.width) / 2;
		}else
		{
			return x;
		}
		
	}//---------------------------------------------------;
	
	// -- Create and return a new Element, initialize it too
	function getNewElement(index:Int):T
	{
		r_el = factory_getElement(index);
		r_el.cameras = [camera];
		r_el.setData(_data[index]);
		r_el.scrollFactor.set(0, 0);
		r_el.moves = false;
		return r_el;
	}//---------------------------------------------------;
	
	//====================================================;
	//  POOLING
	//====================================================;

	// == Pooling mode ==
	// -----
	// NOTE: You MUST call this right after new() and before setting data
	// -----
	// + Values ::
	// 
	// off 		: Elements in view are created as the list scrolls,
	//			  Elements off view are destroyed as the list scrolls.
	
	// recycle	: Recreate X amount of objects and recycle those upon scrolling
	//			  -- Elements are re-inited as the list scrolls
	//			  -- Not Compatible with multiple child types
	//			  -- All elements must be of the same class !! 
	//            -- Useful in very large databases, like a text scroller
	
	// reuse    : Old elements are not destroyed but they are kept in an array
	//			  in case they are needed to get onscreen again.
	//			  -- Useful in multiple child types
	//            -- USE in short lists, BAD FOR LONG LISTS !
	/**
	 * Set a pooling mode, check code comments for more info
	 * @param	val [off, reuse, recycle]
	 * @param	param applicable in reuse, How many elements to store in the reuse pool
	 * @return
	 */
	public function setPoolingMode(val:String, reuse_max:Int = DEF_POOL_REUSE_MAX )
	{
		
		switch(val) {
			case 'recycle':
				flag_pool_recycle = true;
				flag_pool_reuse = false;
				_pool_max_size = _slotsTotal + 2; // Plus 2 is enough, because the scrolling is being done one by one
			case 'reuse':
				flag_pool_recycle = false;
				flag_pool_reuse = true;
				_pool_max_size = reuse_max; 
				if (_pool_max_size < 1) _pool_max_size = DEF_POOL_REUSE_MAX;
			case 'off':
				flag_pool_recycle = false;
				flag_pool_reuse = false;
				_pool_max_size = 0;
			default : throw "Invalid pooling move";
		}
		
		pooling_mode = val;
		
		//trace('Info: Setting POOL mode to [$val]');
		//trace('Info: POOL MAX SIZE [$_pool_max_size]');
		
		// -- Initialize the pool
		if (_pool != null) {
			trace("Error: Resetting the pool is not tested, be careful");
			return;
		}
		
		_pool = [];
		_pool_length = 0;
		
	}//---------------------------------------------------;
	
	// --
	// Get an element depending on the pool type
	function poolGet(_dataIndex:Int):T
	{
		if (flag_pool_reuse)
		{
			// Search if an element with the data is already in the pool
			for (i in _pool) {
				if (i.isSame(_data[_dataIndex])) {
					return i;
				}
			}
			// Didn't find anything in the pool
		}
		else if (flag_pool_recycle)
		{
			if (_pool_length > 0) {
				_pool_length--;
				r_el = _pool.shift();
				r_el.setData(_data[_dataIndex]);
				return r_el;
			}
		}
		// Program got here when could not get any element from the pool
		// OR pool mode is set to "off"
		// Return a new element:
		return getNewElement(_dataIndex);
	}//---------------------------------------------------;
	
	// --
	// Put an element in the pool.
	// Process it depending on the pool type.
	function poolPut(el:T)
	{
		#if debug
		if (el == null) {
			trace("ERROR, POOL, Can't add a null object");
		}
		#end
		
		if (flag_pool_reuse) {
			// Don't add the same element if it's already there
			if (_pool.indexOf(el) !=-1) {
				return;
			}
		}
		else if (!flag_pool_recycle)
		{
			// There is no pooling mode here.
			// Destroy the object
			el.destroy();
			return;
		}
		
		_pool.push(el);
		_pool_length++;
		
		if (_pool_length > _pool_max_size) {
			_pool_length--;
			_pool.shift();
		}
		
	}//---------------------------------------------------;

	
	/**
	 * Moves all the children by an offset
	 * e.g. posOffset(0,10) moves elements by 10 pixels down
	 * NOTE: You'll need to recalculate the height manually again.
	 * @param	X X offset to move
	 * @param	Y Y offset to move
	 */
	public function posOffset(X:Float = 0, Y:Float = 0)
	{
		for (i in this.members) {
			cast(i, FlxSprite).x += X;
			cast(i, FlxSprite).y += Y;
		}
	}//---------------------------------------------------;
	
	//====================================================;
	// DEBUG FUNCTIONS
	//====================================================;
	#if debug
	// Constantly scrolls, thus creating many FLXTweens at once.
	// Useful to keep track of memory use, createf objects, etc.
	// It fills up the memory about ~5 MB then it garbage collects.
	public function debug_scrollForever()
	{
		trace("Info: Starting to scroll forever");
		var f = new flixel.util.FlxTimer();
		
		var dir:Int = 1; // Down or Up
		
		f.start(0.3, function(_) {
			if ((dir > 0 && !scrollDownOne()) || (dir < 0 && !scrollUpOne()))
			{
				dir = dir * -1;
			}
		},0);
		
	}//---------------------------------------------------;
	
	#end
	
}// -- end //