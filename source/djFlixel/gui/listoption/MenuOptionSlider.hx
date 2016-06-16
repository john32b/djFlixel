package djFlixel.gui.listoption;

class MenuOptionSlider extends MenuOptionOneof
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
					updateOptionData();
					cb("optChange");
				}
			case "right":
				if (Std.int(opt.data.current) < Std.int(opt.data.pool[1])) {
					opt.data.current++;
					updateOptionData();
					cb("optChange");
				}		
		}
	}//---------------------------------------------------;
	// --
	override function updateOptionData() 
	{
		arrowStat[0] = (opt.data.current > Std.int(opt.data.pool[0]));
		arrowStat[1] = (opt.data.current < Std.int(opt.data.pool[1]));
		
		label2.text = '${opt.data.current}';
		
		// Check visibility and reset nudge
		_updateArrow();
	}//---------------------------------------------------;
}// --