package;

/**
 * ...
 * @author 
 */
class SaveSlotData
{
	public var slot:Int;
	public var level:Int;
	
	public function new(slot:Int) 
	{
		this.slot = slot;
		level = Std.random(10);
	}//---------------------------------------------------;
	
}