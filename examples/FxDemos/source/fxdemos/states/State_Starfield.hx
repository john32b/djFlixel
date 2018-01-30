package fxdemos.states;
import djFlixel.fx.StarfieldSimple;
import djFlixel.gui.menu.PageData;
import flixel.FlxG;
import djFlixel.gfx.Palette_DB32.COL as DB32;


/**
 * `StarfieldSimple` Use Example
 * Simple starfield with customizable colors etc
 * 
 */
class State_Starfield extends State_Demo 
{
	// --
	override public function create():Void 
	{
		flag_hide_msg = true;
		
		super.create();
		
		// --
		var s = new StarfieldSimple(FlxG.width, FlxG.height);
		group.add(s);
		
		// --
		var	p = new PageData({title:"starfield", initFire:true});
		
		p.add("Angle", {type:"slider", sid:"angle", pool:[0, 360], inc:10, current:120, loop:true,
			desc:"Star travelling angle."});
				
		p.add("Speed", {type:"slider", sid:"speed", pool:[0, 10], inc:0.1, current:2,
			desc:"Star travelling speed multiplier."});
		
		p.add("WidePixel", {type:"toggle", sid:"wide",
			desc:"Use widepixel, A #rendering method# reminiscent to 8bit computers."});
		
		p.label("DB32 Palette Colors ::");
		
		p.add("Background", {type:"slider", sid:"col_bg", pool:[0, 31], noInit:true,
			desc:"Space #DB32# palette index."});
		
		p.add("Shimmering Stars", {type:"slider", sid:"col_1", pool:[0, 31], noInit:true,
			desc:"Shimmering stars #DB32# palette index."});
		
		p.add("Main Stars", {type:"slider", sid:"col_2", pool:[0, 31], noInit:true,
			desc:"Main stars DB32 palette index."});
		
		p.add("Front Stars", {type:"slider", sid:"col_3", pool:[0, 31], noInit:true,
			desc:"Foreground DB32 palette index."});
		
		p.link("Back", "back", "Go $back$ to the Main Menu", EXIT);
		
		// --
		p.callbacks = function(msg, data, item){
			if(msg=="change") switch(data){
				case "angle":
					s.STAR_ANGLE = item.data.current;
				case "speed":
					s.STAR_SPEED = item.data.current;
				case "wide":
					s.WIDE_PIXEL = item.data.current;
				case "col_bg": s.setBGCOLOR(DB32[item.data.current]);
				case "col_1":  s.COLORS[1] = DB32[item.data.current];
				case "col_2":  s.COLORS[2] = DB32[item.data.current];
				case "col_3":  s.COLORS[3] = DB32[item.data.current];
			}
		}
		menu.open(p);				
	}//---------------------------------------------------;
	
}// --