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

 
// Note: generic means that the compiler will create classes for each data 
//       type required. Thus making it faster at the cost of compiled size.

@:generic
class VListBase<T:(IListOption<K>,FlxSprite),K> extends FlxGroup
{	
	// -- System
	public var x(default, null):Float;
	public var y(default, null):Float;
	public var width(default, null):Int;
	public var height(default, null):Int;
	public var isFocused(default, null):Bool;
	public var isScrolling(default, null):Bool;
	var _elementClass:Class<T>;
	
	// Experimental
	// Keep all the tweens applied to this object, so that I can remove them
	var tweens:Array<VarTween>;
	
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
	//			  -- All elements must be of the same type!! 
	
	// reuse    : Old elements are not destroyed but they are kept in an array
	//			  in case they are needed to get onscreen again.
	//			  -- Useful in multiple child types --
	var pooling_mode(default, set):String = "recycle";
	
	// Reuse up to this many elements.
	var POOL_REUSE_MAX_ELEMENTS:Int = 16;
	
	// It is quicker to read BOOLS than compare STRINGS, so I have those:
	// NOTE: ONLY 1 MUST BE SET AT EACH TIME.
	var flag_pool_recycle(default, null):Bool = true;
	var flag_pool_reuse(default, null):Bool = false;
	
	// Have objects become available to get recycled after their animation is complete.
	var markedForRemoval:Array<T>;
	
	// If true, then the elements are initialized right after setting data
	// FLXMenu doesn't need that to happen.
	public var flag_InitViewAfterDataSet:Bool = true;
	
	// -- Elements ::
	var elementSlots:Array<T>;	// As the elements appear on the menu
	var elementHeight:Int; 		// All the elements should share a same height
	
	// The child elements are pooled for recycling
	var _pool_recycle:FlxTypedGroup<T>;
	// Store child elements to reuse as they are later
	var _pool_reuse:Array<T>;
	
	// -- Data --
	var data:Array<K>;		// This holds the data in an array (e.g. OptionData)
	var _scrollOffset:Int;	// What data Index is on the top slot
	var _dataTotal:Int;		// Total data elements
	var _slotsTotal:Int;	// Or Total slots that fit on the menu
	
	// --  Styling and parameters
	public var styleBase:VBaseStyle;
	
	// -- Helpers
	
	// Quick element pointer
	var r_el:T;
	// Quick Int
	var r_1:Int;
	// Quick Int 
	var counter:Int;
		
	// ==-- Animation --==
	
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
	public function new(ObjClass:Class<T>, X:Float, Y:Float, WIDTH:Int, ?SlotsTotal:Int)
	{
		super();
		x = X; y = Y; width = WIDTH;
		_elementClass = ObjClass;
		
		if (SlotsTotal != null) {
			_slotsTotal = SlotsTotal;
			if (_slotsTotal == 0) _slotsTotal = 2;	// Safeguard
		}else{
			trace("Warning: No slots set, setting default to 3");
			_slotsTotal = 3;
		}
		
		// -- Other Data
		r_el = null;
		elementHeight = -1;	// Set later
		elementSlots = new Array<T>();
		_pool_recycle = null;
		_pool_reuse = null;
		
		isScrolling = false;
		isFocused = false;
		markedForRemoval = [];
		data = null;
		_dataTotal = 0;
		_scrollOffset = -1; // -1 allows it to be initialized because it's going to be checked if 0
				
		tweens = [];
	}//---------------------------------------------------;
	
	// -- 
	// Sets a new data source AND INITIALIZES
	// Be sure to have any initialization or styles done up to this point
	public function setDataSource(arr:Array<K>)
	{
		// - Some checks for safeguarding
		if (data != null) {
			/// TODO: Support it in a later version.
			trace("Error: Re-set of data not supported.");  return;
		}
		
		if (arr == null) {
			trace("Error: Array is null"); return;
		}
		
		// Get the default style if it's not set already.
		if (styleBase == null) {
			styleBase = Styles.default_BaseStyle;
		}
		
		// Check for auto width,
		if (width == 0) {
			width = Std.int(FlxG.width - (x * 2));
			if (width < 32) width = Std.int(FlxG.width - x);
		}
		
		// Get Child Height if not already
		// Also :: Set the starting positions of all the slots ::
		if (elementHeight < 0) {
			r_el = Type.createInstance(_elementClass, [this]);
			elementHeight = r_el.getOptionHeight() + styleBase.element_padding;
			height = _slotsTotal * elementHeight;
			
			// -- Get the starting positions of the slots
			elementYPositions = [];
			for (s in 0..._slotsTotal) {
				elementYPositions[s] = s * elementHeight;
			}
			//trace("Info: Set element positions", elementYPositions);
		}
		
		// Create the recycle pool if Applicable, ( only done once )
		_poolRecycleInit();
		
		data = arr;
		_dataTotal = data.length;
		// trace('Info: Added data source with [$_dataTotal] number of elements');

		// It's going to be called upon the first showpage
		if (flag_InitViewAfterDataSet) {
			trace('Info: Setting data, initializing view');
			setViewIndex(0);
		}
	}//---------------------------------------------------;
	
