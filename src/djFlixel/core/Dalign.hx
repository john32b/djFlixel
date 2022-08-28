/**
	Alignment related Functions used to place FlxObjects
	==========================
	- Accessible from (D.align)
	
*******************************************/
package djFlixel.core;

import djA.DataT;
import djA.types.SimpleRect;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;

@:dce
class Dalign 
{
	public function new() {}
	
	/**
	 Align an object using the screen viewport as a guide
	 @param	obj Object to align
	 @param	alignX l r c (left right center) other for none
	 @param	alignY t b c (top bottom center) other for none
	 @param   padding Apply this much padding in pixels
	 */
	public function screen(obj:FlxSprite, alignX:String = "c", alignY:String = "c", padding:Float = 0):FlxSprite
	{
		switch(alignX)
		{
			case "l" : obj.x = 0 + padding;
			case "r" : obj.x = obj.camera.width - obj.width - padding;
			case "c" : obj.x = (obj.camera.width / 2) - (obj.width / 2);
			default: // NONE
		}
		
		switch(alignY)
		{
			case "t" : obj.y = 0 + padding;
			case "b" : obj.y = obj.camera.height - obj.height - padding;
			case "c" : obj.y = (obj.camera.height / 2) - (obj.height / 2);
			default:  // NONE
		}
		
		return obj;
	}//---------------------------------------------------;
	
	/**
	 Align Horizontally an object to another object
	 @param	o Object to Align
	 @param	t The Guide Object
	 @param	type l r c (left right center)
	 @param	offs Placement Offset
	 */
	public function XAxis(o:FlxSprite, t:FlxSprite, type:String = "c", offs:Float = 0):FlxSprite
	{
		switch(type){
			case "c":
				o.x = t.x + (t.width - o.width) / 2;	
			case "l":
				o.x = t.x;
			case "r":
				o.x = t.x + t.width - o.width;
			default:
		}
		o.x += offs; return o;
	}//---------------------------------------------------;
	
	/**
	 Align Verticaly an object to another object
	 @param	o Object to Align
	 @param	t The Guide Object
	 @param	type t b c ( top bottom center )
	 @param	offs Placement Offset
	 */
	public function YAxis(o:FlxSprite, t:FlxSprite, type:String = "c", offs:Float = 0):FlxSprite
	{
		switch(type){
			case "c":
				o.y = t.y + (t.height - o.height) / 2;
			case "t":
				o.y = t.y;
			case "n":
				o.y = t.y + t.height - o.height;
			default:
		}
		o.y += offs; return o;
	}//---------------------------------------------------;
	
	/**
	 Place an object to the RIGHT of another object. Same Y pos
	 @param	o Object to Align
	 @param	t Guide Object
	 @param	offX Offset X
	 @param	offY Offset Y
	 @return  Placed Object
	 */
	public function right(o:FlxSprite, t:FlxSprite, offX:Float = 0, offY:Float = 0):FlxSprite
	{
		o.x = t.x + t.width + offX;
		o.y = t.y + offY;
		return o;
	}//---------------------------------------------------;
	
	/** 
	 Place an object to the LEFT of another object. Same Y pos
	 @param	o Object to Align
	 @param	t Guide Object
	 @param	offX Offset X
	 @param	offY Offset Y
	 @return  Placed Object
	 */
	public function left(o:FlxSprite, t:FlxSprite, offX:Float = 0, offY:Float = 0):FlxSprite
	{
		o.x = t.x - o.width + offX;
		o.y = t.y + offY;
		return o;
	}//---------------------------------------------------;
	
	/**
	 Place an object on TOP of another object. Same X pos
	 @param	o Object to Align
	 @param	t Guide Object
	 @param	offX Offset X
	 @param	offY Offset Y
	 @return  Placed Object
	 */
	public function up(o:FlxSprite, t:FlxSprite, offX:Float = 0, offY:Float = 0):FlxSprite
	{
		o.x = t.x + offX;
		o.y = t.y - o.height + offY;
		return o;
	}//---------------------------------------------------;
	
	/**
	 Place an object BELOW another object. Same X pos
	 @param	o Object to Align
	 @param	t Guide Object
	 @param center If true will center it horizontally. OPTIONAL means you can skip
	 @param	offX Offset X
	 @param	offY Offset Y
	 @return  Placed Object
	 */
	public function down(o:FlxSprite, t:FlxSprite, ?center:Bool, offX:Float = 0, offY:Float = 0):FlxSprite
	{
		o.x = t.x + offX;
		if(center) o.x += ((t.width - o.width) / 2);
		o.y = t.y + t.height + offY;
		return o;
	}//---------------------------------------------------;
	
