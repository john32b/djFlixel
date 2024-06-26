
/**
 * DJFLIXEL DEMO
 * -------------
 * - Quick demo of various DJFlixel components
 *
 * - Goes through a bunch of states until it reaches the Main Menu State
 * 		State_Boot > State_Logos > State_TextScroll > State_MainMenu
 *
 * - F9 Hotkey to switch shaders
 *
 *******************************************/

package;

import openfl.filters.ShaderFilter;
import djA.DataT;
import djFlixel.D;
import djFlixel.gfx.BoxScroller;
import djFlixel.gfx.FilterFader;
import djFlixel.gfx.RainbowStripes;
import djFlixel.other.DelayCall;
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
	inline static var START_STATE = State_Boot;
	// Read the `FPS` value from `Project.xml`
	static var FPS:Int = Std.parseInt(djA.Macros.getDefine('FPS'));

	public function new()
	{
		super();

		// First thing initialize djFlixel
		// The parameters are all optional, checkout inside <D.hx> for more info
		D.init({
			name:"DJFLIXEL DEMO",
			version: D.DJFLX_VER ,
			init:_preStart
		});

		addChild(new FlxGame(320, 240, START_STATE, FPS, FPS, true));

	}//---------------------------------------------------;

	// - Initialize things right after FlxGame has been created
	static function _preStart()
	{
		FlxG.autoPause = false;

		// FlxToast uses a static object with color properties that can be shared between states
		// I want to reset the properties after each state switch
		FlxG.signals.postStateSwitch.add( ()->{
			FlxToast.INIT(true);
		});

		// Prepare those icon sizes to be used. Here FLXMenu will use sizes 8 and 12
		D.ui.initIcons([8, 12]);

		// Adjust some of the Sound volumes Globally
		// Everytime a sound is played with `D.snd.playV()`, this custom volume will be applied
		D.snd.addSoundInfos({
			cursor_high : 0.6,
			cursor_tick : 0.33
			// .. all other sounds will be played at normal volume
		});

		// Pressing F9 from anystate, will call this function
		D.ctrl.hotkey_add(F9,()->{
			// loop
			if(shader_type==2)
				shader_type=0;
			else
				shader_type++;
		});

	}// -------------------------;


	/**
		Apply a shader to FlxGame (0,1,2)
		@param n 0:No Shader, remove previous one
	**/
	public static var shader_type(default,set):Int = 0;
	static var shader_kill:Void->Void = null;

	static public function set_shader_type(n:Int):Int
	{
		if(n<0) n=0; else if(n>2) n=2;

		if(n==shader_type) return n;
		if(shader_kill!=null) {
			shader_kill();
			shader_kill = null;
		}

		var filt:Array<openfl.filters.BitmapFilter>;
		switch(n){
			case 1: // hq2x
				var HQ2X = new djFlixel.gfx.shader.Hq2x();
				filt = [new ShaderFilter(HQ2X)];
			case 2: // crt
				var CRT = new djFlixel.gfx.shader.CRTShader();
				#if debug
					CRT.enable_debug_keys();
				#end
				filt = [new ShaderFilter(CRT)];
				shader_kill = CRT.removeSignals;
			default:
				filt = [];
		}

		FlxG.game.parent.filters = filt;
		trace('DJFLX, Shader Set : ${n}');
		return shader_type=n;
	}// -------------------------;


	/** Change state with an animated effect */
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
