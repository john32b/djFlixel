package common;

import djFlixel.FLS;
import djFlixel.gfx.Palette_DB32;
import djFlixel.gui.Align;
import djFlixel.gui.BlinkSprite;
import djFlixel.gui.Gui;
import djFlixel.gui.PanelPop;
import djFlixel.gui.Styles;
import djFlixel.tool.DataTool;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;


/**
 * A box that sits on the bottom of the screen containing formatted text.
 */
class InfoBox extends FlxSpriteGroup
{

	// Running Parameters
	var P:{
		font:String,
		colorBG:Int,
		colorText:Int,
		colorT1:Int,
		colorT2:Int,
		width:Int,
		height:Int,
		padIn:Int,
		padOut:Int,
		position:Array<Float>
	}; 	
	
	var p:PanelPop;	// Background
	var t:FlxText;	// Text
	var textFormats:Array<FlxTextFormatMarkerPair> = [];
	//--
	var boxWidth:Int;
	var boxHeight:Int;
		
	
	var m:BlinkSprite;
	
	/**
	 * Create and add to the state a text string at the bottom of the screen
	 * @param	TEXT The text to be displayed, supports formatting tags "$","#"
	 * @param	bgCol Background color
	 * @param	textCol Text color
	 * @param	FORCEHEIGHT If true will not autocalculate height
	 */	
	//public function new(TEXT:String = "", bgCol:Int =-1, textCol:Int =-1, FORCEHEIGHT:Int = 0)
	public function new(TEXT:String = "", ?PARAMS:Dynamic)
	{
		super();
		
		P = cast DataTool.copyFieldsC(PARAMS, {
			font:null,
			colorBG:Palette_DB32.COL[1],
			colorText:Palette_DB32.COL[22],	
			colorT1:Palette_DB32.COL[8],	// Text Tag '#'
			colorT2:Palette_DB32.COL[18],	// Text Tag '$'
			width:260,						// 0 to autocalculate
			height:0,						// 0 to autocalculate
			padIn:4,
			padOut:3,
			position:null					// If set will place the box here [x,y]
		});
		
		// --
		textFormats = [ 
			Gui.getFormatRule("#",P.colorT1),
			Gui.getFormatRule("$",P.colorT2),
		];

		// --
		boxWidth = P.width;
		if (boxWidth < 1){
			boxWidth = Std.int(FlxG.width - P.padOut * 2);
		}

		// -- Setup the Text
		t = new FlxText(P.padIn, P.padIn, boxWidth - P.padIn * 2);
		Styles.applyTextStyle(t, {
			font:P.font,
			color:P.colorText
		});
		t.applyMarkup(TEXT, textFormats);
		t.visible = false;
		
		// --
		boxHeight = P.height;
		if (boxHeight < 1) {
			boxHeight = Std.int(t.height + P.padIn * 2);
		}
		
		// -- BG Panel
		p = new PanelPop(boxWidth, boxHeight, P.colorBG);
		Align.YAxis(t, p);
		add(p);
		add(t);
		
		
		// --
		if (P.position == null){
			Align.screen(this, "center", "bottom", P.padOut);
		}else{
			this.setPosition(P.position[0], P.position[1]);
		}
		
		// -- Should I not?
		FlxG.state.add(this);
	}//---------------------------------------------------;
	
	
	//-- Force set the text
	public function setText(TEXT:String)
	{
		t.applyMarkup(TEXT, textFormats);
		
		if (t.height > boxHeight)
		{
			trace("Warning: New text longer than bg");
		}
		
		Align.YAxis(t, p);
	}//---------------------------------------------------;
	
	
	/**
	 * 
	 * @param	T text to show, optional
	 * @param	M Show MORE arrow, optional
	 */
	public function open(?T:String, M:Bool = false )
	{
		visible = true;
		t.visible = false;
		p.visible = true;
		p.clear();	// Just in case
		p.open(function(){
			if (T != null) setText(T);
			t.visible = true;
			if (M) more();
		});
	}//---------------------------------------------------;
	
	// --
	// Shows the `more` sprite until new text has been set
	// You need to call this manually
	public function more()
	{
		if (m == null)
		{
			// -- Blink sprite, create it.
			m = new BlinkSprite();
			m.loadGraphic(Gui.getIcon("ar_right", 8, null, 0xFF888888));
			add(m);
			m.setPosition(this.x + p.width + 2, this.y + p.height - m.height);
		}
		
		m.set(true);
	}//---------------------------------------------------;
	
}// --