package djFlixel.fx;

import djFlixel.SimpleCoords;
import djFlixel.tool.DataTool;
import flash.display.Sprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets;
import djFlixel.gfx.GfxTool;
import flash.display.BitmapData;
import flixel.system.FlxAssets.FlxGraphicSource;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;


/**
 * Various animated effects
 * 
 * USAGE
 * -------
 * 	flag_freeze_last	//	when the last effect is removed, then this will keep the last frame
 * 
 * EFFECTS
 * -------
 *  split
 *  noiseline
 *  noisebox
 *  mask
 *  blink
 * 		
 */
class SpriteEffects extends FlxSprite
{
	
	// Update the effects every this many seconds, can be altered realtime
	public var FREQ:Float = 0.08;
	
	// Keep time for FREQ
	var timer:Float;
	
	// Source image
	var _im:BitmapData;
	var _ma:Matrix;
	var _tr:Rectangle;
	var _tc:ColorTransform;
	var _tp:Point;
	
	// -- Array of all active effects
	var stack:Array<SpriteFX>;
	// -- Awaiting for removal
	var removeList:Array<SpriteFX>;
	// -- Prevent callbacks from beeing called when on a loop
	var callbackList:Array<Void->Void>;
	
	// -- If true, when all effects are removed, it will keep the last frame without resetting it to normal
	public var flag_freeze_last:Bool = false;
	//---------------------------------------------------;
	
	/**
	 * 
	 * @param	im
	 * @param	sheet { .tw .th .frame } Set this if you are loading a tilesheet
	 */
	public function new(im:FlxGraphicAsset, ?sheet:Dynamic) 
	{
		super();
		
		if (sheet != null)
		{
			_im = GfxTool.getBitmapPortion(im, Std.int(sheet.tw * sheet.frame), 0, sheet.tw, sheet.th);
		}
		else
		{
			_im = GfxTool.resolveBitmapData(im);
		}
		
		makeGraphic(_im.width, _im.height, 0x00000000, true); // Transparent
		
		// --
		_tr = new Rectangle(0, 0, _im.width, _im.height);
		_tc = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
		_ma = new Matrix();
		_tp = new Point();
		
		stack = [];
		removeList = [];
		callbackList = [];
		
		drawFirst(); 
	}//---------------------------------------------------;
	

	// --
	override public function destroy():Void 
	{
		if (_im != null) _im.dispose(); /// This might break future calls to the bitmap because of the cache system??
		for (i in stack){
			i.destroy();
		}
		super.destroy();
	}//---------------------------------------------------;
	
	/**
	 * Does not actually remove, but rather requests a removal.
	 * @param	fx
	 */
	public function removeEffect(fx:SpriteFX)
	{
		fx.destroy();
		removeList.push(fx);
	}//---------------------------------------------------;
	
	/**
	 * Remove an effect with target ID
	 */
	public function removeEffectID(id:String)
	{
		if (id == 'all'){
			for (i in stack) removeEffect(i);
			return;
		}
		
		for (fx in stack){
			if (fx.p.id != null && fx.p.id == id) {
				removeEffect(fx); break;
			}
		}
	}//---------------------------------------------------;
	
