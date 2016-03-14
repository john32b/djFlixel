djFlixel Tools
==============
**Version:** 0.2.x (in development)
**Author:** John Dimi, <johndimi@outlook.com>, twitter:[@jondmt](https://twitter.com/jondmt)  
**Language:** Haxe 3.x
**Requires:** haxeflixel 4.x (dev)

__djFlixel__  is a library containing various helpers and tools library for haxeflixel. I created this during the development of my other game projects.  Feel free to use it, study it, fork it, or whatever :-)

####  [!! CLICK HERE FOR A QUICK DEMO !!](http://bit.ly/djflx)

----------

### Features

- Menu System, _easy paged menus with some basic option elements, like toggles_
- Dialog Box, ( in development ) _Easy to use and setup streamlined._
- Unified controls for keyboard and gamepads. _Poll keyboards and gamepad with one call_
- Web Apis _(Kongregate, Newgrounds, GameJolt)_
- Some Screen FX backgrounds _Starfieldm, Rainbow retro loader_
- Simple Save system with slots
- Streamlined _TILED_maps loading and setup.
- Streamlined basic topdown sprite movement.
- Dynamically load parameters from a JSON file, _ability to change parameters on the fly, without having to recompile again_
 
### How to install

```haxelib git djFlixel https://github.com/johndimi/djFlixel.git```

#### [CHECKOUT THE WIKI](https://github.com/johndimi/djFlixel/wiki)

The wiki is in development! Hopefully will be adding content to it.

#### [CHECKOUT THE EXAMPLES DIR](https://github.com/johndimi/djFlixel/tree/master/examples)

Also in development, will be adding more examples hopefully.


----------

#### Menu System

![FlxMenu screenshot](http://i.imgur.com/QpJExaG.png)

Provides easy menu system creation with branching submenus.
- Scrollable
- Customizable, _(Fonts, Colors_Animation variables)_
- Supports Menu Option Types:
	- Link Options _(Call a function or goto another menu)_
	- Togglable _(Can be toggled on or off)_
	- Select one of _(Inline selection of one of many choices)_
	- Number Rage _(Select a number using a slider)
- Menu options can be unselectable or disabled
- Offers simple callbacks 
- Can handle infinite elements with small footprint


#### Starfield
Provides an easy to setup and use __starfield layer__
Customizable speed, colors, direction, widepixel.

![Starfield in action](http://i.imgur.com/YXD2mUk.gif)

#### Rainbow Loader
Emulates a loading screen from the 8bit computers (Amstrad, Commodore64)
Customizable speed and rectangle height, also provides some pre-defined modes.

![Rainbow border in action](http://i.imgur.com/YTjwLWL.gif)


### Easy Controls

Simple static class for handling controls from both keyboard and gamepads from a single base.

example:
```
/*  
This will get controls from WASD + Arrow Keys + Joystick
 */
if (Controls.pressed(Controls.UP)) {
			move(FlxObject.UP);
		}
		else if (Controls.pressed(Controls.DOWN)) {
			move(FlxObject.DOWN);
		}
		else if (Controls.pressed(Controls.LEFT)) {
			move(FlxObject.LEFT);
		}
		else if (Controls.pressed(Controls.RIGHT)) {
			move(FlxObject.RIGHT);
		}else {
			move(0);
		}
```

--------

#### More documentation soon !

Feel free to contact me for questions, suggestions, or anything else.

Cheers,

-- John