	// --
	function checkInput()
	{
		// Override this and check input here
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (isFocused && visible) {
			checkInput();
		}
	}//---------------------------------------------------;
	
	function clearTweens()
	{
		for (i in tweens) {
			if (i != null) { i.cancel(); i = null; }
		}
		tweens = [];
	}//---------------------------------------------------;
	
	
	// --
	override public function destroy():Void 
	{
		super.destroy();
		
		clearTweens();
		
		if (_pool_recycle != null) {
			_pool_recycle.destroy();
			_pool_recycle = null;			
		}
		
		if (_pool_reuse != null) {
			for (i in _pool_reuse) {
				i.destroy();
				i = null;
			}
			_pool_reuse = null;
		}
		
		if (animTimer != null) {
			animTimer.cancel();
			animTimer = null;
		}
		
		data = null;
		elementSlots = null;
		markedForRemoval = null;
		
	}//---------------------------------------------------;
	
	// Reveal the bottom, like moving the camera down
	// v0.1: It works!
	function scrollViewDown():Bool
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
				if(counter==0) {
				 tweens.push(FlxTween.tween(elementSlots[counter], 
					{ alpha:0, y:elementSlots[counter].y - elementHeight }, styleBase.element_scroll_time ));
				} else {
				 tweens.push(FlxTween.tween(elementSlots[counter], 
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
			tweens.push(FlxTween.tween(r_el, { alpha:1, y:r_el.y - elementHeight }, styleBase.element_scroll_time, 
					{ onComplete:__scrollComplete } ));
					
			_scrollOffset++;
			return true;
			
		}else {
			// trace("Can't go down more");
			return false;
		}
	}//---------------------------------------------------;

	// v0.1: It works!
	function scrollViewUp():Bool
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
				tweens.push(FlxTween.tween(elementSlots[counter],
					{alpha:0, y:elementSlots[counter].y + elementHeight }, styleBase.element_scroll_time));
				}else {
				tweens.push(FlxTween.tween(elementSlots[counter],
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

			tweens.push(FlxTween.tween(r_el, { alpha:1, y:r_el.y + elementHeight }, styleBase.element_scroll_time, 
					{ onComplete:__scrollComplete } ));
					
			_scrollOffset--;
			
			return true;
		}else {
			// trace("Can't go up more");
			return false;	
		}
		
	}//---------------------------------------------------;
	
	
	// #Override
	public function focus()
	{
		isFocused = true;
	}//---------------------------------------------------;
	
	// #Override
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
			
			tweens.push(FlxTween.tween(elementSlots[i], 
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
			trace("Warning: Setting new scrollview while animating could cause visual glitches. Clearing Tweens.");
			clearTweens();
		}	
		
		if (ind == _scrollOffset) {
			trace('Warning: Requested to set view to same index [$ind], Skipping.');
			return;
		}
		
		if (_dataTotal == 0){
			trace("Warning: This list is empty");
			return;
		}
		
		// - Remove all visible elements
		for (i in 0..._slotsTotal) {
			if (elementSlots[i] != null) {
				elementSlots[i].visible = false;
				elementSlots[i].alive = false;
				elementSlots[i] = null;
			}
		}
		
		// - Hard scroll to target index
		if (ind > 0 && ind + _slotsTotal > _dataTotal) {
			ind = _dataTotal - _slotsTotal;
			if (ind < 0) ind = 0;
			trace('Debug: Generated index out of bounds, setting to [$ind]');
		}
		
		_scrollOffset = ind;
	
		for (i in 0..._slotsTotal) {
			if (data[i + ind] != null) {
				elementSlots[i] = getNewElementIntoPos(i, i + ind);
				elementSlots[i].alpha = 1;
				elementSlots[i].unfocus();
			}else {	
				// trace("Info: No more data to fill into slots");
				break;
			}
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
		return (_scrollOffset + _slotsTotal < _dataTotal);
	}//---------------------------------------------------;
	
	function __scrollComplete(?t:FlxTween)
	{
		clearTweens();
		isScrolling = false;
		
		// When the scrolling animation is complete,
		// Either destroy the old elements or recycle them.
		for (i in markedForRemoval) {
			
			if (flag_pool_recycle)
			{
				i.alive = false;
			}else if (flag_pool_reuse)
			{
				remove(i);
				poolReuseStore(i);
			}else
			{
				remove(i);
				i.destroy();
				i = null;
			}	
		}
		
		markedForRemoval.splice(0, markedForRemoval.length);
	}//---------------------------------------------------;	
	
	
	// --
	// Initiate the _pool_recycle if it isn't
	function _poolRecycleInit()
	{
		if ((flag_pool_recycle && _pool_recycle == null) == false) {
			return;
		}
		
		// -- Precreate and pool the elements.
		// -- # Using a pool only makes sense if there is only going to be 
		//      just one type of children
		_pool_recycle = new FlxTypedGroup<T>();
		_pool_recycle.cameras = [camera];
		_pool_recycle.maxSize = _slotsTotal + 2;
		
		for (i in 0..._pool_recycle.maxSize) {
			r_el = Type.createInstance(_elementClass, [this]);
			r_el.cameras = [camera];
			r_el.scrollFactor.set(0, 0);
			r_el.x = x; // The X position will not change
			r_el.alive = false; // Ready to be picked up. DO NOT USE KILL();
			r_el.visible = false;
			_pool_recycle.add(r_el);
		}
		
		add(_pool_recycle);
		
		trace('Warning: Recycled element mode');
		trace('Warning: Pool size = ${_pool_recycle.maxSize}');
		
	}//---------------------------------------------------;
	
	
	// --
	// # OVERRIDE THIS, to get custom typed elements
	function factory_getElement(dataIndex:Int):T
	{
		return Type.createInstance(_elementClass, [this]);
	}//---------------------------------------------------;
	
	
   /**
	* Get a Recycled or New Option Element ,
	* Put it into a screen slot, and set it with data
	* @param	ySlot 		, 0 is the first slot. -1 is valid
	* @param	dataIndex	, The index of the data array to pass
	*/
	function getNewElementIntoPos(ySlot:Int, dataIndex:Int):T
	{
		// Get a new element from either recycle or new
		if (flag_pool_recycle)
		{
			// The element is already added on stage
			r_el = _pool_recycle.getFirstDead();
			r_el.setData(data[dataIndex]);
			r_el.alive = true;
			r_el.visible = true;
		}
		else if (flag_pool_reuse)
		{
			r_el = poolReuseGet(data[dataIndex]);
			if (r_el == null) {
				_tempElement_CreateInit(dataIndex);
			}
			add(r_el);
		}
		else
		{
			// Create a new element
			_tempElement_CreateInit(dataIndex);
			r_el.setData(data[dataIndex]);
			add(r_el);
		}
		
		r_el.y = y + (ySlot * elementHeight);
			
		// Note: At this point the alpha could be anything because of recycle
		// Set the desired alpha after getting this.
	   return r_el;
	}//---------------------------------------------------;
	
	// Quick way to create a new child element
	// Used in 2 places
	inline function _tempElement_CreateInit(index:Int)
	{
		r_el = factory_getElement(index);
		r_el.cameras = [camera];
		r_el.setData(data[index]);
		r_el.scrollFactor.set(0, 0);
		r_el.x = x;
	}//---------------------------------------------------;
	
	//====================================================;
	//  POOLING
	//====================================================;
	function set_pooling_mode(val:String):String
	{
		// trace('Info: Setting POOL mode to [$val]');

		switch(val) {
			case 'recycle':
				flag_pool_recycle = true;
				flag_pool_reuse = false;
				pooling_mode = val;
			case 'reuse':
				flag_pool_recycle = false;
				flag_pool_reuse = true;
				pooling_mode = val;
				_pool_reuse = [];
			default :
				flag_pool_recycle = false;
				flag_pool_reuse = false;
				pooling_mode = "off";
		}
		return pooling_mode;
	}//---------------------------------------------------;
	
	
	// Stores this element to the reuse pool for later use
	//--
	inline function poolReuseStore(el:T)
	{
		_pool_reuse.push(el);
		if (_pool_reuse.length > POOL_REUSE_MAX_ELEMENTS) {
			_pool_reuse.shift().destroy();
		}
	}//---------------------------------------------------;
	
	// --
	// Returns element with data from the reuse pool,
	// Optional removal
	function poolReuseGet(data:K, remove:Bool = true):T
	{
		for (i in _pool_reuse) {
			if (i.isSame(data)) {
				// Element found in pool
				if (remove) _pool_reuse.remove(i);
				return i;
			}
		}
		return null;
	}//---------------------------------------------------;
	
	#if debug
	//====================================================;
	// DEBUG 
	//====================================================;
	// Constantly scrolls, thus creating many FLXTweens at once.
	// Useful to keep track of memory use, createf objects, etc.
	// It fills up the memory about ~5 MB then it garbage collects.
	public function debug_overdrive_tween()
	{
		trace("Info: Starting to scroll forever");
		var f:FlxTimer = new FlxTimer();
		
		f.start(0.3, function(_) {
			if (scrollViewDown() == false) {
				// Go to the start when it reaches the end
				setViewIndex(0);
			}
		},0);
		
	}//---------------------------------------------------;
	#end
	
}// -- end //