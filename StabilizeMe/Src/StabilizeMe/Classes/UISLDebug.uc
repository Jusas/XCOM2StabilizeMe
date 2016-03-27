class UISLDebug extends UIScreenListener;

event OnInit(UIScreen screen)
{	

	`log("->(DEBUG) OnInit UIScreen called for " $ Screen.Name);
	
}

event OnRemoved(UIScreen Screen)
{
	`log("->(DEBUG) OnRemoved UIScreen called for " $ Screen.Name);
}

defaultproperties
{

}// This is an Unreal Script