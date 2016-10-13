/**
 * A new ability that allows any soldier to stabilize any bleeding out medkit owner.
 */
class X2Ability_StabilizeMedkitOwnerAbility extends X2Ability 
	config(GameCore);


var config float CARRY_UNIT_RANGE;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;	
	Templates.AddItem(AddStabilizeMedkitOwnerAbility());	
	return Templates;
}


static function X2AbilityTemplate AddStabilizeMedkitOwnerAbility()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityTarget_Single            SingleTarget;
	local X2Condition_UnitProperty          TargetCondition, ShooterCondition;
	local X2AbilityTrigger_PlayerInput      InputTrigger;
	local X2Effect_RemoveEffects            RemoveEffects;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'StabilizeMedkitOwner');
	
	// Costs one action point, just like normal stabilize.
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Template.AbilityToHitCalc = default.DeadEye;

	// Standard restrictions apply to the operator; must be alive, must not be panicked, etc.
	ShooterCondition = new class'X2Condition_UnitProperty';
	ShooterCondition.ExcludeDead = true;
	Template.AbilityShooterConditions.AddItem(ShooterCondition);
	Template.AddShooterEffectExclusions();
	
	// The target conditions: Must be a friendly, must be within carry range, must be bleeding out.
	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.CanBeCarried = true;
	TargetCondition.ExcludeAlive = false;               
	TargetCondition.ExcludeDead = false;
	TargetCondition.ExcludeFriendlyToSource = false;
	TargetCondition.ExcludeHostileToSource = true;     
	TargetCondition.RequireWithinRange = true;
	TargetCondition.IsBleedingOut = true;
	TargetCondition.WithinRange = default.CARRY_UNIT_RANGE; // this does nothing apparently.
	Template.AbilityTargetConditions.AddItem(TargetCondition);

	// This is where we check that the target unit has a usable medkit.
	Template.AbilityTargetConditions.AddItem(new class'X2Condition_StabilizeMedkitOwner');	

	// Ability removes the bleeding out effect. Once removed, the target becomes unconscious.
	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2StatusEffects'.default.BleedingOutName);
	Template.AddTargetEffect(RemoveEffects);
	Template.AddTargetEffect(class'X2StatusEffects'.static.CreateUnconsciousStatusEffect());
	
	SingleTarget = new class'X2AbilityTarget_Single';
	Template.AbilityTargetStyle = SingleTarget;

	InputTrigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(InputTrigger);

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_stabilize";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STABILIZE_PRIORITY;
	Template.Hostility = eHostility_Defensive;
	Template.bDisplayInUITooltip = false;
	Template.bLimitTargetIcons = true;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;

	Template.ActivationSpeech = 'StabilizingAlly';

	Template.BuildNewGameStateFn = StabilizeMedkitOwner_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	
	`log("->(StabilizeMe) AddStabilizeMedkitOwnerAbility has been run.");

	return Template;
}

static function XComGameState StabilizeMedkitOwner_BuildGameState(XComGameStateContext Context)
{
	local XComGameState NewGameState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit Target;
	local XComGameState_Ability AbilityState, UpdatedAbility;
	local XComGameState_Item Item;

	NewGameState = `XCOMHISTORY.CreateNewGameState(true, Context);
	// usual ability handling
	TypicalAbility_FillOutGameState(NewGameState);

	// deduct an ability charge from the target, on the same ability that made StabilizeMedkitOwner available
	AbilityContext = XComGameStateContext_Ability(Context);
	Target = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
	AbilityState = class'X2Condition_StabilizeMedkitOwner'.static.CheckForMedkit(Target);

	if(AbilityState != none && AbilityState.GetCharges() > 0)
	{
		// try to get the ability state from the NewGameState
		// otherwise create and add it
		UpdatedAbility = XComGameState_Ability(NewGameState.GetGameStateForObjectID(AbilityState.ObjectID));
		if(UpdatedAbility == none)
		{
			UpdatedAbility = XComGameState_Ability(NewGameState.CreateStateObject(AbilityState.class, AbilityState.ObjectID));
			NewGameState.AddStateObject(UpdatedAbility);
		}


		// remove 1 charge

		// if the ability uses ammo as charges,
		// deduct the amount of ammo that would be consumed from the source item
		if(UpdatedAbility.GetMyTemplate().bUseAmmoAsChargesForHUD)
		{
			if (UpdatedAbility.SourceAmmo.ObjectID > 0)
			{
				Item = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(UpdatedAbility.SourceAmmo.ObjectID));
			}

			// if SourceAmmo does not exist or coult not be found, try SourceWeapon
			if(Item == none && UpdatedAbility.SourceWeapon.ObjectID > 0)
			{
				Item = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(UpdatedAbility.SourceWeapon.ObjectID));
			}

			if(Item != none && Item.Ammo > 0)
			{
				// update the item and add it to NewGameState
				Item = XComGameState_Item(NewGameState.CreateStateObject(Item.class, Item.ObjectID));
				Item.Ammo -= UpdatedAbility.GetMyTemplate().iAmmoAsChargesDivisor;
				NewGameState.AddStateObject(Item);
			}
		}

		// otherwise subtract from iCharges, if not zero and not negative/infinite
		else if(UpdatedAbility.iCharges > 0)
		{
			UpdatedAbility.iCharges -= 1;
		}
	}
	return NewGameState;
}
