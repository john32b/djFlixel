package djFlixel.gui.listoption;

import djFlixel.gui.list.VListMenu;
import djFlixel.gui.Styles;
import flixel.FlxG;
import flixel.text.FlxText;


class MenuOptionOneof extends MenuOptionBase
{
	// Displayed text
	var label2:FlxText;

	// Hold 2 arrows and their status
	var arrows:Array<FlxText>;
	var arrowStat:Array<Bool>;
	
	// Arrow movement
	var arrow_maxNudge:Int;	// # autogenerated # How far to nudge the arrows, ( depends on fontsize )
	var arrow_nudge:Int;	// Current nudging of the arrows
	var arrow_timer:Float;	// Keep track of the update time
	var arrows_flag:Bool;	// Are the arrows currently showing? Useful for the update function
	
	// Helper, I need to know where does the part 2 starts
	var part2_start:Float = 0;
	
	//---------------------------------------------------;
	public function new(P:VListMenu) 
	{
		super(P);
		
		label2 = new FlxText();
		Styles.styleOptionText(label2, style);
		add(label2);
		
		// --
		arrows = [];
		arrows[0] = new FlxText(0, 0, 0, "<");
		arrows[1] = new FlxText(0, 0, 0, ">");
		Styles.styleOptionText(arrows[0], style);
		Styles.styleOptionText(arrows[1], style);
		arrows[0].color = style.color_default;
		arrows[1].color = style.color_default;
		arrows[0].visible = false;
		arrows[1].visible = false;
		add(arrows[0]);
		add(arrows[1]);
		// --
		arrowStat = [];		
		arrow_maxNudge = Std.int(style.fontSize / 3);
		arrows_flag = false;
		
	}//---------------------------------------------------;
		
	// -- Animate the arrows
	override public function update(elapsed:Float):Void 
	{
		if (arrows_flag)
		{
			arrow_timer -= FlxG.elapsed;
			if (arrow_timer < 0) {
				arrow_timer = 0.12; // # param
				arrows[0].x = this.x + part2_start - arrow_nudge;
				arrows[1].x = label2.x + label2.fieldWidth + arrow_nudge;
				arrow_nudge++;
				if (arrow_nudge > arrow_maxNudge)
					arrow_nudge = 0;
			}
		}
		
		super.update(elapsed);
	}//---------------------------------------------------;
	
	// --
	override function updateElements() 
	{
		super.updateElements();
		
		// The left arrow has a constant X, so check it once
		part2_start = label.fieldWidth + PADDING_FROM_LABEL;
		
		label2.y = 0;
		label2.x = part2_start + arrows[0].width;
		
		updateOptionData();
		
	}//---------------------------------------------------;
	// --
	override function state_default() 
	{
		super.state_default();
		label2.color = style.color_accent;
		arrows[0].visible = false;
		arrows[1].visible = false;
		arrows_flag = false;
	}//---------------------------------------------------;
	// --
	override function state_focused() 
	{
		super.state_focused();
		label2.color = style.color_focused;
		
		arrows_flag = true;
		// Check visibility and reset nudge
		_updateArrow();
	}//---------------------------------------------------;
	// --
	override function state_disabled() 
	{
		super.state_disabled();
		label2.color = style.color_disabled;
		arrows[0].visible = false;
		arrows[1].visible = false;
		arrows_flag = false;
	}//---------------------------------------------------;
	
	// --
	override public function sendInput(inputName:String) 
	{
		switch(inputName) {
			
			case "right":
				if (opt.data.current < opt.data.pool.length - 1) {
					opt.data.current ++;
					updateOptionData();
					parent.callback_option("optChange");
				};
				
			case "left":
				if (opt.data.current > 0) {
					opt.data.current--;
					updateOptionData();
					parent.callback_option("optChange");
				}
		}
	}//---------------------------------------------------;
	// --
	// Called once on data set, and then everytime the data changes
	function updateOptionData()
	{
		arrowStat[0] = (opt.data.current > 0);
		arrowStat[1] = (opt.data.current < opt.data.pool.length - 1);
		label2.text = opt.data.pool[opt.data.current];
		
		// Check visibility and reset nudge
		_updateArrow();
	}//---------------------------------------------------;
	
	// Separate function so that the caller can be overrided
	function _updateArrow()
	{
		// Note: Arrow 2 X is calculated on update();
		// A timer of 0 forces the arrows to update on the next cycle
		arrow_timer = 0;
		arrow_nudge = 0;

		if (isFocused)
		{
			arrows[0].visible = arrowStat[0];
			arrows[1].visible = arrowStat[1];
		}
	}//---------------------------------------------------;
	
}// -- end --