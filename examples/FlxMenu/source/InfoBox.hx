package;

import djFlixel.gui.PanelPop;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;

/**
 * Simple quick panel with text
 * ...
 * @author John Dimi
 */
class InfoBox extends FlxSpriteGroup 
{
	var panel:PanelPop;
	var text:FlxText;
	var isOpen:Bool;
	
	public function new(WIDTH:Int, HEIGHT:Int, COL:Int = 0xFF222222, TCOL:Int = 0xFFAAAAAA) 
	{
		super();
		
		var PAD = 4; // padding on all edges
		panel = new PanelPop(WIDTH, HEIGHT, COL);
		add(panel);
		
		text = new FlxText(PAD, 0, WIDTH - PAD * 2);
		text.color = TCOL;
		add(text);
	
		close();
	}//---------------------------------------------------;
	
	public function close()
	{
		isOpen = false;
		panel.visible = false;
		text.visible = false;
	}//---------------------------------------------------;
	
	public function open(s:String)
	{
		if (isOpen){
			text.text = s;
			return;
		}
		
		panel.visible = true; text.visible = true;
		panel.open(function(){
			text.text = s;
			isOpen = true;
		});
	}//---------------------------------------------------;
	
}