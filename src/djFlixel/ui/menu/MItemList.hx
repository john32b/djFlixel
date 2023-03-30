package djFlixel.ui.menu;
import djA.DataT;
import djFlixel.other.StepLoop;
import djFlixel.ui.IListItem.ListItemInput;
import djFlixel.ui.menu.MPage;
import djFlixel.ui.menu.MItem;
import djFlixel.ui.menu.MItem.FocusState;
import flixel.FlxSprite;
import flixel.text.FlxText;

/**
 * MItemRange extends this as they share functionality
 */
class MItemList extends MItem
{
	// Displayed text
	var label2:FlxText;
	
	// Hold 2 arrows and their status
	var ar0:FlxSprite;
	var ar1:FlxSprite;
	var arStat:Array<Bool> = [];
	var stimer:StepLoop;
	var offy:Int = 1;	// Y offset, applies to Bitmap Arrows (style set)
	var offx:Int = 0;	// X offset for the second arrow. Bitmap arrows, offset to 1 (No style)
	
	var _width:Float = 0;	// Precalculates _width
	
	/**
	`check` If true, will check the 3,4 slots on style (ar_bm, ar_txt) and load these. 
			This is used by MItemRange. Fallbacks to [0,1] if nothing is set to [3,4]
	**/
	public function new(MP:MPage, check34:Bool = false) 
	{
		super(MP);
		
		if (st.ar_offy != null) offy = st.ar_offy;
		
		// -- List Text
		label2 = D.text.get("", st.text);
		label2.y = label.y;
		add(label2);
		
		// -- Create Arrows
		var o = 0;
				
		if (st.ar_bm != null) {
			if (check34 && st.ar_bm[3] != null) o = 2;
			// DEV:
			// I just need to clone(), else if I pass ownership to FlxSprite it 
			// will delete the bitmap from the cache forever on sprite destroy
			ar0 = new FlxSprite(mp.iconcache.get(st.ar_bm[0 + o], 'focus').clone());
			ar1 = new FlxSprite(mp.iconcache.get(st.ar_bm[1 + o], 'focus').clone());
			D.align.YAxis(ar0, label, 'c', offy);
			offx = 1;	// TODO: parameterize this?
			ar1.y = ar0.y;
			
		}else {
			if (check34 && st.ar_txt[3] != null) o = 2;
			if (st.ar_txt == null) throw "Style error, you must set text or bitmap";
			var t0 = D.text.get(st.ar_txt[0 + o], st.text);
			var t1 = D.text.get(st.ar_txt[1 + o], st.text);
			_ctext('focus', t0);
			_ctext('focus', t1);
			ar0 = cast t0;
			ar1 = cast t1;
			// dev: Don't touch the y axis, same height as other texts
		}
		add(ar0);
		add(ar1);
		MP.ghostArrowWidth = Std.int(ar1.width + offx);
		// -- Move arrows
		var c = st.ar_anim.split(','); 
		stimer = new StepLoop(Std.parseInt(c[0]), Std.parseInt(c[1]), Std.parseFloat(c[2]), update_arrowNudge);
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		stimer.update(elapsed);
	}//---------------------------------------------------;
	
	override function on_newdata() 
	{
		super.on_newdata();
		
		if (data.P.loop){
			arStat[0] = arStat[1] = true;
		}
		
		if (mp.STP.align != "justify" ) 
		{
			label2.x = label.x + label.width + st.part2_pad + Math.max(ar0.width - st.part2_pad, 0);
			// pad + if the arrow is width, the difference of pixels to make the arrow fit
		}	
		
		refresh_data();
	}//---------------------------------------------------;
	
	
	override function state_set(id:FocusState) 
	{
		super.state_set(id);
		if (id == idle) {
			_ctext('accent', label2);
		}else{
			_ctext(id.getName(), label2);
		}
		if (id == FocusState.focus) {
			refresh_arrowStates();
			stimer.start();
			stimer.fire();
		}else{
			ar0.visible = ar1.visible = false;
			stimer.stop();
		}
	}//---------------------------------------------------;

	
	// --
	override function handleInput(inp:ListItemInput) 
	{
		// If this is a mouse click, will check and transform to left/right
		inp = transformClick(inp);
		
		if (inp == right)
		{
			var c = Std.int(data.P.c) + 1;
			if (c >= data.P.list.length){
				if (data.P.loop) c = 0; else return;
			}
			data.P.c = c;
			refresh_data();
			stimer.fire();	// note this updates arrow x pos
			callback(change); callback(fire); 
			return;
		}
		if (inp == left)
		{
			var c = Std.int(data.P.c) - 1;
			if (c < 0){
				if (data.P.loop) c = cast data.P.list.length - 1; else return;
			}
			data.P.c = c;
			refresh_data();
			stimer.fire();	// note this updates arrow x pos
			callback(change); callback(fire);
			return;
		}
	}//---------------------------------------------------;
	
	function update_arrowNudge(v:Float)
	{
		ar0.x = label2.x - ar0.width - v;
		ar1.x = label2.x + label2.width + v + offx;	// +1 helps in most cases to position it better
	}//---------------------------------------------------;
	
	/**
	   Decide if left/right arrow should be visible or not
	**/
	function refresh_arrowStates()
	{
		ar0.visible = arStat[0];
		ar1.visible = arStat[1];
	}//---------------------------------------------------;
	
	/**
	   Reflects selected data to label
	   - Also refreshes arrows -
	**/
	function refresh_data()
	{
		if (!data.P.loop){
			arStat[0] = (data.P.c > 0);
			arStat[1] = (data.P.c < data.P.list.length - 1);
		}
		
		label2.text = data.P.list[data.P.c];
		
		if (mp.STP.align == "justify") {
			label2.x = x + mp.menu_width - label2.width;
		}
		
		refresh_arrowStates();
		
		_width = label2.x + label2.width - label.x;
		
	}//---------------------------------------------------;
	
	// This is a hacky way to transform a click to left/right inputs
	// Check if clicked in the general area of the arrow
	// Starting from the middle of the label
	function transformClick(inp:ListItemInput):ListItemInput
	{
		switch(inp) {
		case click(mx, my):
			var l2middlepos = (label2.x - label.x) + (label2.width / 2);
			if (mx < l2middlepos) return left; return right;
		case _: 
		}
		return inp;
	}//---------------------------------------------------;
	
	
	override function get_width():Float 
	{
		return _width;
	}
		
	
}// --