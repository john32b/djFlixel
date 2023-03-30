package djFlixel.ui;

/**
   Events that Items emit. Readable from {VList.onItemEvent}
**/
enum ListItemEvent
{
	focus;		// Item received focus
	fire;		// Item was activated ( for FLXMenu this fires for list,range,toggle as well )
	invalid;	// Whenever a disabled item receives input. Useful for producing sound effects
	change;		// The item value changed ( FlxMenu works with the fire event mostly )
}

/**
   Items get user input states with this.
**/
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
	 * Useful flag that is used by the parent menu
	 */
	public var isFocused(default, null):Bool;
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
	 * Returns true if the parameter data is the same as the current data this item has. 
	 * This is used for pooling.
	 */
	public function isSame(data:T):Bool;
}// --


/** QUICK COPY/PASTE

class MyListItem extends FlxSprite implements IListItem<String>
{
	
	public var isFocused(default, null):Bool = false;
	
	public var callback:ListItemEvent->Void;
	
	public function new()
	{
		super();
	}
	
	public function setData(_data:String):Void
	{
	}
	
	public function onInput(_type:ListItemInput):Void
	{
	}
	
	public function focus():Void
	{
	}
	
	public function unfocus():Void
	{
	}
	
	public function isSame(_data:T):Bool 
	{
	}
}

*/