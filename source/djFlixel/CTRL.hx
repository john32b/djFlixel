package djFlixel;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;

/**
 *  Simple Controls class, for easy input checks.
 * 
 * - Static class for portability and easier access
 * - Unified keyboard and controller inputs
 * - Cursor-like behavior support
 * - Read inputs based on the 360 controller layout
 * - Maps keyboard to 360 controller
 * 	 {
 * 	 	WASD, ARROW,
 * 		Select:SPACE, Start:ENTER
 * 		A: X,K
 * 		B: L
 * 		X: Z,J
 * 		Y: I
 * 		LR: SHIFT
 * 		LT: CONTROLS
 * 	 }
 * 
 * ...
 * @author John Dimi, @jondmt
 * 
 */
class CTRL
{

	// -- CURSOR INPUT
	// Inlines for first and second delay on Cursor inputs
	static inline var INPUT_TIME_1:Float = 0.7;		// First stop delay after the first press
	static inline var INPUT_TIME_2:Float = 0.15;	// Then Repeat every ..
	// --
	static inline var DEADZONE:Float = 0.5;	
	
	// -- Quick reference to buttons.
	// - I am using the xbox360 gamepad layout as a map
	// - Directions are digital & analog
	public static inline var UP:Int = 1;	
	public static inline var DOWN:Int = 2;
	public static inline var LEFT:Int = 3;
	public static inline var RIGHT:Int = 4;
	public static inline var A:Int = 5;
	public static inline var B:Int = 6;
	public static inline var X:Int = 7;
	public static inline var Y:Int = 8;
	public static inline var START:Int = 9;
	public static inline var SELECT:Int = 10;
	public static inline var LB:Int = 11;
	public static inline var RB:Int = 12;
	
	// -- Some key mappings
	
	static var mapping_up =  [FlxKey.W, FlxKey.UP];
	static var mapping_down = [FlxKey.S, FlxKey.DOWN];
	static var mapping_left = [FlxKey.A, FlxKey.LEFT];
	static var mapping_right = [FlxKey.D, FlxKey.RIGHT];
	
	// 2 Buttons for the A button.
	static var mapping_A  = [FlxKey.K, FlxKey.X];
	static var mapping_X  = [FlxKey.J, FlxKey.Z];
	
	
	// no need to keep initializing this class
	static var isInited:Bool = false;
	// pointer to the first connected gamepad
	public static var gamepad(default, null):FlxGamepad = null;
	// Pointer to the keyboard for quick access
	static var keys(default, null):FlxKeyboard;
	
	static var inputDelay:Float = INPUT_TIME_1;
	static var lastInputTime:Float = 0;
	static var cursor_last_dir:Int = 0;	
	
	// User call functions,
	// Those are dynamically created on init
	public static var pressed(default, null):Int->Bool;
	public static var justPressed(default, null):Int->Bool;
	public static var justReleased(default, null):Int->Bool;
	
	
	// -- Gamepad polling vars
	// You can call the poll() function and it will check for 
	// gamepads in an interval
	inline static var GAMEPAD_POLL_TIME:Float = 0.5;
	static var gamepad_lastPoll:Float = 0;

	//====================================================;
	// FUNCTIONS 
	//====================================================;
	// --
	public static function init()
	{
		if (isInited) return;
			isInited = true;
			
		trace("Info: Initializing Controls.");

		// Init some vars
		cursor_last_dir = 0;
	
		// Create a pointer
		keys = FlxG.keys;
		
		// If a gamepad is found, it maps controls automatically
		if (!findGamepad())
		{
			// Map controls to just keyboard
			mapControls();
		}
		
	}//---------------------------------------------------;
	