	// --
	// Draw the original image, don't need to clear the buffer, as the alhpa pixels are copied as well
	function drawFirst()
	{
		// I don't need these, as the first FX will process the source directly
		_tp.setTo(0, 0);
		_tr.setTo(0, 0, _im.width, _im.height);
		pixels.copyPixels(_im, _tr, _tp);
		dirty = true;
	}//---------------------------------------------------;
	
	
	/**
	 * 
	 * @param	effect split | noiseline | noisebox | mask | blink | dissolve | wave
	 * @param	params check the function :-/
	 * @param	callback Make sure this is a short callback as it will be called inside a traverse loop
	 * @return	The FX object created, useful if you want to manually remove it later
	 */
	public function addEffect(effect:String, ?params:Dynamic, ?callback:Void->Void):SpriteFX
	{
		timer = FREQ + 1; // Force the first update to process the effects
		var fx = new SpriteFX();
		fx.onComplete = callback;
		stack.push(fx);
		fx.head = (stack.length == 1);
		
		switch(effect)
		{
			
			//====================================================;
			case "dissolve":
				fx.p = DataTool.defParams(params, {
					open:false,		// if true effect will start reverse, building the image
					time:2,			// Time to complete the effect
					size:2,			// pixel size, it's faster when bigger
					color:0x00000000, // Color to disolve to
					run:1,
					ease: "quintOut",
					delay:0,
					_f:0,			// current pointer
				});
				fx.p._w = Math.ceil(pixels.width / fx.p.size);
				fx.p._h = Math.ceil(pixels.height / fx.p.size);
				fx.p._total = fx.p._w * fx.p._h; // total rects
				//-- 
				var _end = fx.p.open?0:fx.p._total;
				fx.p._f = fx.p._total - _end;
				fx.tween = FlxTween.tween(fx.p, {_f:_end}, fx.p.time, 
					{type:FlxTween.PINGPONG, ease:Reflect.field(FlxEase, fx.p.ease), startDelay:fx.p.delay});
				fx.update = _fx_dissolve;
				var ar:Array<Int> = [for (p in 0...(fx.p._total)) p];
				FlxG.random.shuffle(ar);
				fx.p.ar = ar;
			
			//====================================================;
			case "wave":
				fx.p = DataTool.defParams(params, {
					width:3,		// width of the wave, [Pixels]
					height:0.8,		// height of the wave, [Not Pixels], Smaller value, small wave length
					time:0.4,		// time for the wave to do a cycle
					_f:0			// current offset of the wave
				});
				fx.p._r = Math.PI * 2 / pixels.height;
				fx.update = _fx_wave;
				fx.tween = FlxTween.tween(fx.p, {_f:Math.PI * 2}, fx.p.time, {type:FlxTween.LOOPING});
			//====================================================;
			case "split":
				
			fx.p = DataTool.defParams(params, {
				width:3,  	// max offset width
				time:0.4, 	// reach the max width in this much seconds
				delay:0,    // Delay of the timer to start
				color1:0xFFFF0000, // Left offset color
				color2:0xFF00FF00, // Right offset color
				run: -1,		   // Run forever (x>0 to run x times)
				ease: "circOut",
				_w:0 				// Current offset width
			});
			fx.update = _fx_chromaSplit;
			fx.p.run = fx.p.run * 2;
			fx.tween = FlxTween.tween(fx.p, {_w:fx.p.width}, fx.p.time, 
				{type:FlxTween.PINGPONG, ease:Reflect.field(FlxEase, fx.p.ease),startDelay:fx.p.delay});
					
			//====================================================;
			case "noiseline":  
				
			fx.p = DataTool.defParams(params, {
				w0:2, 	// min width <-- starting width
				w1:8,  	// max width of the Wave
				time:0.5,  // reach the max width in this much seconds. Set to 0 for no wave
				delay:0,    // Delay of the timer to start
				run: -1,   // Run forever (x>0 to run x times)
				ease: "quadOut",
				h0:1, 	//<-- starting line height
				h1:16,	// applies if FX1 / FX2
				// -- flags
				fx1:false,  // RANDOM Height, from h0 to h1
				fx2:false,	// MATCH height to the tweener, YOU MUST HAVE SET time>0 , h0 doesn't matter
				//--
				_w:0  		// Current offset width
				});
			fx.update = _fx_noiseline;
			fx.p._w = fx.p.w0;
			if (fx.p.time > 0) {
				fx.tween = FlxTween.tween(fx.p, {_w:fx.p.w1}, fx.p.time, 
					{type:FlxTween.PINGPONG, ease:Reflect.field(FlxEase, fx.p.ease),startDelay:fx.p.delay});
			}
			//====================================================;
			case "noisebox" :
				 fx.p = DataTool.defParams(params, {
					 w:2, // Size of the noise box
					 j:2  // Jitter distance
				 });
				 fx.update = _fx_noisebox;
				 fx.p._cx = Math.floor(_im.width / fx.p.w);  // Save a calculation
				 fx.p._cy = Math.floor(_im.height / fx.p.w); // Save a calculation
				 fx.p._jm = fx.p.j * 2; // *2 because I want equal jitter from all dirs
				 
			//====================================================;
			case "mask" :
				fx.p = DataTool.defParams(params, {
					colorBG:0xFF000000, 	 // Color of the inverted alpha, black
					colorMask:0xFFFFFFFF,    // Turn this color to alpha 0, Only active if flag all is false
					all:false				 // If true, then all colored pixels will turn to alpha 0
				});
				fx.update = _fx_mask;
				
			//====================================================;
			case "blink" :
				fx.p = DataTool.defParams(params, {
					open:false,		// If true the effect will reverse
					time:1,		// Time to complete the effect
					run:1,
					delay:0,
					ease: "",
					_l:0
				});
				fx.p._hl = Math.ceil(pixels.height / 2); // Half Height
				var _tt = (fx.p.open?0:fx.p._hl); // End pos
				fx.p._l = fx.p._hl - _tt; // Start pos
				fx.tween = FlxTween.tween(fx.p, {_l:_tt}, fx.p.time, 
					{type:FlxTween.PINGPONG, ease:Reflect.field(FlxEase, fx.p.ease),startDelay:fx.p.delay});
				fx.update = _fx_blink;
			default: // ::  --------------------
				throw "Unsupported FX, check for typos";
		}
		
		return fx;
	}//---------------------------------------------------;
	
	
	//====================================================;
	// EFFECTS 
	//====================================================;
	
	
	function _fx_dissolve(fx:SpriteFX)
	{
		if (fx.head) {
			drawFirst();
		}
		
		for (c in 0...Math.floor(fx.p._f)) {
			_tr.setTo(
				Std.int((fx.p.ar[c] % fx.p._w) * fx.p.size),
				Std.int((fx.p.ar[c] / fx.p._w) * fx.p.size),
				fx.p.size, fx.p.size);
			pixels.fillRect(_tr, fx.p.color);
			
		}
	}//---------------------------------------------------;
	
	
	function _fx_wave(fx:SpriteFX)
	{
		/// todo, variable height, copy from the noiseline
		for (yy in 0...pixels.height)
		{
			_tr.setTo(0, yy, pixels.width, 1);
			_tp.setTo(
			Math.sin( fx.p._f + ((fx.p._r * yy) / fx.p.height )) * fx.p.width, 
			yy);
			pixels.copyPixels(fx.src, _tr, _tp);
		}
	}//---------------------------------------------------;
	
