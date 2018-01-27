package guidemos;

import djFlixel.gui.Align;
import djFlixel.gui.Gui;
import djFlixel.gui.Styles;
import djFlixel.gui.list.IListItem;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxSpriteUtil;


/**
 * A simple Object that can go inside a `VListBase` and `VListNav`
 * On how this is used, refer to `State_VListBase.hx` and `State_VListNav.hx`
 * ...
 */
class ListItem extends FlxSpriteGroup implements IListItem<String>
{
	

	static public var WIDTH:Int = 100;
	static public var HEIGHT:Int = 24;
	
	// Box Colors::
	static public var color_focused:Int = 0xFFFF8000;
	static public var color_rest:Int = 0xFF5F5F5F;
	
	// Is the item clicked/toggled or not
	public var CHECKED:Bool;
	// The actual data passed to the list from the parent menu
	var data:String;
	
	public var isFocused(default, null):Bool;

	var b:FlxSprite;
	var t:FlxText;
	
	public function new() 
	{
		super();
		b = new FlxSprite();
		b.makeGraphic(WIDTH, HEIGHT);
		add(b);
		
		t = new FlxText(0, 0, WIDTH);
		t.alignment = 'right';
		Styles.applyTextStyle(t, {
			color:0xFFE0E0E0,
			color_border:0xFF4D312B
		});
		
		add(cast Align.YAxis(t, b));
		
	}//---------------------------------------------------;
	
	/* INTERFACE djFlixel.gui.list.IListItem.IListItem<T> */
	
	public var callbacks:String->Void;
	
	public function setData(data:String):Void 
	{
		CHECKED = false;
		this.data = data;
		updateText();
	}//---------------------------------------------------;
	
	function updateText()
	{
		t.text = data + "  " + (CHECKED?"[X]":"[ ]");
	}//---------------------------------------------------;
	// --
	public function sendInput(inputName:String):Void 
	{
		// NOTE:
		// Mouse clicks get passed as "c|x|y", 
		// So if it starts with c| it's a mouse click
		if (inputName == "fire" || inputName.indexOf("c|") == 0)
		{
			CHECKED = !CHECKED;
			updateText();
		}
	}//---------------------------------------------------;
	public function focus():Void 
	{
		b.color = color_focused;
	}//---------------------------------------------------;
	
	// --
	public function unfocus():Void 
	{
		b.color = color_rest;
	}//---------------------------------------------------;
	
	public function isSame(data:String):Bool 
	{
		return this.data == data;
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
	
}