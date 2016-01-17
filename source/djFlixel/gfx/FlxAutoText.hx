package tools;
import flixel.text.FlxText;
import flixel.util.FlxTimer;



/**
 * Simple AutoText
 */
class FlxAutoText extends FlxText
{
	// Characters per update/
	public var param_time_CPU:Int = 1;
	// Update every this seconds.
	public var param_time_FREQ:Float = 0.04;

	// The final text to animate to
	public var targetText:String;
	
	var currentLength:Int;
	var targetLength:Int;

	var timer:FlxTimer;
	
	//====================================================;
	// 
	//====================================================;
	// --
	public function new(X:Float, Y:Float, FieldWidth:Float = 0, Size:Int = 8)
	{
		super(X, Y, FieldWidth, null, Size);
		wordWrap = false;
		timer = new FlxTimer();
		targetText = "";
		currentLength = 0;
		targetLength = 0;
	}//---------------------------------------------------;
	
	// --
	public function start(?inText:String, ?onComplete:Void->Void)
	{
		clearText();
		
		currentLength = 0;
		targetLength = inText.length;
		targetText = inText;
		
		timer.start(time_FREQ, function(_) {
			
			currentLength += time_CPU;
			
			if (currentLength >= targetLength)
			{
				stop(true);
				
				if (onComplete != null) {
					onComplete();
				}
				
			}else {	
				text = targetText.substr(0, currentLength);
			}
			
		},0);
	}//---------------------------------------------------;
	// --
	public function clearText()
	{
		timer.destroy();
		text = "";
	}//---------------------------------------------------;

	public function stop(showFinal:Bool = false)
	{
		timer.destroy();
		
		if (showFinal && targetText != null)
		{
			currentLength = targetLength;
			text = targetText;
		}
	}//---------------------------------------------------;
	// --
	override public function destroy():Void 
	{
		super.destroy();
		if (timer != null) {
			timer.cancel();
			timer = null;
		}
	}//---------------------------------------------------;	
	
}// -- end -- //