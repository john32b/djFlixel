
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

import djFlixel.D;
import djFlixel.gfx.RainbowStripes;
import djFlixel.other.DelayCall;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.display.Sprite;


class Main extends Sprite
{
	inline static var FPS = 60;
	inline static var START_STATE = State_Boot;
	//inline static var START_STATE = State_Menu;
	//inline static var START_STATE = menu1.State_Menu1;
	
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
		
	}//---------------------------------------------------;
	
	
	
	/** Shortcut to change state */
	static public function goto_state(S:Class<FlxState>)
	{
		FlxG.switchState(Type.createInstance(S, []));
	}//---------------------------------------------------;
	
	
	/** Apply load effect and then change state **/
	static public function create_add_8bitLoader(duration:Float = 0.5, ?cb:Void->Void, ?S:Class<FlxState>):RainbowStripes
	{
		var r = new RainbowStripes(); FlxG.state.add(r);
			r.setMode(FlxG.random.int(1, 3));
			r.setOn();
		var sound = D.snd.play('8bitload'); // keep the sound reference so I can kill it later
		new DelayCall(()->{
			sound.stop();
			if(S!=null){
				goto_state(S);
			}else{
				FlxG.state.remove(r);
				r.destroy();
				if (cb != null) cb();
			}
		}, duration);
		return r;
	}//---------------------------------------------------;
	

}//--end class--