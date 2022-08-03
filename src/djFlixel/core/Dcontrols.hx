/**
 *  DJFlixel - Easy, streamlined input checks
 *  =========================================
 * - Accessible from (D.ctrl)
 * - Unified keyboard and controller inputs
 * - Cursor-like behavior support
 * - Read inputs based on the 360 controller layout
 * - Maps keyboard to 360 controller
 * - Check `MAP_KEYS` for keyboard keys, it can be reconfigured
 * 
 ************************************************************/

package djFlixel.core;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.lists.FlxGamepadButtonList;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;

// ----------------------------------------------------------
// DO NOT CHANGE THE ORDERING OF THIS !
// Basically the key id is going to be used as an array lookup in Dcontrols
enum abstract DButton(Int)
{
	var UP;
	var RIGHT;
	var DOWN;
	var LEFT;
	var A;
	var B;
	var X;
	var Y;
	var SELECT;
	var START;
	var LB;
	var RB;
	
	// : multi:
	var _START_A;		// START, A
	var _ANY;			// A,B,X,Y,START
	var _NONE;			// Used internally
}// ----------------------------------------------------------



class Dcontrols
{
	static inline var GAMEPAD_POLL_TIME = 0.5;
	static inline var ANALOG_DEADZONE = 0.5;
	
	/** Max Acceleration . This is used in timepress() */
	public var MAX_ACCEL:Float = 4;
	
	var t_gpol:Float = 0;		// Gamepad Poll time
	var t_key:DButton = _NONE;
	var t_t1:Float = 0;
	var t_t2:Float = 0;
	var t_ac:Float = 1;
	
	// User call functions
	// Those are dynamically created on init
	public var pressed(default, null):DButton->Bool;
	public var justPressed(default, null):DButton->Bool;
	public var justReleased(default, null):DButton->Bool;
	
	/** You can check for null */
	public var gamepad(default, null):FlxGamepad;
	
	// Pointers to gamepad vars, for shorter typing
	var gp:FlxGamepadButtonList;
	var gjp:FlxGamepadButtonList;
	var gjr:FlxGamepadButtonList;
	
	// This is the actual array the object reads
	var MAP_KEYS:Array<Array<FlxKey>>;
	
	/// TODO ?
	/// Make arrows + sdfg the default keys ? which are the same in (FR,GR,UK,US) 
	/// ESDF is also the same IJKL are the same., CVBF
	
	// -- Default keys for new programs., Copied over to `MAP_KEYS`
	// DO NOT CHANGE THE ORDERING OF THIS !
	// Uses same ordering as Enum DButton
	var MAP_KEYS_DEFAULT = [
		[FlxKey.W, FlxKey.UP],		// UP
		[FlxKey.D, FlxKey.RIGHT],	// RIGHT
		[FlxKey.S, FlxKey.DOWN],	// DOWN
		[FlxKey.A, FlxKey.LEFT],	// LEFT
		[FlxKey.K, FlxKey.V],	// xbox (A)
		[FlxKey.L, FlxKey.B],	// xbox (B)
		[FlxKey.J, FlxKey.C],	// xbox (X)
		[FlxKey.I, FlxKey.F],	// xbox (Y)
		[FlxKey.SPACE],			// xbox (SELECT)
		[FlxKey.ENTER],			// xbox (START)
		[FlxKey.SHIFT],			// xbox (LB)
		[FlxKey.CONTROL],		// xbox (RB)
		
		[],	// START + A	-- Automatically generated -- On user  edit call generateSpecialKeys()
		[], // ANY			-- Automatically generated -- On user  edit call generateSpecialKeys()
		[]	// NONE
	];	

	
	
	/**
	   This needs to be created AFTER flxGame has been added
	**/
	public function new()
	{
		keymap_default();
		gamepad_check();
		map_controls();
	}//---------------------------------------------------;
	
	
	public function keymap_default()
	{
		MAP_KEYS = MAP_KEYS_DEFAULT.copy();
		generateSpecialKeys();
	}//---------------------------------------------------;
	
	/** Replace all keys with these new ones */
	public function keymap_set(KEYS:Array<Int>)
	{
		for (i in 0...MAP_KEYS.length)
		{
			if (i >= KEYS.length || KEYS[i] ==-1) MAP_KEYS[i] = []; 
			else
			MAP_KEYS[i] = [KEYS[i]];
		}
		generateSpecialKeys();
	}//---------------------------------------------------;
	
