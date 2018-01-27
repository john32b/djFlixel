package fxdemos.states;
import djFlixel.fx.BoxScroller;
import djFlixel.gfx.GfxTool;
import djFlixel.gfx.Palette_DB32;
import djFlixel.gui.menu.PageData;
import flash.display.BitmapData;
import flixel.FlxG;



/**
 * `BoxScroller` Use Example
 * Tiles an image inside a box
 */
class State_BoxScroller extends State_Demo 
{
	// The original source tiles are black and white
	// Create clones and colorize them here
	var images:Array<BitmapData>;
	
	// --
	override public function create():Void 
	{
		flag_hide_msg = true;
		
		super.create();
		
		// -- Create colorized tiles
		var imageFiles:Array<String> = P.images;
		images = [];
		for (i in imageFiles)
		{
			var color1:Int;
			var color2:Int;
			do{
				color1 = Palette_DB32.random();
				color2 = Palette_DB32.random();
			}while (color1 == color2);
			
			// b is modified in place, that's why I clone it
			var b:BitmapData = GfxTool.resolveBitmapData(i).clone();
			GfxTool.replaceColor(b, 0xFFFFFFFF, color1);
			GfxTool.replaceColor(b, 0xFF000000, color2);
			images.push(b);
		}// --
		
		
		// --
		var currentImage:Int = 0;
		var box = new BoxScroller(images[currentImage], P.x, P.y, P.w, P.h, true);
		group.add(box);
		
		// --
		var p = new PageData({initFire:true, title:"Box Scroller"});
		
		p.add("Speed X", {type:"slider", sid:"spdX", pool:[ -3, 3], inc:0.1, current:1,
			desc:"Horizontal scrolling #speed#."});
			
		p.add("Speed Y", {type:"slider", sid:"spdY", pool:[ -3, 3], inc:0.1, current:1,
			desc:"Vertical scrolling #speed#."});
			
		p.label("--");
		
		p.add("FullArea", {type:"toggle", sid:"full", current:false,
			desc:"Render to #full# screen or #small# box."});
			
		p.add("Image", {type:"slider", sid:"img", pool:[0, images.length - 1], noInit:true,
			desc:"Change the tiling graphic."});
			
		p.link("Back", "back", "Go $back$ to the Main Menu", EXIT);
			
		p.callbacks = function(a, b, c){
			if (a == "change") switch(b){ default:
				case "spdX":	box.autoScrollX = c.data.current;
				case "spdY":	box.autoScrollY = c.data.current;
				case "img":		box.loadNewGraphic(images[c.data.current]);
				case "full":	
					if (c.data.current){ // full
						box.resize(FlxG.width, FlxG.height);
						box.setPosition(0, 0);
					}else{
						box.resize(P.w, P.h);
						box.setPosition(P.x, P.y);
					}
			} 
		}// --
		menu.open(p);		
	}//---------------------------------------------------;
	
	
	// --
	override public function destroy():Void 
	{
		for (i in images)
		{
			i.dispose();
		}
		
		super.destroy();
	}//---------------------------------------------------;
	
}// --