package djFlixel.ui.menu;

import djFlixel.ui.VList;
import djFlixel.ui.VList.IVListCursor;
import djFlixel.core.Dtext.DTextStyle;
import djFlixel.ui.menu.MPage.MPageStyle;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import openfl.display.BitmapData;



/**
   Properties for styling the Menu Cursor
   Note: Defaults are defined in <UIDefaults>
**/
typedef MCursorStyle = {
	
	?text:String,		// Character to use for cursor, uses the same style as the Menu Items
	
	?icon:String,		// Use a standard D.UI icon string format : "size:name" | e.g. "12:heart" | Auto color and shadow
	
	?bitmap:BitmapData, // Use this bitmap for a cursor (Will be used as is, no colorization or shadow)
	
	?color:DTextStyle,	// Colorize the Text/Bitmap with this. valid:{c,bc,bt,so} | null to get MItem Color
	
	?anim:String,		// Animated Cursor. You need to have (bitmap) set with a tilesheet
						// "size,fps,frame0,frame1,frame2,frame3....."
						// e.g. "16,10,10,11,12,13,13,11"
	
	?offset:Array<Int>,	// [x,y] Cursor Graphic Offset | [0,0] default | For precise tweaking
	
	?tween:{				// <null/notset> for no cursor animation
		time:Float,			// Tween duration
		x0:Float,			// Start pos, in relation to baseline
		x1:Float,			// End pos, in ralation to baseline
		a0:Float,			// Start Alpha
		a1:Float,			// End Alpha
		ease:String			// Ease function Name (FlxEase)
	}
		
		
}//---------------------------------------------------;



/** 
 Menu Cursor
 To be used as a curson in a Menu Page <MPage>
**/
class MCursor implements IVListCursor
{
	var spr:FlxSprite;
	var group:FlxSpriteGroup;
	var STL:MPageStyle;
	var C:MCursorStyle;	// shortcut for STL.cursor
	var easefn:EaseFunction;
	
	public function new(style:MPageStyle)
	{
		STL = style;
		C = STL.cursor;	// shorthand
		
		if (C.anim != null)
		{
			var dat = C.anim.split(',');
			var size = Std.parseInt(dat.shift());
			var fps = Std.parseInt(dat.shift());
			spr = new FlxSprite();
			spr.loadGraphic(C.bitmap, true, size, size);
			spr.animation.add("m", [for(i in dat) Std.parseInt(i)], fps);
			spr.animation.play("m");	// just play it forever
		}
		
		else if (C.bitmap != null)
		{
			spr = new FlxSprite(C.bitmap.clone());
		}
		
		else
		{
			
			// It is TEXT or ICON
			// So I'd better have a color ready to use in any
			
			var col:DTextStyle;	// Final Cursor color
			if (C.color == null) {
				col = Reflect.copy(STL.item.text);
				col.bc = STL.item.col_b.idle;	// Alter the colors a bit
			}else{
				col = C.color;
			}
			
			if (C.icon != null)
			{
				var b:BitmapData = null;
				var ic = C.icon.split(':');
						b = D.ui.getIcon(Std.parseInt(ic[0]), ic[1]);	
						b = D.gfx.colorizeBitmapWithTextStyle(b, col);
				spr = new FlxSprite(b);
			}
			else
			{
				#if debug
				if (C.text == null) throw "Cursor Style Error, nothing is setup, not even text";
				#end
				spr = cast D.text.get(C.text, col);
			
			}
		}
		
		spr.moves = false;
		if (C.tween != null) 
		{
			easefn = Reflect.field(FlxEase, C.tween.ease);
			if(C.offset!=null)
			spr.offset.subtract(C.offset[0], C.offset[1]);
		}
		
	}//---------------------------------------------------;
	
	public function attach(v:FlxSpriteGroup):Void 
	{
		if (group != null) group.remove(spr);
		visible(false);	// Just in case
		group = v;
		group.add(spr);
	}//---------------------------------------------------;
	
	public function point(el:FlxSprite, itemX0:Float)
	{
		visible(true);
		spr.x = itemX0 - spr.width;
		spr.y = el.y;
		
		if (C.tween==null) return;
		spr.alpha = C.tween.a0;
		spr.x += C.tween.x0;
		
		FlxTween.cancelTweensOf(spr);
		FlxTween.tween(spr, {
			x:spr.x - C.tween.x0 + C.tween.x1,
			alpha:C.tween.a1}, 
			C.tween.time, 
			{ease:easefn}
		);
	}//---------------------------------------------------;

	public function visible(enabled:Bool)
	{
		spr.visible = spr.active = enabled;
	}//---------------------------------------------------;
	
	
	public function updateY(ypos:Float)
	{
		// This hack is needed, until I find a better way to manage 
		// following an item that is currently vertically scrolling
		spr.y = ypos;
	}//---------------------------------------------------;
	
	public function updateX(xpos:Float)
	{
		spr.x = xpos - spr.width;
		if (C.tween==null) return;
		spr.x += C.tween.x1;
	}//---------------------------------------------------;
	
}