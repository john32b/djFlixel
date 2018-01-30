package guidemos.states;

import common.Common;
import common.InfoBox;
import djFlixel.CTRL;
import djFlixel.FLS;
import djFlixel.SND;
import djFlixel.fx.BoxScroller;
import djFlixel.gfx.GfxTool;
import djFlixel.tool.DataTool;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxState;

/**
 * General class that will be extended
 * Some common code between the states.
 * ...
 * @author John Dimi
 */
class State_Demo extends FlxState 
{
	
	// Variables,gets the node with the same class name from "params.json"
	public var P:Dynamic;

	// --
	// A box at the bottom of the screen displaying some info
	public var INFO:InfoBox;
	
	// --
	public function new() 
	{
		super();
		var name:String = Type.getClassName(Type.getClass(this)).split('.').pop();
		P = DataTool.copyFieldsC(Reflect.field(FLS.JSON, name));
	}//---------------------------------------------------;
	

	// --
	override public function create():Void 
	{
		super.create();
		
		if (P.colorBG != null)
		{
			camera.bgColor = P.colorBG;
		}
		else if (P.scroller != null)
		{
			add(Common.getBGScroller(P.scroller));
		}
		
		INFO = new InfoBox(P.infoText, FLS.JSON.COMMON.infoBox);		
		if (P.infoText != null) INFO.open();

		SND.play("c_back");
		
		new common.FooterText(FLS.JSON.COMMON.footer);
	}//---------------------------------------------------;
	
	// --
	function EXIT()
	{
		// All demo states will go back to the main menu
		FlxG.switchState(new State_Main());
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		FLS.debug_keys();
		
		if (FlxG.keys.justPressed.ESCAPE || CTRL.justPressed(CTRL.START))
		{
			EXIT();
		}
	}//---------------------------------------------------;

}// --