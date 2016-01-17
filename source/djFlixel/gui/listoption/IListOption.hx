package djFlixel.gui.listoption;

@:generic
interface IListOption<T>
{
	// Change the data shown
	public function setData(data:T):Void;
	
	// Send key input, can be anything like [select, cancel, right, left]..etc
	public function sendInput(inputName:Dynamic):Void;
	
	public function focus():Void;
	public function unfocus():Void;
	
	// This gets reported to the list, as the visual height of the element
	public function getOptionHeight():Int;
	
	// Returns true if passed data is the same as the data set to this object
	// Required for the reuse pooling
	public function isSame(data:T):Bool;
}