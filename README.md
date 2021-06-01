# Advanced-Gem-Crafting
AACv3.3+ for 1.0.7, modified by Schalldampfer

This is my version gathered from the forum.
Thanks for original authors @Raymix and @Hogscraper.
Thanks for @oiad and @theduke77 for updates, @Zupa and @Ghostis for zCraft, dismantling script for @Arstan13.

# Installation:
1. Copy&paste whole scripts and zCraft folder into `DayZ_Epoch_XX.Map\scripts\`
2. Install [clickActions&deployAnything](https://github.com/oiad/deployAnything) by salival
3. Do some coding for crafting:
Add those codes into `DayZ_Epoch_XX.Map\description.ext`
```sqf
	//Advanced Alchemical Crafting
	#include "scripts\Buildables\MT_Defines.hpp"
	#include "scripts\Buildables\Crafting_Defines.hpp"
	#include "scripts\Buildables\Crafting_Dialogs.hpp"
```
Add those codes into your customized `compiles.sqf` or bottom of `init.sqf`
```sqf
	call compile preprocessFileLineNumbers "scripts\Buildables\variables.sqf";//AAC
	call compile preprocessFileLineNumbers "scripts\Buildables\Crafting_Compiles.sqf";//AAC
```
4. You can choose two of them for crafting:

a. Gemcrafting

Add those codes into `DZE_CLICK_ACTIONS` array in `DayZ_Epoch_XX.Map\scripts\clickActions\config.sqf`
```sqf
	//AAC
	["ItemAmethyst","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'scripts\Buildables\Amethyst.sqf';","true"],
	["ItemCitrine","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'scripts\Buildables\Citrine.sqf';","true"],
	["ItemEmerald","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'scripts\Buildables\Emerald.sqf';","true"],
	["ItemObsidian","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'scripts\Buildables\Obsidian.sqf';","true"],
	["ItemRuby","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'scripts\Buildables\Ruby.sqf';","true"],
	["ItemSapphire","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'scripts\Buildables\Sapphire.sqf';","true"],
	["ItemTopaz","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'scripts\Buildables\Topaz.sqf';","true"],
	["ItemLightbulb","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'scripts\Buildables\Lights.sqf';","true"],
	["MortarBucket","Crafting Menu","closeDialog 0;createDialog 'Advanced_Crafting';execVM 'scripts\Buildables\Transportation.sqf';","true"],
```

b. zCraft

Add those codes into `DZE_CLICK_ACTIONS` array in `DayZ_Epoch_XX.Map\scripts\clickActions\config.sqf`
```sqf
	//zCraft
	["ItemEtool","Crafting Menu","closeDialog 0;createDialog ""ZCraft"";","true"],
	["ItemPickAxe","Remove Road","closeDialog 0;execVM 'scripts\Buildables\roadDismantle.sqf';","true"],
```
And, in `DayZ_Epoch_XX.Map\description.ext`
```sqf
	//zCraft
	#include "scripts\Buildables\zCraft\description.hpp"
	#include "scripts\Buildables\zCraft\zCraft.hpp"
```
5. Do some jobs for dismantling: by @Arstan13

This step will allow your players to remove items they craft just like they can currently remove Epoch items. If they die, they will no longer be able to remove them. 

In `dayz_code\compiles\fn_selfActions.sqf`, find 
```sqf
    if ((damage _cursorTarget >= DZE_DamageBeforeMaint) && {_cursorTarget isKindOf "ModularItems" || _cursorTarget isKindOf "DZE_Housebase" || _cursorTarget isKindOf "BuiltItems" || _cursorTarget isKindOf "DZ_buildables" || _typeOfCursorTarget == "LightPole_DZ"}) then {
```
and replace with this line:
```sqf
    if ((damage _cursorTarget >= DZE_DamageBeforeMaint) && {_cursorTarget isKindOf "ModularItems" || _cursorTarget isKindOf "DZE_Housebase" || _cursorTarget isKindOf "BuiltItems" || _cursorTarget isKindOf "DZ_buildables" || _typeOfCursorTarget == "LightPole_DZ" || _typeOfCursorTarget in DZE_maintainClasses}) then {
```
This will activate some more missing maintainance menu for objects like Workbench and so on.

And, find 
```sqf
	local _isModular = _cursorTarget isKindOf "ModularItems";
```
and replace with this line:
```sqf
	local _isModular = (_cursorTarget isKindOf "ModularItems" || _typeOfCursorTarget in DZE_maintainClasses);
```

# Add something new:
in MT_Defines.hpp, add new classname like other classnames.

#Battleye
In createvehicle.txt, change all checks from 5 to 1. Previewing and Building needs all items to be in exception.
In scripts.txt, add exceptions (DO NOT REPLACE!) like
```
camCreate  !="cutText [\"\",\"BLACK IN\",0.2];\n\n_camera = \"camera\" camCreate [10,10,5000];\n_camera cameraEffect [\"INTERNAL\",\"BACK\"];"
createDialog  !"0;createDialog 'ZCraft';" !"0;createDialog 'Advanced_Crafting';[]"
createVehicleLocal  !"_objPos set [2,6000];\n_object = _lbText createVehicleLocal _objPos;\n_object setDir _dir;"
cutText  !="_object setDir _dir;\n_object setPos _objPos;\n_objPos = getPos _object;\n\ncutText [\"\",\"BLACK IN\",0.2];"
DZE_PlotManagementAdmins !"_isAdmin = dayz_playerUID in DZE_PlotManagementAdmins;"
hint !"case default {hint \"Error! nothing selected!!!\"};"
lbCurSel !"_lbIndex=lbCurSel 3901;\n_lbText=lbText [3901,_lbIndex];" !"_lbIndex = lbCurSel 3901;\nDZE_buildItem = lbText [3901,_lbIndex];"
nearestObject !"_near = nearestObjects [_target,_buildables,_range];\n_count = count(_near);"
```