	/**
	   Flush all the button presses
	   Useful sometimes in menus when you switch from 
	   one Cursor navigation system to another Cursor system.
	**/
	public function flush()
	{
		#if (FLX_KEYBOARD)
		FlxG.keys.reset();
		#end
		
		if (gamepad != null) {
			gamepad.reset();
		}
	}//---------------------------------------------------;	
	
	/**
	 * Get a timed button press, (like a cursor on a text editor)
	 * Holding a button example:
	 * X are triggers
	 * time-->  x------------x--x--x--x--x--x--x--x
	 * @param	btn 
	 * @param	Time1 First Delay
	 * @param	Time2 Time interval to fire after the first delay
	 * @param	Accel Accelerate when reached Time2
	 * @return
	 */
	public function timePress(btn:DButton, Time1:Float = 0.7, Time2:Float = 0.12, Accel:Float = 0):Bool
	{
		if (justPressed(btn))
		{
			t_key = btn;
			t_t1 = 0;
			t_t2 = 0;
			t_ac = 1;
			return true;
		}
		else
		if (pressed(btn))
		{
			if (t_key != btn)	// TRIGGER at first press
			{
				return false;
			}
			
			if (t_t1 < Time1)
			{
				t_t1 += FlxG.elapsed;
				if (t_t1 >= Time1){	// TRIGGER after the first delay
					return true;
				}
				return false;
			}
			
			if (t_t2 < Time2)
			{
				t_t2 += FlxG.elapsed * t_ac;
				t_ac += Accel;
				if (t_ac > MAX_ACCEL) t_ac = MAX_ACCEL;
				if (t_t2 >= Time2){ // TRIGGER
					t_t2 = 0;
					return true;
				}
				return false;
			}
			
		}
		else if (justReleased(btn)) {
			if (t_key == btn) t_key = DButton._NONE;
		}
		
		return false;
	}//---------------------------------------------------;
	
	
	/**
	   Call on update()
	   Returns TRUE once if a gamepad is found
	**/
	public function gamepad_poll():Bool
	{
		if (gamepad != null) return false;
		
		// gamepad_poll at an interval, no reason to do it in every single frame
		t_gpol += FlxG.elapsed;
		if (t_gpol > GAMEPAD_POLL_TIME)
		{
			t_gpol = 0;
			if (gamepad_check()) {
				map_controls(); 
				return true;
			}
		}
		
		return false;
	}//---------------------------------------------------;
	
	
	// --
	// Check for a gamepad and initialize it
	// Returns if it found anything
	function gamepad_check():Bool
	{		
		#if FLX_GAMEPAD
		gamepad = FlxG.gamepads.lastActive;
		if (gamepad != null) {
			gp = gamepad.pressed;
			gjp = gamepad.justPressed;
			gjr = gamepad.justReleased;
			return true;
		}
		#end
		return false;
	}//---------------------------------------------------;
	
	// --
	// If a controller hasn't been found on start
	// You can always do it later
	function map_controls()
	{
		if (gamepad == null) 
		{
			trace("Info: Controller not found");
			pressed = _keyPressed;
			justPressed = _keyJustPressed;
			justReleased = _keyJustReleased;
		}
		else 
		{
			#if FLX_GAMEINPUT_API
			trace('Info: Controller found, MODEL=${gamepad.model}, NAME=${gamepad.name}');
			#end
			
			gamepad.deadZone = ANALOG_DEADZONE;
			pressed = function(b:DButton){
				return _keyPressed(b) || _padPressed(b);
			};
			
			justPressed = function(b:DButton) {
				return _keyJustPressed(b) || _padJustPressed(b);
			};
			
			justReleased = function(b:DButton) {
				return _padJustReleased(b) || _keyJustReleased(b);
			};
		}
	}//---------------------------------------------------;
	
