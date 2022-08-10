/**

== Simple graphic button with 3 states ( normal | hover | pressed )
 

 - Uses djFlixel built in asset gfx for the button, (slice9 scale capable)
 - Can include a graphic on top of the button, so basically this is two sprites
 
 
 *********************************************************************/

package djFlixel.ui;

import djA.DataT;
import djFlixel.core.Dtext.DTextStyle;
import flash.display.BitmapData;
import flash.display3D.VertexBuffer3D;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;


class UIButton extends FlxSpriteGroup
{
	inline static var STATE_NORMAL:Int = 0;
	inline static var STATE_HOVER:Int = 1;
	inline static var STATE_PRESS:Int = 2;
	
	// The default colors that are going to be replaced
	static var TEMPLATE_COLOR_MAP:Array<Int> = [
		0xFF000000,	//  Border
		0xFF0000FF, //  Dark
		0xFFFF0000, //  Main
		0xFFFFFFFF  //  Highlight
	];
	
	
	// All buttons will share the same hover text object,
	// , as only one can be shown at any time
	static var hoverText:FlxText;
	static public var hoverCount:Int = 0;	// How many buttons currently use hovertext
	//====================================================;
	
	var P = {
		w:0,		// Width 0 for auto
		h:0,		// Height 0 for auto
		pad:4,		// if autosize in an axis, put this much padding
		
		// Background Bitmap Colors
		col0:[
			0xFF111111,	// Border
			0xFF3A3D49,	// Dark
			0xFFB4B6C0, // Main
			0xFFEAEBEE  // Highlight
		],
		
		// If set, will colorize the TEXT/BITMAP with these colors
		// put (0) to get the color from the previous state 
		col1:[
			0xFF222222,	// NORMAL
			0xFF475850, // HOVER
			0			// Same as HOVER
		],
		
		txt:null,		// Text Style in case of Text
		
		bmc:true		// BitmapColorize. If true will colorize the bitmap
						// IT MUST BE WHITE 0xFFFFFFFF, else will leave it alone
	};

	
	// 0:Normal, 1:Hover, 2:Pressed
	public var STATE(default, null):Int = -1;
	public var onPress:UIButton->Void;
	public var onRelease:UIButton->Void;
	public var onHover:UIButton->Void;
	public var onOut:UIButton->Void;
	
	// -- The BG and FG elements
	var spr_bg:FlxSprite;
	var spr_fg:FlxSprite;
	
	// Stores the final slice9-scaled BG bitmaps
	var BITS:Array<BitmapData> = [];
	
	// 1:Text 2:Bitmap
	var _type:Int = 0;
	
	// Hover text
	var _htxt:String;
	
	/**
	 * Can be either text/bitmapdata
	 */
	public function new(?text:String, ?bitm:BitmapData, ?PAR:Dynamic)
	{
		super();
		moves = false;
		P = DataT.copyFields(PAR, P);
		
		if (text != null)
		{
			var st = D.text.get(text, 0, 0, P.txt);
			st.fieldWidth = P.w;
			_type = 1;	// Text Object
			spr_fg = cast st;
		
		}else if (bitm != null)
		{
			spr_fg = new FlxSprite(bitm);
			_type = 2;	// Bitmap
		}else
		{
			throw "Text or Bitmap required";
		}
		
		var W:Int = P.w;
		var H:Int = P.h;

		if (W == 0){
			W = cast spr_fg.width + (P.pad * 2);
		}
		if (H == 0){
			H = cast spr_fg.height + (P.pad * 2);
		}
		
		// -- Create the button BG
		var _r = new Rectangle(8, 8, 8, 8);
		for (i in 0...3) {
			BITS.push(D.bmu.scale9(D.ui.atlas.get_bn('btn', i), _r, W, H));
			D.bmu.replaceColors(BITS[i], TEMPLATE_COLOR_MAP, P.col0);
		}
		
		spr_bg = new FlxSprite(0, 0);
		spr_bg.makeGraphic(W, H, 0x00000000, true);
		
		// -- Center FG into BG
		D.align.XAxis(spr_fg, spr_bg);
		D.align.YAxis(spr_fg, spr_bg);
		
		add(spr_bg);
		add(spr_fg);
		
		_setState(STATE_NORMAL);
		
		FlxMouseEventManager.add(spr_bg, _onPress, _onRelease, _onHover, _onOut);
	}//---------------------------------------------------;
	
	
	/** Removes the FlxMouseEventManager Plugin 
	 */
	public static function STOP_PLUGIN()
	{
		FlxG.plugins.removeType(FlxMouseEventManager);
	}//---------------------------------------------------;
	
	
	// --
	static function hover_update()
	{
		hoverText.x = FlxG.mouse.x;
		hoverText.y = FlxG.mouse.y - hoverText.height - 2;
		if (hoverText.x + hoverText.width > FlxG.width)
			hoverText.x = FlxG.width - hoverText.width;
	}//---------------------------------------------------;
	
	/** _htxt must exist and should be checked
	 **/
	static function hover_start(txt:String)
	{
		hoverText.text = txt;
		FlxG.signals.postUpdate.add(hover_update);
		FlxG.state.add(hoverText);
	}//---------------------------------------------------;
	
	
	/** Add / Remove the hover
	 **/
	static function hover_stop()
	{
		if (hoverText != null) {
			FlxG.signals.postUpdate.remove(hover_update);
			FlxG.state.remove(hoverText);
		}
	}//---------------------------------------------------;

	
	override public function destroy():Void 
	{
		if (_htxt != null)  {
			hoverCount--;
			if (hoverCount < 1) hover_stop(); // just in case
		}
		super.destroy();
	}//---------------------------------------------------;

	/**
	   On Hover, show a this text above the cursor
	**/
	public function setHover(txt:String, style:DTextStyle = null)
	{
		if (style == null) style = {
			c:0xFFDEDEDE, bc:0xFF222222, bt:2, bs:2
		};
		
		if (hoverText == null || !hoverText.exists)
		{
			hoverText = D.text.get(txt);
		}
		
		_htxt = txt;
		D.text.applyStyle(hoverText, style);
		hoverCount++;
	}//---------------------------------------------------;
	
	/**
	 * Change the graphics and state
	 * @param	s 0:normal, 1:hover, 2:press
	 */
	function _setState(s:Int)
	{
		if (STATE == s) return;
		STATE = s;
		D.bmu.copyOn(BITS[s], spr_bg.pixels);
		spr_bg.dirty = true;
		
		// If it gets (-1) value, reduce s and try again
		var col = 0;
		do col = P.col1[s--] while (col==0);
		
		if (_type == 2 && !P.bmc) return;
			
		spr_fg.color = col;
		
	}//---------------------------------------------------;
	
	
	function _onPress(D:Dynamic)
	{
		_setState(STATE_PRESS);
		if (onPress != null) onPress(this);
	}//---------------------------------------------------;
	
	function _onRelease(D:Dynamic)
	{
		if (STATE != STATE_PRESS) return; // release from pressed
		_setState(STATE_HOVER);
		if (onRelease != null) onRelease(this);
	}//---------------------------------------------------;

	function _onHover(D:Dynamic)
	{
		_setState(STATE_HOVER);
		if (_htxt != null) hover_start(_htxt);
		if (onHover != null) onHover(this);
	}//---------------------------------------------------;	
	
	function _onOut(D:Dynamic)
	{
		_setState(STATE_NORMAL);
		hover_stop();
		if (onOut != null) onOut(this);
	}//---------------------------------------------------;
	
}// --