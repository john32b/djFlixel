package djFlixel.gui.list;


/**
 * Interface for a sprite that can go inside a ( VListBase | VListNav )
 */
interface IListItem<T>
{
	/**
	 * Sometimes you might need the list items to push callbacks to the parent menu. 
	 * VListNa autosets this.
	 */
	public var callbacks:String->Void;
	/**
	 * Handles data pushed from the parent menu.
	 * @param	data
	 */
	public function setData(data:T):Void;
	/**
	 * Handles key input that is passed from VListNav.
	 * @param	inputName [ left, right, fire, c|0|0 ]
	 */
	public function sendInput(inputName:String):Void;
	/**
	 * Visually focus the element.
	 */
	public function focus():Void;
	/**
	 * Visually unfocus the element. (Resting state)
	 */
	public function unfocus():Void;
	/**
	 * Useful flag that is used by the parent menu
	 */
	public var isFocused(default, null):Bool;
	/**
	 * Returns true if the parameter data is the same as the current data this item has. 
	 * This is used for pooling.
	 * @param	data
	 */
	public function isSame(data:T):Bool;
}