	// --
	function _padPressed(id:DButton):Bool
	{
		return switch(id) {
			case UP: 
				gp.DPAD_UP ||
				gamepad.analog.value.LEFT_STICK_Y < 0;
			case DOWN:
				gp.DPAD_DOWN ||
				gamepad.analog.value.LEFT_STICK_Y > 0;
			case LEFT:
				gp.DPAD_LEFT ||
				gamepad.analog.value.LEFT_STICK_X < 0;
			case RIGHT:
				gp.DPAD_RIGHT ||
				gamepad.analog.value.LEFT_STICK_X > 0;
			case A: gp.A;
			case X: gp.X;
			case Y: gp.Y;
			case B: gp.B;
			case START:  gp.START;
			case SELECT: gp.BACK;
			case LB: gp.LEFT_SHOULDER;
			case RB: gp.RIGHT_SHOULDER;
			case _START_A: gp.START || gp.A;
			case _ANY: gp.START || gp.A || gp.B || gp.X || gp.Y;
			case _: false;
		}
	}//---------------------------------------------------;	
	// --
	// WARN: On analog input, returns the state!
	function _padJustPressed(id:DButton):Bool
	{
		return switch(id) {
			case UP: 
				gjp.DPAD_UP ||
				(	gamepad.analog.justMoved.LEFT_STICK_Y && 
					gamepad.analog.value.LEFT_STICK_Y < 0 );
			case DOWN:
				gjp.DPAD_DOWN ||
				(	gamepad.analog.justMoved.LEFT_STICK_Y &&
					gamepad.analog.value.LEFT_STICK_Y > 0 );
			case LEFT:
				gjp.DPAD_LEFT ||
				(	gamepad.analog.justMoved.LEFT_STICK_X &&
					gamepad.analog.value.LEFT_STICK_X < 0 );				
			case RIGHT:
				gjp.DPAD_RIGHT ||
				(	gamepad.analog.justMoved.LEFT_STICK_X &&
					gamepad.analog.value.LEFT_STICK_X > 0 );				
			case A: gjp.A;
			case X: gjp.X;
			case Y: gjp.Y;
			case B: gjp.B;
			case START:  gjp.START;
			case SELECT: gjp.BACK;
			case LB: gjp.LEFT_SHOULDER;
			case RB: gjp.RIGHT_SHOULDER;
			case _START_A: gjp.START || gjp.A;
			case _ANY: gjp.START || gjp.A || gjp.B || gjp.X || gjp.Y;
			case _: false;
		}
	}//---------------------------------------------------;
	function _padJustReleased(id:DButton):Bool
	{
		return switch(id) {
			case UP: 
				gjr.DPAD_UP ||
				gamepad.analog.justReleased.LEFT_STICK_Y;
			case DOWN:
				gjr.DPAD_DOWN ||
				gamepad.analog.justReleased.LEFT_STICK_Y;
			case LEFT:
				gjr.DPAD_LEFT ||
				gamepad.analog.justReleased.LEFT_STICK_X;
			case RIGHT:
				gjr.DPAD_RIGHT ||
				gamepad.analog.justReleased.LEFT_STICK_X;
			case A: gjr.A;
			case X: gjr.X;
			case Y: gjr.Y;
			case B: gjr.B;
			case START:  gjr.START;
			case SELECT: gjr.BACK;
			case LB: gjr.LEFT_SHOULDER;
			case RB: gjr.RIGHT_SHOULDER;
			case _START_A: gjr.START || gjr.A;
			case _ANY: gjr.START || gjr.A || gjr.B || gjr.X || gjr.Y;
			case _: false;
		}
	}//---------------------------------------------------;	
	
	// --
	function _keyPressed(id:DButton):Bool
	{
		#if (FLX_KEYBOARD)
		return FlxG.keys.anyPressed(MAP_KEYS[cast id]);
		#else return false; #end
	}//---------------------------------------------------;	
	// --
	function _keyJustPressed(id:DButton):Bool
	{
		#if (FLX_KEYBOARD)
		return FlxG.keys.anyJustPressed(MAP_KEYS[cast id]);
		#else return false; #end
	}//---------------------------------------------------;
	// --
	function _keyJustReleased(id:DButton):Bool
	{
		#if (FLX_KEYBOARD)
		return FlxG.keys.anyJustReleased(MAP_KEYS[cast id]);
		#else return false; #end
	}//---------------------------------------------------;
	
	
	/**
	 From  the current KEYMAP get the first key of the Dbutton assigmnent
	 */
	public function getKeymapName(id:DButton):String
	{
		return MAP_KEYS[cast id][0].toString();
	}//---------------------------------------------------;
	
	/** Call this after you alter MAP_KEYS
	 - Will construct the special DButtons (ANY, START_A)
	*/
	public function generateSpecialKeys()
	{
		MAP_KEYS[cast DButton._START_A] = MAP_KEYS[cast START].concat(MAP_KEYS[cast A]);
		
		MAP_KEYS[cast DButton._ANY] = 
			MAP_KEYS[cast START].concat(
			MAP_KEYS[cast SELECT].concat(
			MAP_KEYS[cast A].concat(
			MAP_KEYS[cast B].concat(
			MAP_KEYS[cast X].concat(
			MAP_KEYS[cast Y])))));
			
	}//---------------------------------------------------;

}// -- end --//