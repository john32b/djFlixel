
/********************************************
 ** DJFLIXEL DEMO
 *****************************************
 * - Quick demo of various DJFlixel components
 * ====================
 * 
 * - Goes through a bunch of states until it reaches the Main Menu State
 * 		State_Boot > State_Logos > State_TextScroll > State_Menu
 * 
 * - Can build to cpp, hashlink, flash
 * - HTML5 has problems with Fonts, rendering and metrics.
 * 
 *******************************************/

package;

import djA.DataT;
import djFlixel.D;
import djFlixel.gfx.BoxScroller;
import djFlixel.gfx.FilterFader;
import djFlixel.gfx.RainbowStripes;
import djFlixel.other.DelayCall;
import djFlixel.ui.FlxMenu.MenuEvent;
import djFlixel.ui.FlxToast;
import djFlixel.ui.IListItem.ListItemEvent;
import djFlixel.ui.UIButton;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.system.FlxAssets;
import openfl.display.Sprite;


class Main extends Sprite
{
	inline static var FPS = 60;
	inline static var START_STATE = State_Boot;
	
	public function new() 
	{
		super();
		
		// First thing initialize djFlixel
		// The parameters are all optional, checkout inside <D.hx> for more info
		D.init({
			name:"DJFLIXEL DEMO " + D.DJFLX_VER,
			smoothing:true
		});
		
		D.ui.initIcons([8, 12]); // Prepare those icon sizes to be used. Here FLXMenu will use sizes 8 and 12
		
		FlxG.autoPause = false;
		
		addChild(new FlxGame(320, 240, START_STATE, 2, FPS, FPS, true));
		
		// DEV NOTE : CHANGE v0.5:
		// There used to be some Dynamic Asset Reloading code here
		// It was the case that release&debug would share the asset loading code
		// So FlxGame would have to be created after handling the assets 
		// (e.g parsing a JSON file with settings)
		// > None of that now. The FlxGame is created at once, and the HOTRELOAD
		//   code is to be managed manually. Check more in <Dassets.hx>

		
		// FlxToast uses a static object with color properties that can be shared between states
		// I want to reset the properties after each state switch
		FlxG.signals.postStateSwitch.add( ()->{
			FlxToast.INIT(true);
		});
		

	}//---------------------------------------------------;
	
	
	
	/** Shortcut to change state */
	static public function goto_state(S:Class<FlxState>, ?effect:String)
	{
		
		switch (effect)
		{
			case "fade":
				new FilterFader( ()->goto_state(S) );
				
			case "8bit":
				create_add_8bitLoader(0.5, S);
				
			case "let":
				var col = DataT.randAr([
					[0xff181425, 0xff262b44],
					[0xff180d11, 0xff6d4653],
					[0xff131c13, 0xfffee761]
				]);
				
				new common.SubState_Letters(
					"FLIXEL", ()->goto_state(S), {
						bg:col[0],
						text:{c:col[1]}, 
						snd:"bleep0", tPre:0.3, tPost:0.2, 
						ease:"EaseIn",tLetter:0.12
					});
				
			default:
				FlxG.switchState(Type.createInstance(S, []));
		}
		
	}//---------------------------------------------------;
	
	
	/** Apply load effect and then (change state OR callback)
	 **/
	static public function create_add_8bitLoader(duration:Float = 0.5, ?cb:Void->Void, ?S:Class<FlxState>):RainbowStripes
	{
		var r = new RainbowStripes(); 
			FlxG.state.add(r);
			r.setMode(FlxG.random.int(1, 3));
			r.setOn();
		var sound = D.snd.play('8bitload'); // keep the sound reference so I can kill it later
		new DelayCall(duration, ()->{
			sound.stop();
			if(S!=null){
				goto_state(S);
			}else{
				FlxG.state.remove(r);
				r.destroy();
				if (cb != null) cb();
			}
		});
		return r;
	}//---------------------------------------------------;
	
	
	/**
	   Universal Sound Handler for menus. Handles both types of events in one place
	   @param	ev Either this
	   @param	me Or this, can't be both
	**/
	static public function handle_menu_sound(?ev:ListItemEvent, ?me:MenuEvent)
	{
			if (me != null)
			{
				if (me == pageCall) {
					D.snd.playV('cursor_high', 0.6);
				}else
				if (me == back){
					D.snd.playV('cursor_low');
				}
				return;
			}
		
			if(ev!=null)
			switch(ev) {
				case fire:
					D.snd.playV('cursor_high',0.7);
				case focus:
					D.snd.playV('cursor_tick',0.33);
				case invalid:
					D.snd.playV('cursor_error');
				default:
			};
	}//---------------------------------------------------;

	
	/**
	   Add a footer text + scroller, used in some states
	**/
	public static function add_footer_01(col:Int = 0xFF0c0c0c)
	{
		var b = new djFlixel.gfx.BoxScroller("im/stripe_01.png", 0, FlxG.height - 24, FlxG.width);
			b.color = col;
			b.autoScrollX = 1;
			b.randomOffset();
			FlxG.state.add(b);
			
		var t = D.text.get('djFlixel ${D.DJFLX_VER}', {c:0xff3a4466});
			FlxG.state.add(D.align.screen(t, "r", "b"));
	}//---------------------------------------------------;
	
	
	
	/**
	   - Add background scroller
	   - Or change settings
	**/
	public static var bgsc:BoxScroller;
	public static function bg_scroller(index:Int, C:Array<Int>)
	{
		if (bgsc == null || !bgsc.exists)
		{
			bgsc = new BoxScroller('im/bg01.png', 0, 0, FlxG.width, FlxG.height);
			bgsc.autoScrollX = 0.2;
			bgsc.autoScrollY = 0.2;
			FlxG.state.insert(0, bgsc);
		}
		if (index > 6) index = 6;	// bg01-bg06.png in assets dir
		
		var b = FlxAssets.resolveBitmapData('im/bg0${index}.png');
			b = D.bmu.replaceColors(b.clone(), [0xFFFFFFFF, 0xFF000000], C);
		bgsc.loadNewGraphic(b);
	}//---------------------------------------------------;
	

}//--end class--
