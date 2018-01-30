package;
import djFlixel.FLS;
import djFlixel.SAVE;

/**
 * Customized initialization, etc
 * ...
 */
class Reg extends FLS
{

	public function new() 
	{
		super();
		
		// User Code
		// -
		// This part is run once per app lifetime
		// A good place to initialize e.g. savegames
		
		SAVE.init("megademo", 1);
		SAVE.setSlot(0);
		
		// -- Try to get the AntiAliasing toggle if was saved on a previous run
		if (SAVE.exists("AA"))
		{
			FLS.ANTIALIASING = SAVE.load("AA");
		}
		
	}//---------------------------------------------------;
	
	// -- Sets the AntiAliasing/Smoothing and saves
	// --
	public static function setAA(val:Bool)
	{
		FLS.ANTIALIASING = val;
		SAVE.setSlot(0);
		SAVE.save("AA", FLS.ANTIALIASING);
		SAVE.flush();
	}//---------------------------------------------------;

	override function onStateSwitch() 
	{
		super.onStateSwitch();
		// User Code
	}//---------------------------------------------------;
	
	override function onPostGameReset() 
	{
		// User Code
	}//---------------------------------------------------;
	
	override function onPreGameReset() 
	{
		// User Code
	}//---------------------------------------------------;
	
}// --