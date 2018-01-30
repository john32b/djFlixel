package djFlixel.tool;
import flixel.util.FlxDestroyUtil;

/**
 * Executes a function for each element in the array
 * but will only iterate the next element on a callback.
 * Useful when the operations done on the queue are ASYNC.
 * ...

EXAMPLE:
	
	queue = new ArrayExecSync<String>(fileArray);
	queue.start(	function(file:String){ queue.next(); },
					function(){ all done; }
				);
*/
 

class ArrayExecSync<T> implements IFlxDestroyable
{
	public var queue:Array<T>;
	public var counter(default, null):Int;
	public var queue_complete:Void->Void;
	public var queue_action:T->Void;
	
	public function new(?ar:Array<T>) {
		if (ar != null) queue = ar;
		else queue = new Array();
	}//---------------------------------------------------;
	
	public function push(el:T):Void {
		queue.push(el);
	}//---------------------------------------------------;
	
	public function start(?fn_action:T->Void, ?fn_complete:Void->Void):Void {
		if (queue.length == 0) return;
		counter = -1;
		// I don't want to null them because the execution could be reset and they don't have to change
		if (fn_action != null) queue_action = fn_action;
		if (fn_complete != null) queue_complete = fn_complete;
		next();
	}//---------------------------------------------------;
	
	public function next() {
		if (++counter < queue.length) {
			queue_action(queue[counter]);
		} else {
			if (queue_complete != null) queue_complete();
		}
	}//---------------------------------------------------;
	
	public function destroy() {
		queue = null;
		queue_complete = null;
		queue_action = null;
	}//---------------------------------------------------;
	
	public function reset() {
		queue = [];
		counter = -1;
	}//---------------------------------------------------;	
	
}//--//