	// --
	// Call on update()
	// Triggers once if a gamepad is found.
	public static function poll():Bool
	{
		if (gamepad != null) return false;
		
		// Poll at an interval, no reason to do it in every single frame
		gamepad_lastPoll += FlxG.elapsed;
		if (gamepad_lastPoll > GAMEPAD_POLL_TIME)
		{
			gamepad_lastPoll = 0;
			return findGamepad();
		}
		
		return false;
	}//---------------------------------------------------;
	
	
	// --
	// Quick way for user to know if gamepad is connected
	// Preferably called once on init
	// Else you can keep calling findGamepad to check for gamepad
	public static inline function gamepadConnected():Bool
	{
		return (gamepad != null);
	}//---------------------------------------------------;
	
	
	// --
	// Check for a gamepad and initializes it.
	// Returns if it found anything.
	static function findGamepad():Bool
	{		
		#if FLX_GAMEPAD
		gamepad = FlxG.gamepads.lastActive;
		
		if (gamepad != null)
		{
			mapControls();
			return true;
		}
		#end
		return false;
	}//---------------------------------------------------;
	
	// --
	// If a controller hasn't been found on start
	// You can always do it later
	static function mapControls()
	{
		if (gamepad == null) 
		{
			trace("Info: Controller not found");
			
			pressed = function(id:Int) {
				return _PressedKey(id);
			};
			
			justPressed = function(id:Int) {
				return _justPressedKey(id);
			};
			
			justReleased = function(id:Int) {
				return _justReleasedKey(id);
			};

		}
		else 
		{
			#if FLX_GAMEINPUT_API
			trace('Info: Controller found, MODEL=${gamepad.model}, NAME=${gamepad.name}');
			#end
			
			gamepad.deadZone = DEADZONE;
			
			pressed = function(id:Int) {
				return _PressedKey(id) || _PressedPad(id);
			};
			
			justPressed = function(id:Int) {
				return _justPressedKey(id) || _justPressedPad(id);
			};
			
			justReleased = function(id:Int) {
				return _justReleasedPad(id) || _justReleasedKey(id);
			};
		
		}
	}//---------------------------------------------------;
	
	
	// -- Easy Cursor like movement
	// -- 
	public static inline function CURSOR_OK():Bool
	{	
		return justPressed(A);
	}//---------------------------------------------------;
	// --
	public static inline function CURSOR_CANCEL():Bool
	{
		return justPressed(X);
	}//---------------------------------------------------;
	// --
	public static inline function CURSOR_START():Bool
	{
		return justPressed(A) || justPressed(START);
	}//---------------------------------------------------;
	

	// -- NOTE: Call once per update cycle
	// 			get with a switch(CURSOR_DIR()).
	// Return the current cursor direction.
	// but only once, works for analog sticks
	@:deprecated("Use timePress()")
	public static function CURSOR_DIR():Int
	{
		if (pressed(UP))
		{
			return __processCursorDir(UP);
		}else
		if (pressed(DOWN))
		{
			return __processCursorDir(DOWN);
		}else
		if (pressed(LEFT))
		{
			return __processCursorDir(LEFT);
		}else
		if (pressed(RIGHT))
		{
			return __processCursorDir(RIGHT);
		}else
		{
			cursor_last_dir = 0;
			lastInputTime = 0;
			inputDelay = INPUT_TIME_1;
			return 0;
		}
	}//---------------------------------------------------;

	//--
	// Call right after opening a menu that calls CURSOR_DIR
	// Clears the cursor direction.
	@:deprecated("Use timePress()")
	static public function CURSOR_RESET()
	{	
		inputDelay = INPUT_TIME_1;
		cursor_last_dir = 0;
		lastInputTime = 0;
		
		// Set the last_dir to the currently pressing direction, if any
		if (pressed(UP)) {
			cursor_last_dir = UP;
		}else
		if (pressed(DOWN)) {
			cursor_last_dir = DOWN;
		}else
		if (pressed(LEFT)) {
			cursor_last_dir = LEFT;
		}else
		if (pressed(RIGHT)) {
			cursor_last_dir = RIGHT;
		}
	}//---------------------------------------------------;

	
	
