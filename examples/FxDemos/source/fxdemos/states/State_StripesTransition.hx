package fxdemos.states;
import djFlixel.fx.substate.Stripes;
import djFlixel.gui.menu.PageData;
import djFlixel.gfx.Palette_DB32;


/**
 * `Stripes.hx` Overlay transition effect with animated stripes 
 * Use Example
 */
class State_StripesTransition extends State_Demo 
{
	// --
	override public function create():Void 
	{
		super.create();
		
		var p = new PageData({title:"Animated Stripes"});
		
		p.add("Mode", {type:"oneof", pool:["on", "off"], sid:"mode",
		desc:"$ON$ = Stripes hide the screen.\n$OFF$ = Stripes reveal the screen."});
		
		p.add("Direction", {type:"oneof", pool:["left", "right", "in", "out"], sid:"dir",
			desc:"Direction of the stripes."});
		
		p.add("Color", {type:"slider", pool:[0, 31], sid:"col",
			desc:"Stripe color, #DB32 Palette# index."});
		
		p.add("Number of stripes", {type:"slider", pool:[5, 25], current:11, sid:"num",
			desc:"Number of stripes."});
		
		p.add("Time Total", {type:"slider", pool:[0.1, 2], inc:0.1, current:1, sid:"time",
			desc:"Total time to animate."});
		
		p.add("Time Stripe", {type:"slider", pool:[ 0.1, 1], inc:0.2, current: 0.1, sid:"timeA",
			desc:"Time each stripe takes to tween."});
		
		p.link("CREATE", "create", "$Create$ and $Run$ with the above parameters.");
		
		p.link("Back", "back", "Go $back$ to the Main Menu.", EXIT);
		
		// --
		p.callbacks = function(msg, data, item) {
			if (msg == "fire" && data == "create") {
				var t1:String = p.get("mode").get();
				var t2:String = p.get("dir").get();
				var s = new Stripes('$t1-$t2', 
				
					function()
					{
						this.closeSubState();
					}, 
				
					{
						time:p.get("time").get(),
						timeStripe:p.get("timeA").get(),
						stripes:p.get("num").get(),
						color:Palette_DB32.COL[p.get("col").get()]
					}
				);
				
				this.openSubState(s);
			}
		};
		
		// --
		menu.open(p);		
	}//---------------------------------------------------;
	
}// --