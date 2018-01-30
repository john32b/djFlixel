package djFlixel.fx;


import djFlixel.gfx.GfxTool;
import djFlixel.tool.DEST;
import djFlixel.tool.DataTool;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.NumTween;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;


/**
 * Various realtime animated effects that are applied on a bitmap
 * 
 * Effect List 
 * -------------------
 * - dissolve - 
 * - wave -
 * - split -
 * - noiseline - 
 * - noisebox - 
 * - blink - 
 * - mask -
 */

class SpriteEffects extends FlxSprite
{
	
	// Update the effects every this many seconds, can be altered realtime
	public var FREQ:Float = 0.08;
	
	// Keep time for FREQ
	var timer:Float = 0;
	
	// Source image
	var _im:BitmapData;
	// Helpers that are used often
	var _ma:Matrix;
	var _tr:Rectangle;
	var _tc:ColorTransform;
	var _tp:Point;
	// Currently processing FX
	var fx:SpriteFX;
	
	// -- Effect Stack, [0] is the last effect
	var stack:Array<SpriteFX>;
	
	// -- Prevent callbacks from beeing called when on a loop
	var callbackList:Array<Void->Void>;
	
	// When is it safe to delete the source image
	var flag_unique_src:Bool;
	//---------------------------------------------------;
	
	/**
	 * 
	 * @param	im A Bitmap or an Asset
	 * @param	sheet { .tw .th .frame } Set this if you are loading a tilesheet
	 */
	public function new(im:FlxGraphicAsset, ?sheet:Dynamic) 
	{
		super();
		
		if (sheet != null)
		{
			_im = GfxTool.getBitmapPortion(im, Std.int(sheet.tw * sheet.frame), 0, sheet.tw, sheet.th);
			flag_unique_src = true;
		}
		else
		{
			_im = GfxTool.resolveBitmapData(im);
			flag_unique_src = false;
		}
		
		makeGraphic(_im.width, _im.height, 0x00000000, true); // Transparent
		
		// --
		_tr = new Rectangle(0, 0, _im.width, _im.height);
		_tc = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
		_ma = new Matrix();
		_tp = new Point();
		
		stack = [];
		callbackList = [];
		
		drawFirst(); 
	}//---------------------------------------------------;
	

	// --
	override public function destroy():Void 
	{
		if (_im != null && flag_unique_src) _im.dispose();
		for (i in stack){
			i.destroy();
		}
		super.destroy();
	}//---------------------------------------------------;
	
	/**
	 * Remove an effect with target ID
	 * You must have set the ID beforehand
	 * Most useful when called externally
	 */
	public function removeEffectID(id:String)
	{
		if (id == 'all'){
			for (i in stack) i.destroy();
			stack = [];
			return;
		}
		
		for (fx in stack){
			if (fx.p.id != null && fx.p.id == id) {
				removeEffect(fx);
				return;
			}
		}
	}//---------------------------------------------------;
	
	public function removeEffect(fx:SpriteFX)
	{
		if (fx != null)
		{
			fx.destroy();
			stack.remove(fx);
		}
		
		if (stack.length == 0) {
			drawFirst();
		}
	}//---------------------------------------------------;
	
