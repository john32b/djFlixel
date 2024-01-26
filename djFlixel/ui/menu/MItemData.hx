/**
 
 MenuItemData
 
	- Menu Items are the elements that build up a page of an FlxMenu
	- MItemData is the data that the actual Menu Item Sprites will read from
	- MItemData always exist inside a <MPageData>
	- MitemData are usually created from an <MPage>
	
==== The string format for making a MenuItem
	
	> "Label | Type | ID | .. | .. " 
	
	- Text separated with |
	- The first three fields are MANDATORY and are required for ALL TYPES 
	- Label is the Text of the MenuItem that will be displayed
	- Type is one of <MItemType> enum name as a string e.g | range |
		For what each <MItemType> does, read further below
	- ID is the unique identifier, Callbacks will come with this, so put a good name you can identify
	- Spaces at the edges of fields are trimmed. so `|  c=1  |` is the same as `|c=1|`
		HOWEVER: Spaces between the inner strings are not trimmed so `| c = 1 |` is NOT `|c=1|`
	- Some fields require the format of "KEY=VALUE", DONT put spaces between "KEY = VALUE"
	- Some types like {range} and {list} require one more mandatory field, more later
	- The {label} type is the only type that doesn't require an ID to be set. so "Hello world|label" is valid
	
	- There are some standard field options that can go to any field, these are:
	
*new*	|AF| AutoFocus. Will make the item focused by default when the page opens
		|D|	Put it after the mandatory fields. Will DISABLE the element
		|U| Put it after the mandatory fields. Will make the item UNSELECTABLE (useful for labels)
		|I=Some Text|  Writes custom text in the .info field of the object. It can be used later however you want
		
==== Menu Item Types:
	
	>> {link}
		A clickable link. Links can navigate to other menu pages, or callback to user.
		> Important Note about links ID
		> If you prefix a linkID with the @ symbol, it means "goto that menupageID"
		> it is handled internally and is really useful to navigate multi-paged menus"
		e.g.
			" Options | link |@options " 
			This link when selected will tell FlxMenu to go to the MPage with ID "options"
		> Another special ID string is the word "@back" which will make the FLXmenu 
		  navigate to the previous page in history
		  
		- In short for ID setting : "@back" and "@MenuPageID"
		- Otherwise you can set a normal id like "id_ng" and it will callback to user
		  
		- Additionaly {link} has a Confirmation functionality which presents the user
		  with a question in a popup or a new menu before triggering an action
		  
		- You can enable a Confirmation to a link by setting the optional field like this:
		  `| ?fs=Are you sure?:Yes:No |`
		  `| ?pop=Sure?:Yes:No |`
		  
		  Notice it is one string with = and : used as a separators `?askid=QUESTION:YES:NO`
		  `?fs` means that the question will be presented as a new menu page (autogenerated)
		  `?pop` will open a small popup over the item and ask (good for short things)
		  
		  - You can *skip the question* by entering an empty string , like so
			`?pop=:Yes:No` , notice the `=:`
				 
		  - *Supports* `\n` newlines in the ASK string, and it will generate multiple labels
				e.g. `?fs=First Line\nSecond Line?:yes:no`
				> will produce two labels for the question. 
				> This is for cases where the question does not fit the screen
				 
		examples >>>>>>>>>>>>>>>>>>>>
		
		"New Game | link | ng "		; simple new game, will callback to user with id`ng`
		"New Game+ | link | ng+ |D" ; Don't forget. D makes elements Disabled by default.
									  you can enable them with a function call later on
		"Delete Save|link|delsave|?fg=You are about to delete the saves. Are you sure?:Yes:No!!"
			^ this will callback to user with id (delsave) but first will present
			  a fullscreen confirmation dialog with a question. If Yes, will actually callback
		
		"Options| link |@options|I=Go to the options page"
			^ Notice the "I=text". That text is stored in the menuitem datatype
			  as of now, you have to manually do something to read it and present it
			  e.g. have a onMenuChange listener and for every item highlighted write
			  the info to a textbox.
			  
		"Back|link|@back"	; Simple, if this is a nested page. Go back to the previous page
							; e.g. From options menu Page, back to the main menu

		-------------------------------------------------------------
									  
	>> {range}
		A number selection, from N0 to N1, taking steps of S 
		The numbers and steps can also be floats 
		This has a 4th MANDATORY field in the string and it is the range of numbers
		Declare it as such : | 0,10 |  , which is  | min,max | values of the range
		The items are separated with , and there is whitespace between them
		Optional Fields are
		
		|c=n|	Where n is the currently selected number. It must be between min and max
				Default is 0
		|loop=true| If set it will loop through the edges of the list instead of stopping
					default is false, not looping
		|step=n|	Set a custom step for changing the value. It can be INT or FLOAT
		
		|fstep=n|	First Step. When the list is at the beginning, apply N as a first step
					instead of `step` This is useful for making a (1-100)(fstep=4) range with
					the selection iterating (1..5..10..15..) e.g. for making a level select 
					
		
		examples >>>>>>>>>>>>>>>>>>>>
		
		"Volume | range | id1| 0,100 | c=50 | step=5" 	; 0 to 100, default is 50 and 
														; steps increment/decrement by 5
														
		"Brightness | range | id2| 0.0,1.0 | c=0.5 | step=0.02" ; Having the step as a float
					
		-------------------------------------------------------------
		
	>> {list}
		A list of items where you can select one
		This has a 4th MANDATORY field in the string and it is the list of items
		Declare it as such : | item1,item2,item3,item4 |
		The items are separated with , and there is whitespace between them
		Optional Fields are
		|c=n| 	where n is the index of the item in the list. This item will be selected
				default value is 0, the first item will be selected
		|loop=true| If set it will loop through the edges of the list instead of stopping
					default is false, not looping
		
		examples >>>>>>>>>>>>>>>>>>>>
		
		"Color |list|id1| red,green,blue"	; List with 3 elements, red is selected by default
		"Difficulty |list|id2| easy,medium,hard | c=1 | loop=true" ; Select 'medium' by default, loop at edges
		
		-------------------------------------------------------------
		
	>> {toggle}
		A check box. Can be on or off.
		
		By default this is turned off
		You can set the starting state of this using | c=true |
		Get the current state with {MItemData.P.c}
		
		examples >>>>>>>>>>>>>>>>>>>>
		
		"Toggle Music |  toggle  | id_tog_mus"
		"Fullscreen   |  toggle  | id_fs | c=true"   ; starts off as enabled
		"Fullscreen   |  toggle  | id_fs |D| c=true" ; starts off as enabled but it disabled as an element
	
		-------------------------------------------------------------
		
	>> {label}
		Creates a text element on the menu that is not selectable. Cursor will jump past it
		- the `ID` field is *optional*
		examples >>>>>>>>>>>>>>>>>>>>
		
		"Advanced Options | label " 			; Note that I didn't put an ID
		"Advanced Options | label | id_lbl " 	; But if you want, you can declare one
		"Advanced Options | label | id_lbl |U"  ; Make this label Unselectable. The Cursor will JUMP over it
		-------------------------------------------------------------
		
=== For more usage examples, check <MPageData.hx> and <FlxMenu.hx>
	
***********************************************************************/
package djFlixel.ui.menu;

