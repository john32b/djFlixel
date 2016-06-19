package;

import djFlixel.gui.list.VListBase;
import djFlixel.gui.listoption.IListOption;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;


//--
class SaveSlotGfx extends FlxSpriteGroup implements IListOption<SaveSlotData>
{	
	inline static var WIDTH:Int = 160;
	inline static var HEIGHT:Int = 32;
	
	var bg:FlxSprite;
	var textLevel:FlxText;
	var textSlot:FlxText;
	
	var data:SaveSlotData;
	
	public var isFocused(default, null):Bool;
	
	public var callbacks:String->Void = null;

	//====================================================;
	// -- CONSTRUCTOR --
	public function new() 
	{
		super();

		bg = new FlxSprite(0, 0);
		bg.makeGraphic(200, getOptionHeight(), 0xFF993399);
		add(bg);
		
		textLevel = new FlxText(2, 2);
		add(textLevel);
		
		textSlot = new FlxText(2, 20);
		add(textSlot);
		
		isFocused = true;
		unfocus();
		
		// unfocus is going to be called by parent
	}//---------------------------------------------------;
	
	// --
	public function setData(d:SaveSlotData):Void
	{
		data = d;
		textSlot.text = 'Slot : ${data.slot}';
		textLevel.text = 'Level: ${data.level}';
	}//---------------------------------------------------;
	
	public function sendInput(inputName:Dynamic):Void
	{
	}//---------------------------------------------------;
	
	public function focus():Void 
	{ 
		if (isFocused) return;
			isFocused = true;
			
		if (callbacks != null) callbacks("optFocus");
			
		bg.color = 0xFFFF2222;
	}//---------------------------------------------------;
	public function unfocus():Void
	{ 
		if (!isFocused) return;
			isFocused = false;
		bg.color = 0xFF22FF22;
	}//---------------------------------------------------;
	
	public inline function getOptionHeight():Int
	{
		return HEIGHT;
	}//---------------------------------------------------;
	
	// -
	public function isSame(data:SaveSlotData):Bool
	{
		return this.data == data;
	}//---------------------------------------------------;
	
	// -- 
	// - GroupAlpha is broken, so do it manually... :/
	override private function set_alpha(Value:Float):Float 
	{
		if (Value < 0) Value = 0;
		if (Value > 1) Value = 1;
		for (i in group) { i.alpha = Value; }
		return alpha = Value;
	}//---------------------------------------------------;

}// -- end class --;