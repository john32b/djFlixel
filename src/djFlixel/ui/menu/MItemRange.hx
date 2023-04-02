package djFlixel.ui.menu;
import djA.DataT;
import djFlixel.ui.IListItem.ListItemInput;
import djFlixel.ui.menu.MItemData;

/**
 */
class MItemRange extends MItemList
{
	var isFloat:Bool = false;
	
	override function on_newdata() 
	{
		isFloat = (data.P.step % 1 != 0);
		super.on_newdata();
	}//---------------------------------------------------;
	override function handleInput(inp:ListItemInput)
	{
		inp = transformClick(inp);
		
		if (inp == left)
		{
			// DEV: Need to cast those to help the compiler
			var c:Float = data.P.c;
			var lim:Float = data.P.range[0];
			
			if (c == lim && !data.P.loop) return;
			
			c -= data.P.step;
			
			if (isFloat) c = DataT.roundFloat(c);
			
			if (c < lim){
				if (data.P.loop) c = data.P.range[1]; else c = lim;
			}
			
			data.P.c = c;
			refresh_data();
			stimer.fire();
			callback(change); callback(fire);
			return;
		}
		
		if (inp == right)
		{
			// DEV: Need to cast those to help the compiler
			var c:Float = data.P.c;
			var lim:Float = data.P.range[1];
			
			if (c == lim && !data.P.loop) return;
			
			if (data.P.fstep != null && c == data.P.range[0])
				c += data.P.fstep;
			else
				c += data.P.step;
				
			if (isFloat) c = DataT.roundFloat(c);
			
			if (c > lim) {
				if (data.P.loop) c = data.P.range[0]; else c = lim;
			}
			
			data.P.c = c;
			refresh_data();
			stimer.fire();
			callback(change); callback(fire);
			return;
		}
		
	}//---------------------------------------------------;
	
	override function refresh_data() 
	{
		if (!data.P.loop){
			arStat[0] = (data.P.c > Std.int(data.P.range[0]));
			arStat[1] = (data.P.c < Std.int(data.P.range[1]));
		}
		
		label2.text = '${data.P.c}';
		if (mp.STP.align == "justify") {
			label2.x = x + mp.menu_width - label2.width;
		}
		
		refresh_arrowStates();
		
		_width = label2.x + label2.width - label.x;
	}//---------------------------------------------------;
	
}// --