	/**
	 Places an object below another object and centers it in the middle of it
	 */
	@:deprecated("Use down(), it has a new `center` argument")
	public function downCenter(o:FlxSprite, t:FlxSprite, offY:Float = 0):FlxSprite
	{
		o.x = t.x + ((t.width - o.width) / 2);
		o.y = t.y + t.height + offY;
		return o;
	}//---------------------------------------------------;
	
	
	/**
	 Align a bunch of elements centered below a target sprite
	 @param	elements Array of elements to align on the line
	 @param	source The element to put the line below
	 @param	padX X padding of line elements
	 @param	padY Y padding from the source element
	 */
	public function inLineCenterBelow(elements:Array<FlxSprite>, guide:FlxSprite, offX:Float = 1, offY:Float = 1)
	{
		inLine(guide.x, guide.y + guide.height + offY, guide.width, elements, "c", offX);
	}//---------------------------------------------------;
	
	/**
	 Align a bunch of objects in a line
	 @param	x Line start X
	 @param	y Line start Y
	 @param	width Width of the Line, 0: Rest of the screen, -1: Center of the screen mirror to X
	 @param	elements Array of elements to align
	 @param	align l r j c (left right justify center)
	 @param pad if align is [c,l,r] use padding between elements in pixels
	 */
	public function inLine(x:Float, y:Float, width:Float, els:Array<FlxSprite>, align:String = "c", pad:Float = 0)
	{
		if (els == null || els.length == 0) return;
		if (els.length == 1) pad = 0;
		
		var sx:Float; // start x, when placing
		var tw:Float = 0; // total Width padding included
		
		if (width == 0) width = FlxG.width - x;
		if (width < 0) width = FlxG.width - x * 2;
		
		inline function getTW(){
			tw = 0;
			for (i in els) tw += i.width;
			tw += (els.length - 1) * pad; // Total width of all the elements with padding
		};
		
		switch(align)
		{
			case "l":
				sx = x;
				for (i in els){ i.x = sx; sx += (i.width + pad); i.y = y; }
			case "r":
				getTW();
				sx = x + width - tw;
				for (i in els){ i.x = sx; sx += (i.width + pad); i.y = y; }	
			case "c":
				getTW();
				sx = x + (width / 2) - (tw / 2);
				for (i in els){ i.x = sx; sx += (i.width + pad); i.y = y; }				
			case "j":
				if (els.length == 1) {
					inLine(x, y, width, els, 'c'); return;
				}
				// Fix the pos of the first and last elements
				// Then for the middle elements, call this function again with ('center')
				var fs = width; var e:FlxSprite; // fs = freespace on the width
				e = els.shift();
					fs -= e.width;
					e.setPosition(x, y);
					var x1 = x + e.width;	// I want to keep where the first el ends
				e = els.pop();
					fs -= e.width;
					e.setPosition(x + width - e.width, y);	
				if (els.length == 0) return;	// No need to center anything else
				var elw = 0.0;	// Figure out the padding between the center elements
				for (i in els) elw += i.width;	
				var padspace = (fs - elw) / (els.length + 1);	// padspace between elements
				inLine(x1, y, fs, els, 'c', padspace);
			default:
		}
	}//---------------------------------------------------;
	
