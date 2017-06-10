package djFlixel.gui.menu;

import djFlixel.gui.Styles;
import djFlixel.gui.list.IListItem;
import djFlixel.gui.menu.MItemData;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;


// Menu Item Base
// --
// Basic Menu Item, Other more specific items will derive from this.
// Don't forget this is only a representation of data.
// Any changes should be written back to the $data object, as it acts as a pointer
// --
class MItemBase extends FlxSpriteGroup implements IListItem<MItemData>
{
	// Pointer to the MItemData. Deal with this when handling data
	public var opt(default, null):MItemData;
	
	// Pointer to a style, parent sets this.
	public var style:MItemStyle;
	
	// Whether or not this item has input focus right now
	public var isFocused(default, null):Bool;

	// -- Set by parent, fire input events.
	//    The ID is handled by parent.
	public var callbacks:String->Void;
	// -- Helper
	function cb(a:String) { if (callbacks != null) callbacks(a); }	
	
	// This is part 1, the label
	var label:FlxText;

	// How many pixels right of the label to pad the active element
	var PADDING_FROM_LABEL:Int;

	//====================================================;
	
	public function new(_style:MItemStyle)
	{
		super();
		
		// Note:
		// ---------------
		// Don't get this.width, It WILL report bad values.
		
		// - Init
		isFocused = false;
		style = _style;
		
		// - All items must have a label
		label = new FlxText();
		Styles.styleMItemText(label, style);
		add(label);
		
		PADDING_FROM_LABEL = style.size;
	}//---------------------------------------------------;
	
	// --
	// NOTE: can be called multiple times in recycled objects
	// If you want to update the extended object,
	// do so in updateVisual();
	public function setData(OPT:MItemData) 
	{
		opt = OPT;
		// Updates the data portion
		initElements();
		// Check and set the visual state (disabled,default)
		updateState();
	}//---------------------------------------------------;
	// --
	public function isSame(OPT:MItemData)
	{
		// It is quicker to check for Integers, just be sure they are set.
		return this.opt.UID == OPT.UID;
	}//---------------------------------------------------;
	
	// -- 
	// Gets called JUST AFTER getting data
	// Updates the Elements with the new data
	// * Override to init other elements *
	function initElements()
	{			
		label.fieldWidth = 0; // Auto width
		label.text = opt.label;
	
		// VERSION: 0.3 removed:
		//if (label.fieldWidth > parent.width) {
		//	label.fieldWidth = parent.width;
		// }
	
	}//---------------------------------------------------;
	// --
	// Accepting: [select, cancel, right, left];
	public function sendInput(inputName:String) 
	{
		if (opt.disabled) {
			cb("invalid");
		}else {
			handleInput(inputName);
		}
	}//---------------------------------------------------;
	
	// -- OVERRIDE THIS --
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
			label.color = style.color_default;	
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
	// Called on initialization and by user
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
		if (Value < 0) Value = 0;
		if (Value > 1) Value = 1;
		for (i in group) { i.alpha = Value; }
		return alpha = Value;
	}//---------------------------------------------------;
	// --
	public inline function getItemHeight():Int
	{
		return Std.int(label.size);
		//return Std.int(label.textField.textHeight);
	}//---------------------------------------------------;
	
}// --