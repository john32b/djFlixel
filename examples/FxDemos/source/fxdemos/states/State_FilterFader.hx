package fxdemos.states;
import djFlixel.fx.FilterFader;
import djFlixel.gui.menu.PageData;



/**
 * `FilterFader.hx` Fades the screen in and out with hard steps using BitmapFilters
 * Use Example
 */
class State_FilterFader extends State_Demo 
{
	
	// --
	var fx:FilterFader;
	
	// --
	override public function create():Void 
	{
		flag_hide_msg = true;
		
		super.create();
		
		addDecoAndText("Fade the camera viewport in and out and then callback after (delayPost) time has passed.\nThis object is automatically added and removed from the state.");
		
		// --
		var p = new PageData({initFire:true, title:"Filter Fader"});
		// --
		p.add("Delay Post", {type:"slider", sid:"delayp", pool:[0.1, 1], inc:0.4,
			desc:"After finishing the animation, #wait this much time to callback#."});
			
		p.add("Time to complete", {type:"slider", sid:"time", pool:[1, 4],
			desc:"Time to complete the fade."});
			
		p.link("Fade to Black", "fbl", "Fades to #black#.");
		
		p.link("Fade to Screen", "fscr", "Fades from black to #off#. Reveals the screen.");
		
		p.link("Back", "back", "Go $back$ to the Main Menu", EXIT);
		
		p.callbacks = function(a, b, c){
		if (a == "fire") switch(b){ default: 
		case "fbl": // Fade to black
			menu.unfocus();
			fx = new FilterFader("toblack", fadeCallback, {
				delayPost:p.get("delayp").data.current,
				time:p.get("time").data.current
			});
		case "fscr": // Fade to off/screen
			menu.unfocus();
			fx = new FilterFader("toscreen", fadeCallback, {
				time:p.get("time").data.current
			});
		}
		}// --
		
		menu.open(p);				
	}//---------------------------------------------------;
	
	
	// --
	function fadeCallback()
	{
		menu.focus();
		fx.destroy();
	}//---------------------------------------------------;
}// --