/************************************************************
 * UI Helper
 * 
 * ICONS : 
 * 	- Available sizes 8,12,16,24
 *  - Atlas ID = "ic.8","ic.12' .....
 *  - Available INDEXES = 0..22
 * 
 * 
 * PANEL:
 * 	- get with D.ui.atlas.get_bn('panel')
 * 
 * BUTTON:
 * 	- get with D.ui.atlas.get_bn('btn') // returns 3 tiles 24x24 
 * 
 *********************************************************/

package djFlixel.core;

import djfl.util.Atlas;
import flash.display.BitmapData;
import flash.filters.BitmapFilterType;


@:dce
class Dui 
{
	// The default UI Atlas in 'djflixel/assets' 
	static inline var UI_ATLAS = "assets/ui_atlas.png";
	
	// - Icon Indexes
	public static var ICON_INDEX(default, null) = [
		"ar_left", "ar_right", "ar_up", "ar_down",
		"ch_off", "ch_on", "dot", "cross",
		"reset", "left", "right", "exit",
		"params", "o", "x", "v", "X",
		"home", "options", "heart",
		"star", "minus", "plus"
		];

	// Manage and handle loading atlas, and getting bitmapdata portions from it
	public var atlas(default, null):Atlas;
	
	public function new() 
	{
		loadUIAtlas(UI_ATLAS);
	}//---------------------------------------------------;
	
	/**
	   You can load your own UI Atlas.
	**/
	public function loadUIAtlas(s:String)
	{
		if (atlas != null) {
			atlas.pixels.dispose(); // I don't know if this is needed?
		}
		atlas = new Atlas(s);
		
		atlas.dtile('panel', 0, 112, 24, 24);
		atlas.darea('btn', 0, 80, 24, 24, 0, 0, 3);	
	}//---------------------------------------------------;
	
	/**
	   To Save Memory, You can Initialize just the icon sizes
	   that you intend to use
	   @param	sizes Valid: 8,12,16,24
	**/
	public function initIcons(sizes:Array<Int>)
	{
		for (size in sizes)
		switch(size) {
			case 8:
				atlas.darea("ic8", 0, 0, 8, 8, 0, 0, 4, 6);
			case 12:
				atlas.darea("ic12", 32, 0, 12, 12, 0, 0, 4, 6);
			case 16:
				atlas.darea("ic16", 80, 0, 16, 16, 0, 0, 4, 6);
			case 24:
				atlas.darea("ic24", 144, 0, 24, 24, 0, 0, 4, 6);
			default:
				 throw "Unsupported Size";
		}
	}//---------------------------------------------------;
	
	/**
	   Get icon bitmap data. (Default icons are white with transparent background)
	   -- Make sure you have initialized the icons first with initIcons() --
	   @param	size 8,12,16,24
	   @param	icName Icon Name as defined in 'ICON_INDEX' Array
	   @param	index 0-22 Set Either this or name
	   @return
	**/
	public function getIcon(size:Int, ?icName:String, index:Int =-1):BitmapData
	{
		if (icName != null) {
			index = ICON_INDEX.indexOf(icName);
			#if debug
			if (index ==-1) {
				index = 0;
				trace("ERROR: INDEX WRONG, check for typos");
			}
			#end
		}
		
		return atlas.get_bn('ic$size', index);
	}//---------------------------------------------------;
	

}// --