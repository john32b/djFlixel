/**
	Menu State
	===================
	
	- This is the main menu state
	- FLXMenu practical example
	
*******************************************/
 
package ;
import djA.DataT;
import djFlixel.D;
import djFlixel.gfx.FilterFader;
import djFlixel.gfx.SpriteEffects;
import djFlixel.gfx.pal.Pal_DB32 as DB32; // Cool Haxe Feature
import djFlixel.other.DelayCall;
import djFlixel.other.FlxSequencer;
import djFlixel.ui.FlxMenu;
import djFlixel.ui.FlxToast;
import djFlixel.ui.MPlug_Header;
import djFlixel.ui.UIButton;
import djFlixel.ui.menu.MPageData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.FlxAssets;
import flixel.text.FlxText;


class State_Menu extends FlxState
{
	// I want to keep the text that says "Arrows .. K to select ..." 
	// so I can change its color
	var keystext:FlxText;
	
	override public function create() 
	{
		super.create();
		
		// -- Nice animated BG
		Main.bg_scroller(4, [0xff45283c, 0xff76428a ] );
		
		// -- The Menu
		var m = create_get_menu();
		add(m);
		m.goto('main');	// Will goto that page and open the menu
		
		
		// -- Black strip
		var bg1 = new FlxSprite();
			bg1.makeGraphic(FlxG.width, 18, 0xFF000000);
			add(D.align.screen(bg1, '' , 'b')); // '' to leave it alone in the X axis
		
			
		// text.fix(style), makes all following text.get(..) calls to apply a specific style
		// useful if you want to create a style on the fly and use it multiple times
		// Check the typedef for the style object in <Dtext.h>
 		D.text.fix({c:DB32.COL[21], bc:DB32.COL[1], bt:2});
		var t1 = D.text.get('DJFLIXEL ${D.DJFLX_VER} by John32B');
			add(D.align.screen(t1, 'l', 'b', 2)); // Add and Align to screen in one call
			
			
		// Note that I can overlay a style here. This will use the fixed style and
		// also apply a new color
		var t2 = D.text.get('Music "DvD - Deep Horizons"', {c:DB32.COL[22]});
			add(D.align.screen(t2, 'r', 'b', 2 ));
		
		// Unfix the text style. text.get() will now return unstyled text
		D.text.fix();
		
		// --
		keystext= D.text.get('Mouse / [ARROWS] move / [K] select / [J] cancel', {bc:0xff45283c, c:0xff76428a, bt:2});
		add(D.align.up(keystext, bg1));
		
		// --
		// Apply an effect to the title
		var title = D.text.get('djFlixel ${D.DJFLX_VER}', {
				f:"fnt/blocktopia.ttf",
				s:32,
				c:DB32.COL[8],
				bc:DB32.COL[5],
				bs:2 });
				
		// DEV: title.pixels are small in size, because the scaling is done after
		//      to get a big bitmap with the text, I need to stamp
		
		var b2 = new FlxSprite();
		b2.makeGraphic(cast title.width,cast title.height, 0x00000000, true);
		b2.stamp(title);

		var fx1 = new SpriteEffects(b2.pixels);
		fx1.addEffect("wave", {width:3, height:1.8, time : 2, loopDelay:0});
		add(D.align.up(fx1, m.mpActive, 0, -8));	// Place above the menu, 8 more to the top
		
		// --
		D.snd.playV('fx2');
		
		// -- Add some mouse clickable icons
		
		var ic1 = new UIButton(
			D.bmu.getBitmapSquare(FlxAssets.getBitmapData('im/icons.png'), 0, 0, 24, 24));
		var ic2 = new UIButton(
			D.bmu.getBitmapSquare(FlxAssets.getBitmapData('im/icons.png'), 48, 0, 24, 24),
			{bmc:false});
			
		add(D.align.screen(ic1, "r", "b", 8));
		ic1.y -= 14;
		add(D.align.left(ic2, ic1, -2));
		
		ic1.setHover("Github");
		ic1.onPress = (_)->{
			FlxG.openURL('https://github.com/john32b/djFlixel');
		};
		
		ic2.setHover("HaxeFlixel");
		ic2.onPress = (_)->{
			FlxG.openURL('https://haxeflixel.com/');
		};
		
		// --
		new DelayCall(1, () -> {
			FlxToast.FIRE("Hello $:-)$", {screen:"top:right"});
		});
	}//---------------------------------------------------;
	
	
	
