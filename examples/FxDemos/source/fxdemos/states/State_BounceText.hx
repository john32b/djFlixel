package fxdemos.states;

import djFlixel.fx.TextBouncer;
import djFlixel.gui.Align;
import djFlixel.gui.menu.PageData;



/**
 * `TextBouncer` Use Example
 * Make a string appear with letter by letter animation
 */
class State_BounceText extends State_Demo 
{
	// --
	override public function create():Void 
	{
		super.create();
		
		// --
		var t:TextBouncer;
		
		// --
		var p = new PageData({title:"Text Bouncer"});
		
		p.add("Y Offset", {type:"slider", sid:"yoffs", pool:[ -100, 100], inc:5, current: -30,
			desc:"Beginning #Y offset# of the letters."});
		
		p.add("X Offset", {type:"slider", sid:"xoffs", pool:[ -100, 100], inc:5, current:0,
			desc:"Beginning #X offset# for the letters."});
		
		p.add("Ease", {type:"oneof", sid:"ease",pool:["bounceOut", "elasticOut", "linear", "circOut", "backOut"],
			desc:"Type of #letter tween#"});
		
		p.add("Time Total", {type:"slider", sid:"timeA", pool:[0.1, 3], inc:0.1, current:0.7,
			desc:"Total time it takes for the whole animation to complete"});
		
		p.add("Time letter", {type:"slider", sid:"timeB", pool:[0.1, 3], inc:0.1, current:0.6,
			desc:"Time it takes for a single letter to drop"});
		
		p.link("CREATE!", "create", "$Create$ and $Run$ the effect with the above parameters.");
		
		p.link("Back", "back", "Go $back$ to the Main Menu", EXIT);
		
		// --
		p.callbacks = function(msg, data, item){
			if (msg == "fire" && data == "create")
			{
				if (t != null){
					group.remove(t);
					t.destroy();
				}
				
				var o = {
					fontSize:16,
					colorBorder:0xFF111111,
					startY: p.get("yoffs").get(),
					startX: p.get("xoffs").get(),
					time: p.get("timeA").get(),
					timeLetter: p.get("timeB").get(),
					ease: p.get("ease").get(),
					pad:-2
				};
				
				t = new TextBouncer("TEXT BOUNCER", 100, 100, o);
				// Try to align it in the space between the menu and end of the screen
				Align.inLine(menu.x + menu.width, menu.y + 48, 0, [t], "center");
				group.add(t);
				t.start();
			}
		};
		
		// --
		menu.open(p);
	}//---------------------------------------------------;
	
}// --