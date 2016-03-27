class X2Condition_StabilizeMedkitOwner extends X2Condition;

// Check for a 'MedikitStabilize' ability in the target unit that the unit would be able to activate.
static function bool CheckForMedkit(XComGameState_Unit TargetUnit)
{
	local StateObjectReference AbilityRef;
	local XComGameState_Ability AbilityState;
	local XComGameStateHistory History;

	if (TargetUnit == none)
		return false;

	History = `XCOMHISTORY;

	//`log("->(StabilizeMe) CheckForMedkit");
		
	AbilityRef = TargetUnit.FindAbility('GremlinStabilize');
	if(AbilityRef.ObjectID == 0)
	{
		AbilityRef = TargetUnit.FindAbility('MedikitStabilize');
	}
	
	if(AbilityRef.ObjectID != 0)
	{
		AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));
		if(AbilityState.GetCharges() > 0)
		{
			return true;
		}
	}
	
	return false;
	
}

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{ 
	local XComGameState_Unit TargetUnit;

	TargetUnit = XComGameState_Unit(kTarget);
	if (TargetUnit == none)
		return 'AA_NotAUnit';

	if (CheckForMedkit(TargetUnit))
		return 'AA_Success';

	return 'AA_TargetHasNoStabilizeAbility';
}

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource) 
{ 
	local XComGameState_Unit SourceUnit, TargetUnit;

	SourceUnit = XComGameState_Unit(kSource);
	TargetUnit = XComGameState_Unit(kTarget);

	if (SourceUnit == none || TargetUnit == none)
		return 'AA_NotAUnit';

	if (SourceUnit.ControllingPlayer == TargetUnit.ControllingPlayer)
	{
		// 144 is the default CarryUnit distance.
		if(class'Helpers'.static.IsUnitInRangeFromLocations(SourceUnit, TargetUnit, SourceUnit.TileLocation, TargetUnit.TileLocation, 0, 144))
		{
			return 'AA_Success';
		}
		return 'AA_NotInRange';
	}
		

	return 'AA_UnitIsHostile';
}