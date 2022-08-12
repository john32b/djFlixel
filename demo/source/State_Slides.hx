/*****************************
	- FlxSlides Demo
	- D.align Demo
******************************/
package ;

import djA.DataT;
import djFlixel.D;
import djFlixel.gfx.StarfieldSimple;
import djFlixel.gfx.pal.Pal_DB32;
import djFlixel.other.DelayCall;
import djFlixel.ui.FlxSlides;
import djFlixel.ui.FlxToast;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;


class State_Slides extends FlxState
{

	override public function create() 
	{
		super.create();
		
		// --
		var sf = new StarfieldSimple();
		add(sf);
		
		// -- Initialize UI Placer, for quick text generation/placement
		var AL = D.align; // I don't want to type `D.align` all the time
		AL.pInit();

		// DEV NOTE 2022:
		// The D.align placer functions are awkard I don't like them
		
		// -- 
		var SL = new FlxSlides({delay:0.04, time:0.06});
		SL.setArrows(12, 12, 80, 300);
		SL.onEvent = (e)->{
			if (e == "close") {
				Main.goto_state(State_Menu, "let");
			}else
			if (e == "next" || e == "previous") {
				D.snd.play('hihat');
			}
		};
		
		//---------------------------------------------------;		
		SL.newSlide();
		// Note: c:0 means no column defined. place in whole area
		SL.a(AL.pT('FlxSlides Demo', {c:0, ta:'c', oy:24}, {s:16, c:0xFF3D22D0}));
		SL.a(AL.pT('FlxSlides is a container that bundles Sprites in pages', {c:0,ta:'c'} ));
		SL.a(AL.pT('for an effect it tweens the sprites in one by one', {c:0,ta:'c'} ));
		SL.a(AL.pT('- Press Left and Right to Navigate -', {c:0,ta:'c'} ));
		SL.a(AL.pT('- You can also use mouse click to go forward -', {c:0,ta:'c'} ));
		SL.finalize(); // Need to call finalize when you are done adding things to a slide
		//---------------------------------------------------;
		
		SL.newSlide();
		// - Define some columns in the UI Placer
		// - Column 100 pixels width, 0 padding from the left
		// - Column 100 pixels width, 16 pixels padding from the previous column
		AL.pCol('100,0|100,16'); 
		AL.pPad(8);	// Pad 16 pixels from top
		SL.a(AL.pT('DJFLIXEL comes with some predefined general use icons.', {c:0, ta:'c'}));
		AL.pPad(2);
		var c = 1;
		for (i in 0...22) {
			// Columns defined earlier with AL.pcol(..)
			if (i >= 11) c = 2 else c = 1;
			//SL.a(AL.pT('Icon ' + i, {c:c, ta:'l'}, {c:0xFFf2ea51}));
			SL.a(AL.pT('Icon ' + i, {c:c, ta:'l'}, {c:Pal_DB32.COL[i + 3]}));
			var ic = new FlxSprite(0, 0, D.ui.getIcon(12, i));
				ic.color = Pal_DB32.COL[i + 3];
			SL.a(AL.p(ic, {c:c, next:true, ox:4}));
		}
		SL.a(AL.pT("Also tools to place text/sprites in columns", {c:0, a:'c', oy:10}));
		SL.a(AL.pT("with alignment and text style options.", {c:0, a:'c'}, {c:0xFF00FFFF, bc:0xFF334499}));	
		SL.finalize();
		//---------------------------------------------------;
		
		
		//---------------------------------------------------;		
		SL.newSlide();
		AL.pClear();
		SL.a(AL.pT("djFlixel was developed as a helper for my projects", {c:0, a:'c', oy:24}));
		SL.a(AL.pT("Visit the github page to learn more", {c:0, a:'c'}));
		SL.a(AL.pT("_____________", {c:0, a:'c'}));
		SL.a(AL.pT("~$Thanks for checking this out.$", {c:0, a:'c'}));
		SL.a(AL.pT("~$John$", {c:0, a:'c'},{c:0xFF5077C0,bc:0xFF65102E}));
		SL.finalize();
		//---------------------------------------------------;		
		
		add(SL);
		SL.goto(0);
		
		new DelayCall(0.7, ()->{
			FlxToast.FIRE("Press Esc to Exit", {screen:"bottom:left", text:{c:0xFFDDEEDD}, bg:0xFF000000});
		});
	}//---------------------------------------------------;
	
}// --