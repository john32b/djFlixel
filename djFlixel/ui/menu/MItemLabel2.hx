/**
 * TWO part label
 * 
 *  [label]   -pad-   [text]
 * 
 */

 
package djFlixel.ui.menu;
import djFlixel.ui.IListItem.ListItemInput;
import djFlixel.ui.menu.MItem.FocusState;
import flixel.text.FlxText;

class MItemLabel2 extends MItem
{
	
	var part2:FlxText;
	
	public function new(MP:MPage) 
	{
		super(MP);
		part2 = new FlxText();
		part2.wordWrap = false;
		add(part2);
	}//---------------------------------------------------;
	// --
	override function on_newdata() 
	{
		super.on_newdata();
		part2.text = data.data.text;
		part2.x = label.x + label.width + mp.styleIt.part2_pad;
	}//---------------------------------------------------;
	
	// --
	override function handleInput(inp:ListItemInput) 
	{
		switch(inp) {
			case click(_) | fire:
				callback(fire);
			case _:
		}
	}//---------------------------------------------------;
	
	override function state_set(id:FocusState) 
	{
		//_ctext('accent'); // Force this color
		_ctext(id.getName());
		
		if (id == idle)
			_ctext('accent', part2);
		else
			_ctext(id.getName(), part2);
		
	}//---------------------------------------------------;
	
}// --