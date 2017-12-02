package;
import djFlixel.gui.Align;
import flixel.FlxG;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import djFlixel.FLS;

/**
 * ...
 * @author John Dimi
 */
class FooterText
{

	// My Twitter Link for now.
	var url = "https://www.twitter.com/jondmt";
	
	/**
	 * Automatically add a footer text to the current state
	 * Just create this and it will automatically get added
	 * 
	 * @param	align left, right, center
	 */
	public function new(ALIGN:String = "left") 
	{
		var str = 'DjFlixel ${FLS.VERSION},  by JohnDimi';
		var text = new FlxText();
			text.text = str;
			text.color = 0xFF555555;
			text.borderColor = 0xFF223322;
			text.y = FlxG.height - text.height;
			Align.screen(text, ALIGN, "none");
		FlxG.state.add(text);
		FlxMouseEventManager.add(text, function(_){FlxG.openURL(url);});
	}//---------------------------------------------------;
	
}