	// --
	// Draw the original image
	function drawFirst()
	{
		// Note, I am not clearing the buffer since the original image alphas are copied
		// I don't need these, as the first FX will process the source directly
		_tp.setTo(0, 0);
		_tr.setTo(0, 0, _im.width, _im.height);
		pixels.copyPixels(_im, _tr, _tp);
		dirty = true;
	}//---------------------------------------------------;
	
	
	/**
	 * 
	 * @param	effect split | noiseline | noisebox | mask | blink | dissolve | wave
	 * @param	params check the code :-(
	 * @param	callback When the effect completes, make sure RUN times is not -1 (infinite)
	 * @return	The FX object created, useful if you want to manually remove it later
	 */
	public function addEffect(effect:String, ?params:Dynamic, ?callback:Void->Void):SpriteFX
	{
		timer = FREQ + 1; // Force the first update to process the effects
		
		var FX = new SpriteFX();
			FX.onComplete = callback;
			FX.head = (stack.length == 0);
			stack.unshift(FX);	// Add the last effect to the top of the array
		
		// Temporarily store the effect parameters
		var P:Dynamic = null;
		
		switch(effect)
		{
			//====================================================;
			case "dissolve":
				P = DataTool.copyFieldsC(params, {
					open:false,		// if true effect will start reverse, building the image
					random:true,	// if false the tiles will be revealed in sequence
					size:6,			// dissolve rectangle size
					color:0, 		// color to disolve to
					//-- tween params:
					time:2, delay:0, ease: "linear", run:1, ttype:4
				});
				P._w = Math.ceil(pixels.width / P.size);
				P._h = Math.ceil(pixels.height / P.size);
				P._total = P._w * P._h;
				var ar:Array<Int> = [for (i in 0...P._total) i];
				if (P.random) FlxG.random.shuffle(ar);
				FX.p = P; P.ar = ar;
				FX.startTween(0, P._total);
				FX.update = _fx_dissolve;
			//====================================================;
			case "wave":
				P = DataTool.copyFields(params,{
					width:3,		// width of the wave, [Pixels]
					height:0.8,		// height of the wave, [Not Pixels], Smaller value, small wave length
					//-- tween params:
					time:0.4, delay:0, ease: "linear", run: -1, ttype:2
				});
				P._r = Math.PI * 2 / pixels.height;
				FX.p = P;
				FX.startTween(0, Math.PI * 2);
				FX.update = _fx_wave;
			//====================================================;
			case "split":
				P = DataTool.copyFieldsC(params, {
					width:3,  			// max offset width
					color1:0xFFFF0000, 	// Left offset color
					color2:0xFF00FF00, 	// Right offset color
					//-- tween params:
					time:0.4, delay:0, ease: "circOut", run:-1, ttype:4, loopDelay:0.2
				});
				P.run = P.run * 2;	// Just in case
				FX.p = P;
				FX.startTween(0, P.width);
				FX.update = _fx_chromaSplit;
			//====================================================;
			case "noiseline":  
			P = DataTool.copyFields(params, {	
					w0:2, 		// min width <-- starting width
					w1:8,  		// max width of the Wave
					h0:1, 		// <-- starting line height
					h1:16,		// applies if FX1 / FX2
					// -- flags:
					FX1:false,  // RANDOM Height, from h0 to h1
					FX2:false,	// MATCH height to the tweener, YOU MUST HAVE SET time>0 , h0 doesn't matter
					//-- tween params:
					time:0.5, delay:0, ease: "quadOut", run:-1, ttype:4, loopDelay:0.2
				});
				FX.C = P.w0;
				FX.p = P;
				FX.startTween(P.w0, P.w1);
				FX.update = _fx_noiseline;
			//====================================================;
			case "noisebox" :
				 P = DataTool.copyFields(params, {
					 w:2, 	// Size of the noise box
					 j1:2,	// Jitter distance start
					 j2:5,	// Jitter distance end, Set to same value as j1 for no animation
					//-- tween params:
					time:0.5, delay:0, ease: "linear", run:-1, ttype:4, loopDelay:0.2
				 });
				 FX.C = P.j1;
				 P._cx = Math.floor(_im.width / P.w);  // Save a calculation
				 P._cy = Math.floor(_im.height / P.w); // Save a calculation
				 FX.p = P;
				 if (P.j1 != P.j2) FX.startTween(P.j1, P.j2); else FX.C = P.j1;
				 FX.update = _fx_noisebox;
			//====================================================;
			case "mask" :
				#if neko
				trace("Warning: Realtime Masking is EXTREMELY slow on NEKO");
				#end
				P = DataTool.copyFieldsC(params, {
					colorBG:0xFF000000, 	 // Color of the inverted alpha, black
					colorMask:0xFFFFFFFF,    // Turn this color to alpha 0, Only active if flag all is false
					all:false				 // If true, then all colored pixels will turn to alpha 0
				});
				FX.p = P;
				FX.update = _fx_mask;
			//====================================================;
			case "blink" :
				P = DataTool.copyFields(params, {
					open:true,
					//-- tween params:
					time:1, delay:0, ease: "linear", run:1, ttype:4, loopDelay:0.2
				});
				if (P.open) {
					P.ttype = 16;
				}
				FX.p = P;
				FX.startTween(0, pixels.height / 2);
				FX.update = _fx_blink;
			default: // ::  --------------------
				throw "Unsupported FX, check for typos";
		}
		
		return FX;
	}//---------------------------------------------------;
	