import haxe.Exception;
import haxe.EnumTools;

enum MItemType {
  link;
  range;
  list;
  toggle;
  label;
}

class MItemData 
{
	// ID string of the item. Should be unique between items in the MPage
	public var ID:String;
	
	// Label text of the menu item, This is the full text, not the rendered one.
	public var label:String;
	
	// Optional Text e.g. for when you hover over an element
	// , this is not automatic, you must do the appearance of such infos manually
	public var info:String;
	
	// If this is false, then this item can't be selected
	public var selectable:Bool = true;
	
	// A disabled element can't have interactions, but it can be highlighted
	public var disabled:Bool = false;

	// What functionality this MenuItem has
	public var type(default, null):MItemType = null;
	
	
	/**
	   - P for Parameters -
	   Possible Fields for {P} depending on {type}
	   These are all autogenerated upon creation
	   Some values change in realtime, like {.c} which is the current value for some types
	   
		.c			;	Current Value. Is INDEX for {range}{list} and Boolean for {toggle}
		.step		;	Increment Step in {range} and {list}
		.loop		;	in {range} and {list} does it loop at the edges
		.list		;	Array<String> holds all the elements for {list}
		.range		;	Array<Float>[2]	[from,to] Holds the range for {range}
		
		
		.link		;	The action id a {link} performs when it is fired (clicked on)
		.ltype		;	Int Link type for {link} One of the following 
						0:PageCall, 1:Call, 2:Call-AskPopUp, 3:Call-AskFullScreen
						
		.ask		;	Array<String> The question to ask in {linK} if .ltype==2,3 
						e.g. ["Are you sure?","Yes","No"] valid for {links}
						
		.autofocus  ;   Boolean. If this is set. This item gets focused by default
						
	   
	**/
	public var P:Dynamic = {};
	
	
	/**
	   Creates a new Item Data from an encoded String
		Encoded String Example: "New Game | link | ng+ | optionA | optionB "
	   @param	str Encoded String. Check <MItemData.hx> header comments for more info on formatting
	**/
	public function new(str:String) 
	{
		try { parse(str); }
		catch(e:String) {
			var m = 'Error Parsing line\n"${str}"\n::${e}';
			throw new Exception(m);
		}
	}//---------------------------------------------------;
	
