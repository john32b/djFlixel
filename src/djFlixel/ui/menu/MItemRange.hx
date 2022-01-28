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
		isFloat = (data.data.step % 1 != 0);
		super.on_newdata();
	}//---------------------------------------------------;
	override function handleInput(inp:ListItemInput)
	{
		inp = transformClick(inp);
		
		if (inp == left)
		{
			var c:Float = data.data.c;
			var lim:Float = data.data.range[0];
			if (c == lim && !data.data.loop) return;
			#if (neko || hl)
			c -= data.data.step;
			#else
			c -= Std.parseFloat(data.data.step);
			#end
			if (isFloat) c = roundFloat(c);
			if (c < lim){
				if (data.data.loop) c = data.data.range[1]; else c = lim;
			}
			data.data.c = c;
			refresh_data();
			stimer.fire();
			callback(fire);
			return;
		}
		
		if (inp == right)
		{
			var c:Float = data.data.c;
			var lim:Float = data.data.range[1];
			if (c == lim && !data.data.loop) return;
			#if (neko || hl)
			c += data.data.step;	
			#else
			c += Std.parseFloat(data.data.step); // Dev, parsefloat is needed, but it shouldnt?
			#end
			if (isFloat) c = roundFloat(c);
			if (c > lim) 
			{
				if (data.data.loop) c = data.data.range[0]; else c = lim;
			}
			
			data.data.c = c;
			refresh_data();
			stimer.fire();
			callback(fire);
			return;
		}
		
	}//---------------------------------------------------;
	
	override function refresh_data() 
	{
		if (!data.data.loop){
			arStat[0] = (data.data.c > Std.int(data.data.range[0]));
			arStat[1] = (data.data.c < Std.int(data.data.range[1]));
		}
		
		label2.text = '${data.data.c}';
		if (mp.style.align == "justify") {
			label2.x = x + mp.menu_width - label2.width;
		}
		
		refresh_arrowStates();
	}//---------------------------------------------------;
	
}// --