/**
 * 
 * TrophyPopup 
 * -------------
 * A sprite group that pops up on the screen with basic Trophy information
 * , like trophy pic, name, description and type
 * 
 */


package djFlixel.gapi;

import flixel.group.FlxSpriteGroup;

import djFlixel.gapi.ApiOffline.Trophy;
import djFlixel.gfx.Palette_DB32;
import djFlixel.gui.Align;
import djFlixel.gui.Gui;
import djFlixel.tool.Sequencer;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxSpriteUtil;

/**
 * Basic popup BG trophy notification
 * ...
 */
class TrophyPopup extends FlxSpriteGroup
{
	
	//====================================================;
	// # USER SET 
	//====================================================;
	
	// Seconds to display
	public static var TIME_TO_SHOW:Float = 2;
	// Pixels from the edges when aligning
	public static var ALIGN_PADDING:Int = 2;
	// If this is not null then try not to obstruct it when displaying the popup
	public var objectRef:FlxObject = null;
	
	
	// You can change the colors or tween styles if you want
	// Colors are DB32 base
	public static var P:Dynamic = {
		col 	: { border:20, bg:21, thumb:15, text:14 },
		bg  	: { pos : { x:0, y:0 }, tw: { x: 0, y: -4 } },
		thumb  	: { pos : { x:3, y:4 }, tw: { x:-2, y: -2 }	},		
		text  	: { 					tw: { x: 0, y: -2 } }
	};
	
	//====================================================;
	
	// Sizes of the whole box depending on a 32x32, 24x24, 16x16 thumb
	static var SIZES(default,never):Array<Int> = [ 
		120  , 40,
		110  , 32,
		100  , 24
	];
	
	// --
	var bg:FlxSprite;
	var text:FlxText;
	var thumb:FlxSprite;
	// Handle sequences
	var seq:Sequencer;
	// Store the ID of the trophies to popup
	var queue:Array<String>;	
	
	var THUMB_SIZE:Int;
	var WIDTH:Int;	// Auto get from available sizes
	var HEIGHT:Int; // Auto get from available sizes
	
	//---------------------------------------------------;
	/**
	 * Thumbnail size
	 * @param	size_ 16,24,[32]
	 */
	public function new(size_:Int = 32)
	{
		super(4,4);
		THUMB_SIZE = size_;
		switch(THUMB_SIZE) {
			case 32: WIDTH = SIZES[0]; HEIGHT = SIZES[1];
			case 24: WIDTH = SIZES[2]; HEIGHT = SIZES[3];
			case 16: WIDTH = SIZES[4]; HEIGHT = SIZES[5]; 
		}
		
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
		text.fieldWidth = WIDTH - (P.thumb.pos.x + THUMB_SIZE);
		add(text);
		// --
		thumb = new FlxSprite();
		thumb.loadGraphic(Reg.api.TROPHY_SPRITE_SHEET, true, THUMB_SIZE, THUMB_SIZE);
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
			queue.shift();   // Finished working with it.
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
		trace("PUSHING POPUP ID", id);
		queue.push(id);
		// Only process it now if it's the only one.
		if (queue.length == 1) processNext();
	}//---------------------------------------------------;
	
	/**
	 * Reads the achievement queue and displays the trophy popup
	 */
	function processNext()
	{
		// --
		// Automatically position the trophy depending on an object or global align mode
		var al :Array<String> = [];
		if (objectRef != null) {
			var point = objectRef.getScreenPosition(null, objectRef.camera);
			if (point.x < camera.width / 2) al[0] = "right" else al[0] = "left";
			if (point.y < camera.height / 2) al[1] = "bottom" else al[1] = "top";
			point.put();
		}else {			
			al = Reg.api.TROPHY_ALIGN.split('|');
		}
		Align.screen(this, al[0], al[1], ALIGN_PADDING);
		
		// --

		if (queue.length == 0) return;
		var id = queue[0]; // Don't pop it! Get the First One!
		trace("DISPLAYING POPUP WITH ID", id);
		
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
		thumb.visible = false; 
		thumb.setPosition(x + P.thumb.pos.x + P.thumb.tw.x, y + P.thumb.pos.y + P.thumb.tw.y);
		text.text = tr.name; text.visible = false; 
		text.setPosition(thumb.x + THUMB_SIZE + 1 + P.text.tw.x, y + (HEIGHT / 2) - text.height / 2 + P.text.tw.y);
		if (tr.imIndex > 0) thumb.animation.frameIndex = tr.imIndex - 1;
		
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
		"tw" : { "x" : 0, "y" : -2 }
	}
},
------------------------------------------*/
