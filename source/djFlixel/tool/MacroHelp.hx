package djFlixel.tool;

class MacroHelp
{
	public static macro function getProjectPath() {
		return macro $v{ Sys.getCwd() };
    }
}// --