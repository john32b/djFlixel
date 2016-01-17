package djFlixel;

/**
 * Executes a function for each element in the array
 * but will only iterate the next element on callback.
 * Useful when the operations done on the queue are ASYNC.
 * ...

EXAMPLE:
	
	queue = new ArrayExecSync<String>(fileArray);
	queue.start(	function(file:String){ queue.next(); },
					function(){ all done; }
				);
*/
 

class ArrayExecSync<T>
{
	public var queue:Array<T>;
	public var counter:Int;
	public var queue_complete:Void->Void;
	public var queue_action:T->Void;
	
	public function new(?ar:Array<T>) {
		if (ar != null) queue = ar;
		else queue = new Array();
	}//---------------------------------------------------;
	
	public function push(el:T):Void {
		queue.push(el);
	}//---------------------------------------------------;
	
	public function start(fn_action:T->Void, fn_complete:Void->Void):Void {
		if (queue.length == 0) return; //throw "Queue is empty";
		counter = -1;
		queue_action   = fn_action;
		queue_complete = fn_complete;
		next();
	}//---------------------------------------------------;
	
	public function next() {
		if (++counter < queue.length) {
			queue_action(queue[counter]);
		} else {
			queue_complete();
		}
	}//---------------------------------------------------;
	
	public function kill() {
		queue = null;	
	}//---------------------------------------------------;
	
}//--//