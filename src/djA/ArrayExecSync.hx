/***************************************************************
  Executes a function for each element in the array
  but will only iterate the next element on a callback.
  Useful when the operations done on the queue are ASYNC.
 
 EXAMPLE :
	queue = new ArrayExecSync(fileArray);
	queue.start(	(file)->{ queue.next(); },
					()->{ all done; }
				);
*************************************************************/
 

package djA;

class ArrayExecSync<T>
{
	
	/**
	  Executes a function for all elements but only goes to the next element with a callback.
	   @param	ar The Array to run
	   @param	cb (element, next())
	**/
	public static function run<T>(ar:Array<T>, cb:T->(Void->Void)->Void)
	{
		var c = 0;
		var q:Void->Void = null;
		q = ()-> cb(ar[c++], q);
		q();
	}//---------------------------------------------------;
	
	public var items:Array<T>;
	public var C(default, null):Int; // Current
	public var onComplete:Void->Void;
	public var onItem:T->Void;
	
	public function new(?ar:Array<T>) 
	{
		items = ar;
	}//---------------------------------------------------;
	
	public function start(?ONITEM:T->Void, ?ONCOMPLETE:Void->Void):Void 
	{
		C = -1;
		// I don't want to null them because the execution could be reset and they don't have to change
		if (ONITEM != null) onItem = ONITEM;
		if (ONCOMPLETE != null) onComplete = ONCOMPLETE;
		next();
	}//---------------------------------------------------;
	
	public function next():Void
	{
		if (++C < items.length) {
			return onItem(items[C]);
		} else {
			if (onComplete != null) return onComplete();
		}
	}//---------------------------------------------------;
		
}//--