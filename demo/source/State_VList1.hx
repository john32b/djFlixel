/** Basic example on how to make a custom VListItem
 */

package;

import common.InfoBox;
import djA.DataT;
import djFlixel.D;
import djFlixel.core.Dcontrols.DButton;
import djFlixel.core.Dtext.DTextStyle;
import djFlixel.gfx.pal.Pal_DB32;
import djFlixel.ui.FlxToast;
import djFlixel.ui.IListItem;
import djFlixel.ui.VList;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import djFlixel.other.DelayCall;

/**
   This SpriteGroup will go inside a VLIST
   - Here is an example of a simple box containing two text objects
   - for "Achievement Title" and "Achievement Detail"
   - Must implement IListItem, to know when it is being focused,
     and what to do withthe data it gets
**/
class MyListItem extends FlxSpriteGroup implements IListItem<String>
{
	inline static var WIDTH:Int = 220;
	inline static var HEIGHT:Int = 32;
	inline static var color_0 = 0xFF3a4466;
	inline static var color_1 = 0xFFff0044;
	
	// Text Styles
	var STInfo0:DTextStyle = {
		c:0xFF9badb7,
		bc:0xff323c39
	}
	var STInfo1:DTextStyle = {
		c:0xFFfbf236,
		bc:0xff323c39
	}
	
	var bg:FlxSprite;
	var title:FlxText;
	var info:FlxText;
	var data:String;
	
	public var isFocused(default, null):Bool = false;
	public var callback:ListItemEvent->Void;
	
	// For the constructor, just adding the items
	public function new()
	{
		super();
		
		bg = new FlxSprite(0, 0);
		bg.makeGraphic(WIDTH, HEIGHT, 0xFFFFFFFF);
		add(bg);
			// ^ Note: I am going to colorize this with a color transform later
			// so having a non-unique bitmap that is shared between these elements works.
		
		title = D.text.get('', 2, 2, {
			c:0xFFeec39a,
			bc:0xff45283c,
			bt:2,bs:1
		});
		add(title);
		
		// Using the D.align helper to place it right under the title
		info = D.text.get('', STInfo0);
		add(D.align.down(info, title));

	}
	
	// Update the Item Visual state whether it is Focus/Unfocused
	function visual_refresh()
	{
		if (isFocused){
			bg.color = color_1;
			D.text.applyStyle(info, STInfo1);
		}else {
			bg.color = color_0;
			D.text.applyStyle(info, STInfo0);
		}
	}
	
	// Data is in this format "Title:Description"
	public function setData(_data:String):Void
	{
		data = _data;
		var a = _data.split(":");
		title.text = "== " + a[0];
		info.text = "" + a[1];
		visual_refresh();
	}
	
	// Handle User Input {fire, left, right, click(x,y);
	public function onInput(_type:ListItemInput):Void
	{
		if (_type == fire) {
			callback(fire);
		}
	}
	
	public function focus():Void
	{
		callback(ListItemEvent.focus);
		isFocused = true;
		visual_refresh();
	}
	
	public function unfocus():Void
	{
		isFocused = false;
		visual_refresh();
	}
	
	public function isSame(_data:String):Bool 
	{
		return data == _data;
	}
}//---------------------------------------------------;



class State_VList1 extends FlxState
{
	override public function create():Void
	{
		super.create();
		
		camera.bgColor = 0xFF181425;

		/**
		   The VLIST I am going to create will simulate displaying achievements
		   This is some fake Achievements to feed to the list (Borrowed from N++)
		   This is a custom format, where I am separating two values into one string
		   divided with the ":" character. Format is "Title:Description"
		**/
		var data = [
			"More Practice Makes More Perfect:Die 1000 times.",
			"Perseverance:Triumph over adversity.",
			"Death from All of the Above:Die in every possible way.",
			"Using your Head:Die by hitting the ceiling too hard.",
			"Tutorial Master:Get all the gold in the Solo Introduction.",
			"Novice:Beat the entire top row of Solo Episodes.",
			"Adept:Beat the entire middle row of Solo Episodes."
		];

		// New Vertical List . pos (32,32) width (100) slots (4)
		var list = new VList<MyListItem,String>(MyListItem, 32, 32, 100, 4);

		list.setInputMode(2);	// 2 Means allow selecting individual elements
								// 1 Means only allow scrolling up and down
								
		// Adjust the default style a bit
		// NOTE : By default VList grabs a pointer to the Default Global VList Style
		//        If I am to make changes, I'd better create a unique copy first
		//		  Else I will be modifying the shared global style :-/
		list.STL = DataT.copyDeep(list.STL);
		list.STL.focus_nudge = 1;
		list.STL.item_pad = 3;
		
		// You can check to see whether an item was triggered here
		// Currently only `fire` events can emmit here
		list.onItemEvent = (a, b)-> {
			trace("Item Event", a, b);
		}
		// List events are not exciting. Just four options
		list.onListEvent = (e)->{
			trace("List Event" , e);
		}
		
		// This is where you fill the VList with data
		// It will actually create the sprites here
		// It must be called after setting the styles and setting all parameters
		list.setDataSource(data);
		
		// Once I give data to the list, the elements are created
		// so it gets valid width/height values. That's when I align it
		D.align.screen(list, "c", "t", 18);
		add(list);
		
		// The VList is created, but it is sitting around doing nothing
		// You must give it focus to be interactible
		list.focus();
		
		// ------------------------------------------------------------
		
		var str = 
		"$VList$ is a generic Vertical Scrollable list, FlxMenu is based on this. " +
		"You can use a VList to create simple lists with custom user items, like in this example an achievement showcase. " +
		"Press #[ESC]# to return";
		
		var box = new InfoBox(str, {
			width:290, colBG:0xf0f0f0, text:{c:0xff535359, bc:0xffcbdbfc}});
		add(D.align.screen(box, "c", "b", 12 ));
		new DelayCall(0.5, box.open.bind());
		
		// -- Init FlxToast because the style could be altered from another state
		new DelayCall(1, ()->{ 
			FlxToast.FIRE("Press Esc to Exit", {screen:"top:right", bg:0xFFAAAAAA});
		});
		
	}//---------------------------------------------------;
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (D.ctrl.justPressed(DButton.B) || FlxG.keys.justPressed.ESCAPE)
		{
			Main.goto_state(State_Menu, "8bit");
		}
	}//---------------------------------------------------;
	
}// --