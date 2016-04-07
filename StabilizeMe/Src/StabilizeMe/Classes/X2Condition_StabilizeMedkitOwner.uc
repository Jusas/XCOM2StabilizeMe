class X2Condition_StabilizeMedkitOwner extends X2Condition;

// Check for a 'MedikitStabilize' ability in the target unit that the unit would be able to activate.
static function bool CheckForMedkit(XComGameState_Unit TargetUnit)
{
	local StateObjectReference AbilityRef;
	local XComGameState_Ability AbilityState;
	local XComGameStateHistory History;
	local StateObjectReference Item;
	local XComGameState_Item ItemState;
	local X2AbilityTemplate AbilityTemplate;
	local X2Effect Effect;
	local X2Effect_RemoveEffects RemoveEffect;
	local name EffectName;
	

	if (TargetUnit == none)
		return false;

	History = `XCOMHISTORY;

	`log("->(StabilizeMe) CheckForMedkit");

	// Check all the abilities for one that has a RemoveEffect that removes the BleedingOutName effect.
	foreach TargetUnit.Abilities(AbilityRef)
	{
		AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));
		
		// Skip me!
		if(AbilityState.GetMyTemplateName() == 'StabilizeMedkitOwner')
		{
			continue;
		}

		AbilityTemplate = AbilityState.GetMyTemplate();
		foreach AbilityTemplate.AbilityTargetEffects(Effect)
		{
			if(Effect.IsA('X2Effect_RemoveEffects'))
			{
				//`log("->(StabilizeMe) Found X2Effect_RemoveEffects entry from soldier's ability");
				RemoveEffect = X2Effect_RemoveEffects(Effect);
				foreach RemoveEffect.EffectNamesToRemove(EffectName)
				{
					if(EffectName == class'X2StatusEffects'.default.BleedingOutName)
					{
						//`log("->(StabilizeMe) Found BleedinOutName entry EffectNamesToRemove");
						if(AbilityState.GetCharges() > 0)
						{
							//`log("->(StabilizeMe) Ability has " $ AbilityState.GetCharges() $ " charges, SUCCESS!");
							return true;
						}
						//`log("->(StabilizeMe) Ability has " $ AbilityState.GetCharges() $ " charges, FAILURE!");
					}
				}
			}
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