	//====================================================;
	// EFFECTS 
	//====================================================;
	
	function _fx_dissolve()
	{
		if (fx.head) drawFirst();
		
		for (c in 0...Std.int(fx.C)) {
			_tr.setTo(
				(fx.p.ar[c] % fx.p._w) * fx.p.size,
				Math.floor(fx.p.ar[c] / fx.p._w) * fx.p.size,
				fx.p.size, fx.p.size);
				
			pixels.fillRect(_tr, fx.p.color);
		}
	}//---------------------------------------------------;
	
	function _fx_wave()
	{
		for (yy in 0...pixels.height)
		{
			_tr.setTo(0, yy, pixels.width, 1);
			_tp.setTo(Math.sin( fx.C + ((fx.p._r * yy) / fx.p.height )) * fx.p.width, yy);
			pixels.copyPixels(fx.src, _tr, _tp);
		}
	}//---------------------------------------------------;
	
	function _fx_blink()
	{
		if (fx.head) drawFirst();
		
		_tr.setTo(0, 0, pixels.width, Math.ceil(fx.C) );
		pixels.fillRect(_tr, 0x00000000);
		
		_tr.setTo(0, Math.ceil(pixels.height -  fx.C), pixels.width, Math.ceil(fx.C));
		pixels.fillRect(_tr, 0x00000000);
		
	}//---------------------------------------------------;
	
	function _fx_mask()
	{
		#if (!neko)
		
			if (fx.head) drawFirst(); else {
				// _tr and _tp were set on drawFirst();
				_tr.setTo(0, 0, pixels.width, pixels.height);
				_tp.setTo(0, 0);
			}
			
			pixels.threshold(fx.src, _tr, _tp, "==", 0x00000000, fx.p.colorBG);
			
			if (fx.p.all)
				pixels.threshold(fx.src, _tr, _tp, ">", 0xFF000000, 0x00000000);
			else
				pixels.threshold(fx.src, _tr, _tp, "==", fx.p.colorMask, 0x00000000);
			
		#else 

		// Threshold is VERY SLOW on NEKO
			if (fx.head) drawFirst();
			var p:Int;
			for (xx in 0..._im.width)
			for (yy in 0..._im.height) {
			 	p = pixels.getPixel32(xx, yy);
				if (p == 0x00000000){ pixels.setPixel32(xx, yy, fx.p.colorBG); continue; }
				if (p == fx.p.colorMask){ pixels.setPixel32(xx, yy, 0x00000000); continue; }
			}
			
		#end
		
	}//---------------------------------------------------;
	
	function _fx_noisebox()
	{
		for (yy in 0...fx.p._cy)
		for (xx in 0...fx.p._cx)
		{
			_tr.setTo(xx * fx.p.w, yy * fx.p.w, fx.p.w, fx.p.w);
			_tp.setTo(	xx * fx.p.w + (Math.random() * fx.C * 2) - fx.C, 
						yy * fx.p.w + (Math.random() * fx.C * 2) - fx.C);
			pixels.copyPixels(fx.src, _tr, _tp);
		}
		
	}//---------------------------------------------------;

