package common;
import djFlixel.SND;
import djFlixel.fx.BoxScroller;
import djFlixel.fx.RainbowStripes;
import djFlixel.gfx.GfxTool;
import djFlixel.gfx.Palette_DB32;
import djFlixel.gui.menu.MItemData;
import djFlixel.tool.DataTool;
import djFlixel.tool.DelayCall;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxState;

/**
 * Static class with helpers
 * ...
 */
class Common 
{

	// State Demos will return to this page on ESC and QUITS
	public static var demo_return_state:Class<FlxState>;
	
	// -- Assumes demo_return_state is set
	public static function GOTO_MEGADEMO()
	{
		FlxG.switchState(cast Type.createInstance(demo_return_state, []));
	}//---------------------------------------------------;
	
	// --
	// Being inline and empty will completely ignore this function in release builds
	inline public static function setPixelPerfect()
	{
		#if debug
			FlxG.scaleMode = new flixel.system.scaleModes.PixelPerfectScaleMode();
		#end
	}//---------------------------------------------------;
	
	/**
	 * Return a box scroller with a predefined image from the assets,
	 * also colorizes the patern
	 */
	public static function getBGScroller(Z:{colorA:Int, colorB:Int, x:Float, y:Float, bg:Int})
	{
		Z = DataTool.copyFields(Z, {
			colorA:Palette_DB32.COL[24],
			colorB:Palette_DB32.COL[25],
			x:0.2,
			y:0.2,
			bg:1
		});
		
		var cb:BitmapData = GfxTool.resolveBitmapData("assets/bg0" + Z.bg + ".png");
			cb = GfxTool.replaceColor(cb, 0xFFFFFFFF, Z.colorA);
			cb = GfxTool.replaceColor(cb, 0xFF000000, Z.colorB);
		var bs = new BoxScroller(cb, 0, 0, FlxG.width, FlxG.height, true);
			bs.autoScrollX = Z.x;
			bs.autoScrollY = Z.y;
		return bs;		
	}//---------------------------------------------------;
	
	/**
	 * Pass through function for flxMenus callbacks. Generates sounds
	 */
	public static function handleMenuSounds(id:String)
	{
		if (id == "tick" || id == "tick_change") SND.play("c_tick");
		if (id == "tick_fire") SND.play("c_sel");
	}//---------------------------------------------------;
	
	
	/**
	 * Creates and adds to the state a fullscreen 8bit stripe loader. Autoremoves it later.
	 * @param	duration
	 * @param	callback
	 * @return
	 */
	public static function create_8bitLoader(duration:Float = 0.5, callback:Void->Void):RainbowStripes
	{
		var r = new RainbowStripes(); FlxG.state.add(r);
		r.setPredefined(FlxG.random.int(1, 3));
		#if(FLX_SOUND_SYSTEM)
		var sound = SND.play("8bitload");
		#end
		new DelayCall(function(){
			FlxG.state.remove(r);
			r.destroy();
			#if(FLX_SOUND_SYSTEM)
				sound.stop();
			#end
			if (callback != null) callback();
		}, duration);
		return r;
	}//---------------------------------------------------;
}// 