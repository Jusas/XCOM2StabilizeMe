/**
 * A helper class, contains the actual method that adds abilities.
 */
class X2Action_UpdateAbilities extends Object;

function Register()
{
	local XComGameState_HeadquartersXCom XComHQ;
	local StateObjectReference UnitRef;

	local X2EventManager EM;
	local Object EventObj;
	EventObj = self;
	EM = `XEVENTMGR;

	
	`log("->(StabilizeMe) XCOM HQ Squad getting abilities");
	XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	foreach XComHQ.Squad(UnitRef)
	{
		class'X2Action_UpdateAbilities'.static.UpdateAbilityOnUnit(UnitRef, 'StabilizeMedkitOwner');
	}
	

	/*
	`log("->(StabilizeMe) Registering listener for OnUnitBeginPlay");
	if(!EM.AnyListenersForEvent('OnUnitBeginPlay', EventObj))
	{
		EM.RegisterForEvent(EventObj, 'OnUnitBeginPlay', OnAddAbilitiesEvent, ELD_OnStateSubmitted);
	}
	//`XEVENTMGR.TriggerEvent('ObjectMoved', MovingUnitState, MovingUnitState, NewGameState);
	if(!EM.AnyListenersForEvent('PlayerTurnBegun', EventObj))
	{
		EM.RegisterForEvent(EventObj, 'PlayerTurnBegun', OnAddAbilitiesEvent, ELD_OnStateSubmitted);
	}
	*/
}

function UnRegister()
{
	local Object EventObj;
	EventObj = self;

	`log("->(StabilizeMe) Unregistering the listener for OnUnitBeginPlay");
	`XEVENTMGR.UnRegisterFromEvent(EventObj, 'OnUnitBeginPlay');
}

static function UpdateAbilityOnUnit(StateObjectReference unitRef, name abilityName)
{
	local StateObjectReference AbilityRef;
	local XComGameState_Ability AbilityState;
	local XComGameStateHistory History;
	local XComGameState_Unit TargetUnit;
	local X2AbilityTemplateManager AbilityTemplateMgr;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState NewGameState;
	local XComGameState_Unit NewUnitState;
	local X2TacticalGameRuleset TacticalRules;
	local XComGameStateContext_ChangeContainer ChangeContainer;

	History = `XCOMHISTORY;
	TacticalRules = `TACTICALRULES;
	TargetUnit = XComGameState_Unit(History.GetGameStateForObjectId(unitRef.ObjectID));
	AbilityTemplateMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	
	if(!TargetUnit.IsSoldier())
	{
		return;
	}

	`log("->(StabilizeMe) UpdateAbilityOnUnit being run for " $ TargetUnit.Name);

	// Check if the soldier has the ability already - if not, add it.
	AbilityRef = TargetUnit.FindAbility(abilityName);
	if(AbilityRef.ObjectID == 0)
	{		
		AbilityTemplate = AbilityTemplateMgr.FindAbilityTemplate(abilityName);
		if(AbilityTemplate != none)
		{
			// New state is needed when tampering with abilities.
			ChangeContainer = class'XComGameStateContext_ChangeContainer'.static.CreateEmptyChangeContainer("Gain ability '" $ abilityName $ "'");
			NewGameState = History.CreateNewGameState(true, ChangeContainer);
			NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', TargetUnit.ObjectID));
			NewGameState.AddStateObject(NewUnitState);
			TacticalRules.InitAbilityForUnit(AbilityTemplate, NewUnitState, NewGameState);

			TacticalRules.SubmitGameState(NewGameState);

			`log("->(StabilizeMe) Added ability '" $ abilityName $ "' to soldier");
			`log(TargetUnit.GetFirstName());
		}
	}
}


function EventListenerReturn OnAddAbilitiesEvent(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateHistory History;
	local StateObjectReference UnitRef;
	local XComGameState_Unit UnitState;
	local Object EventObj;
	
	EventObj = self;

	
	UnitState = XComGameState_Unit(EventData);

	History = `XCOMHISTORY;

	`log("->(StabilizeMe) OnAddAbilitiesEvent, source event name is '" $ EventID $ "'");
	
	// Run ObjectMoved only once - this is to have the adding of abilities happen right after loading a game.
	if(EventID == 'PlayerTurnBegun')
	{
		// get player units somehow
	}
	if(EventID == 'OnUnitBeginPlay')
	{
		UnitState = XComGameState_Unit(EventData);
		UpdateAbilityOnUnit(UnitState.GetReference(), 'StabilizeMedkitOwner');
	}
	/*
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	foreach XComHQ.Squad(UnitRef)
	{
		class'X2Action_UpdateAbilities'.static.UpdateAbilityOnUnit(UnitRef, 'StabilizeMedkitOwner');
	}
	*/
	//native function UnRegisterFromEvent(const ref Object SourceObj, Name EventID);
	//`log("->(StabilizeMe) Unregistering OnAddAbilitiesEvent");
	//`XEVENTMGR.UnRegisterFromEvent(EventObj, 'OnUnitBeginPlay');

	return ELR_NoInterrupt;
}