	function _fx_blink(fx:SpriteFX)
	{
		if (fx.head) {
			drawFirst();
		}
	
		_tr.setTo(0, 0, pixels.width, fx.p._l );
		pixels.fillRect(_tr, 0x00000000);
		
		_tr.setTo(0, pixels.height -  fx.p._l, pixels.width, fx.p._l);
		pixels.fillRect(_tr, 0x00000000);
		
	}//---------------------------------------------------;
	
	/* -- UNUSED -
	function ___deleteLine(yy:Float)
	{
		_tr.setTo(0, yy, pixels.width, 1);
		_tp.setTo(0, yy);
		pixels.threshold(pixels, _tr, _tp, ">", 0xFF000000, 0x00000000);
	}//---------------------------------------------------;*/
	
	function _fx_mask(fx:SpriteFX)
	{
		if (fx.head) {
			drawFirst();
		}else{
			// Save some cpu, since tr and tp were set on the drawfirst() call
			_tr.setTo(0, 0, pixels.width, pixels.height);
			_tp.setTo(0, 0);
		}
		
		pixels.threshold(fx.src, _tr, _tp, "==", 0x00000000, fx.p.colorBG);
		
		if (fx.p.all)
			pixels.threshold(fx.src, _tr, _tp, ">", 0xFF000000, 0x00000000);
		else
			pixels.threshold(fx.src, _tr, _tp, "==", fx.p.colorMask, 0x00000000);
			
	}//---------------------------------------------------;
	
