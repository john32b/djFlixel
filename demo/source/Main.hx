
/********************************************
 ** DJFLIXEL DEMO
 *****************************************
 * - Quick demo of various DJFlixel components
 * ====================
 * 
 * - Goes through a bunch of states until it reaches the Main Menu State
 * 		State_Boot > State_Logos > State_TextScroll > State_MainMenu
 * 
 * - Can build to cpp, hashlink, flash, html5
 * 
 *******************************************/

package;

import djA.DataT;
import djFlixel.D;
import djFlixel.gfx.BoxScroller;
import djFlixel.gfx.FilterFader;
import djFlixel.gfx.RainbowStripes;
import djFlixel.other.DelayCall;
import djFlixel.other.GF_Blur;
import djFlixel.ui.FlxMenu;
import djFlixel.ui.FlxMenu.MenuEvent;
import djFlixel.ui.FlxToast;
import djFlixel.ui.IListItem.ListItemEvent;
import djFlixel.ui.MPlug_Audio;
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
	
	// Global Filter Blur
	public static var BLUR:GF_Blur;
	
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
		
		// Adjust some of the Sound volumes Globally
		// Everytime a sound is played with `D.snd.playV()`, this custom volume will be applied
		D.snd.addSoundInfos({
			cursor_high : 0.6,
			cursor_tick : 0.33
			
			// .. all other sounds will be played at normal volume
		});
		
		
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
		
		// This is a simple and quick way to add a blurFilter
		// Automatically adds event listeners and handles [F9] key (for debug)
		BLUR = new GF_Blur(0.7, 1.5, 2);
		BLUR.enabled = true;
		
		
		FlxG.autoPause = false;
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
				
			case "let": // LETTERS
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
	   Same sound settings for all menus created in this app
	   @param	m an FlxMenu
	**/
	static public function menu_attach_sounds(m:FlxMenu)
	{
		m.plug(new MPlug_Audio({
			pageCall:'cursor_high',
			back:'cursor_low',
			it_fire:'cursor_high',
			it_focus:'cursor_tick',
			it_invalid:'cursor_error'
		}));
		
		// ^ Note that these sounds will play with `D.snd.playV()` 
		//   so they will apply any custom volumes set in D.snd
		
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
