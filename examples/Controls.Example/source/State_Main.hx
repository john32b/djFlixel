package ;

import djFlixel.Controls;
import djFlixel.gui.PageData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * In this example
 * ----------------
 * + How to use controls
 * + How to read variables from the external JSON parameters File
 * 
 * Check the file "assets/data/params.json" for the running parameters
 */
class State_Main extends FlxState
{
	// Create a simple box
	var box:FlxSprite;
	
	// --
	// These variables are going to be read from the JSON file once the game starts
	// This is to avoid having to re-compile everytime I change something.
	// --
	var ACCELSPEED:Float;
	var MAXACEL:Float;
	var STARTPOS_Y:Float;
	var STARTPOS_X:Float;
	var MAXVELOCITY:Float;
	var DRAGX:Float; // Deceleration ratio
	var DRAGY:Float; // Deceleration ratio
	
	// --
	override public function create():Void
	{
		super.create();
		
		// This will copy ALL the fields from the "boxData" node
		// into this object.
		// VARIABLE NAMES MUST BE THE SAME!!
		
		// The file is located at "assets/data/params.json"
		// Be sure the flag "EXTERNAL_LOAD" is set on the Project.xml
		// If it's not, then the data is going to be embedded into the bin.
		Reg.applyParamsInto("boxData", this);
		trace("TYPEOF STARTPOSX") ;
		trace(Type.typeof(STARTPOS_X));
		trace(STARTPOS_X);
		
		//-- Add a simple box
		box = new FlxSprite(STARTPOS_X, STARTPOS_Y);
		//box.makeGraphic(16, 16, FlxColor.RED);
		box.loadGraphic("assets/ball.png");
		box.maxVelocity.set(MAXVELOCITY, MAXVELOCITY);
		box.drag.set(DRAGX, DRAGY);
		add(box);
		
		// -- Add some info
		for (c in 0...Reg.JSON.titleText.length) {
			var txt = new FlxText((c), (c * 10), 0, Reg.JSON.titleText[c]);
			add(txt);
		}
	
	}//---------------------------------------------------;
	
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// I need to check if any direction key was pressed
		var any_pressed = false;
		
		// Controls.hx
		// This will check Analog, DPAD, Arrow keys and WASD
		if (Controls.pressed(Controls.UP)) {
			box.acceleration.y -= ACCELSPEED;
			if (box.acceleration.y < -MAXACEL) {
				box.acceleration.y = -MAXACEL;
			}
		}else
		if (Controls.pressed(Controls.DOWN)) {
			box.acceleration.y += ACCELSPEED;
			if (box.acceleration.y > MAXACEL) {
				box.acceleration.y = MAXACEL;
			}
		}else
		{
			box.acceleration.y = 0;
		}
		
		if (Controls.pressed(Controls.LEFT)) {
			box.acceleration.x -= ACCELSPEED;
			if (box.acceleration.x < -MAXACEL) {
				box.acceleration.x = -MAXACEL;
			}
		}else
		if (Controls.pressed(Controls.RIGHT)) {
			box.acceleration.x += ACCELSPEED;
			if (box.acceleration.x > MAXACEL) {
				box.acceleration.x = MAXACEL;
			}			
		}else
		{
			box.acceleration.x = 0;
		}

		// Bounce the object on the edges
		if (box.x < 0 || box.x + box.width > FlxG.width) {
			box.velocity.x = -box.velocity.x;
			box.x = box.last.x;
		}
		
		if (box.y < 0 || box.y + box.height > FlxG.height) {
			box.velocity.y = -box.velocity.y;
			box.y = box.last.y;
		}
		
		#if debug
		// On keypress "f12" reload JSON parameters and reset game
		// So I can quickly make changes to the json file and see them in action
		Reg.debug_keys();
		#end
	
	}//---------------------------------------------------;
	
	
}// --