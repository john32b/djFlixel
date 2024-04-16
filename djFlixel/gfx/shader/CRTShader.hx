/**
   CRT Shader - V1.2
   -----------------
   
   * FAST CRT-like effect with blur and scanlines.

   * Scale aware, scanlines will always apply between game pixels

   * In this version some properties are hard coded, you can adjust
     the strength with `BLUR_STR`

   * Auto-adds a gameResized() Flixel signal to handle 
     proper scanline scaling. However That signal is not autoremoved
	 so be sure to call `removeSignals()` when you remove this shader!

   * example:
   	```
	var SHADER = new CRTShader();
		SHADER.BLUR_STR = 0.8;
	FlxG.game.setFilters([new ShaderFilter(SHADER)]);
	```

	# DEV NOTES:
	- scanline brightness is hardcoded (should I parameterize it?)
		....mix(0.78, 1.0, sin())
	- The blur amount is limited when the window scales too large
	  the set values seem to work so far, but are not tested in 
	  very high resolutions (4K)

**/

package djFlixel.gfx.shader;

import flixel.FlxG;

class CRTShader extends openfl.display.GraphicsShader
{

@:glFragmentSource('

#pragma header
#define PI 3.14159265358

// This is for calculating the scanlines
// Double the real game size e.g. (320x240) => (640x480)
// > Why double ? Because true scanlines are once every other row
//   Saves a x2 calculation from hapenning for every pixel on the shader
uniform vec2 GAME_SIZE_DOUBLE;

// The actual rendered game size.
// - This should be (openfl_TextureSize) but that doesnt seem to work?
// - So I am manually updating this everytime window resizes
uniform vec2 WIN_SIZE;

// Blur Strength (x,y)
uniform vec2 BLUR_DIR;

// Gaussian blur, reads `BLUR_DIR`
// Based on : https://github.com/Experience-Monks/glsl-fast-gaussian-blur
// MIT License : Located at the end of this file
vec4 blur9(vec2 uv, vec2 resolution)
{
	vec4 color = vec4(0.0);
	vec2 off1 = (vec2(1.3846153846) * BLUR_DIR) / resolution;
	vec2 off2 = (vec2(3.2307692308) * BLUR_DIR) / resolution;
	color += texture2D(bitmap, uv) * 0.2270270270;
	color += texture2D(bitmap, uv + off1) * 0.3162162162;
	color += texture2D(bitmap, uv - off1) * 0.3162162162;
	color += texture2D(bitmap, uv + off2) * 0.0702702703;
	color += texture2D(bitmap, uv - off2) * 0.0702702703;
	return color;
}

void main()
{
	// -- Blur
	vec4 col = blur9(openfl_TextureCoordv, openfl_TextureSize);

	// -- Simple Scanlines
	float yratio = (gl_FragCoord.y / WIN_SIZE.y);
	col = col * mix(0.825, 1.0, sin(PI * GAME_SIZE_DOUBLE.y * yratio));

	gl_FragColor = col;
}

')

	// Limit the maximum Blur Strength when the window resizes up
	static inline var SR_MAX_X = 2;
	static inline var SR_MAX_Y = 2;

	// Additional Blur Y multiplier. I want more horizontal blur than Vertical.
	static inline var MULT_Y = 0.2;

	/** Blur Strength, applies to shader **/
	public var BLUR_STR(default, set):Float;

	// Size Ratio
	// Current resolution ratio to size2[]
	var sr:Array<Float> = [1, 1];

	// Keeps the original game size doubled!
	var size2:Array<Float>;

	// setter
	function set_BLUR_STR(val:Float):Float
	{
		// Send to shader
		data.BLUR_DIR.value = [val * sr[0], val * sr[1] * MULT_Y];
		return BLUR_STR = val;
	}// -------------------------;

	/**
		@param strength Starting Blur Strength, you can change it in real time later.
	**/
    public function new(strength:Float = 0.5)
    {
        super();
		
		// Gamesize, doubled
		size2 = [FlxG.width * 2, FlxG.height * 2];
		data.GAME_SIZE_DOUBLE.value = size2;
		
		BLUR_STR = strength;
		_onresize(cast FlxG.game.width, cast FlxG.game.height);
		FlxG.signals.gameResized.add(_onresize);		

    }//---------------------------------------------------;

	#if debug
	/** `[` `]` keys to increase/decrease blur **/
	public function enable_debug_keys()
	{
		FlxG.signals.postUpdate.add( ()->{
			if (FlxG.keys.justPressed.LBRACKET) {
				BLUR_STR -= 0.05;
				trace('Shader DJFLX-CRT-0 :: BLUR_STR = ${BLUR_STR}');
			}else
			if (FlxG.keys.justPressed.RBRACKET) {
				BLUR_STR += 0.05;
				trace('Shader DJFLX-CRT-0 :: BLUR_STR = ${BLUR_STR}');
			}
		});
	}// -------------------------;
	#end


	public function removeSignals()
	{
		FlxG.signals.gameResized.remove(_onresize);
		trace("Shader DJFLX-CRT-0 :: removed onresize [OK]");
	}// -------------------------;

	function _onresize(W:Int,H:Int)
	{
		data.WIN_SIZE.value = [cast(W, Float), cast(H, Float)]; 
		sr[0] = W / size2[0];
		sr[1] = H / size2[1];
		if(sr[0] < 0.2) sr[0] = 0.2;
		if(sr[1] < 0.2) sr[1] = 0.2;
		if(sr[0]>SR_MAX_X) sr[0] = SR_MAX_X;
		if(sr[1]>SR_MAX_Y) sr[1] = SR_MAX_Y;

		BLUR_STR = BLUR_STR; // force set again
		trace('Shader DJFLX-CRT-0 :: Resize, sr:${sr}, W:${W}, H:${H}');
	}// -------------------------;
}





/**
# LICENSE FOR THE `blur9()` function :

The MIT License (MIT) Copyright (c) 2015 Jam3

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
**/