	/**
	 Align a bunch of elements vertically 
	 @param	x Line start X
	 @param	y Line start Y
	 @param	height Line Height 0:Rest of the screen, -1:Center of the screen mirror to Y
	 @param	elements The elements to align
	 @param	align t b j c (top bottom justify center)
	 @param pad if align="c,t,b" use padding between elements in pixels
	 */
	public function inVLine(x:Float, y:Float, height:Float, els:Array<FlxSprite>, align:String = "c", pad:Float = 0)
	{
		if (els == null || els.length == 0) return;
		
		var sy:Float; // start x, when placing
		var th:Float = 0; // total Width padding included
		if (height == 0) height = FlxG.height - y;
		if (height < 0 ) height = FlxG.height - y * 2;
		
		inline function getTH(){
			th = 0;
			for (i in els) th += i.height;
			th += (els.length - 1) * pad; // Total width of all the elements with padding
		};
		
		switch(align)
		{
			case "t":
				sy = y;
				for (i in els){ i.y = sy; sy += (i.height + pad); i.x = x; }
			case "b":
				getTH();
				sy = y + height - th;
				for (i in els){ i.y = sy; sy += (i.height + pad); i.x = x; }
			case "c":
				getTH();
				sy = y + (height / 2) - (th / 2);
				for (i in els){ i.y = sy; sy += (i.height + pad); i.x = x; }				
			case "j":
				throw "TODO:copy implementation from invline()";
			default:
		}
	}//---------------------------------------------------;
	
	
	/****************************************************************
	 * == PLACER functions (A thing that places objects?)
	 * 
	 * - Place elements in an area without worrying coordinates
	 * - Elements are placed automatically one below another
	 * - Defines an area on the screen for placing sprites/text
	 * - Can define columns and then place to them
	 * - Following a bunch of functions with the `p` prefix
	 * 
	 * == EXAMPLE :
	 *  ; Initialize the placer area 
	 *  	D.align.pInit() // No params to define screen
	 *  ; Place a sprite
	 * 		D.align.p(new FlxSprite(..), {a:"c"});
	 * 	; Create place text
	 *  	D.align.pT("~Formatted <g>text<g>",{oy:8},styleText);
	 * 
	 ****************************************************************/
	
	// Currently defined columns in the area, null for no columns
	var cols:Array<{w:Int,x:Int,p:Int,ly:Int}>;	
	// Last Sprite places
	var last:FlxSprite;
	// Next Y position to place sprites (when no column)
	var ly:Int;
	
	@:noCompletion var __p_no_new_obj:Bool = false;

	var _DEF_PLACE = {
		c:0,		// column to place element, 0 for no column
		ox:0,		// offset x
		oy:0,		// offset y
		next:false, // overrides all rules and just places right next to the previous element
		a:"l",      // Align - l:left, c:center, r:right
		ta:"l"		// TextAlign - l:left, c:center, r:right
	};
	
	/** The defined area for the placer */
	public var parea(default, null):SimpleRect;
	
	/** Set to false if you don't want object generation to add to the state, just return them. */
	public var PLACE_ADD:Bool = false;
	
	/**
	   Initialize the Placer,
	   Predefined area, or default for fullscreen
	**/
	public function pInit(X:Int = 0, Y:Int = 0, W:Int = 0, H:Int = 0)
	{
		if (W == 0) W = FlxG.width - X;
		if (H == 0) H = FlxG.height - Y;
		parea = new SimpleRect(X, Y, W, H);
		ly = parea.y;
		cols = null;
		last = null;
		PLACE_ADD = false;
	}//---------------------------------------------------;
	
	/**
	   Clear the ceiling, so elements will start from the top. 
	   Useful in some cases (like flxslides) where you need to keep the same column structure
	   @param ceil True will reset to the top of the global Area, False to make all COLUMNS snap to the last Ceiling
	**/
	public function pClear(ceil:Bool = true)
	{
		if (ceil) {
			last = null;
			ly = parea.y;
		}
		if (cols != null) for (i in cols) i.ly = ly;
	}//---------------------------------------------------;
	
	/** Add a bit of padding on the current element ceiling/lasty */
	public function pPad(h:Int = 8)
	{
		ly += h;
		if (cols != null) for (i in cols) i.ly += h;
	}//---------------------------------------------------;
	
