package djFlixel.gui;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;
import openfl.display.BitmapData;


/// THIS NEEDS UPDATING -- DO NOT USE --

/**
 * Display sprites in pages,
 * useful for help pages
 * ...
 */
class FlxMenuPages extends FlxGroup
{
	// World Coordinates to draw this menu to
	var pos_x:Float;
	var pos_y:Float;

	var width:Float;
	var height:Float;

	// Hold all the objects
	var pages:Array<Array<FlxSprite>>;
	// Current page
	var pageIndex:Int;
	
	var isAnimating:Bool;
	
	// Sprites for the left and right indicators
	var cursor_left:FlxSprite;
	var cursor_right:FlxSprite;

	var cursorTimer:Float = 0;
	var cursor_offset:Int = 0;
	var cursor_offset_distance:Int = 2;
	
	
	var tim:FlxTimer;
	
	
	// Simple event callbacks, USERSET
	// ["change","back"]
	public var callback_action:String->Void;
	
	//---------------------------------------------------;
	
	public function new(posX:Float = 10, posY:Float = 10, Width:Float = 300, Height:Float = 200)
	{
		super();
		pos_x = posX;
		pos_y = posY;
		width = Width;
		height = Height;
		
		isAnimating = false;
		
		pages = [];
		pageIndex = -1; // none
		
		// -- Add the cursors
		cursor_left = new FlxSprite(0, 0);
		cursor_left.loadGraphic(Gui.GUI_ICONS, true, 16, 16);
		cursor_left.animation.frameIndex = 4;
		cursor_left.setSize(4, 4);
		cursor_left.centerOffsets();
		cursor_right = new FlxSprite(0, 0);
		cursor_right.loadGraphicFromSprite(cursor_left);
		cursor_right.animation.frameIndex = 5;
		cursor_right.setSize(4, 4);
		cursor_right.centerOffsets();
		
		cursor_left.visible = false;
		cursor_right.visible = false;
		
		//TODO: fix the params
		cursor_left.setPosition(pos_x + 12, (pos_y / 2) + (height / 2));
		cursor_right.setPosition(pos_x + width - 16, cursor_left.y);
		
		add(cursor_left);
		add(cursor_right);
		
		this.visible = false;
	}//---------------------------------------------------;
	
	/**
	 * Create a page and return it,
	 * You should then push elements to that array.
	 * @param index The page index to create.
	 */
	public function createPage(index:Int):Array<FlxSprite>
	{
		if (pages[index] != null)
		{
			trace('Error: Page index($index) already exists');
			return null;
		}
		
		pages[index] = [];
		return pages[index];
	}//---------------------------------------------------;
	
	// --
	public function showPage(index:Int, ?onComplete:Void->Void)
	{
		
		trace("Showing page", index);
		#if debug
		if (pages[index] == null) {
			trace('Error: Page with index($index) does not exist');
			return;
		}
		#end
		
		// Remove all the previous page sprites
		if (pages[pageIndex] != null)
		for (i in pages[pageIndex]) {
			remove(i);
		}
		
		pageIndex = index;
		
		// --
		
		var page:Array<FlxSprite> = pages[pageIndex];
		
		var delayTime:Float = 0.6 / page.length;
		var transitionTime:Float = delayTime * 0.8;
		
		var cc:Int = 0;
		for (el in page) 
		{
			el.y -= 8; //#PARAM
			el.alpha = 0;
			FlxTween.tween(el, { y:el.y + 8, alpha:1 }, transitionTime, 
					{ type:FlxTween.ONESHOT, startDelay:cc * delayTime } );
			cc++;
			add(el);
		}
		
		isAnimating = true;

		if (tim != null) tim.cancel();
		tim = new FlxTimer().start(cc * delayTime, function(_) {
			isAnimating = false;
			tim.destroy(); tim = null;
			if (onComplete != null) onComplete();
		});
		
		cursor_left.visible = (pageIndex > 0);
		cursor_right.visible = (pageIndex >= 0) && pageIndex < pages.length - 1;
		
		this.visible = true;
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// Tween the cursors
		cursorTimer += FlxG.elapsed;
		if (cursorTimer > 0.07)	//#param
		{
			cursorTimer = 0;
			cursor_offset++;
			if (cursor_offset > cursor_offset_distance) 
				cursor_offset = -cursor_offset_distance;

			cursor_left.x += cursor_offset;
			cursor_right.x += -cursor_offset;
		}
		
		
		// No key input when
		if (isAnimating || !visible) return;
		
		// Keys
		if (CTRL.CURSOR_START() || CTRL.CURSOR_CANCEL()) {
			if (callback_action != null) callback_action("back");
		}else
		switch(CTRL.CURSOR_DIR()) {
				case CTRL.RIGHT: 
				if (pageIndex < pages.length-1) {
					showPage(pageIndex + 1);
					if (callback_action != null) callback_action("change");
				}
				case CTRL.LEFT: 
				if (pageIndex > 0) {
					showPage(pageIndex-1);
					if (callback_action != null) callback_action("change");
				}
		}
		
	}//---------------------------------------------------;
	
	// --
	override public function destroy():Void 
	{	
		super.destroy();
		tim = FlxDestroyUtil.destroy(tim);
		
		if (pages != null)
		for (page in pages)
		{
			if (page != null)
			for (obj in page) {
				if (obj != null)
				{
					obj.destroy();
					obj = null;
				}
			}
			page = null;
		}
		pages = null;
		
	}//---------------------------------------------------;
	
	
}//-- end --//