	// @throws <string> errors
	function parse(S:String)
	{
		/* DEVNOTE:
			- The string should be in this format 
				LABEL | TYPE | ID | <optional A> | <optional B>
			- The string may end with a `|` it will be ignored
			- The first two fields are mandatory (label does not need the third ID field)
		 */

		var F = S.split('|').map((i)->StringTools.trim(i));

		if(F.length<2) throw "Insufficient fields";

		// Allowing empty Labels, I am just going to warn
		label = F.shift();
		if(label=="") trace('Warning: Empty label for "${S}"');

		try{
			type = EnumTools.createByName(MItemType, F.shift());
		} catch (_)
			throw 'Undefined TYPE, typo?';
		
		ID = F.shift();
		if ( (ID == null || ID == "") && type != MItemType.label )
			throw 'No ID defined';
		
		// Processes all optional fields one by one in a custom function
		// func(key,value)
		function feed(fn:String->String->Void)
		{
			for (i in F)
			{
				// Handle strings ending with an |
				if(i=="") continue;

				// Check for universal options first ::

				// |AF| , for autofocusing
				if (i == "AF") {
					P.autofocus = true;
					continue;
				}
				
				// |D| , for Disabling the item
				if (i == "D") {
					disabled = true;
					continue;
				}
				
				// |U| , for making it Unselectable
				if (i == "U"){
					selectable = false;
					continue;
				}
				
				// All other Fields must be in this format "KEY=VALUE"
				var KV = i.split('=');
				if (KV.length != 2){
					throw 'Illegal Parameter for "${i}"';
				}
				
				// |I=Information Text| for attaching some text to the item
				if (KV[0] == "I") {
					info = KV[1];
					continue;
				}

				// Pass everything else to type specific code
				fn(KV[0], KV[1]);
			}
			
		}//---------------;
		
		switch (type)
		{
			case link:
				
				if (ID.charAt(0) == "@") {
					P.link = ID.substr(1);
					P.ltype = 0;	// pagecall type
				}else{
					P.link = ID;	// Normal call, will callback to user
					P.ltype = 1;	// Normal call
				}
				
				feed((k, v)->{
				if (k.charAt(0) == "?") {
					k = k.substr(1);
					if (k == "pop") P.ltype = 2; else
					if (k == "fs") P.ltype = 3;
					P.ask = v.split(":");
					if (P.ask.length != 3) 
					  throw 'Improper Ask Format';
				}
				});
				
				
			case range:
				if (F[0] == null) throw 'Must define a Range';
				var _n = F.shift().split(',');
				P.c = 0.0;	// I need it to be Float so I can increment with a float later
				P.step = 1;
				P.loop = false;
				P.range = [
					Std.parseFloat(_n[0]),
					Std.parseFloat(_n[1]),
				];
				feed((k,v)->{
					if (k == "c") P.c = Std.parseFloat(v);
					if (k == "step") P.step = Std.parseFloat(v);
					if (k == "loop") P.loop = (v == "true");
					if (k == "fstep") P.fstep = Std.parseInt(v);
				});
				
				if ( cast(P.c, Float) < cast(P.range[0], Float)) {
					trace("Warning. Range default off range");
					P.c = P.range[0];
				}
				
			case list:
				if (F[0] == null) throw 'Must define a List';
				P.c = 0;
				P.loop = false;
				P.list = F.shift().split(',');
				feed((k,v)->{
					if (k == "c") P.c = Std.parseInt(v);
					if (k == "loop") P.loop = (v == "true");
				});
				
			case toggle:
				P.c = false;
				feed((k, v)->{
					if (k == "c") P.c = (v == "true");
				});
				
			default:
				feed((k,v)->{});
		}
		
	}//---------------------------------------------------;
	
	
	/** Get the major element data according to type
	    e.g. index for lists, value for ranges, linkdata for links */
	public function get():Any
	{
		return switch(type){
			case list  : P.list[P.c];
			case link  : P.link;
			case toggle: P.c;
			case range : P.c;
			default: 0;
		}
	}//---------------------------------------------------;
	
	/** In some cases you may want to change the current data of an item
	 *  like in FlxMenu.item_update(..) */
	public function set(d:Any)
	{
		switch (type){
			case list | toggle | range : P.c = d;
			case link : P.link = d;
			default:
		}
	}//---------------------------------------------------;
		
	/** Human Readable, for logging/debugging **/
	public function toString():String
	{
		return 'ID:$ID | Label:$label | Type:$type | Data:$P';
	}//---------------------------------------------------;

	/* BASIC encoded string of the item. Used for checking for changes */
	public function toStr2():String
	{
		// DEV: no type, since it would never change
		// no info, it is not crucial
		var s = ID+label+selectable+disabled;
		for (f in Reflect.fields(this.P))
			s += ':' + Reflect.getProperty(this.P, f);
		return s;
	}// -------------------------;

}// --


