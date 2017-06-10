package djFlixel.gui.menu;

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
				if (Std.int(opt.data.current) > Std.int(opt.data.pool[0])) {
					opt.data.current--;
					updateItemData();
					cb("change");
				}
			case "right":
				if (Std.int(opt.data.current) < Std.int(opt.data.pool[1])) {
					opt.data.current++;
					updateItemData();
					cb("change");
				}
				
			case "click":
				var r = collideWithCursor();
				if (r < 0) handleInput("left"); else if (r > 0) handleInput("right");
		}
	}//---------------------------------------------------;

	// --
	override function updateItemData() 
	{
		arrowStat[0] = (opt.data.current > Std.int(opt.data.pool[0]));
		arrowStat[1] = (opt.data.current < Std.int(opt.data.pool[1]));
		
		label2.text = '${opt.data.current}';
		
		// Check visibility and reset nudge
		_updateArrow();
	}//---------------------------------------------------;
}// --