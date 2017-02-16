package;
import djFlixel.Controls;
import djFlixel.FLS;
import djFlixel.SND;
import flixel.FlxState;
import flixel.text.FlxText;

/**
 * ...
 * @author 
 */
class StateTest extends FlxState
{

	override public function create():Void 
	{
		super.create();
		
		add(new FlxText(10, 10, 0, "mobile"));
	}//---------------------------------------------------;
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (Controls.justPressed(Controls.A))
		{
			SND.play('c_sel');
		}
		
		FLS.debug_keys();
	}//---------------------------------------------------;
	
}