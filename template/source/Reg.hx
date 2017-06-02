package;

import djFlixel.FLS;

class Reg extends FLS
{
	// -- This will be called before the first state is created
	public function new()
	{
		super();
		trace("-- Any custom initialization here --");
	}//---------------------------------------------------;
	
	// -- You can override this for customizability
	override function onPostGameReset() 
	{
		super.onPostGameReset();
	}//---------------------------------------------------;
	
	// -- You can override this for customizability
	override function onPreGameReset() 
	{
		super.onPreGameReset();
	}//---------------------------------------------------;
	
	// -- You can override this for customizability
	override function onStateSwitch() 
	{
		super.onStateSwitch();
	}//---------------------------------------------------;

	
}//--