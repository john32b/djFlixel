package djFlixel.gapi;

import djFlixel.gapi.ApiOffline.Trophy;
import djFlixel.gfx.Palette_DB32;
import djFlixel.gui.Gui;
import djFlixel.tool.Sequencer;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxSpriteUtil;

/**
 * Basic popup BG trophy notification
 * ...
 * HACKS USED :
 * + To align text vertically when chars>16 field goes up a it.
 */
class TrophyPopup extends FlxSpriteGroup
{
	public static var WIDTH:Int = 120;
	public static var HEIGHT:Int = 40;
	// --
	public static var TIME_TO_SHOW:Float = 2;
	
	public static var P:Dynamic = {
		col : { border:20, bg:21, thumb:15, text:14 },
		bg  : { 
			pos : { x:0, y:0 }, tw: { x:0, y: -4 }	
		},
		thumb  : { 
			pos : { x:3, y:4 }, tw: { x:-2, y: -2 }	
		},		
		text  : { 
			pos : { x:36, y:12 }, tw: { x:0, y: -2 }	
		},
	};// ---------------------------;

	// --
	var bg:FlxSprite;
	var text:FlxText;
	var thumb:FlxSprite;
	// Handle sequences
	var seq:Sequencer;
	// Parameters
	
	//====================================================;
	// STATIC 
	//====================================================;
	
	// Store the ID of the trophies to popup
	var queue:Array<String>;	
	
	//---------------------------------------------------;
	public function new(X:Float,Y:Float)
	{
		super(X, Y);
		scrollFactor.set(0, 0);
		visible = false;
		// --
		// Create the basic Elements, no positioning
		bg = new FlxSprite(0, 0);
		bg.makeGraphic(WIDTH, HEIGHT, Palette_DB32.COL[P.col.bg]);
		add(bg);
		// --
		text = Gui.getQText("", 8, Palette_DB32.COL[P.col.text], -1);
		text.alignment = "center";
		text.fieldWidth = WIDTH - (P.thumb.pos.x + 32);
		add(text);
		// --
		thumb = new FlxSprite();
		thumb.loadGraphic(Reg.api.SPRITE_SHEET, true, 32, 32);
		add(thumb);
		// --
		seq = new Sequencer(seqHandler);
		
		queue = [];
	}//---------------------------------------------------;
	
	
	function seqHandler(step:Int)
	{
		switch(step) {
		case 1:
			bg.visible = true;
			bg.scale.x = 0.1;
			FlxSpriteUtil.drawRect(bg, 0, 0, WIDTH, HEIGHT, Palette_DB32.COL[P.col.bg]);
			FlxSpriteUtil.drawRect(bg, 0, 0.75 * HEIGHT, WIDTH, 0.75 * HEIGHT, Palette_DB32.COL[P.col.border]);
			FlxTween.tween(bg.scale, { x:1 }, 0.12, { onComplete:seq.nextT } );
			FlxTween.tween(bg, { x: bg.x - P.bg.tw.x, y: bg.y - P.bg.tw.y }, 0.08);
		case 2:
			// Draw a border around the whole box
			FlxSpriteUtil.drawRect(bg, 0, 0, WIDTH - 1, HEIGHT - 1, 0x0, { color:Palette_DB32.COL[P.col.border] } );
			thumb.visible = true;
			thumb.alpha = 0;
			FlxTween.tween(thumb, { alpha:1,y: thumb.y - P.thumb.tw.y, x: thumb.x - P.thumb.tw.x }, 0.15, { onComplete:seq.nextT } );
		case 3:
			text.visible = true;
			text.alpha = 0;
			// Draw a border around the THUMB
			FlxSpriteUtil.drawRect(bg, P.thumb.pos.x + 1, P.thumb.pos.y + 1, thumb.width , thumb.height, Palette_DB32.COL[P.col.thumb]);
			FlxTween.tween(text, { alpha:1, y: text.y - P.text.tw.y, x: text.x - P.text.tw.x }, 0.15, { onComplete:seq.nextT } );
		case 4:
			seq.next(TIME_TO_SHOW);
		case 5: 
			FlxTween.tween(thumb, { alpha:0 }, 0.15 );
			FlxTween.tween(text,  { alpha:0 }, 0.15, { onComplete:seq.nextT } );
		case 6:
			FlxTween.tween(bg.scale, { x:0 }, 0.12, { onComplete:seq.nextT } );
		case 7:
			visible = false;
			active = false;
			queue.pop();   // Finished working with it.
			processNext(); // Will check for others and process, else, it will return.
			
		default:
		}
	}//---------------------------------------------------;
	
	/**
	 * Trophy ID to show
	 * @param	id
	 */
	public function popup(id:String)
	{
		queue.push(id);
		// Only process it now if it's the only one.
		if (queue.length == 1) processNext();
	}//---------------------------------------------------;
	
	function processNext()
	{
		if (queue.length == 0) return;
		var id = queue[queue.length - 1]; // Don't pop it!
		
		var tr:Trophy = Reg.api.trophies.get(id);
		if (tr == null) return; //Could not find anything
		
		// - Play a sound
		if (Reg.api.TROPHY_SOUND != null) {
				SND.playFile(Reg.api.TROPHY_SOUND);
			}
		
		// - Initalize the elements
		
		// -- Positions
		visible = true;
		bg.setPosition(x + P.bg.tw.x, y + P.bg.tw.y);
		text.visible = false; text.setPosition(x + P.text.pos.x + P.text.tw.x, y + P.text.pos.y + P.text.tw.y);
		thumb.visible = false; thumb.setPosition(x + P.thumb.pos.x + P.thumb.tw.x, y + P.thumb.pos.y + P.thumb.tw.y);
		thumb.animation.frameIndex = tr.imIndex - 1;
		// --
		text.text = tr.name;
		if (text.text.length >= 16) text.y -= 8;
		// --
		seq.forceTo(1);
	}//---------------------------------------------------;
	
	override public function destroy():Void 
	{
		seq.destroy();
		seq = null;
		super.destroy();
	}//---------------------------------------------------;
	
}// -- 



/*------------------------------------------
	"trophyPopup" :{	
	"col" : { 
		"border":20, "bg":21, "thumb":15, "text":14 
	},
	"bg" : {  
		"pos" : { "x" : 0, "y" : 0 }, "tw":{ "x" : 0, "y" : -4 }
	},		
	"thumb" : { 
		"pos" : { "x" : 3, "y" : 4 }, "tw" : { "x" : -2, "y" : -2 }
	},	
	"text" : { 
		"pos" : { "x" : 36, "y" : 12 }, "tw" : { "x" : 0, "y" : -2 }
	}
},
------------------------------------------*/