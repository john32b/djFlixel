/** 
 # HQ2X shader
 # Source: 
 - HaxeFlixel Demos
 - https://github.com/HaxeFlixel/flixel-demos/blob/dev/Effects/Filters/source/filters/Hq2x.hx

 # Original Code License :

	The MIT License (MIT)

	Copyright (c) 2013

	Permission is hereby granted, free of charge, to any person obtaining a copy of
	this software and associated documentation files (the "Software"), to deal in
	the Software without restriction, including without limitation the rights to
	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
	the Software, and to permit persons to whom the Software is furnished to do so,
	subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
	FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
	IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

	----

	# John32B Edit
	- Parameterized blur strength

*/

package djFlixel.gfx.shader;

class Hq2x extends openfl.display.GraphicsShader
{
	@:glFragmentSource('
		#pragma header
		
		// Blur Multiplier (x,y) ! warning cannot be 0
		uniform float BLUR_M;

		void main()
		{
			float x = BLUR_M / openfl_TextureSize.x;
			float y = BLUR_M / openfl_TextureSize.y;

			vec4 color1 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(-x, -y));
			vec4 color2 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(0.0, -y));
			vec4 color3 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(x, -y));

			vec4 color4 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(-x, 0.0));
			vec4 color5 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(0.0, 0.0));
			vec4 color6 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(x, 0.0));

			vec4 color7 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(-x, y));
			vec4 color8 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(0.0, y));
			vec4 color9 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(x, y));
			vec4 avg = color1 + color2 + color3 + color4 + color5 + color6 + color7 + color8 + color9;

			gl_FragColor = avg / 9.0;
		}')


	public function new(strength:Float = 1.0)
	{
		super();
		if(strength<=0) strength=0.01;
		data.BLUR_M.value = [strength];
	}// -------------------------;

}