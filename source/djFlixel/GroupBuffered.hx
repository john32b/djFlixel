package djFlixel;


import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;


/// UNUSED

class GroupBuffered<T:FlxSprite> extends FlxTypedGroup<T>
{
	
	var minSize:Int;
	
	// ----
	var flag_offScreenKiller:Bool = false;
	var _osk_freq:Float = 1; // Every 1 second.
	var _osk_timer:Float;	// Last time group was checked for offscreen
	var _osk_camera:FlxCamera = null; // Pointer to a camera
	
	//---------------------------------------------------;
	
	public function new(MinSize:Int = 0, MaxSize:Int = 0)
	{
		super(maxSize);
		minSize = MinSize;
		// The group is not filled here. Extend the class and fill there.
	}//---------------------------------------------------;
	
	
	/**
	 * Start checking for offscreen entities and kill them if offscreen
	 * 
	 * @param	checkFreq Time Frequency to check
	 * @param	_cam      Camera to take into account when checking for offscreen
	 * 
	 */
	public function enableOffScreenKiller(checkFreq:Float = 1, ?_cam:FlxCamera)
	{
		flag_offScreenKiller = true;
		_osk_freq = checkFreq;
		_osk_timer = 0;
		_osk_camera = _cam;
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		/*	
		if (flag_offScreenKiller)
		{
			_osk_timer += FlxG.elapsed;
			
			if (_osk_timer >= _osk_freq)
			{
				_osk_timer = 0;
				
				forEachAlive(function(spr:FlxSprite) {
					if (spr.isOnScreen(_osk_camera) == false) {
						spr.kill();
					}
				});
			}
		}
		
		*/
		
	}//---------------------------------------------------;
	
	// -- Destroy all sprites exceeding the minSize
	//    The rest is killed()s
	public function reset()
	{
		for (i in this) i.kill();
		
		if (minSize > 0 && length > minSize) {
			var delta:Int = length - minSize;
			for (i in 0...delta) { members.pop().destroy(); }
			length = members.length;
		}
	}//---------------------------------------------------;
	
}// -- end --