package game1;
import flixel.FlxSprite;

class Enemy extends FlxSprite
{
	public function new(X:Float = 0, Y:Float = 0) 
	{
		super(X, Y);
		loadGraphic('im/g_en.png', true, 16, 16);
		animation.add("main", [0, 1, 2], 10);
		setSize(14, 14); centerOffsets();
		animation.play("main");
		acceleration.y = 700;
	}//---------------------------------------------------;	
}