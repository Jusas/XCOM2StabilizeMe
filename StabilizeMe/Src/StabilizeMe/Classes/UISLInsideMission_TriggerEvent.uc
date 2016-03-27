class UISLInsideMission_TriggerEvent extends UIScreenListener;

var X2Action_UpdateAbilities AbilityUpdater;

event OnInit(UIScreen screen)
{	

	//if(!bFirstRun)
	//	return;
	// Update all existing soldiers in the active squad when entering the tactical UI.
	// We add the 'StabilizeMedkitOwner' ability to all squadmates.
	// This means it working even when loading existing saves.

	//EventManager.RegisterForEvent(ThisObj, 'PlayerTurnBegun', OnPlayerTurnBegun, ELD_OnStateSubmitted);
	//	ELD_Immediate,						// The Listener will be notified in-line (no deferral)
	//  ELD_OnStateSubmitted,				// The Listener will be notified after the associated game state is processed

	//bFirstRun = false;
	`log("->(StabilizeMe) OnInit UIScreen called, calling Register");

	if(AbilityUpdater == none)
	{
		AbilityUpdater = new class'X2Action_UpdateAbilities';
	}
	AbilityUpdater.Register();
	
	//`XEVENTMGR.RegisterForEvent(EventObj, 'PlayerTurnBegun', AbilityUpdater.OnPlayerTurnBegun, ELD_OnStateSubmitted);
	
	//OnTacticalBeginPlay
	//OnUnitBeginPlay
	
}

event OnRemoved(UIScreen Screen)
{
	`log("->(StabilizeMe) OnRemoved UIScreen called, calling UnRegister");
	AbilityUpdater.UnRegister();
}

defaultproperties
{
	// This event gets triggered whenever we enter the tactical UI.
	ScreenClass = class'UITacticalHUD';
}