	static var t_key:Int = 0;
	static var t_t1:Float = 0;
	static var t_t2:Float = 0;
	static var t_ac:Float = 1;
	public static var MAX_ACCEL:Float = 4;
	
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
	static public function timePress(btn:Int, Time1:Float = 0.7, Time2:Float = 0.12, Accel:Float = 0):Bool
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
			if (t_key == btn) t_key = 0;
		}
		
		return false;
	}//---------------------------------------------------;
	
	
	
	// Flush all the button presses
	// Useful sometimes in menus when you switch from 
	// one Cursor navigation system to another Cursor system.
	static public function RESET()
	{
		FlxG.keys.reset();
		
		if (gamepad != null) {
			gamepad.reset();
		}
	}//---------------------------------------------------;
	
	
	//====================================================;
	// PRIVATE FUNCTIONS 
	//====================================================;
	// I am inlining these to save 1 function call, because
	// Those functions are going to called constantly upon update()
	//---------------------------------------------------;
	
	
	// -- HELPER
	// Called from CURSOR_DIR()
	// Returns a cursor direction button ID
	static function __processCursorDir(dir:Int):Int
	{
		if (cursor_last_dir == dir) 
		{
			if (lastInputTime >= inputDelay)  {
				lastInputTime = 0; 
				inputDelay = INPUT_TIME_2;
			}
			else 
			{
				lastInputTime += FlxG.elapsed;
				return 0;	// No Direction
			}
		}
		else
		{
			inputDelay = INPUT_TIME_1;
		}
		
		cursor_last_dir = dir;
		return dir;
	}//---------------------------------------------------;
	// --
	inline static function _PressedPad(id:Int):Bool
	{
		return switch(id) {
			case UP: 
				gamepad.pressed.DPAD_UP ||
				gamepad.analog.value.LEFT_STICK_Y < 0;
			case DOWN:
				gamepad.pressed.DPAD_DOWN ||
				gamepad.analog.value.LEFT_STICK_Y > 0;
			case LEFT:
				gamepad.pressed.DPAD_LEFT ||
				gamepad.analog.value.LEFT_STICK_X < 0;
			case RIGHT:
				gamepad.pressed.DPAD_RIGHT ||
				gamepad.analog.value.LEFT_STICK_X > 0;
			case A:
				gamepad.pressed.A;
			case X:
				gamepad.pressed.X;
			case Y:
				gamepad.pressed.Y;
			case B:
				gamepad.pressed.B;
			case START:
				gamepad.pressed.START;
			case SELECT:
				gamepad.pressed.BACK;
			case LB:
				gamepad.pressed.LEFT_SHOULDER;
			case RB:
				gamepad.pressed.RIGHT_SHOULDER;
			case _: return false;
		}
	}//---------------------------------------------------;	
	// --
	// WARN: On analog input, returns the state!
	inline static function _justPressedPad(id:Int):Bool
	{
		return switch(id) {
			case UP: 
				gamepad.justPressed.DPAD_UP ||
				(	gamepad.analog.justMoved.LEFT_STICK_Y && 
					gamepad.analog.value.LEFT_STICK_Y < 0 );
			case DOWN:
				gamepad.justPressed.DPAD_DOWN ||
				(	gamepad.analog.justMoved.LEFT_STICK_Y &&
					gamepad.analog.value.LEFT_STICK_Y > 0 );
			case LEFT:
				gamepad.justPressed.DPAD_LEFT ||
				(	gamepad.analog.justMoved.LEFT_STICK_X &&
					gamepad.analog.value.LEFT_STICK_X < 0 );				
			case RIGHT:
				gamepad.justPressed.DPAD_RIGHT ||
				(	gamepad.analog.justMoved.LEFT_STICK_X &&
					gamepad.analog.value.LEFT_STICK_X > 0 );				
			case A:
				gamepad.justPressed.A;
			case X:
				gamepad.justPressed.X;
			case Y:
				gamepad.justPressed.Y;
			case B:
				gamepad.justPressed.B;
			case START:
				gamepad.justPressed.START;
			case SELECT:
				gamepad.justPressed.BACK;
			case LB:
				gamepad.justPressed.LEFT_SHOULDER;
			case RB:
				gamepad.justPressed.RIGHT_SHOULDER;
			case _: return false;
		}
	}//---------------------------------------------------;
	inline static function _justReleasedPad(id:Int):Bool
	{
		return switch(id) {
			case UP: 
				gamepad.justReleased.DPAD_UP ||
				gamepad.analog.justReleased.LEFT_STICK_Y;
			case DOWN:
				gamepad.justReleased.DPAD_DOWN ||
				gamepad.analog.justReleased.LEFT_STICK_Y;
			case LEFT:
				gamepad.justReleased.DPAD_LEFT ||
				gamepad.analog.justReleased.LEFT_STICK_X;
			case RIGHT:
				gamepad.justReleased.DPAD_RIGHT ||
				gamepad.analog.justReleased.LEFT_STICK_X;
			case A:
				gamepad.justReleased.A;
			case X:
				gamepad.justReleased.X;
			case Y:
				gamepad.justReleased.Y;
			case B:
				gamepad.justReleased.B;
			case START:
				gamepad.justReleased.START;
			case SELECT:
				gamepad.justReleased.BACK;
			case LB:
				gamepad.justReleased.LEFT_SHOULDER;
			case RB:
				gamepad.justReleased.RIGHT_SHOULDER;
			case _: return false;
		}
	}//---------------------------------------------------;	
	// --
	inline static function _PressedKey(id:Int):Bool
	{
		return switch(id) {
			case UP: keys.anyPressed(mapping_up);
			case DOWN: keys.anyPressed(mapping_down);
			case LEFT: keys.anyPressed(mapping_left);
			case RIGHT: keys.anyPressed(mapping_right);
			case A: keys.anyPressed(mapping_A);
			case X: keys.anyPressed(mapping_X);
			case Y: keys.pressed.I;
			case B: keys.pressed.L;
			case START: keys.pressed.ENTER;
			case SELECT: keys.pressed.SPACE;
			case LB: keys.pressed.SHIFT;
			case RB: keys.pressed.CONTROL;
			case _: return false;
		}
	}//---------------------------------------------------;	
	// --
	inline static function _justPressedKey(id:Int):Bool
	{
		return switch(id) {
			case UP: keys.anyJustPressed(mapping_up);
			case DOWN: keys.anyJustPressed(mapping_down);
			case LEFT: keys.anyJustPressed(mapping_left);
			case RIGHT: keys.anyJustPressed(mapping_right);
			case A: keys.anyJustPressed(mapping_A);
			case X: keys.anyJustPressed(mapping_X);
			case Y: keys.justPressed.I; 
			case B: keys.justPressed.L;
			case START: keys.justPressed.ENTER;
			case SELECT: keys.justPressed.SPACE;
			case LB: keys.justPressed.SHIFT;
			case RB: keys.justPressed.CONTROL;
			case _: return false;
		}
	}//---------------------------------------------------;
	// --
	inline static function _justReleasedKey(id:Int):Bool
	{
		return switch(id) {
			case UP: keys.anyJustReleased(mapping_up);
			case DOWN: keys.anyJustReleased(mapping_down);
			case LEFT: keys.anyJustReleased(mapping_left);
			case RIGHT: keys.anyJustReleased(mapping_right);
			case A: keys.anyJustReleased(mapping_A);
			case X: keys.anyJustReleased(mapping_X);
			case Y: keys.justReleased.I; 
			case B: keys.justReleased.L; 
			case START: keys.justReleased.ENTER;
			case SELECT: keys.justReleased.SPACE;
			case LB: keys.justReleased.SHIFT;
			case RB: keys.justReleased.CONTROL;
			case _: return false;
		}	
	}//---------------------------------------------------;
	
	
}// -- end --//