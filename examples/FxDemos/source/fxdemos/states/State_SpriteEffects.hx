package fxdemos.states;
import djFlixel.fx.SpriteEffects;
import djFlixel.gui.Align;
import djFlixel.gui.menu.PageData;
import flixel.text.FlxText;



/**
 * `SpriteEffects` Use Example
 * Various realtime animated effects that are applied on a bitmap
 */
class State_SpriteEffects extends State_Demo 
{
	// --
	override public function create():Void 
	{
		super.create();
		
		// --
		var s = new SpriteEffects("assets/HAXELOGO.png");
		s.setPosition(P.x, P.y); // Get position from parameters
		group.add(s);
		
		// --
		var p = new PageData({title:"Sprite FX", initFire:true});
		
		p.add("NoiseBox", {type:"toggle", sid:"noisebox", 
			desc:"Apply #box noise#, Custom box size, speeds"});
		
		p.add("NoiseLine", {type:"toggle", sid:"noiseline", 
			desc:"Apply #noise lines#, Custom sizes, speeds"});
		
		p.add("Split", {type:"toggle", sid:"split", 
			desc:"#Chromatic Aberration# like effect, Custom colors, speeds, offsets"});
		
		p.add("Dissolve", {type:"toggle", sid:"dissolve", 
			desc:"Dissolve #on# or #off# with custom sized boxes"});
		
		p.add("Blink", {type:"toggle", sid:"blink", 
			desc:"#Draw/Remove# the image with a blink effect"});
		
		p.add("Wave", {type:"toggle", sid:"wave", 
			desc:"Apply a #horizontal wave#, customizable length, speed"});
		
		p.link("Back", "back", "Go $back$ to the Main Menu", EXIT);
		
		// --
		p.callbacks = function(msg, data, item)
		{
			if (msg == "change" && item.type == "toggle")
			{
				if(item.data.current)
					item.data.fx = s.addEffect(data);
				else
					s.removeEffect(item.data.fx);
			}
		};
		
		menu.open(p);
		

		// --
		var txt = new FlxText(0, 0, 160);
		djFlixel.gui.Styles.applyTextStyle(txt, djFlixel.gui.Gui.textStyles.get("default"));
		txt.text = "Here are some basic predefined effects. Effects can be stacked, be customized and have callbacks, checkout the wiki and class comments for more info";
		group.add(txt);
		Align.downCenter(txt, s, 8);		
	}//---------------------------------------------------;
	
}// --