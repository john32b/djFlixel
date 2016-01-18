package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;



class State_Main extends FlxState
{
	// --
	override public function create():Void
	{
		super.create();
		
		add(new FlxText(10, 10, 0, "DjFlixel Tools"));
		
	}//---------------------------------------------------;
	
	// --
	override public function destroy():Void
	{
		super.destroy();
	}//---------------------------------------------------;

	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	}//---------------------------------------------------;
	
}// --