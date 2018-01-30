# CHANGELOG

## Version 0.3  | *2018 January 26*

> Breaking Changes

 #### New ::
 
 - `FlxAutoText` : Text Auto-type system supporting inline tags so that you can change the parameters as it's reading the string.
- `TextBouncer.hx` : Animates in a string of text by tweening letter by letter
- `FilterFader.hx`: Fades screen on/off with bitmap filters
- `PanelPop.hx` :  Creates animated panel with customizable borders
- `PixelFader.hx` : Fades screen on/off with per pixel operations
- `MaskedSprite.hx` : Loads an image and apply masking to it, (*i.e. cut a whole where a color is*)
- `SpriteEffects.hx` : Various per pixel effect operations on an image, comes with some predefined but customizable styles
- `BoxScroller.hx` : Tiles an image inside a square, like `FlxTiledSprite` but it is faster
- `UIButton.hx` : Simple clickable buttons. Customizable and support 2 layers, the background sprite and overlay icon/text
- `Trophies`: Trophy support for offline and online APIS *( newgrounds, gamejolt)*
- `StaticNoise.hx` : Box simulating static noise. Pre-rendered frames for speed
- `Align.hx`: Helper functions for aligning elements to each other or the screen.
- `Palette_DB16.hx` : Color definitions for the DB 16 color palette

#### Improvements and changes ::

- `FlxMenu` : 
	- Overall refactor and bug fixes
	- Mouse support for interacting with elements, scroll wheel scrolls
	- Dynamic pages support, you can now pass a dynamic page object to `open()`
	- Improved Header Text
	- `item_updateData()` change an item's data at will
	- `close()` optionally will remember the current state and will be resumed with `open()`
- `SND.hx` : 
	- Overall better code
	- `setVolume()` can set the volume to the global sound groups for music and sounds.
	- `addMetadataNode()` can now Read sound metadata from an object so, instead of doing it hard-coded, you can set the sound groups in run-time.
	- Automatic load of metadata from the main `params.json` ⇒ `soundFiles` node. `FLS` does this automatically.
- RENAMED  `Controls.hx` ⇒ `CTRL.hx` :
	- All caps Static Class for easier access and to comfort with the other static classes which are ALL_CAPS
	- `CTRL.timepress()` a better implementation of `cursor_press()`, supports acceleration and custom times
	- Now also supports `ARROW KEYS + ZX`
- `VListBase` :
	- Bug-fixes and better code
	- More style options
	- Alignment support
	- Better more arrows when there are more elements to scroll to
- `VListNav` :
	- Bug-fixes and better code
	- Better cursor, aligns better, more options, supports animated sprites
	- Supports mouse interaction
- `VListMenu` :
	- More styles
	- Bug-fixes
- RENAMED `MenuOptionBase` ⇒`MItemBase` *and siblings* :
	- Bug-fixes and better code
	- Support getting mouse input along with X|Y Coordinates
	- Better check-boxes due to the new `djflixel` built in icon lib
	- Support Alignments ( left, right, center, justify )
- RENAMED `BGPop.hx` ⇒ `PanelPop.hx` : 
	- Better code and styling options
- `Styles.hx` :
	- Renamed some things, to be more consistent and start with the prefix `style`
		- `VBaseStyle` ⇒ `StyleVLBase`
		- `VListStyle` ⇒ `StyleVLNav`
		- `MItemStyle` ⇒ `StyleVLMenu`
	- Added a bunch of new style options to the VList Objects, like cursors, icons etc
	- NEW, `TextStyle` *typedef* holding styles for `FlxText`
	- `applyTextStyle()` applies a text style object to an `FlxText`
- RENAMED `OptionData.hx`  ⇒ `MItemData.hx`  :
	- Renamed to make more sense (Menu Item Data)
	- NEW function `get()` will return the appropriate date from each item
	- Sliders now support rational number increments
	- Sliders and OneOfs now support looping
- `MainTemplate.hx` : 
	- Better and less code.
	- User `Main` class now overrides `init()` and sets parameters there.
- `DynAssets.hx` : 
	- No longer a static class, but instead resides as an object inside `FLS`
- `GfxTool.hx` : 
	-  `palCol()` will convert a special formatted string holding a palette color to a color int. Useful to quickly setting colors from external parameter files
	- `replaceColor()` replaces a color in a bitmap-data using the flash `threshold` method
	- `getSpriteFrame()` Quickly get an animated `FlxSprite` loaded with a target tile image at current frame
	- `stitchBitmaps()`, Takes a bunch of bitmaps and stitches them together to a long stripe
- `Gui.hx` : 
	- `autoplace()` and `autoplaceOff()`, Experimental guide to autoplacing sprites on the screen
	- `place()` Places a sprite to the previously configured autoplacer
	- `getIcon()` djFlixel now comes with standard icons. 8,12,16,24 pixel square size. This function gets a bitmapdata for an icon ID, along with shadow color. Also the icons are pooled
	- `getApproxIconSize()` Return the closest icon size to a number. Useful to figuring out what icon size to use for what font height etc.
	- `addTextStyle()` Append a textstyle object to the gui library so that you can quickly get an `flxtext` with that style later
	- `getSText()` *Get Styled Text* Return a new `FlxText` with the textstyle ID previously set with `addTextStyle()`
- More that I didn't document 

#### Removed ::

- `DialogBox.hx` : It was really immature and not working, I need to make a decent class, probably in the next version
- `Old Examples` : Replaced with new examples,


--- 

#### changelog note
> I am starting from a clean state with this changelog from v0.3. Older logs to be discarded, since so much have changed in this project it makes sense to start anew
