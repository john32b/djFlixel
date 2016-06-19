package djFlixel.gui.list;

import djFlixel.gui.Styles;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.util.FlxPool;
import flixel.util.FlxTimer;
import djFlixel.gui.listoption.IListOption;
import haxe.Constraints.Function;
	

/**
 * 
 * General Purpose ListBox that presents ChildElements in a
 * scrollable vertical list
 * 
 * # Purpose is to be extended into a more specific class
 *   or you can use it as a bare element scroller
 * 
 * # Children must have a standard Height and implement <IListOption>
 * 
 * T: Type Element of Child
 * K: Type of Child Data
 * 
 */


class VListBase<T:(IListOption<K>,FlxSprite),K> extends FlxGroup
{	
	
	// -- Some Defaults ::
	// --
	static inline var DEF_SLOTS:Int = 3;
	static inline var DEF_POOL_REUSE_MAX:Int = 8;
	static inline var DEF_POOL_MODE:String = "recycle";

	// -- User set Variables ::
	// --
	// If true, then the elements are initialized right after setting data
	// e.g. FLXMenu doesn't need that to happen.
	public var flag_InitViewAfterDataSet:Bool = true;
		
	// Custom Styling and parameters
	public var styleBase:VBaseStyle;
		
	// -- System ::
	// --
	public var x(default, null):Float;
	public var y(default, null):Float;
	public var width(default, null):Int;
	public var height(default, null):Int;
	public var isFocused(default, null):Bool;
	public var isScrolling(default, null):Bool;
	var _elementClass:Class<T>;
	
	// Experimental
	// Keep all the tweens applied to this object, so that I can remove them
	var allTweens:Array<VarTween>;
	
	// == Pooling mode ==
	// -----
	// + NOTE: You MUST set this right after new() and before setting data.
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
	var elementSlots:Array<T>;	// As the elements appear on the menu
	var elementHeight:Int; 		// INCLUDES PADDING !!

	
	// -- Data ::
	// --
	var _data:Array<K>;		// This holds the data in an array (e.g. OptionData)
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
		
	// ==-- Animation --
	// --
	// Have the elements appear with a transitioning animation
	var animTimer:FlxTimer;
	// Store the starting Y position of each slot, used later in the animation
	var elementYPositions:Array<Int>;
	
	// ===================================================;
	// ===================================================;
	
	/**
	 * 
	 * @param	X Position on the screen.
	 * @param	Y Position on the screen.
	 * @param	WIDTH Set to 0 to Fill Screen Width with some padding
	 * @param	SlotsTotal How many slots to show on the screen.
	 */
	public function new(ObjClass:Class<T>, X:Float, Y:Float, WIDTH:Int = 0, SlotsTotal:Int = 0)
	{
		super();
		x = X; y = Y; width = WIDTH;
		_elementClass = ObjClass;
		
		_slotsTotal = SlotsTotal;
		if (_slotsTotal == 0) {
			trace("Info: Setting default slots to ", DEF_SLOTS);
			_slotsTotal = DEF_SLOTS;
		}
		
		// -- Other Data
		r_el = null;
		elementHeight = -1;	// Set later
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
		// trace('Info: Added data source with [$_data_length] number of elements');
		
		// Ready this to accept new data
		clearTweens();
		
		// Get the default style if it's not set already.
		if (styleBase == null) {
			styleBase = Styles.default_BaseStyle;
		}
		
		// Removed Width init
		// --
		
		// Get Child Height if not already
		// Also :: Set the starting positions of all the slots ::
		if (elementHeight < 0) {
			r_el = factory_getElement(0);
			elementHeight = r_el.getOptionHeight() + styleBase.element_padding;
			r_el.destroy();
			height = _slotsTotal * elementHeight;
			
			// -- Get the starting positions of the slots
			elementYPositions = [];
			for (s in 0..._slotsTotal) {
				elementYPositions[s] = s * elementHeight;
			}
			//trace("Info: Set element positions", elementYPositions);
		}
		
		if (pooling_mode == null) 
			setPoolingMode(DEF_POOL_MODE);

		// It's going to be called upon the first showpage
		if (flag_InitViewAfterDataSet) {
			trace('Info: Setting data, initializing view');
			setViewIndex(0);
		}
	}//---------------------------------------------------;
	
	
	// -- Helper
	function clearTweens()
	{
		for (i in allTweens) {
			if (i != null) { i.cancel(); i = null; }
		}
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
		styleBase = null;
		elementYPositions = null;
		
		if (animTimer != null) {
			animTimer.cancel();
			animTimer = null;
		}
				
		if (_pool != null) { for (i in _pool) i.destroy(); _pool = null; }
		
	}//---------------------------------------------------;
	
	
	
