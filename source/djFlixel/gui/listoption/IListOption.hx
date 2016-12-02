package djFlixel.gui.listoption;


interface IListOption<T>
{
	// -- Set by parent, fire input events.
	//    The ID is handled by parent.
	public var callbacks:String->Void;
	// Change the data shown
	public function setData(data:T):Void;
	// Send key input, can be anything like [select, cancel, right, left]..etc
	public function sendInput(inputName:String):Void;
	public function focus():Void; // Visually Focus
	public function unfocus():Void; // Visually Unfocus
	public var isFocused(default, null):Bool;
	// This gets reported to the list as the visual height of the element
	public function getOptionHeight():Int;
	// Returns true if passed data is the same as the data set to this object
	// Required for the reuse pooling
	public function isSame(data:T):Bool;
}