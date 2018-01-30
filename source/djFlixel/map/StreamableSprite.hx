/**
 # StreamableSprite.hx
 # ====================

 Steamable Sprites are any sprites that live on a map
 have tile coordinates, and can be dynamically created and destroyed 
 as the camera pans.
 
 Works in conjuction with MapTemplate.hx and it is responsible for 
 managing them sprites.
 
 It is useful to lighten the CPU and MEM usage, 
 e.g. If you have hundreds of sprites in a map, they will not all be created at once
 
====================================*/


package djFlixel.map;

import djFlixel.SimpleCoords;
import flixel.FlxSprite;


class StreamableSprite extends FlxSprite
{
	// Unique ID
	public var UID:Int;
	
	// Tile Coordinates
	public var coords(default, null):SimpleCoords;
	
	// When going offscreen, use this much padding to trigger a kill
	// Do not use negative values!
	public var offscreen_kill_pad:Int = 0;

	// Unused for now
	// public var flag_auto_kill_when_offscreen:Bool;
	
}//---------------------------------------------------;