	function _fx_noisebox(fx:SpriteFX)
	{
		for(yy in 0...fx.p._cy)
		for (xx in 0...fx.p._cx)
		{
			_tr.setTo(xx * fx.p.w, yy * fx.p.w, fx.p.w, fx.p.w);
			_tp.setTo(xx * fx.p.w + (Math.random() * fx.p._jm) - fx.p.j, yy * fx.p.w + (Math.random() * fx.p._jm) - fx.p.j);
			pixels.copyPixels(fx.src, _tr, _tp);
		}
		
	}//---------------------------------------------------;

	function _fx_chromaSplit(fx:SpriteFX)
	{
		_ma.identity();
		// --
		_ma.tx = fx.p._w * -1;
		_tc.color = fx.p.color1;
		pixels.draw(fx.src, _ma, _tc);
		// --
		_ma.tx = fx.p._w;
		_tc.color = fx.p.color2;
		pixels.draw(fx.src, _ma, _tc);
		// --
		_ma.tx = 0;
		pixels.draw(fx.src, _ma);
	}//---------------------------------------------------;
	
	function _fx_noiseline(fx:SpriteFX)
	{
		if(fx.p.fx1){
			_tr.height = fx.p.h0 + Std.random(Std.int(fx.p.h1 - fx.p.h0));
		}else if (fx.p.fx2){
			_tr.height = (fx.p._w / fx.p.w1) * fx.p.h1;
		}else{
			_tr.height = fx.p.h0;
		}
		_tr.x = 0;
		_tr.width = _im.width;
		for (yy in 0...Math.floor(pixels.height / _tr.height)) {
			_tr.y = yy * _tr.height;
			_tp.y = yy * _tr.height;
			_tp.x = Std.int((Math.random() * fx.p._w)) * FlxG.random.sign();
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
			// --
			if (removeList.length > 0) 
			{
				for (r in removeList) {
					stack.remove(r);
				}
				
				for (f in 0...stack.length){
					// Reorder the head flag, only the first one should be true
					stack[f].head = (f == 0);
				}
				
				removeList.splice(0, removeList.length);
				
				if (stack.length == 0 && !flag_freeze_last)
				{
					drawFirst();
				}
			}// -- remove
		
			timer = 0;
			pixels.lock();
			
			// -- Clear the buffer
			_tr.setTo(0, 0, _im.width, _im.height);
			pixels.fillRect(_tr, 0x00000000);
			
			for (i in 0...stack.length) {
				
				// If there is just one fx, save some CPU time
				if (i == 0) {
					stack[i].src = _im; 
				}else{
					stack[i].src = pixels.clone();
				}
				
				stack[i].update(stack[i]);
				
				if (stack[i].checkLoopEnd()) {
					removeEffect(stack[i]);
					if (stack[i].onComplete != null) callbackList.push(stack[i].onComplete);
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
	var head:Bool;			  // True if this is the first of the effects applied
	var p:Dynamic;
	var onComplete:Void->Void;
	var tween:VarTween;		  // optional tween, some effects might use this
	var src:BitmapData;		  // temp bitmapdata for operations
	
	// flag use previous for input
	inline public function checkLoopEnd():Bool {
		return (p.run > 0 && tween.executions == p.run);
	}
	public dynamic function destroy(){
		if (tween != null){ tween.cancel(); tween.destroy(); }
		//if (tp != null) {tp.dispose(); tp = null; }	// No because it could be a pointer to "_im"
	}//---------------------------------------------------;
	public dynamic function update(a:SpriteFX){}
	public function new(){}
}