	/**
	  Prepare some columns for item placement
	  @param C "columWidth,Leftpad|column2,leftpad" e.g. "100,1|100,16"
	  @param XPos if -1 All columns will be centered to area. Else will be positioned to this value.
	**/
	public function pCol(C:String, XPos:Int = -1, clear:Bool = true)
	{
		if (clear) {
			last = null;
			ly = parea.y;
		}
		
		cols = [];
		
		var widthTotal:Int = 0;
		
		// Column,Leftpad
		var A = C.split('|'); // ["100,1"], ["150,15"]  , width, pad
		for (i in 0...A.length)
		{
			var a = A[i];
			var V = a.split(',');
			var col = {w:Std.parseInt(V[0]), p:0, x:0, ly:parea.y};
			if (V[1] != null){
				col.p = Std.parseInt(V[1]);
			}
			cols.push(col);
			widthTotal += col.w;
			if (i > 0) widthTotal += col.p;
		}
		
		// X Position of the whole columns group
		var cx = 0;
		if (XPos < 0){
			cx = parea.x + Math.round( (parea.w - widthTotal) / 2);
		}else{
			cx = parea.x + XPos;
		}
		
		// Calculate (X) on all columns
		for (i in 0...cols.length) {
			cols[i].x = cx;
			if (i > 0) cols[i].x += cols[i].p;	// No padding on the first column
			cx = cols[i].x + cols[i].w;
			
			if (!clear) {
				cols[i].ly = ly;	// Continue from where it was before
			}
		}

	}//---------------------------------------------------;
	
	
	/** Place an element 
		P parameters {
			c: column number, 0 for no column, 1 for first column
			ox: offset X
			oy: offset Y
			next: place this element next(right) to the previous one, not below it
			   !! NEXT is a hack, and only works once !!
			a : align in relation to the area space (c,l,r)
	  */
	public function p(EL:FlxSprite, P:Dynamic):FlxSprite
	{
		if (!__p_no_new_obj) P = DataT.copyFields(P, Reflect.copy(_DEF_PLACE));
		
		__p_no_new_obj = false;
		
		EL.scrollFactor.set(0, 0);
		
		if (P.next)
		{
			// Do not adjust last Y or any columns lasty
			if (last == null) return EL;
			EL.x = last.x + last.width + P.ox;
			EL.y = last.y + P.oy;
			last = EL;
			return EL;
		}
		
		var cx = parea.x; // column x 
		var cw = parea.w; // column width
		
		// Position Y Axis
		if (P.c > 0){
			var c = cols[Std.int(P.c - 1)];
			#if debug
				if (c == null) throw "No column data, forgot to init?";
			#end
			cx = c.x;
			cw = c.w;
			EL.y = c.ly + P.oy;
			c.ly = Std.int(EL.y + EL.height);
			ly = c.ly;
		}else{
			EL.y = ly + P.oy;	// it should be right where it needs to
			ly = Std.int(EL.y + EL.height);
			if (cols != null)
				for (i in cols) {
					// Make all columns start from here
					i.ly = ly;
				}
		}
		
		// Position X axis
		switch(P.a) {
			case "c":
				EL.x = cx + ((cw - EL.width) / 2);
			case "r":
				EL.x = cx + cw - EL.width + P.ox;
			case _: // left
				EL.x = cx + P.ox;
		}
		
		last = EL;
		if (PLACE_ADD){
			FlxG.state.add(EL);
		}
		return EL;
	}//---------------------------------------------------;
	
	/**
	   Gets text with D.text.get();
	   If you want to get Formated Text put a ~ at the start of the string. (Just make sure you have called D.text.formatAdd() to add formats)
	   @param	str Starting with ~ will call D.text.getF()
	   @param	P Parameter overrides. Check {_DEF_PLACE}
	   @param	st Text Style
	   @return
	**/
	public function pT(str:String, ?P:Dynamic, ?st:djFlixel.core.Dtext.DTextStyle):FlxText
	{
		var T:FlxText;
		if (str.charAt(0) == "~") {
			T = D.text.getF(str.substr(1), 0, 0, st);
		}else{
			T = D.text.get(str, 0, 0, st);
		}
		
		var O = DataT.copyFields(P, Reflect.copy(_DEF_PLACE));
		
		if (O.ta != "l")
		{
			// fix the width to column
			var cw = parea.w; // column width
			if (O.c > 0) cw = cols[O.c - 1].w;
			T.fieldWidth = cw;
			T.alignment = switch(O.ta) {case "c": "center"; case _: "right"; };
			O.a = "l";	// normal alignent if the textfield is full width
		}
		
		__p_no_new_obj = true;
		p(T, O);	// place it
		return T;	
	}//---------------------------------------------------;
	
	
	/**
	   Place Multiple in one Line using D.align.inLine()
	   @param	ar Array of elements
	   @param	P a:(c,l,r,j) 
	**/
	public function pM(ar:Array<FlxSprite>, col:Int = 0, align:String = 'c', pad:Int = 0)
	{
		// Default no column whole area
		var x = parea.x;
		var y = ly;
		var w = parea.w;
		if (col > 0) {
			var c = cols[col];
			x = c.x;
			y = c.ly;
			w = c.w;
		}
		D.align.inLine(x, y, w, ar, align, pad);
		pPad(Std.int(ar[0].height));	// compensate the ceiling for the new elements
	}//---------------------------------------------------;
	
}// --