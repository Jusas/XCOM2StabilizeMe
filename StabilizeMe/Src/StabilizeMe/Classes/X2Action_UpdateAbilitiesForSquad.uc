/**
 * The class that contains the actual method that adds abilities to the current squad.
 */
class X2Action_UpdateAbilitiesForSquad extends Object;

var name AbilityClassName;

function Run()
{
	local XComGameState_HeadquartersXCom XComHQ;
	local StateObjectReference UnitRef;
		
	`log("->(StabilizeMe) XCOM HQ Squad getting abilities");

	// We process the soldiers in the current selected squad (the squad in the mission).
	XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	foreach XComHQ.Squad(UnitRef)
	{
		class'X2Action_UpdateAbilitiesForSquad'.static.UpdateAbilityOnUnit(UnitRef, AbilityClassName);
	}
	
}


static function UpdateAbilityOnUnit(StateObjectReference unitRef, name abilityName)
{
	local StateObjectReference AbilityRef;
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

			// Note here: TacticalRules.SubmitGameState did not work when tested loading of Ironman campaign savegame.
			// History.AddGameStateToHistory however did. Also worked in pure Tactical debug tests.
			//TacticalRules.SubmitGameState(NewGameState);

			History.AddGameStateToHistory(NewGameState);

			`log("->(StabilizeMe) Added ability '" $ abilityName $ "' to soldier " $ TargetUnit.GetFirstName() $ " " $ TargetUnit.GetLastName());
		}
	}
}
