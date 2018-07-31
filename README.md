# Advanced-Gem-Crafting
AACv3.3+ for 1.0.6.2, modified by Schalldampfer

This is my version gathered from the forum.
Thanks for original authors @Raymix and @Hogscraper.
Thanks for @oiad and @theduke77 for updates, @Zupa and @Ghostis for zCraft, dismantling script for @Arstan13.

# Installation:
1. Copy&paste whole scripts and zCraft folder into `DayZ_Epoch_XX.Map\Custom\`
2. Install [clickActions&deployAnything](https://github.com/oiad/deployAnything) by salival
3. Do some coding for crafting:
Add those codes into `DayZ_Epoch_XX.Map\description.ext`
```sqf
	//Advanced Alchemical Crafting
	#include "Custom\Buildables\MT_Defines.hpp"
	#include "Custom\Buildables\Crafting_Defines.hpp"
	#include "Custom\Buildables\Crafting_Dialogs.hpp"
```
Add those codes into your customized `compiles.sqf` or bottom of `init.sqf`
```sqf
	call compile preprocessFileLineNumbers "Custom\Buildables\variables.sqf";//AAC
	call compile preprocessFileLineNumbers "Custom\Buildables\Crafting_Compiles.sqf";//AAC
```
4. You can choose two of them for crafting:

a. Gemcrafting

Add those codes into `DZE_CLICK_ACTIONS` array in `DayZ_Epoch_XX.Map\scripts\clickActions\config.sqf`
```sqf
	//AAC
	["ItemAmethyst","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'Custom\Buildables\Amethyst.sqf';","true"],
	["ItemCitrine","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'Custom\Buildables\Citrine.sqf';","true"],
	["ItemEmerald","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'Custom\Buildables\Emerald.sqf';","true"],
	["ItemObsidian","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'Custom\Buildables\Obsidian.sqf';","true"],
	["ItemRuby","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'Custom\Buildables\Ruby.sqf';","true"],
	["ItemSapphire","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'Custom\Buildables\Sapphire.sqf';","true"],
	["ItemTopaz","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'Custom\Buildables\Topaz.sqf';","true"],
	["ItemLightbulb","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'Custom\Buildables\Lights.sqf';","true"],
	["MortarBucket","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'Custom\Buildables\Transportation.sqf';","true"],
```

b. zCraft

Add those codes into `DZE_CLICK_ACTIONS` array in `DayZ_Epoch_XX.Map\scripts\clickActions\config.sqf`
```sqf
	//zCraft
	["ItemEtool","Crafting Menu","closeDialog 0;createDialog ""ZCraft"";","true"],
	["ItemPickAxe","Remove Road","closeDialog 0;execVM 'Custom\Buildables\roadDismantle.sqf';","true"],
```
And, in `DayZ_Epoch_XX.Map\description.ext`
```sqf
	//zCraft
	#include "Custom\Buildables\zCraft\description.hpp"
	#include "Custom\Buildables\zCraft\zCraft.hpp"
```
5. Do some jobs for dismantling: by @Arstan13

This step will allow your players to remove items they craft just like they can currently remove Epoch items. If they die, they will no longer be able to remove them. 
 
open `fn_selfActions.sqf` find 
```sqf
_isModular = _cursorTarget isKindOf "ModularItems";
```
and change that entire line to:
```sqf
_isModular = (_cursorTarget isKindOf "ModularItems") or ((typeOf _cursorTarget) in Custom_Buildables);
```
add this code
```sqf
  if ((_typeOfCursorTarget in Custom_Buildables) && (player distance _cursorTarget <= 5) && {speed player <= 1} && (_canDo)) then {
		_hasAccess = [player, _cursorTarget] call FNC_check_access; //checks if player has rights to object
		_allowed = ((_hasAccess select 0) || (_hasAccess select 2) || (_hasAccess select 3) || (_hasAccess select 4)); //returns values from fn_checkAccess of [_player, _isOwner, _isFriendly, _isPlotOwner]
		if ((s_custom_dismantle < 0) && (_allowed || (_hasAccess select 1))) then {
			s_custom_dismantle = player addAction [("<t color=""#FF0000"">"+("Dismantle Object") + "</t>"), "scripts\buildables\dismantle.sqf",_cursorTarget, 3, true, true];
		};
	} else {
		player removeAction s_custom_dismantle;
		s_custom_dismantle = -1;
	};
  
  if (_typeOfCursorTarget == "Plastic_Pole_EP1_DZ" && {speed player <= 1}) then {
		_hasAccess = [player, _cursorTarget] call FNC_check_access; //checks if player has rights to object
		_allowed = ((_hasAccess select 0) || (_hasAccess select 2) || (_hasAccess select 3) || (_hasAccess select 4)); //returns values from fn_checkAccess of [_player, _isOwner, _isFriendly, _isPlotOwner]
		if ((s_amplifier_dismantle < 0) && (_allowed || (_hasAccess select 1))) then {
			s_amplifier_dismantle = player addAction [("<t color=""#b7b7b5"">"+("Dismantle Amplifier") + "</t>"), "scripts\buildables\ampDismantle.sqf",_cursorTarget, 3, true, true];
		};
	} else {
		player removeAction s_amplifier_dismantle;
		s_amplifier_dismantle = -1;
	};
```
above tame dogs code to use the custom dismantle script for all the buildables

this goes in the self_action resets in `fn_selfActions.sqf`
```sqf
player removeAction s_custom_dismantle; //buildables dismantle
s_custom_dismantle = -1;
player removeAction s_amplifier_dismantle;
s_amplifier_dismantle = -1;
```
and this into your `variables.sqf`
```sqf
s_custom_dismantle = -1;
s_amplifier_dismantle = -1;
```
