//---------------------------------------------------------------------------------------
//  FILE:    X2TacticalGameRuleset_PostBeginTacticalGameObserver.uc
//  AUTHOR:  Dan Kaplan  --  5/12/2014
//  PURPOSE: Provides an event hook for the start of a tactical game.
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class X2TacticalGameBeginObserver extends Object implements(X2GameRulesetEventObserverInterface);

//A core assumption of this method is that new ability state objects cannot be created by abilities running. If this assumption does not
//hold true, the lists below will be incomplete
event CacheGameStateInformation()
{
	`log("XXX X2TacticalGameBeginObserver.CacheGameStateInformation XXX");
}

event Initialize()
{
	`log("XXX X2TacticalGameBeginObserver.Initialize XXX");
}

event PreBuildGameStateFromContext(const out XComGameStateContext NewGameStateContext)
{
	`log("XXX X2TacticalGameBeginObserver.PreBuildGameStateFromContext XXX");
}

event InterruptGameState(const out XComGameState NewGameState)
{	
	`log("XXX X2TacticalGameBeginObserver.InterruptGameState XXX");
}

event PostBuildGameState(const out XComGameState NewGameState)
{	
	`log("XXX X2TacticalGameBeginObserver.PostBuildGameState XXX");
}

