package djFlixel.gui.menu;
import djFlixel.tool.DataTool;

class MItemSlider extends MItemOneof
{
	/* 
	 * NOTE:
	 * ------
	 * dataPool[0] = rangeFrom
	 * dataPool[1] = rangeTo
	 * dataCurrent = Actual Value
	 */
	override function handleInput(inputName:String) 
	{
		switch(inputName)
		{
			case "left":
				var c:Float = opt.data.current;
				var lim:Float = opt.data.pool[0];
				
				if (c == lim && !opt.data.loop) return;

				c -= opt.data.inc;
				
				if (opt.data.float) {
					c = DataTool.roundFloat(c);
				}
				
				if (c < lim) {
					if (opt.data.loop) c = opt.data.pool[1]; else c = lim;
				}
				
				opt.data.current = c;
				updateItemData();
				cb("change");
				
			case "right":
				var c:Float = opt.data.current;
				var lim:Float = opt.data.pool[1];
				if (c == lim && !opt.data.loop) return;
				
				c += opt.data.inc;
				
				if (opt.data.float) {
					c = DataTool.roundFloat(c);
				}
				
				if (c > lim) {
					if (opt.data.loop) c = opt.data.pool[0]; else c = lim;
				}
				
				opt.data.current = c;
				updateItemData();
				cb("change");
			
			default:
				handleInputClick(inputName);
		}
	}//---------------------------------------------------;

	// --
	override function updateItemData() 
	{
		if (!opt.data.loop){
			arrowStat[0] = (opt.data.current > Std.int(opt.data.pool[0]));
			arrowStat[1] = (opt.data.current < Std.int(opt.data.pool[1]));
		}else{
			arrowStat[0] = arrowStat[1] = true;
		}
		
		label2.text = '${opt.data.current}';
		
		// Check visibility and reset nudge
		_updateArrows();
		
		updateLabel2Pos();
	}//---------------------------------------------------;
}// --