	// Reveal the bottom, like moving the camera down
	// v0.1: It works!
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
				// Make sure the tween starts from a valid pos
				if (counter == 0) {
				 allTweens.push(FlxTween.tween(elementSlots[counter], 
					{ alpha:0, y:elementSlots[counter].y - elementHeight }, styleBase.element_scroll_time ));
				} else {
				 allTweens.push(FlxTween.tween(elementSlots[counter], 
					{ y:elementSlots[counter].y - elementHeight }, styleBase.element_scroll_time ));
				}
				elementSlots[counter] = elementSlots[counter + 1];
				counter++;
			}
			// At this point counter points to the index that isn't there
			// New element at the bottom;
			r_el = getNewElementIntoPos(counter , _scrollOffset + counter);
			elementSlots[counter - 1] = r_el;
			isScrolling = true;

			r_el.alpha = 0;
			allTweens.push(FlxTween.tween(r_el, { alpha:1, y:r_el.y - elementHeight }, styleBase.element_scroll_time, 
					{ onComplete:__scrollComplete } ));
					
			_scrollOffset++;
			return true;
			
		}else {
			// trace("Can't go down more");
			return false;
		}
	}//---------------------------------------------------;

	// v0.1: It works!
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
				if (counter == r_1) {
				allTweens.push(FlxTween.tween(elementSlots[counter],
					{alpha:0, y:elementSlots[counter].y + elementHeight }, styleBase.element_scroll_time));
				}else {
				allTweens.push(FlxTween.tween(elementSlots[counter],
					{y:elementSlots[counter].y + elementHeight }, styleBase.element_scroll_time));
				}
				elementSlots[counter] = elementSlots[counter - 1];
				counter--;
			}
			
			// Counter is now -1;
			r_el = getNewElementIntoPos(counter, _scrollOffset - 1);
			r_el.alpha = 0;
			elementSlots[0] = r_el;
			
			isScrolling = true;

			allTweens.push(FlxTween.tween(r_el, { alpha:1, y:r_el.y + elementHeight }, styleBase.element_scroll_time, 
					{ onComplete:__scrollComplete } ));
					
			_scrollOffset--;
			
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
	}//---------------------------------------------------;
	
	
	//====================================================;
	// 
	//====================================================;
	
	// --
	// THIS is mainly used for the onScreen,offScreen animations
	// Animate all slots , Implies the elements are on their starting position!!!
	// NOTE : Starting and ending positions are offsets
	function animationAllSlots(	startAlpha:Float, endAlpha:Float, 
								startOffsetX:Float, endOffsetX:Float,
								startOffsetY:Float, endOffsetY:Float, 
								onComplete:Void->Void)
	{
		
		var elementTime:Float = styleBase.anim_total_time / _slotsTotal;
		var betweenTime:Float = styleBase.anim_time_between_elements;
			if (betweenTime < 0) betweenTime = elementTime * 0.9;
			
		var easeFn:EaseFunction;
		
		switch(styleBase.anim_tween_ease) {
			case "bounce": easeFn = FlxEase.bounceOut;
			case "elastic": easeFn = FlxEase.elasticOut;
			case "back": easeFn = FlxEase.backOut;
			case "circ": easeFn = FlxEase.circOut;
			default: easeFn = null; // linear
		}
		
		var i:Int = 0;
		while (elementSlots[i] != null)
		{		
			elementSlots[i].alpha = startAlpha;
			elementSlots[i].x += startOffsetX;
			elementSlots[i].y += startOffsetY;
			
			allTweens.push(FlxTween.tween(elementSlots[i], 
				{ x:this.x + endOffsetX, y:this.y + elementYPositions[i] + endOffsetY, alpha:endAlpha }, elementTime,
				{ startDelay:(i * betweenTime), ease:easeFn } ));
				
			i++;
		}
		
		// trace("ANIMATION END AT INDEX", i);
		
		isScrolling = true;
		
		if (animTimer != null) {
			animTimer.cancel();
		}
		
		animTimer = new FlxTimer();
		animTimer.start((betweenTime * i) + elementTime * 2, function(_) { 
				isScrolling = false;
				clearTweens();
				animTimer = null;
				onComplete();
			} );	
	}//---------------------------------------------------;
	
	
	// --
	// # OPTIONAL
	public function onScreen(focusAfter:Bool = true, ?onComplete:Void->Void)
	{
		visible = true;
			
		animationAllSlots( 0, 1, styleBase.anim_start_x, 0, 
								 styleBase.anim_start_y, 0,
							function() {
								if (focusAfter) focus();
								if (onComplete != null) onComplete(); 
							});
	}//---------------------------------------------------;
	
	public function offScreen(?onComplete:Void->Void)
	{
		unfocus();
			
		animationAllSlots( 0.9, 0,  0, styleBase.anim_end_x,
									0, styleBase.anim_end_y,
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
			trace('Warning: Setting new scrollview while animating could cause visual glitches. Clearing Tweens.');
			clearTweens();
		}	
		
		if (ind == _scrollOffset) {
			trace('Warning: Requested to set view to same index [$ind], Skipping.');
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
		
		// -- This is the first time the autowidth is going to be calculated
		if (width == 0)
		{
			var maxw:Float = 0;
			for (i in elementSlots) {
				if (i != null && i.width > maxw) maxw = i.width;
			}
			width = cast maxw;
			if (width == 0) { trace("Error: Autowidth was 0 !"); width = 42; }	
		}
		
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
	}//---------------------------------------------------;	
	
	
	// --
	// # OVERRIDE THIS, to get custom typed elements if you need them
	function factory_getElement(dataIndex:Int):T
	{
		return Type.createInstance(_elementClass, []);
	}//---------------------------------------------------;
	
	
   /**
	* Get a Recycled or New Option Element
	* put it into a screen slot, and set it with data
	* # Adds it to the stage
	* @param	ySlot 		, 0 is the first slot. -1 is valid
	* @param	dataIndex	, The index of the data array to pass
	*/
	function getNewElementIntoPos(ySlot:Int, dataIndex:Int):T
	{
		r_el = poolGet(dataIndex);
		r_el.visible = true; // Just in case
		r_el.x = x; // Just in case
		r_el.y = y + (ySlot * elementHeight);
		r_el.unfocus(); // Element might be focused or just created. Just in case to default?
		add(r_el);
		// Note: At this point the alpha could be anything because of recycle
		// Set the desired alpha after getting this.
	   return r_el;
	}//---------------------------------------------------;
	
	// --
	function getNewElement(index:Int):T
	{
		r_el = factory_getElement(index);
		r_el.cameras = [camera];
		r_el.setData(_data[index]);
		r_el.scrollFactor.set(0, 0);
		return r_el;
	}//---------------------------------------------------;
	
	//====================================================;
	//  POOLING
	//====================================================;

	/**
	 * Call this BEFORE setting DATA
	 * @param	val [off,reuse,recycle]
	 * @param	param applicable in reuse
	 * @return
	 */
	public function setPoolingMode(val:String, param:Int = 0 )
	{
		
		switch(val) {
			case 'recycle':
				flag_pool_recycle = true;
				flag_pool_reuse = false;
				pooling_mode = val;
				_pool_max_size = _slotsTotal + 2; // Plus 2 is enough, because the scrolling is being done one by one
			case 'reuse':
				flag_pool_recycle = false;
				flag_pool_reuse = true;
				pooling_mode = val;
				_pool_max_size = param; if (_pool_max_size < 1) _pool_max_size = DEF_POOL_REUSE_MAX;
			default : // off
				flag_pool_recycle = false;
				flag_pool_reuse = false;
				_pool_max_size = 0;
				pooling_mode = "off";
		}
		
		//trace('Info: Setting POOL mode to [$val]');
		//trace('Info: POOL MAX SIZE [$_pool_max_size]');
		
		// -- Initialie the pool
		
		#if debug
			if (_pool != null) trace("Error: Pool was already initialized, and it shouldn't be");
		#end
		
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
					// trace("Pool GET, found element on the pool");
					return i;
				}
			}
			// Didn't find anything in the pool
		}
		else if (flag_pool_recycle)
		{
			if (_pool_length > 0) {
				// trace("Pool GET, returning first available element");
				_pool_length--;
				return _pool.shift();
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
				// trace('Pool PUT, Element already exists, skipping');
				return;
			}
		}
		else if (!flag_pool_recycle)
		{
			// There is no pooling mode here.
			// Destroy the object
			// trace('Pool PUT, No pool mode, destroying object');
			el.destroy();
			return;
		}
		
		_pool.push(el);
		_pool_length++;
		
		if (_pool_length > _pool_max_size) {
			_pool_length--;
			_pool.shift();
			//trace('Pool PUT - OVERFLOW, destroying first element. New pool size = $_pool_length');
		}
		
		// trace('Pool PUT , New pool size = $_pool_length');
	}//---------------------------------------------------;

	
	
	//====================================================;
	// DEBUG FUNCTIONS
	//====================================================;
	#if debug
	// Constantly scrolls, thus creating many FLXTweens at once.
	// Useful to keep track of memory use, createf objects, etc.
	// It fills up the memory about ~5 MB then it garbage collects.
	public function debug_overdrive_tween()
	{
		trace("Info: Starting to scroll forever");
		var f:FlxTimer = new FlxTimer();
		
		f.start(0.3, function(_) {
			if (scrollDownOne() == false) {
				// Go to the start when it reaches the end
				setViewIndex(0);
			}
		},0);
		
	}//---------------------------------------------------;
	
	#end
	
}// -- end //