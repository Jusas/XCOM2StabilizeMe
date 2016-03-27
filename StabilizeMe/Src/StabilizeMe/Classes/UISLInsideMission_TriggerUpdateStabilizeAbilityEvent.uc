class UISLInsideMission_TriggerUpdateStabilizeAbilityEvent extends UIScreenListener;

var X2Action_UpdateAbilitiesForSquad AbilityUpdater;

event OnInit(UIScreen screen)
{	

	`log("->(StabilizeMe) OnInit UIScreen called, calling Run");

	if(AbilityUpdater == none)
	{
		AbilityUpdater = new class'X2Action_UpdateAbilitiesForSquad';
		AbilityUpdater.AbilityClassName = 'StabilizeMedkitOwner';
	}
	AbilityUpdater.Run();
	
}

event OnRemoved(UIScreen Screen)
{
	`log("->(StabilizeMe) OnRemoved UIScreen called");
}

defaultproperties
{
	// This event gets triggered whenever we enter the tactical UI.
	ScreenClass = class'UITacticalHUD';
}