	function create_get_menu()
	{
		// -- Create
		var m = new FlxMenu(32, 72);
		
		// This makes the [Start/Enter] key fire on menu items
		// Else if will be handled and pushed as "start" event 
		// (e.g. when you want to close the menu when you press START button)
		m.PAR.start_button_fire = true;
		
		// -- Create some pages	
		// Note: Haxe supports multiline strings, this is OK:
		m.createPage('main').add('
			-|FlxMenu Demo		|link|st_menu
			-|FlxAutotext Demo	|link|st_autot
			-|Other				|link|@other
			-|Options			|link|@options
			-|Reset				|link|rst| ?pop=:YES:NO ');
			 
		m.createPage('options', 'Options').add('
			-|Fullscreen	|toggle|fs
			-|Smoothing		|toggle|sm
			-|Volume		|range|vol| 0,100 | step=5'+
			#if(desktop) // preprocessors don't work inside a string
			'-|Windowed Mode	|range|winmode|1,${D.MAX_WINDOW_ZOOM}' + 
			#end
			'-|Change Background	|link|bgcol
			 -|Back			| link | @back');
			 
		m.createPage('other').add('
			-|FlxSlides	| link | st_slides
			-|Back | link |@back ');
			 
		// -- Styling
		// STP is the object that holds STYLE data for the Menu Pages
		// Every FlxMenu comes with a predefined default
		// Here I am overriding some fields.
		// I could also use overlayStyle();
		m.STP.item.text = {
			f:"fnt/blocktopia.ttf",
			s:16,
			bt:1, 		// Border Type 1:Shadow
			so:[1, 1]	// Shadow Offset (1,1) pixels
		};
		
		// Text Color
		m.STP.item.col_t = {
			idle:DB32.COL[21],
			focus:DB32.COL[28],
			accent:DB32.COL[29],
			dis:DB32.COL[25],		// Disabled
			dis_f:DB32.COL[23], 	// Disabled focused
		};
		
		// Border Color
		m.STP.item.col_b = {
			idle:DB32.COL[1],
			focus:DB32.COL[0]
		};
		
		// Set a dark background for the menu pages
		m.STP.background = 0xFF121212;
		
		
		/** Handle Page Events, keep track when I am going in and out of pages 
		 * (MenuEvent->PageID) */
		m.onMenuEvent = (ev, id)->{
			// This is just to produce sounds depending on the type of event
			Main.handle_menu_sound(ev);
			
			// Just went to the options page
			// I want to alter the Item Datas to reflect the current settings
			if (ev == page && id == "options") {
				// (2) , is the index starting from 0, I could pass the ID to get the item also
				m.item_update(0, (t)->t.set(FlxG.fullscreen) );
				m.item_update(1, (t)->t.set(D.SMOOTHING) );
				m.item_update(2, (t)->t.set(Std.int(FlxG.sound.volume * 100)) );	
			}
			
		};//-----

		
		/** Handle Item events. When you interact with items they will fire here
		 * (ItemEvent->Item) */
		m.onItemEvent = (ev, item)->{
			
			// This is just to produce sounds depending on the type of event
			Main.handle_menu_sound(ev);
			
			// -
			if (ev == fire) switch (item.ID) {
				case "fs":
					FlxG.fullscreen = item.get();
					
				case "sm":
					D.SMOOTHING = item.get();
					
				case "vol":
					FlxG.sound.volume = cast(item.get(), Float) / 100;
					
				case "rst":
					Main.goto_state(State_Logos);
					
				case "bgcol":
					scroller_change();
					
				case "winmode":
					D.setWindowed(item.get());
					m.item_update(0, (t)->{t.P.c = FlxG.fullscreen; });

				case "st_slides": 
					Main.goto_state(State_Slides);
				
				case "st_autot":	 
					m.unfocus();
					new FilterFader( Main.goto_state.bind(State_Autotext) );
					
				case "st_menu": 
					m.unfocus();
					new FilterFader( Main.goto_state.bind(menu1.State_Menu1) );
					
				case _:
			};
			
		};//-----
		
		return m;
	}//---------------------------------------------------;
	
	
	// Scroller ID, used to select asset for the background
	// Helper for background scroller. Loops through 1-6
	var bgInd = 0;

	// <gfx.Pal.PAL_DB32> color indexes 
	// Random colors for the background scroller
	var BGCOLS = [
		[1,2],
		[24,25],
		[14,16],
		[3,12],
		[14,25],
		[16,15],
		[10,12],
		[2,26]
	];
	
	/**
	 * Change the background graphic/colors
	 * Also changes the keytext colors
	 **/
	function scroller_change()
	{
		var C = DataT.arrayRandom(BGCOLS).copy();
		// C has indexes, convert to real colors
		C[0] = DB32.COL[C[0]];
		C[1] = DB32.COL[C[1]];
		D.text.applyStyle(keystext, {c:C[1], bc:C[0], bt:2});
		if (++bgInd > 6) bgInd = 1;	// 1 to 6
		
		Main.bg_scroller(bgInd, C);
	}//---------------------------------------------------;
	
}// --