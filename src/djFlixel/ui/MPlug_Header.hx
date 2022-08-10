package djFlixel.ui;

import djA.DataT;
import djA.Macros;
import djFlixel.core.Dtext.DTextStyle;
import djFlixel.ui.FlxMenu;
import flixel.FlxG;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.NumTween;
import flixel.util.FlxSpriteUtil;

/**
   Menu Plugin - Header Text + Animated Line
**/

class MPlug_Header extends FlxSpriteGroup implements IFlxMenuPlug
{
	var m:FlxMenu;
	var headerText:FlxAutoText;
	var line:DecoLine;
	
	var P = {
		
		offsetY: -3,		// Positioning Y offset
		
		cps:20,				// Header Text, CPS for animation 0 for instant
		
		lineHeight:1,		// Decorative Line pixel height. 0 to disable the line
		lineTime:0.6,		// Decorative Line time to animate in
		
		text:{}				// DTextStyle for the menu Header
							// If not set will get values from MenuItem Style
							// - overlays properties
							// - NOTE: .align works here {left,center,right}
	};
		
	/**
	   Create this object and call `FlxMenu.plug( plugin )` to enable it
	   @param	PAR Check inside the code {P} object for more info
	**/
	public function new(?PAR:Dynamic)
	{
		super();
		P = DataT.copyFields(PAR, P);
		
		headerText = new FlxAutoText(0, 0, 0, 1);
		headerText.setCPS(P.cps);
		headerText.textObj.height; // HACK?: Forces flxtext regen graphic to get proper height
		add(headerText);
		
		// --
		if (P.lineHeight > 0)
		{
			line = new DecoLine(P.lineHeight);
			add(line);
		}
		
	}//---------------------------------------------------;
	
	// -- INTERFACE
	@:allow(djFlixel.ui.FlxMenu)
	function attach(m:FlxMenu)
	{
		this.m = m;
		m.add(this);	// not all plugins are to be added?
	}//---------------------------------------------------;
	
	// -- INTERFACE
	function onMEvent(ev:MenuEvent, pid:String)
	{
		if (ev == MenuEvent.page) onPage(); else
		if (ev == MenuEvent.close) onClose();
	}//---------------------------------------------------;
	
	
	function onPage()
	{
		if (m.pageActive.title == null)
		{
			visible = false;
			return;
		}
		
		visible = true;
		
		// -- AutoText
		
		var STP = m.mpActive.STP; // proper style with page data overrides applied to it
		var stt:DTextStyle = DataT.copyDeep(P.text);
		
		if (stt.c == null) stt.c = STP.item.col_t.accent;
		if (stt.bc == null) stt.bc = STP.item.col_b.accent;
		if (stt.bc == null) stt.bc = STP.item.col_b.idle;
		if (stt.f == null) stt.f = STP.item.text.f;
		if (stt.s == null) stt.s = STP.item.text.s;
		if (stt.bt == null) stt.bt = STP.item.text.bt;
				
		headerText.style = stt;
		headerText.textObj.fieldWidth = m.mpActive.menu_width;
		headerText.setText(m.pageActive.title);
		
		// -- Deco Line
		line.start(P.lineTime, m.mpActive.menu_width, stt.c);
		line.y = headerText.y + headerText.height + 2;
		
		// --
		this.x = m.mpActive.x;
		this.y = m.mpActive.y - this.height + P.offsetY;
		
		
	}//---------------------------------------------------;
	
	
	function onClose()
	{
		visible = false;
	}//---------------------------------------------------;
	
	
}// --







private class DecoLine extends FlxSprite 
{
	var t:NumTween;
	
	public function new(HEIGHT:Int = 2, COLOR:Int = 0xFFFFFFFF)
	{
		super();
		moves = false;
		makeGraphic(FlxG.width, HEIGHT, 0x00000000);
	}
	
	public function start(time:Float = 1, W:Int = 100, C:Int = 0xFFFFFFFF, ?Ease:String = "linear", ?callback:FlxTween->Void)
	{
		stop(true);
		t = FlxTween.num(0, W, time, {ease:Reflect.field(FlxEase, Ease)}, function(v:Float){
			FlxSpriteUtil.drawRect(this, 0, 0, Std.int(v), graphic.height, C);
		});
	}
	
	public function stop(clear:Bool = false)
	{
		t = D.dest.numTween(t);
		if (clear) {
			pixels.floodFill(0, 0, 0x00000000);
			dirty = true;
		}
	}
	
	override public function destroy():Void 
	{
		stop();
		super.destroy();
	}
	
}