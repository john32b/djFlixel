package;
import djFlixel.Controls;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;


class Player extends FlxSprite
{
	// -- Dynamic vars, are going to be loaded from assets/data/params.json file
	var movespeed:Float;
	var jumpspeed:Float;
	var jumpease:Float;
	var bounceSpeed:Float;
	
	// --
	public var isJumping(default, null):Bool; // Is going up
	public var isFalling(default, null):Bool; // Is going down
	
	// --
	public function new(X:Float = 0, Y:Float = 0) 	
	{
		super(X, Y);
		acceleration.y = Reg.JSON.gravity;
		isJumping = false;
		isFalling = false;
		loadGraphic("assets/player.png", true, 16, 16);
		animation.add("main", [0, 1, 2], 10);
		animation.play("main");
		setSize(14, 14); centerOffsets();
		// "params.json" file, copy player node to this object
		Reg.applyParamsInto("player", this); 
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{				
		if (!isFalling && velocity.y > 0) { isFalling = true; }
		if (isFalling && isTouching(FlxObject.FLOOR)) { isFalling = false; isJumping = false; }
		
		velocity.x = 0;
		
		if (Controls.pressed(Controls.LEFT)) {
			velocity.x = -movespeed;
			facing = FlxObject.LEFT;
			flipX = true;
		}
		else if (Controls.pressed(Controls.RIGHT)) {
			velocity.x = movespeed;
			facing = FlxObject.RIGHT;
			flipX = false;
		}
		
		if (Controls.justPressed(Controls.A) && !isFalling && !isJumping) {
			isJumping = true;
			velocity.y = -jumpspeed;
		}
		// This next check will enable the player to variable height jump
		else if (Controls.justReleased(Controls.A) && !isFalling && isJumping) {
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
		if (Controls.pressed(Controls.A)) {
			velocity.y = -jumpspeed * 0.8;
		}else {
			velocity.y = -bounceSpeed;
		}
		
	}//---------------------------------------------------;
	
	override public function hurt(Damage:Float):Void 
	{
		if (FlxFlicker.isFlickering(this)) return;
		FlxFlicker.flicker(this);
	}//---------------------------------------------------;
	
}