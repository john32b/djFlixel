package djFlixel.gapi;

import djFlixel.gui.Gui;
import djFlixel.gfx.Palette_DB32;
import djFlixel.gui.listoption.IListOption;
import djFlixel.gapi.ApiOffline.Trophy;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.FlxSprite;

/**
 * 
 * NOTE: 
 * 
 * + Need to have set the P.image!
 * + Needs to have Reg.api set
 * + End of document for JSON
 * 
 */
class TrophyBigBox extends FlxSpriteGroup implements IListOption<Trophy>
{
	var bg:FlxSprite;
	var thumb:FlxSprite;
	
	var name:FlxText;
	var desc:FlxText;
	var type:FlxText;
	
	// :: Needed For Interface::
	var data:Trophy;
	
	var unlocked:Bool = false;
	
	public var isFocused(default, null):Bool;
	public var callbacks:String->Void = null;
	
	// -- These values can be copied to a JSON for easier modification
	public static var PMaster:Dynamic = {
		
		s32: {
			width : 200, height:38,
			name :  { x:41,  y:4 ,  w:170, colOff:22, colOn:1 },
			desc :  { x:41,  y:16 , w:170, colOff:22, colOn:14 },
			type :  { x:140, y:4 ,  w:60,  colOff:22 },
			imbox:  { x:3,   y:3 ,  w:170, col:20 }
		},
		
		s24: {
			width : 200, height:38,
			name :  { x:41,  y:4 ,  w:170, colOff:22, colOn:1 },
			desc :  { x:41,  y:16 , w:170, colOff:22, colOn:14 },
			type :  { x:140, y:4 ,  w:60,  colOff:22},
			imbox:  { x:7,   y:7 ,  w:170, col:20 }
		}
	};
	
	// -- # USER SET #
	// - Path to the trophybox spritesheet
	public static var IMAGE:String = "";
	// -- Size of the trophy thumbs,
	public static var SIZE:Int = 32;
	
	// Locally used parameters
	var P:Dynamic;
	
	//--
	public function new() 
	{
		super();
		
		if (SIZE == 32) P = PMaster.s32; else P = PMaster.s24;
		
		bg = new FlxSprite(0, 0);
		bg.loadGraphic(IMAGE, true, P.width, P.height);
		bg.animation.frameIndex = 0;
		add(bg);
		// --
		thumb = new FlxSprite(P.imbox.x, P.imbox.y);
		thumb.loadGraphic(Reg.api.TROPHY_SPRITE_SHEET, true, SIZE, SIZE);
		thumb.visible = false;
		add(thumb);
		// --
		name = new FlxText(P.name.x, P.name.y, P.name.w, "", 8);
		name.color = Palette_DB32.COL[P.name.colOn];
		add(name);
		//--
		desc = new FlxText(P.desc.x, P.desc.y, P.desc.w, "", 8);
		desc.color = Palette_DB32.COL[P.desc.col];
		add(desc);
		//--
		type = new FlxText(P.type.x, P.type.y, P.type.w, "", 8);
		type.color = Palette_DB32.COL[P.type.col];
		type.alignment = "right";
		add(type);
		//--
		
		// -- Force Graphic change to OFF
		isFocused = true;
		unfocus();
		
	}//---------------------------------------------------;
	
	// --
	public function setData(d:Trophy):Void
	{
		data = d;
		name.text = d.name;
		desc.text = d.desc;
		type.text = d.type;
		thumb.animation.frameIndex = d.imIndex - 1;
		thumb.visible = d.unlocked;
		
		unlocked = d.unlocked;
		
		if (unlocked)
		{
			name.color = Palette_DB32.COL[P.name.colOn];
			desc.color = Palette_DB32.COL[P.desc.colOn];
			type.color = getTypeColor(d.type);
		}else {
			name.color = Palette_DB32.COL[P.name.colOff];
			desc.color = Palette_DB32.COL[P.desc.colOff];
			type.color = Palette_DB32.COL[P.type.colOff];
		}
		
	}//---------------------------------------------------;
	
	function getTypeColor(type:String):Int {
		return switch(type) {
				case "bronze" : Palette_DB32.COL[5];
				case "silver" : Palette_DB32.COL[24];
				case "gold" : Palette_DB32.COL[8];
				case "platinum" : Palette_DB32.COL[20];
				default : Palette_DB32.COL[1];
		}
	}//---------------------------------------------------;
		
	public function sendInput(inputName:Dynamic):Void
	{
	}//---------------------------------------------------;
	
	public function focus():Void 
	{ 
		if (isFocused) return;
			isFocused = true;
			
		if (callbacks != null) callbacks("optFocus");
		
		if (unlocked) {
			bg.animation.frameIndex = 3;
		}else {
			bg.animation.frameIndex = 1;
		}
	}//---------------------------------------------------;
	public function unfocus():Void
	{ 
		// if (!isFocused) return;
			isFocused = false;
		
		if (unlocked) {
			bg.animation.frameIndex = 2;
		}else {
			bg.animation.frameIndex = 0;
		}
	}//---------------------------------------------------;
	// -
	public inline function getOptionHeight():Int
	{
		return P.height;
	}//---------------------------------------------------;
	
	// -
	public function isSame(data:Trophy):Bool
	{
		return this.data.sid == data.sid;
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
}// -- end -- //




/* JSON Example::
 
	"trophyBox":{
		"image": "assets/trophy_box.png",
		"size" : 32,
		"name" : { "x" : 41 , "y" : 4,  "w":170, "colOff" : 22, "colOn" : 1  },
		"desc" : { "x" : 41 , "y" : 16, "w":170, "colOff" : 22, "colOn" : 14 },
		"type" : { "x" : 140 , "y" : 4, "w":60,  "colOff" : 22, "colOn" : 5 },
		"imbox": { "x" : 3, "y" : 3, "col":20 }
	}
*/