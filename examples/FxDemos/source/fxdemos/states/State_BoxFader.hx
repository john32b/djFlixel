package fxdemos.states;
import djFlixel.fx.BoxFader;
import djFlixel.gfx.GfxTool;
import djFlixel.gui.menu.PageData;
import flixel.FlxG;
import djFlixel.gfx.Palette_DB32 as DB32;


/**
 * `BoxFader` Use Example
 * A Simple Colored Box that fades in and out by changing the alpha through hard steps.
 * You can put it in front of other things to produce some visual effects
 */
class State_BoxFader extends State_Demo 
{
	// --
	var b:BoxFader;
	
	// --
	override public function create():Void 
	{
		flag_hide_msg = true;
		
		super.create();
		
		// -- 
		addDecoAndText("A sprite that fades with hardsteps. Variable sized, supports flash filters.");
		
		// -- Object
		b = new BoxFader(0, 0, 128, 128);
		group.add(b);
				
		// --
		var p = new PageData({initFire:true, title:"Box Fader"});
		
		p.add("Time to complete", {type:"slider", sid:"time", pool:[1, 5],
			desc:"#Time# to complete the fade in seconds." });
		
		p.add("Color", {sid:"color", type:"slider", pool:[0, 31],
			desc:"Select a color index from the #DB32# palette."});
		
		p.add("Blend", {sid:"blend", type:"oneof", pool:BoxFader.BLEND_MODES,
			desc:"Choose a $blend mode$ currently works on flash target"});
		
		p.add("FullArea", {type:"toggle", sid:"full", current:false,
			desc:"Toggle between a #small box# and #full screen#."});
		
		p.link("Fade To Color", "fcol", "Fade #into# the selected color.");
		
		p.link("Fade To Off", "foff", "Fade #off# from the selected color.");
		
		p.link("Back", "back", "Go $back$ to the Main Menu", EXIT);
	
		// --
		p.callbacks = function(msg, data, item){
		
		if (msg == "change") switch(item.SID){ default:
			case "full": 	setBoxSize(item.data.current?"full":"small");
			case "blend":	b.blend = item.get();
			case "color":	b.color = DB32.COL[item.get()];
		} else
		
		if (msg == "fire") switch(item.SID){ default: 
			case "fcol": // fade to color
				b.fadeColor(DB32.COL[p.get("color").get()], {
							blend : p.get("blend").get(),
							time  : p.get("time").get()
						});
			case "foff": // fade to off
				b.fadeOff();
			}
		}// --
		
		// Create the box
		setBoxSize("small");
		
		//--
		menu.open(p);				
	}//---------------------------------------------------;
	
	// -- 
	// Set small or big size
	function setBoxSize(size:String = "full")
	{
		if (size == "full"){
			b.setPosition(0, 0);
			b.makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF, true);
		}else{
			b.setPosition(P.x, P.y);
			b.makeGraphic(cast P.w, cast P.h, 0xFFFFFFFF, true);
		}
	}//---------------------------------------------------;

		
}// --