package fxdemos.states;

import common.Common;
import djFlixel.FLS;
import djFlixel.gui.FlxMenu;
import djFlixel.gui.menu.PageData;
import flixel.FlxG;
import flixel.FlxState;


/**
 * State selector
 */
class State_Main extends State_Demo
{
	// --
	override public function create():Void
	{
		// Special occasion, no submenu
		flag_main_menu = true;
		
		super.create();
				
		Common.setPixelPerfect();
			
		// --		
		menu = new FlxMenu(P.menu.x, P.menu.y, -1, 10);
		menu.applyMenuStyle(P.menu.style, P.menu.header);
		add(menu);
		
		// -- Create a link for every state with a demo:
		var p:PageData = menu.newPage("main", {title:"FX Demo Selection"});
		
		// NOTE: I don't need SID to be set, I will access the state field later
		p.add("Rainbow Stripes", {type:"link", state:State_RainbowStripes,
			desc:"Object simulating #8bit# computers loading screen."});
			
		p.add("Sprite Effects", {type:"link", state:State_SpriteEffects,
			desc:"Various #Per-pixel# operations on an image."});
			
		p.add("Bouncy Text", {type:"link", state:State_BounceText,
			desc:"Letter by Letter #text animation#."});
			
		p.add("Box Scroller", {type:"link", state:State_BoxScroller,
			desc:"#Infinite scroller# in a box area."});
			
		p.add("StarField", {type:"link", state:State_Starfield,
			desc:"A simple starfield. #Shimmering stars#, customizable #colors#, #angle# and #speed#."});
			
		p.add("Static Noise", {type:"link", state:State_StaticNoise,
			desc:"A basic customizable static noise box"});
			
		p.add("Box Fader", {type:"link", state:State_BoxFader,
			desc:"A box sprite that #fades with hardsteps#. Supports flash filters."});	
			
		p.add("Stripes Transition", {type:"link", state:State_StripesTransition,
			desc:"Fullscreen screen #animated stripes#. Useful for transitions."});
			
		p.add("Filter Fader", {type:"link", state:State_FilterFader,
			desc:"Fades the camera #on and off# using realtime bitmapfilters."});

		#if (MEGADEMO)
			p.addBack();
		#end
		
		// --
		menu.callbacks = function(a, b, c)
		{
			// Menu item comes with a state, go to it
			if (a == "fire" && c.data.state != null)
			{
				FlxG.switchState(Type.createInstance(c.data.state, []));
			}
			
			else if (a == "focus") {
				INFO.setText("$" + c.label + "$\n" + c.description);
			}
			
			if (a == "rootback") EXIT();
			
			Common.handleMenuSounds(a);
		}// --
		
		// --
		menu.open("main");
	}//---------------------------------------------------;
	
	// --
	override function EXIT()
	{
		#if (MEGADEMO)
			Common.GOTO_MEGADEMO();
		#end
	}//---------------------------------------------------;
	
}// --