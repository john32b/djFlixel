package fxdemos.states;

import djFlixel.fx.RainbowStripes;
import djFlixel.gui.menu.PageData;

/**
 * `RainbowStripes` Use Example,
 * Basic functionalities controled by a menu
 */
class State_RainbowStripes extends State_Demo 
{
	//--
	override public function create():Void 
	{
		flag_hide_msg = true;
		
		super.create();
		
		// --
		var r = new RainbowStripes();
		group.add(r);
		
		// --
		var p:PageData = new PageData({initFire:true, title:"Rainbow Stripes" });
		
		p.add("Predefined Style", { type:"slider", sid:"pred", current:1, pool:[0, 3],
				desc:"Choose a $predefined style$ (lineheights and speeds)."});
				
		p.label("Set Stripe Height ::");
		
		p.add("Height Min", {type:"slider", sid:"minH", pool:[1, 64],
			desc:"$Minimum$ line height." });
			
		p.add("Height Max", {type:"slider", sid:"maxH", pool:[1, 128],
			desc:"$Maximum$ line height."});
			
		p.link("Apply Height", "applyH", "$Apply$ the Heights set above.");
		
		p.label("Set Speed ::");
		
		p.add("Speed", {type:"slider", sid:"spd", pool:[0.05, 1], inc:0.05,
			desc:"How often the stripes should update, frequency in $milliseconds$"});
			
		p.link("Back", "back", "Go $back$ to the Main Menu", EXIT);
		
		p.callbacks = function(a, b, c){
			if (a == "change" && b == "pred") {
				r.setPredefined(c.data.current);
			}else
			if ( a == "fire" && b == "applyH"){
				var h0:Int = p.get("minH").data.current;
				var h1:Int = p.get("maxH").data.current;
				r.setStripeHeight(h1, h0);
			}else
			if ( a == "change" && b == "spd") {
				r.setSpeed(c.data.current);
			}
		}// --
		
		menu.open(p);
	}//---------------------------------------------------;
	
}// --