	function _fx_chromaSplit()
	{
		_ma.identity();
		// --
		_ma.tx = fx.C * -1;
		_tc.color = fx.p.color1;
		pixels.draw(fx.src, _ma, _tc);
		// --
		_ma.tx = fx.C;
		_tc.color = fx.p.color2;
		pixels.draw(fx.src, _ma, _tc);
		// --
		_ma.tx = 0;
		pixels.draw(fx.src, _ma);
	}//---------------------------------------------------;
	
	function _fx_noiseline()
	{
		if(fx.p.fx1){
			_tr.height = fx.p.h0 + Std.random(Std.int(fx.p.h1 - fx.p.h0));
		}else if (fx.p.fx2){
			_tr.height = (fx.C / fx.p.w1) * fx.p.h1;
		}else{
			_tr.height = fx.p.h0;
		}
		_tr.x = 0;
		_tr.width = _im.width;
		for (yy in 0...Math.floor(pixels.height / _tr.height)) {
			_tr.y = yy * _tr.height;
			_tp.y = yy * _tr.height;
			_tp.x = Std.int((Math.random() * fx.C)) * FlxG.random.sign();
			pixels.copyPixels(fx.src, _tr, _tp);
		}
	}//---------------------------------------------------;	

	
	//====================================================;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		timer += elapsed;
		
		if (timer > FREQ && stack.length > 0) 
		{
			timer = 0;
			pixels.lock();
			
			// -- Clear the buffer
			_tr.setTo(0, 0, _im.width, _im.height);
			pixels.fillRect(_tr, 0x00000000);
			
			var i = stack.length;
			while (--i >= 0)
			{
				fx = stack[i];
				
				// Save some CPU, don't copy the pixels of the first effect
				if (i == stack.length - 1) {
					fx.src = _im; 
				}else{
					fx.src = pixels.clone();
				}
				
				fx.update();
				
				if (fx.checkLoopEnd()) {
					stack.splice(i, 1);	// Save to remove as the iteration is going down
					if (fx.onComplete != null) callbackList.push(fx.onComplete);
				}
			}
			
			pixels.unlock();
			dirty = true;
			
			// -- callbacks
			if (callbackList.length > 0) {
				for (c in callbackList) c(); 
				callbackList.splice(0, callbackList.length);
			}
		}// -- timer
		
	}//---------------------------------------------------;
	
	
}//--


//====================================================;
// 
//====================================================;


@:publicFields
class SpriteFX {
	var update:Void->Void;	// Main Effect function
	var head:Bool;			// True if this is the first of the effects applied
	var p:Dynamic;			// Every effect can have it's own custom parameters here
							// Some Common :: {
							//  ttype: Tween Type ( PERSIST:1, LOOPING:2, PINGPONG:4, BACKWARD:16 )
							// 	run :	How many times to repeat the effect, -1 for infinite
							//	delay:	Delay the tween start, for effects that use a tween
							//  ease:	String name of FlxEase to use for effects that use a tween
							//  loopDelay: Delay between loops ( if the effect is looping )
							// }
	var onComplete:Void->Void;
	var tween:NumTween;		// optional tween, some effects might use this
	var src:BitmapData;		// temp bitmapdata for operations
	var C:Float = 0;		// general Purpose counter used in Tweens.
	//====================================================;
	// --
	inline public function checkLoopEnd():Bool {
		if (tween == null) return false;
		return (p.run > 0 && tween.executions == p.run);
	}
	// --
	public dynamic function destroy(){
		DEST.numTween(tween);
	}//---------------------------------------------------;
	// - Starts a tween that affects the "C" variable,
	// - Uses some parameters in the P object
	public function startTween(start:Float, end:Float)
	{
		if (p.time > 0)
		tween = FlxTween.num(start, end, p.time, {
				type:p.ttype,	
				startDelay:p.delay,
				loopDelay:p.loopDelay,
				ease:Reflect.field(FlxEase, p.ease)
		},
		function(v){
			C = v;
		});
	}//---------------------------------------------------;
	public function new(){};
}


