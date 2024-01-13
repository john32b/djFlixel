package game1;
import flixel.util.FlxDirectionFlags;
import djFlixel.D;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;

class Player extends FlxSprite
{
	var movespeed = 80.0;
	var jumpspeed = 250.0;
	var jumpease  = 30.0;
	var bounceSpeed = 100.0;
	
	public var isJumping(default, null):Bool; // Is going up
	public var isFalling(default, null):Bool; // Is going down
	
	public function new(X:Float = 0, Y:Float = 0) 	
	{
		super(X, Y);
		acceleration.y = 700;
		isJumping = false;
		isFalling = false;
		loadGraphic("im/g_pl.png", true, 16, 16);
		animation.add("main", [0, 1, 2], 10);
		animation.play("main");
		setSize(14, 14); centerOffsets();
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{				
		if (!isFalling && velocity.y > 0) { isFalling = true; }
		if (isFalling && isTouching(FlxDirectionFlags.FLOOR)) { isFalling = false; isJumping = false; }
		
		velocity.x = 0;
		
		if(D.ctrl.pressed(LEFT)) {
			velocity.x = -movespeed;
			facing = FlxDirectionFlags.LEFT;
			flipX = true;
		}
		else if (D.ctrl.pressed(RIGHT)) {
			velocity.x = movespeed;
			facing = FlxDirectionFlags.RIGHT;
			flipX = false;
		}
		
		if(D.ctrl.justPressed(A) && !isFalling && !isJumping) {
			isJumping = true;
			velocity.y = -jumpspeed;
		}
		// This next check will enable the player to variable height jump
		else if (D.ctrl.justReleased(A) && !isFalling && isJumping) {
			isJumping = false;
			velocity.y = -jumpease; // ease out a bit
		}
		
		super.update(elapsed);
		
	}//---------------------------------------------------;
	
	// -- Called from collision check, when player collides with enemy from the top
	public function jumpOffEnemy()
	{
		isJumping = true;
		isFalling = false;

		// If jump button is being pressed while stomping on enemy, jump heigher
		if (D.ctrl.pressed(A)){
			velocity.y = -jumpspeed * 0.8;
		}else {
			velocity.y = -bounceSpeed;
		}
		
	}//---------------------------------------------------;
	
	override public function hurt(Damage:Float):Void 
	{
		if (FlxFlicker.isFlickering(this)) return;
		
		FlxFlicker.flicker(this, 0.4, 0.08);
		setColorTransform(1, 1, 1, 1, 255, 255, 255, 0);
		var t = new FlxTimer().start(0.20, (_)->{
			setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
		});
	}//---------------------------------------------------;
	
}


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