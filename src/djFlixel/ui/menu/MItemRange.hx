package djFlixel.ui.menu;
import djFlixel.ui.IListItem.ListItemInput;
import djFlixel.ui.menu.MItemData;

/**
 */
class MItemRange extends MItemList
{
	var isFloat:Bool = false;
	
	// Taken from Franco Ponticelli's THX library:
	// https://github.com/fponticelli/thx/blob/master/src/Floats.hx#L206
	function roundFloat(number:Float, precision:Int = 2):Float {
		number *= Math.pow(10, precision);
		return Math.round(number) / Math.pow(10, precision);
	}//---------------------------------------------------;
	
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
			var c:Float = data.P.c;
			var lim:Float = data.P.range[0];
			if (c == lim && !data.P.loop) return;
			#if (neko || hl)
			c -= data.P.step;
			#else
			c -= Std.parseFloat(data.P.step);
			#end
			if (isFloat) c = roundFloat(c);
			if (c < lim){
				if (data.P.loop) c = data.P.range[1]; else c = lim;
			}
			data.P.c = c;
			refresh_data();
			stimer.fire();
			callback(fire);
			return;
		}
		
		if (inp == right)
		{
			var c:Float = data.P.c;
			var lim:Float = data.P.range[1];
			if (c == lim && !data.P.loop) return;
			#if (neko || hl)
			c += data.P.step;	
			#else
			c += Std.parseFloat(data.P.step); // Dev, parsefloat is needed, but it shouldnt?
			#end
			if (isFloat) c = roundFloat(c);
			if (c > lim) 
			{
				if (data.P.loop) c = data.P.range[0]; else c = lim;
			}
			
			data.P.c = c;
			refresh_data();
			stimer.fire();
			callback(fire);
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
	}//---------------------------------------------------;
	
}// --