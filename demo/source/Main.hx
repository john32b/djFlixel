
/********************************************
 ** DJFLIXEL DEMO
 *****************************************
 * 
 * - Quick demo of various djflixel components
 * 
 * ====================
 * - Can build for HL and FLASH
 * - HTML5 has issues
 * 
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
	#if final
	inline static var START_STATE = State_Boot;
	#else
	inline static var START_STATE = State_Boot;
	#end
	
	public function new() 
	{
		super();
		
		// :: First thing initialize djFlixel
		D.init({
			name:"DJFLIXEL DEMO " + D.DJFLX_VER,
			debug_keys:true, // Automatic asset reload on [F12]
			smoothing:true
		});
		D.snd.ROOT_SND = 'snd/';
		D.snd.ROOT_MSC = 'snd/';
		D.ui.initIcons([8, 12]); // Prepare those icon sizes to be used globally
		D.assets.DYN_FILES = ['assets/data.txt']; // Declare which files to be reloaded with [F12]
		D.assets.onAssetLoad = ()->{
			var data = D.assets.files['assets/data.txt'];
			trace('Data file loaded', data);
			 //Then you could just parse this to JSON or whatever
		}; 
		
		// :: Start the game after loading the dynamic assets
		D.assets.reload( ()->{
			addChild(new FlxGame(320, 240, START_STATE, 2, FPS, FPS, true));
			FlxG.autoPause = false;
		});
		
	}//---------------------------------------------------;
	
	
	//====================================================;
	//  Some global helpers
	//====================================================;
	
	static public function goto_state(S:Class<FlxState>)
	{
		FlxG.switchState(Type.createInstance(S, []));
	}//---------------------------------------------------;
	
	
	/**
	   Load effect and then load a state
	**/
	static public function create_add_8bitLoader(duration:Float = 0.5, ?cb:Void->Void, ?S:Class<FlxState>):RainbowStripes
	{
		var r = new RainbowStripes(); FlxG.state.add(r);
			r.setMode(FlxG.random.int(1, 3));
			r.setOn();
		var sound = D.snd.play('8bitload'); // keep the sound to kill it later
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