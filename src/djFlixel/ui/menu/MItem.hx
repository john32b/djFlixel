package djFlixel.ui.menu;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

import djFlixel.core.Dtext.DTextStyle;
import djFlixel.ui.IListItem;
import djFlixel.ui.menu.MPage;
import djFlixel.ui.menu.MItemData;

import openfl.display.BitmapData;



typedef MItemStyle = {
	
	text:DTextStyle,	// Text style, to use on all ITEMS
						// All Items will use colors from (col_t,col_b)
						// MUST SET : bt

	col_t:StateColors,	// Text Colors. You should set ALL states
	col_b:StateColors,	// Border Colors. You can only set 'idle' and all states will get that color.
	
	// :: ADVANCED ::
	
	part2_pad:Int,		// Push the second part of items (toggle,list,range) to the right by this many pixels
						// Applicable in left/center/center2 alignments.
						// NOTE: In 'center2' the list arrows padding will not be applied, so make sure this is big enough to accomodate
						
	// Must set either {box_txt} or {box_bm}
	?box_txt:Array<String>,		// Text instead of graphic e.g. '[ ]' '[x]'
	?box_bm:Array<BitmapData>,	// off,on checkbox Bitmaps
	?box_offy:Int,				// In case of checkbox bitmap icon, offset it this much on the y axis (def=1)
	
	// Must set either {ar_txt} or {ar_bm}
	// NEW: the 3rd and 4th slot can be used to use in `MItemRange`
	//      else it will use the 0 and 1 slots
	// Element Arrows, that show up in List and Range items
	?ar_txt:Array<String>,		// Text instead of graphic e.g. '<' '>'
	?ar_bm:Array<BitmapData>,	// Left,Right Arrows Bitmaps
	?ar_offy:Int,				// In case of arrow bitmap icon, offset it this much on the y axis (def=1)	
	?ar_anim:String,			// "type,steps,time" Type=1 repat, 2 loop. Every steps is a pixel moved. Time for each tick
								// <defaults in MItemList>
	?bm_no_col:Bool,			// If true will NOT colorize the bitmaps in [ar_bm, box_bm] use this for custom pre-colored graphics
};


private typedef StateColors = {
	?idle:Int,	// Default/Idle
	?focus:Int,	
	?accent:Int,
	?dis:Int,	// Disabled
	?dis_f:Int	// Disabled Focus
}

// These must match the `StateColors` names
enum FocusState
{
	idle;
	focus;
	dis;
	dis_f;
}



/**
 * Generalized Item that can go in a MPage
 */
class MItem extends FlxSpriteGroup implements IListItem<MItemData>
{
	static public var DEFAULT_STYLE:MItemStyle = {
		text:{bt:1},
		col_t:{idle:0xFFF4F4F4, focus:0xFFFFFF00, accent:0xFFFF8000, dis:0xFF5C5C5C, dis_f:0xFF909090},
		col_b:{idle:0xFF222222},
		box_txt:["( )","(X)"],
		ar_txt:["<", ">"],
		part2_pad:10
	}
		
	/** Pointer to the menu this item belongs to */
	var mp:MPage;

	// Pointer to data
	public var data:MItemData;
	
	// This will ALWAYS be set
	public var callback:ListItemEvent->Void;
	
	public var isFocused(default, null):Bool = false;
	
	var label:FlxText;			// This is the left portion of the item, the label
	
	//====================================================;
	
	public function new(MP:MPage) 
	{
		super();
		mp = MP;
		
		#if debug
			if (mp.iconcache == null) throw "Forgot to initialize ICONCACHE";
		#end
		
		label = new FlxText();
		label.wordWrap = false;
		// This is mainly for the size/font/borders. Coloring will take place later:
		D.text.applyStyle(label, mp.styleIt.text);
				
		if (mp.style.align == "center2")
		{
			label.fieldWidth = mp.page.params.part1W;
			label.alignment = "right";
		}else{
			label.fieldWidth = 0;
		}
		
		add(label);
		
	}//---------------------------------------------------;
	public function setData(d:MItemData):Void
	{
		data = d;
		on_newdata();
		state_refresh();
	}//---------------------------------------------------;
	/** Receives input IDs from the container
	 *  @param	type [ fire , left , right , click ]
	 */
	public function onInput(type:ListItemInput):Void
	{
		if (data.disabled) {
			callback(invalid);
		}else {
			handleInput(type);
		}
	}//---------------------------------------------------;
	public function focus():Void
	{
		isFocused = true;
		state_refresh();
		callback(ListItemEvent.focus);
	}//---------------------------------------------------;
	// Note: When a VLIST creates/poolgets an item it will call unfocus() first thing
	public function unfocus():Void
	{
		isFocused = false;
		state_refresh();
	}//---------------------------------------------------;
	public function isSame(d:MItemData):Bool
	{
		return data == d;
	}//---------------------------------------------------;
	//====================================================;
	//-- Height reported to parent for spacing vertically 
	override function get_height():Float 
	{
		return label.height;
	}//---------------------------------------------------;
	// --
	override public function add(Sprite:FlxSprite):FlxSprite 
	{
		Sprite.active = false;
		return super.add(Sprite);
	}//---------------------------------------------------;
	
	#if debug
	override public function toString():String {
		return 'x:$x | y:$y | width:$width | height:$height | data:(${data})';
	}//---------------------------------------------------;
	#end
	
	//====================================================;
	
	/**
	  - Called right after setting new data.
	  - Can be called multiple times.
	  - ! Override to initialize other objects
	**/
	function on_newdata()
	{
		label.text = data.label;
	}//---------------------------------------------------;
	
	
	/** Updates the visual state
	  - Called whenever new data is set
	  - On focus/unfocus
	**/
	public function state_refresh()
	{
		if (isFocused){
			if (data.disabled) 
				state_set(dis_f);
			else
				state_set(FocusState.focus);	// Compiler error, because I have a focus() function
		}else{
			if (!data.selectable || data.disabled){
				state_set(dis);
			}else{
				state_set(idle);
			}
		}	
	}//---------------------------------------------------;
	
	function state_set(id:FocusState)
	{
		_ctext(id.getName());
	}//---------------------------------------------------;
	
	
	// -- Override this to manage input --
	function handleInput(type:ListItemInput) {}
	
	/** Colorize Text/Border from style fields
	   @param	s idle, focus, accent, dis, dis_f
	**/
	function _ctext(f:String,?T:FlxText)
	{
		if (T == null) T = label;
		if(Reflect.hasField(mp.styleIt.col_t, f)) {
			T.color = cast(Reflect.field(mp.styleIt.col_t, f), Int);
		}
		if (Reflect.hasField(mp.styleIt.col_b, f)) {
			T.borderColor = cast(Reflect.field(mp.styleIt.col_b, f), Int);
		}else{
			T.borderColor = cast(Reflect.field(mp.styleIt.col_b, 'idle'), Int);
		}
	}//---------------------------------------------------;
	
}// -- end
