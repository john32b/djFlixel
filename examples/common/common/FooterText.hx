package common;

import djFlixel.gui.Align;
import djFlixel.gui.Styles;
import djFlixel.tool.DataTool;
import flixel.FlxG;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import djFlixel.FLS;


/**
 * Simple footer text
 * ...
 */
class FooterText
{
	/**
	 * Automatically add a footer text to the current state
	 * Just create this and it will automatically get added
	 */
	public function new(params:Dynamic)
	{
		var P = DataTool.copyFieldsC(params, {
			color:0xFF606060, 
			x:0,
			y:0,
			align:"no",
			pad:0
		});
		
		var url = "https://www.twitter.com/jondmt";
		var str = 'DjFlixel 0.3, johndimi, 2018';
		var text = new FlxText(P.x,P.y);
			//text.font = "fonts/pixelarial";
			//text.fontSize = 8;
			text.text = str;
			text.color = P.color;
			
			if (P.align != "no")
			{
				var ss:String = P.align;
				var a = ss.split('-');
				Align.screen(text, a[0], a[1], P.pad);
			}
			
		FlxG.state.add(text);
		FlxMouseEventManager.add(text, function(_){FlxG.openURL(url);});
	}//---------------------------------------------------;
	
}