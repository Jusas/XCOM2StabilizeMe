# StabilizeMe

TLDR: StabilizeMe mod for XCOM2. \
Soldiers gain the ability to stabilize any other soldier that is bleeding out and happens to be carrying a medikit.

### A mod for XCOM2

This mod was created to fix one annoying "feature" in the game. The scenario usually goes something like this:

- <insert alien here> destroys your specialist's cover
- <insert alien here> scores a critical hit on your specialist
- Your specialist is knocked unconscious and is bleeding out
  - and by the way, he's the only one with a medikit
- You go: _Oh for f*ck sakes! This is bull!_
- The specialist proceeds to bleed out as nobody around him can help him, even though in practise the victim has a medikit lying right beside him.
 
### How this mod works

The mod's operation is quite simple actually. In essence the mod creates a new ability called _'StabilizeMedkitOwner'_ and injects it to the soldiers in combat. This image describes the technical aspects of the mod:

![Diagram](http://i.imgur.com/toIZ2iA.png "Diagram")

Explained in short:
1. We create a new ability, called _'StabilizeMedkitOwner'_. This ability is like standard stabilize but with special condition, the _X2Condition_StabilizeMedkitOwner_ that checks that the target unit has the standard 'MedikitStabilize' ability and has at least one charge left on that ability.
2. We create a UIScreenListener that listens the screen change to _UITacticalHUD_. That's when we'll do our dirty work. Once UITacticalHUD is on the screen, we're in tactical combat and we can empower our squad with the new godly ability.

_Why do we do this only when we enter tactical combat_ you must be asking - the reason is that in this way even when we load an existing save game in the middle of combat the new abilities get applied. As you load the game, the strategic data is loaded, the squad set up and the tactical UI loaded - and that's when we apply our new ability. So whenever you enter tactical combat your squad members get checked for the ability, if they don't have it yet then the ability gets added.

### License

The freedom of MIT license applies, so have fun!
