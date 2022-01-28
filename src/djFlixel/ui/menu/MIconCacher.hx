package djFlixel.ui.menu;

import djFlixel.ui.menu.MItem;
import flash.display.BitmapData;

/**
 * Helper class for MITEMS
 * - Cache Generated Bitmaps (colorized + shadow applied)
 * - this is so the program doesn't generate new colored icons every time they are needed
 */
class MIconCacher 
{
	static inline var COLOR_KEY = 0xFFFFFFFF;
	
	var cache:Map<IconCombo,BitmapData>;
	var st:MItemStyle;
	
	public function new(STYLE:MItemStyle) 
	{
		clear();
		st = STYLE;
	}//---------------------------------------------------;
	
	public function clear()
	{
		if (cache != null) 
		for (i in cache) {
			i.dispose();
		}
		cache = [];
	}//---------------------------------------------------;
	
	/**
	   Get from cache, and if doen't exist, Creates it
	   Applies COLOR and BORDER to a white bitmapdata
	   @param	bd The original bitmap to colorize
	   @param	f A field of `StateColors` [idle,focus,accent,dis,dis_f] 
	**/
	public function get(src:BitmapData, f:String):BitmapData
	{
		if (cache.exists(combo(src, f))){
			return cache.get(combo(src, f));
		}
		// Create it
		var b:BitmapData = src.clone();
		if (st.bm_no_col != null) return b;
		
		if (Reflect.hasField(st.col_t, f)) {
			D.bmu.replaceColor(b, COLOR_KEY, Reflect.field(st.col_t, f));
		}
		if (Reflect.hasField(st.col_b, f)) {
			var ox = 1; var oy = 1;
			var s = st.text.bs == null?1:st.text.bs;
			if (st.text.so != null) {
				ox = st.text.so[0];
				oy = st.text.so[1];
			}
			b = D.bmu.applyShadow(b, Reflect.field(st.col_b, f), ox * s, oy * s);
		}
		cache.set(combo(src, f), b);
		return b;
	}//---------------------------------------------------;
		
}// --

// --
private enum IconCombo {
	combo(a:BitmapData, b:String); // Bitmap data , state type (focus,access,idle...)
}
