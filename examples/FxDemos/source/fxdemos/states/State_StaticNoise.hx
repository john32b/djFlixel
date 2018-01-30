package fxdemos.states;
import djFlixel.fx.StaticNoise;
import djFlixel.gfx.Palette_DB32.COL as DB32;
import djFlixel.gui.menu.PageData;


/**
 * `StaticNoise` Demo
 * Quick static noise box.
 */
class State_StaticNoise extends State_Demo 
{
	// --
	override public function create():Void 
	{
		flag_hide_msg = true;
		
		super.create();
		
		// --
		var n = new StaticNoise();
		group.add(n);
		
		// --
		var p = new PageData({title:"Noise Box", initFire:true});
		
		p.add("FPS", {type:"slider", sid:"fps", pool:[1, 30], current:14,
			desc:"Frames Per Second"});
		
		p.add("Frames", {type:"slider", sid:"frames", pool:[2, 10], current:4,
			desc:"How many frames to #prerender#. It is faster to prerender frames than having them generate at realtime."});
		
		p.add("Noise Ratio", {type:"slider", sid:"ratio", pool:[0.1, 0.9], inc:0.1, current:0.5,
			desc:"Noise #ratio# between colors"});
		
		p.add("Color 1", {type:"slider", sid:"col_1", pool:[0, 31], current:8,
			desc:"Noise color #A#"});
		
		p.add("Color 2", {type:"slider", sid:"col_2", pool:[0, 31], current:2,
			desc:"Noise color #B#"});
		
		p.link("CREATE!", "create", "$Create$ the effect using the above parameters.");
		
		p.link("Back", "back", "Go $back$ to the Main Menu", EXIT);
		
		// --
		p.callbacks = function(msg, data, item) {
			if (msg == "change" && data == "fps") {
				n.setFPS(item.data.current);
			}
			else if (msg == "fire" && data == "create") {
				// Create a new staticbox, since it can't change the parameters
				group.remove(n);
				n.destroy();
				n = new StaticNoise(0, 0, 0, 0,{
					color1:DB32[p.get("col_1").data.current],
					color2:DB32[p.get("col_2").data.current],
					frames:p.get("frames").data.current,
					fps:p.get("fps").data.current,
					ratio:p.get("ratio").data.current
				});
				group.add(n);
			}
		};// --
		
		menu.open(p);		
	}//---------------------------------------------------;
	
}// --