package djFlixel.ui;


enum ListItemEvent
{
	focus;		// Item received focus
	fire;		// Item was activated
	invalid;	// Whenever a disabled item receives input. Useful for producing sound effects
	change;		// Item data changed, applicable in Toggle,List,Range
}

enum ListItemInput
{
	fire;
	left;
	right;
	click(x:Int, y:Int);	// Coordinates should be relative to item pos
}

/**
 * Interface for a sprite that can go inside a VList
 */
interface IListItem<T>
{
	/**
	 * You might need the list items to push callbacks to the parent menu. 
	 * VList autosets this.
	 */
	public var callback:ListItemEvent->Void;
	/**
	 * Handles data pushed from the parent menu.
	 */
	public function setData(data:T):Void;
	/**
	 * Handles key input that is passed from a VList
	 */
	public function onInput(type:ListItemInput):Void;
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
	 */
	public function isSame(data:T):Bool;
}// --


/**

	public var callbacks:String->Void;
	public var isFocused(default, null):Bool
	
	public function new() 
	{
		
	}
	public function setData(data:T):Void
	{
		
	}
	public function onInput(type:String):Void
	{
		
	}
	public function focus():Void
	{
	
	}
	public function unfocus():Void
	{
		
	}
	public function isSame(data:T):Bool
	{
		
	}

*/