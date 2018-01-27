package djFlixel.gui.menu;

import djFlixel.gui.Styles;
import djFlixel.gui.list.IListItem;
import djFlixel.gui.menu.MItemData;
import flixel.FlxSprite;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;


// Menu Item Base
// Basic Menu Item, Other more specific items derive from this.
// ------------
// This is only a representation of data.
// Any changes should be written back to the $data object, as it acts as a pointer
// --
// Menu Items consist of 2 parts, the label, which is standard to all items
// and the functional part which is variable to each specific menu item
// ------
class MItemBase extends FlxSpriteGroup implements IListItem<MItemData>
{
	
	// In alignment(left,right,center) pad the elements by (fontwidth * this)
	static public var PADDING_MULTIPLIER:Float = 0.85;
	
	// Pointer to the MItemData. Deal with this when handling data
	public var opt(default, null):MItemData;
	
	// Pointer to a style, parent sets this
	public var style:StyleVLMenu;
	
	// Whether or not this item has input focus right now
	public var isFocused(default, null):Bool;

	// -- Set by parent, fire input events.
	//    The ID is handled by parent.
	public var callbacks:String->Void;
	
	// -- Helper
	function cb(a:String) { if (callbacks != null) callbacks(a); }	
	
	// This is the left portion of the item, the label
	@:allow(djFlixel.gui.list.VListMenu)
	var label:FlxText;

	// Minimum padding to pad (part 2) when it's placed next to the label
	var EL_PADDING:Float;

	// The width of the Vertical List this belongs to
	var parentWidth:Int;
	
	// Write the actual width for better alignment, works with get_width();
	// Separate var so I don't have to override the getter at each extended class
	var self_width:Float = 0;
	
	//====================================================;
	
	/**
	 * Create 
	 * @param	_style Menu Item Style, MUST BE SET
	 * @param	_w VerticalList width, good to know for the justify alignment
	 */
	public function new(_s:StyleVLMenu, _w:Int)
	{
		super();
		
		// - Init
		isFocused = false;
		style = _s;
		parentWidth = _w;
		
		// - All items must have a label
		label = new FlxText();
		label.fieldWidth = 0; // Auto width
		label.wordWrap = false;
		Styles.applyTextStyle(label, style);
		add(label);
		
		EL_PADDING = style.fontSize * PADDING_MULTIPLIER;
	}//---------------------------------------------------;
	
	// --
	// NOTE: can be called multiple times in recycled objects
	// If you want to update the extended object,
	// do so in updateVisual();
	public function setData(OPT:MItemData) 
	{
		opt = OPT;
		// Update elements and check state
		initElements();
		updateState();
	}//---------------------------------------------------;
	// --
	// VListBase needs an equality check for pooling functionality
	public function isSame(OPT:MItemData)
	{
		// It is quicker to check for Integers, just be sure they are set.
		return opt.UID == OPT.UID;
	}//---------------------------------------------------;
	
	// -- 
	// Gets called JUST AFTER setting the data
	// Updates the Elements with the new data
	// -- OVERRIDE TO INITIALIZE EXTENDED OBJECT --
	function initElements()
	{
		label.text = opt.label;
		
		if (style.alignment == "right"){
			label.x = x + parentWidth - label.fieldWidth;
			self_width = parentWidth;
		}else
		if (style.alignment == "justify"){
			self_width = parentWidth;
		}else{
			// left center
			self_width = label.fieldWidth;
		}
		
	}//---------------------------------------------------;
	
	/**
	 * Receives input IDs from the container
	 * @param	inputName [ fire , left , right , click, clickR ]
	 */
	public function sendInput(inputName:String) 
	{	
		if (opt.disabled) {
			cb("invalid");
		}else {
			handleInput(inputName);
		}
	}//---------------------------------------------------;
	
	// -- Override this to manage input --
	function handleInput(inputName:String)
	{	
	}//---------------------------------------------------;
	
	// -- Override to manage extra objects --
	function state_focused()
	{
		if (opt.disabled)
			label.color = style.color_disabled_f;
		else
			label.color = style.color_focused;
	}//---------------------------------------------------;
	// -- Override to manage extra objects --
	function state_default()
	{
		// It will never be focused because it should be disabled!
		// Thus color it as default unselected
		if (opt.disabled)
			label.color = style.color_disabled;
		else
			label.color = style.color;	
	}//---------------------------------------------------;
	// -- Override to manage extra objects --
	function state_disabled()
	{
		label.color = style.color_disabled;
	}//---------------------------------------------------;
	// --
	public function focus() 
	{
		if (!opt.selectable) return; // DEV: I could skip this call
		isFocused = true;
		state_focused();
	}//---------------------------------------------------;
	// --
	// Note: All elements that are added to a list are 
	//       auto-unfocused by parent
	public function unfocus() 
	{
		if (!opt.selectable) return; // DEV: I could skip this call
		isFocused = false;
		state_default();
	}//---------------------------------------------------;
	
	// --
	// Updates the visual state
	// Called on initialization and by user ( call after making changes to the MenuData to reflect state changes )
	public function updateState()
	{
		if (!opt.selectable)  {
			state_disabled(); 
		}else {
			if (isFocused) state_focused(); else state_default();
		}
	}//---------------------------------------------------;
	
	// -- 
	// - GroupAlpha is broken, so do it manually
	override private function set_alpha(Value:Float):Float 
	{
		if (Value < 0) Value = 0; else
		if (Value > 1) Value = 1;
		for (i in group) { i.alpha = Value; }
		return alpha = Value;
	}//---------------------------------------------------;
	//--
	//- Just return the font height in pixels. The true pixel size of the menu item
	override function get_height():Float 
	{
		return label.size;
	}//---------------------------------------------------;
	
	override function get_width():Float 
	{
		return self_width;
	}//---------------------------------------------------;
	
	// --
	// There is a 2 pixel gutter around a textfield so I am putting
	// 	everything 2 pixels higher
	override public function add(Sprite:FlxSprite):FlxSprite 
	{
		Sprite.offset.add(0, 2);
		return super.add(Sprite);
	}//---------------------------------------------------;
	
	#if debug
	override public function toString():String {
		return 'x:$x | y:$y | width:$width | height:$height | data:(${opt})';
	}//---------------------------------------------------;
	#end
	
	
	/**
	 * Translate mouse input status to X,Y
	 * @param	str "c|X|Y"
	 * @return [X,Y] int array, NULL otherwise
	 */
	private function getMouseCoords(str:String):Array<Int>
	{
		if (str.indexOf("c|") == 0) {
			var s:Array<String> = str.split("|");
			return [Std.parseInt(s[1]), Std.parseInt(s[2])];
		}
		return null;
	}//---------------------------------------------------;
	
}// --