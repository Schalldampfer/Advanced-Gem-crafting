//Modified modular_build.sqf
if (dayz_actionInProgress) exitWith {localize "str_epoch_player_40" call dayz_rollingMessages;};
dayz_actionInProgress = true;

private ["_abort","_reason","_distance","_isNear","_lockable","_isAllowedUnderGround","_offset","_classname","_zheightdirection","_zheightchanged","_rotate","_objectHelperPos","_objHDiff","_position","_isOk","_dir","_vector","_cancel","_location2","_buildOffset","_location","_limit","_finished","_proceed","_counter","_combination_1_Display","_combination_1","_combination_2","_combination_3","_combination","_combinationDisplay","_combination_4","_num_removed","_tmpbuilt","_vUp","_classnametmp","_text","_ghost","_objectHelper","_location1","_object","_helperColor","_canDo","_pos","_onLadder","_vehicle","_inVehicle","_needNear","_canBuild","_friendsArr"];

////////////////////////////////////////
_AdminCraft = dayz_playerUID in Admin_Crafting;

//Get building name
_lbIndex = lbCurSel 3901;
DZE_buildItem = lbText [3901,_lbIndex];

//Item check

//create arrays for checking whether or not the player
//has the correct tools and materials to make the desired item
_requiredtools = getArray (missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> DZE_buildItem >> "requiredtools");
_requiredmaterials = getArray (missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> DZE_buildItem >> "requiredmaterials");
_RT_temp=getArray (missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> DZE_buildItem >> "requiredtools");
_RM_temp=getArray (missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> DZE_buildItem >> "requiredmaterials");
_hastools = false;
_hasmaterials = false;
_weaps=[];
_mags=[];

_weaps=weapons player;
_mags=magazines player;
_tmp_Pos=0;
_counter=0;

{
	_tmp_Pos= _weaps find _x;
	if (_tmp_Pos > -1) then {
		_requiredtools set [_counter,objNull];
		_weaps set [_tmp_Pos,objNull];
	};
	_counter = _counter + 1;
} forEach _RT_temp;

_requiredtools=_requiredtools-[objNull];
_weaps=_weaps-[objNull];

_tmp_Pos=0;
_counter=0;
{
	_tmp_Pos= _mags find _x;
	if (_tmp_Pos > -1) then {
		_requiredmaterials set [_counter,objNull];
		_mags set [_tmp_Pos,objNull];
	};
	_counter = _counter + 1;
} forEach _RM_temp;
_requiredmaterials=_requiredmaterials-[objNull];
_mags=_mags-[objNull];

if(((count _requiredmaterials) == 0) or (_AdminCraft)) then {
	_hasmaterials = true;
};
if(((count _requiredtools) == 0) or (_AdminCraft)) then {
	_hastools = true;
};

//Create the message to display if player is missing any of the required tools
if (!_hasTools) then{
	_HT_temp = "";
	{  
		_HT_temp = _HT_temp+" " + getText (configFile >> "CfgWeapons" >> _x >> "displayName") + ",";
	} foreach _requiredtools;
	_HT_temp = format[localize "str_crafting_missing",_HT_temp,""];
};

//Create the message to display if player is missing any of the required materials
if (!_hasMaterials) then{
	_HM_temp= "";
	{  
		if (getText (configFile >> "CfgMagazines" >> _x >> "displayName")=="Supply Crate") then{
			_HM_temp = _HM_temp+" " + getText (configFile >> "CfgMagazines" >> _x >> "descriptionShort") + ",";
		} else {
			_HM_temp = _HM_temp+" " + getText (configFile >> "CfgMagazines" >> _x >> "displayName") + ",";
		};
	} foreach _requiredmaterials;
	_HM_temp = format[localize "str_crafting_missing",_HM_temp,""];
};

if (!_hasTools) exitWith {dayz_actionInProgress = false; format["%1",_HT_temp] call dayz_rollingMessages;};
if (!_hasMaterials) exitWith {dayz_actionInProgress = false; format["%1",_HM_temp] call dayz_rollingMessages;};

//PlotCheck
_requireplot = DZE_requireplot;
if(_AdminCraft) then {
	_requireplot=0;
} else {
	if(isNumber (missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> _classname >> "requireplot")) then {
		_requireplot = getNumber(missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> _classname >> "requireplot");
	};
};

_canBuild = false;
_nearestPole = objNull;
_ownerID = 0;
_friendlies = [];

_plotcheck = [player, false] call FNC_find_plots;
_distance = DZE_PlotPole select 0;
_needText = localize "str_epoch_player_246";
_exitWith = "";

_IsNearPlot = _plotcheck select 1;
_nearestPole = _plotcheck select 2;

if (_IsNearPlot == 0) then {
	if (_requireplot == 0) then {
		_canBuild = true;
	} else {
		_exitWith = localize "STR_EPOCH_PLAYER_135";
	};
} else {
	_ownerID = _nearestPole getVariable["CharacterID","0"];
	if (dayz_characterID == _ownerID) then {
		_canBuild = true;
	} else {
		if (DZE_permanentPlot) then {
			_buildcheck = [player, _nearestPole] call FNC_check_access;
			_isowner = _buildcheck select 0;
			_isfriendly = ((_buildcheck select 1) or (_buildcheck select 3));
			if (_isowner || _isfriendly) then {
				_canBuild = true;
			} else {
				_exitWith = localize "STR_EPOCH_PLAYER_134";
			};
		} else {
			_friendlies = player getVariable ["friendlyTo",[]];
			if (_ownerID in _friendlies) then {
				_canBuild = true;
			} else {
				_exitWith = localize "STR_EPOCH_PLAYER_134";
			};
		};
	};
};

// _message
if(!_canBuild) exitWith { dayz_actionInProgress = false; format[_exitWith,_needText,_distance] call dayz_rollingMessages; };

////////////////////////////////////////

_pos = [player] call FNC_GetPos;

_onLadder =	(getNumber (configFile >> "CfgMovesMaleSdr" >> "States" >> (animationState player) >> "onLadder")) == 1;

_vehicle = vehicle player;
_inVehicle = (_vehicle != player);

DZE_Q = false;
DZE_Z = false;

DZE_Q_alt = false;
DZE_Z_alt = false;

DZE_Q_ctrl = false;
DZE_Z_ctrl = false;

DZE_5 = false;
DZE_4 = false;
DZE_6 = false;

DZE_F = false;

DZE_cancelBuilding = false;

DZE_updateVec = false;
DZE_memDir = 0;
DZE_memForBack = 0;
DZE_memLeftRight = 0;

call gear_ui_init;
closeDialog 1;

if (dayz_isSwimming) exitWith {dayz_actionInProgress = false; localize "str_player_26" call dayz_rollingMessages;};
if (_inVehicle) exitWith {dayz_actionInProgress = false; localize "str_epoch_player_42" call dayz_rollingMessages;};
if (_onLadder) exitWith {dayz_actionInProgress = false; localize "str_player_21" call dayz_rollingMessages;};
if (player getVariable["combattimeout",0] >= diag_tickTime) exitWith {dayz_actionInProgress = false; localize "str_epoch_player_43" call dayz_rollingMessages;};

//DZE_buildItem = _this;

_abort = false;
_reason = "";

//_needNear = getArray (configFile >> "CfgMagazines" >> DZE_buildItem >> "ItemActions" >> "Build" >> "neednearby");
_needNear = getArray (missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> DZE_buildItem >> "neednearby");

{
	call {
		if (_x == "fire") exitwith {
			_distance = 3;
			_isNear = {inflamed _x} count (_pos nearObjects _distance);
			if (_isNear == 0) then {
				_abort = true;
				_reason = localize "STR_EPOCH_FIRE";
			};
		};
		if (_x == "workshop") exitwith {
			_distance = 3;
			_isNear = count (nearestObjects [_pos, DZE_Workshops, _distance]);
			if (_isNear == 0) then {
				_abort = true;
				_reason = localize "STR_EPOCH_WORKBENCH_NEARBY";
			};
		};
		if (_x == "fueltank") exitwith {
			_distance = 30;
			_isNear = count (nearestObjects [_pos, dayz_fuelsources, _distance]);
			if (_isNear == 0) then {
				_abort = true;
				_reason = localize "STR_EPOCH_VEHUP_TNK";
			};
		};
	};
} count _needNear;

if (_abort) exitWith {
	format[localize "str_epoch_player_135",_reason,_distance] call dayz_rollingMessages;
	dayz_actionInProgress = false;
};

_canBuild = [_pos, DZE_buildItem, true] call dze_buildChecks;
if (_canBuild select 0) then {
	_classname = DZE_buildItem;
	_classnametmp = _classname;
	if (isText (missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> DZE_buildItem >> "buildText")) then {
		_text = getText (missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> DZE_buildItem >> "buildText");
	} else {
		_text = getText (configFile >> "CfgVehicles" >> _classname >> "displayName");
	};
	_ghost = getText (configFile >> "CfgVehicles" >> _classname >> "ghostpreview");

	_lockable = 0;
	if (isNumber (configFile >> "CfgVehicles" >> _classname >> "lockable")) then {
		_lockable = getNumber(configFile >> "CfgVehicles" >> _classname >> "lockable");
	};

	_isAllowedUnderGround = 0; //1
	if (isNumber (configFile >> "CfgVehicles" >> _classname >> "nounderground")) then {
		_isAllowedUnderGround = getNumber(configFile >> "CfgVehicles" >> _classname >> "nounderground");
	};

	_offset = getArray (missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> DZE_buildItem >> "offset");
	_objectHelper = objNull;
	_isOk = true;
	_location1 = [player] call FNC_GetPos;
	_dir = getDir player;

	if (_ghost != "") then {
		_classname = _ghost;
	};

	_object = _classname createVehicle [0,0,0];

	if ((count _offset) <= 0) then {
		_offset = [0,(abs(((boundingBox _object)select 0) select 1)),0];
	};

	_objectHelper = "Sign_sphere10cm_EP1" createVehicle [0,0,0];
	_helperColor = "#(argb,8,8,3)color(0,0,0,0,ca)";
	_objectHelper setobjecttexture [0,_helperColor];
	_objectHelper attachTo [player,_offset];
	_object attachTo [_objectHelper,[0,0,0]];

	if (isClass (configFile >> "SnapBuilding" >> _classname)) then {
		["","","",["Init",_object,_classname,_objectHelper]] spawn snap_build;
	};

	if !(DZE_buildItem in DZE_noRotate) then{
		["","","",["Init","Init",0]] spawn build_vectors;
	};

	_objHDiff = 0;
	_cancel = false;
	_reason = "";

	helperDetach = false;
	_canDo = (!r_drag_sqf && !r_player_unconscious);
	_position = [_objectHelper] call FNC_GetPos;

	while {_isOk} do {

		_zheightchanged = false;
		_zheightdirection = "";
		_rotate = false;

		if (DZE_Q) then {
			DZE_Q = false;
			_zheightdirection = "up";
			_zheightchanged = true;
		};
		if (DZE_Z) then {
			DZE_Z = false;
			_zheightdirection = "down";
			_zheightchanged = true;
		};
		if (DZE_Q_alt) then {
			DZE_Q_alt = false;
			_zheightdirection = "up_alt";
			_zheightchanged = true;
		};
		if (DZE_Z_alt) then {
			DZE_Z_alt = false;
			_zheightdirection = "down_alt";
			_zheightchanged = true;
		};
		if (DZE_Q_ctrl) then {
			DZE_Q_ctrl = false;
			_zheightdirection = "up_ctrl";
			_zheightchanged = true;
		};
		if (DZE_Z_ctrl) then {
			DZE_Z_ctrl = false;
			_zheightdirection = "down_ctrl";
			_zheightchanged = true;
		};
		if (DZE_4) then {
			_rotate = true;
			DZE_4 = false;
			if (DZE_dirWithDegrees) then{
				DZE_memDir = DZE_memDir - DZE_curDegree;
			}else{
				DZE_memDir = DZE_memDir - 45;
			};
		};
		if (DZE_6) then {
			_rotate = true;
			DZE_6 = false;
			if (DZE_dirWithDegrees) then{
				DZE_memDir = DZE_memDir + DZE_curDegree;
			}else{
				DZE_memDir = DZE_memDir + 45;
			};
		};

		if (DZE_updateVec) then{
			[_objectHelper,[DZE_memForBack,DZE_memLeftRight,DZE_memDir]] call fnc_SetPitchBankYaw;
			DZE_updateVec = false;
		};

		if (DZE_F and _canDo) then {
			if (helperDetach) then {
				_objectHelper attachTo [player];
				DZE_memDir = DZE_memDir-(getDir player);
				helperDetach = false;
				[_objectHelper,[DZE_memForBack,DZE_memLeftRight,DZE_memDir]] call fnc_SetPitchBankYaw;
			} else {
				_objectHelperPos = getPosATL _objectHelper;
				detach _objectHelper;
				DZE_memDir = getDir _objectHelper;
				[_objectHelper,[DZE_memForBack,DZE_memLeftRight,DZE_memDir]] call fnc_SetPitchBankYaw;
				_objectHelper setPosATL _objectHelperPos;
				_objectHelper setVelocity [0,0,0];
				helperDetach = true;
			};
			DZE_F = false;
		};

		if (_rotate) then {
			[_objectHelper,[DZE_memForBack,DZE_memLeftRight,DZE_memDir]] call fnc_SetPitchBankYaw;
		};

		if (_zheightchanged) then {
			if (!helperDetach) then {
				detach _objectHelper;
			};

			_position = [_objectHelper] call FNC_GetPos;

			if (_zheightdirection == "up") then {
				_position set [2,((_position select 2)+0.1)];
				_objHDiff = _objHDiff + 0.1;
			};
			if (_zheightdirection == "down") then {
				_position set [2,((_position select 2)-0.1)];
				_objHDiff = _objHDiff - 0.1;
			};

			if (_zheightdirection == "up_alt") then {
				_position set [2,((_position select 2)+1)];
				_objHDiff = _objHDiff + 1;
			};
			if (_zheightdirection == "down_alt") then {
				_position set [2,((_position select 2)-1)];
				_objHDiff = _objHDiff - 1;
			};

			if (_zheightdirection == "up_ctrl") then {
				_position set [2,((_position select 2)+0.01)];
				_objHDiff = _objHDiff + 0.01;
			};
			if (_zheightdirection == "down_ctrl") then {
				_position set [2,((_position select 2)-0.01)];
				_objHDiff = _objHDiff - 0.01;
			};

			if ((_isAllowedUnderGround == 0) && {(_position select 2) < 0}) then {
				_position set [2,0];
			};

			if (surfaceIsWater _position) then {
				_objectHelper setPosASL _position;
			} else {
				_objectHelper setPosATL _position;
			};

			if (!helperDetach) then {
				_objectHelper attachTo [player];
			};
			[_objectHelper,[DZE_memForBack,DZE_memLeftRight,DZE_memDir]] call fnc_SetPitchBankYaw;
		};

		uiSleep 0.5;

		_location2 = [player] call FNC_GetPos;
		_objectHelperPos = [_objectHelper] call FNC_GetPos;

		if (DZE_5) exitWith {
			_isOk = false;
			_position = [_object] call FNC_GetPos;
			detach _object;
			_dir = getDir _object;
			_vector = [(vectorDir _object),(vectorUp _object)];
			deleteVehicle _object;
			detach _objectHelper;
			deleteVehicle _objectHelper;
		};

		if (_location1 distance _location2 > DZE_buildMaxMoveDistance) exitWith {
			_isOk = false;
			_cancel = true;
			_reason = format[localize "STR_EPOCH_BUILD_FAIL_MOVED",DZE_buildMaxMoveDistance];
			detach _object;
			deleteVehicle _object;
			detach _objectHelper;
			deleteVehicle _objectHelper;
		};

		if (_location1 distance _objectHelperPos > DZE_buildMaxMoveDistance) exitWith {
			_isOk = false;
			_cancel = true;
			_reason = format[localize "STR_EPOCH_BUILD_FAIL_TOO_FAR",DZE_buildMaxMoveDistance];
			detach _object;
			deleteVehicle _object;
			detach _objectHelper;
			deleteVehicle _objectHelper;
		};

		if (abs(_objHDiff) > DZE_buildMaxHeightDistance) exitWith {
			_isOk = false;
			_cancel = true;
			_reason = format[localize "STR_EPOCH_BUILD_FAIL_HEIGHT",DZE_buildMaxHeightDistance];
			detach _object;
			deleteVehicle _object;
			detach _objectHelper;
			deleteVehicle _objectHelper;
		};

		if (DZE_BuildHeightLimit > 0 && {_position select 2 > DZE_BuildHeightLimit}) exitWith {
			_isOk = false;
			_cancel = true;
			_reason = format[localize "STR_EPOCH_PLAYER_168",DZE_BuildHeightLimit];
			detach _object;
			deleteVehicle _object;
			detach _objectHelper;
			deleteVehicle _objectHelper;
		};

		if (player getVariable["combattimeout",0] >= diag_tickTime) exitWith {
			_isOk = false;
			_cancel = true;
			_reason = localize "str_epoch_player_43";
			detach _object;
			deleteVehicle _object;
			detach _objectHelper;
			deleteVehicle _objectHelper;
		};

		if (DZE_cancelBuilding) exitWith {
			_isOk = false;
			_cancel = true;
			_reason = localize "STR_EPOCH_PLAYER_46";
			detach _object;
			deleteVehicle _object;
			detach _objectHelper;
			deleteVehicle _objectHelper;
		};
	};

	_isOk = true;
	_proceed = false;
	_counter = 0;
	_location = [0,0,0];

	if (!DZE_BuildOnRoads) then {
		if (isOnRoad _position) then { _cancel = true; _reason = localize "STR_EPOCH_BUILD_FAIL_ROAD"; };
	};
	if (!canbuild) then { _cancel = true; _reason = format[localize "STR_EPOCH_PLAYER_136",localize "STR_EPOCH_TRADER"]; };

	if (!_cancel) then {
		_classname = _classnametmp;
		_tmpbuilt = _classname createVehicle _location;
		//_tmpbuilt setdir _dir; // setdir is incompatible with setVectorDirAndUp and should not be used together on the same object https://community.bistudio.com/wiki/setVectorDirAndUp
		_tmpbuilt setVariable["memDir",_dir,true];
		_location = _position;

		if ((_isAllowedUnderGround == 0) && {(_location select 2) < 0}) then {
			_location set [2,0];
		};

		_tmpbuilt setVectorDirAndUp _vector;

		_buildOffset = [0,0,0];
		_vUp = _vector select 1;

		/*
		switch (_classname) do {
			case "MetalFloor_DZ": { _buildOffset = [(_vUp select 0) * .148, (_vUp select 1) * .148,0]; };
		};

		*/
		_location = [
			(_location select 0) - (_buildOffset select 0),
			(_location select 1) - (_buildOffset select 1),
			(_location select 2) - (_buildOffset select 2)
		];

		if (surfaceIsWater _location) then {
			_tmpbuilt setPosASL _location;
			_location = ASLtoATL _location;
		} else {
			_tmpbuilt setPosATL _location;
		};

		format[localize "str_epoch_player_138",_text] call dayz_rollingMessages;

		_limit = 3;

		if (DZE_StaticConstructionCount > 0) then {
			_limit = DZE_StaticConstructionCount;
		}
		else {
			if (isNumber (missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> DZE_buildItem >> "constructioncount")) then {
				_limit = getNumber(missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> DZE_buildItem >> "constructioncount");
			};
		};

		while {_isOk} do {
			format[localize "str_epoch_player_139",_text, (_counter + 1),_limit] call dayz_rollingMessages; //report how many steps are done out of total limit

			[player,(getPosATL player),40,"repair"] spawn fnc_alertZombies;

			_finished = ["Medic",1,{player getVariable["combattimeout",0] >= diag_tickTime or DZE_cancelBuilding}] call fn_loopAction;

			if (!_finished) exitWith {
				_isOk = false;
				_proceed = false;
			};

			if (_finished) then {
				_counter = _counter + 1;
			};

			if (_counter == _limit) exitWith {
				_isOk = false;
				_proceed = true;
			};
		};

		if (_proceed) then {
			//_num_removed = ([player,DZE_buildItem] call BIS_fnc_invRemove); //remove item's magazine from inventory
			//TODO: Check item removal
			_num_removed = 1;
			if(!_AdminCraft) then{
				{
					player removeMagazine _x;
				} foreach _RM_temp;
			};
			if (_num_removed == 1) then {
				["Working",0,[20,10,5,0]] call dayz_NutritionSystem;
				call player_forceSave;
				[format[localize "str_build_01",_text],1] call dayz_rollingMessages;

				_tmpbuilt setVariable ["OEMPos",_location,true]; //store original location as a variable

				if (_lockable > 1) then { //if item has code lock on it

					_combinationDisplay = ""; //define new display

					call { //generate random combinations depending on item type

						if (_lockable == 2) exitwith { // 2 lockbox
							dayz_combination = "";
							dayz_selectedVault = objNull;

							createDialog "KeyPadUI";
							waitUntil {!dialog};

							_combinationDisplay = dayz_combination call fnc_lockCode;
							if (keypadCancel || {typeName _combinationDisplay == "SCALAR"}) then {
								_combination_1 = (floor(random 3)) + 100; // 100=red,101=green,102=blue
								_combination_2 = floor(random 10);
								_combination_3 = floor(random 10);
								_combination = format["%1%2%3",_combination_1,_combination_2,_combination_3];
								dayz_combination = _combination;
								if (_combination_1 == 100) then {
									_combination_1_Display = localize "STR_TEAM_RED";
								};
								if (_combination_1 == 101) then {
									_combination_1_Display = localize "STR_TEAM_GREEN";
								};
								if (_combination_1 == 102) then {
									_combination_1_Display = localize "STR_TEAM_BLUE";
								};
								_combinationDisplay = format["%1%2%3",_combination_1_Display,_combination_2,_combination_3];
							} else {
								_combination = dayz_combination;
							};
						};

						if (_lockable == 3) exitwith { // 3 combolock
							DZE_topCombo = 0;
							DZE_midCombo = 0;
							DZE_botCombo = 0;
							DZE_Lock_Door = "";
							dayz_selectedDoor = objNull;

							dayz_actionInProgress = false;
							createDialog "ComboLockUI";
							waitUntil {!dialog};
							dayz_actionInProgress = true;

							if (keypadCancel || {parseNumber DZE_Lock_Door == 0}) then {
								_combination_1 = floor(random 10);
								_combination_2 = floor(random 10);
								_combination_3 = floor(random 10);
								_combination = format["%1%2%3",_combination_1,_combination_2,_combination_3];
								DZE_Lock_Door = _combination;
							} else {
								_combination = DZE_Lock_Door;
							};
							if (_classname in ["WoodenGate_1_DZ","WoodenGate_2_DZ","WoodenGate_3_DZ","WoodenGate_4_DZ"]) then {
								GateMethod = DZE_Lock_Door;
							};

							_combinationDisplay = _combination;
						};

						if (_lockable == 4) exitwith { // 4 safe
							dayz_combination = "";
							dayz_selectedVault = objNull;

							createDialog "SafeKeyPad";
							waitUntil {!dialog};

							if (keypadCancel || {(parseNumber dayz_combination) > 9999} || {count (toArray (dayz_combination)) < 4}) then {
								_combination_1 = floor(random 10);
								_combination_2 = floor(random 10);
								_combination_3 = floor(random 10);
								_combination_4 = floor(random 10);
								_combination = format["%1%2%3%4",_combination_1,_combination_2,_combination_3,_combination_4];
								dayz_combination = _combination;
							} else {
								_combination = dayz_combination;
							};
							_combinationDisplay = _combination;
						};
					};

					_tmpbuilt setVariable ["CharacterID",_combination,true]; //set combination as a character ID

					//call publish precompiled function with given args and send public variable to server to save item to database
					if (DZE_permanentPlot) then {
						_tmpbuilt setVariable ["ownerPUID",dayz_playerUID,true];
						PVDZ_obj_Publish = [_combination,_tmpbuilt,[_dir,_location,dayz_playerUID,_vector],[],player,dayz_authKey];
						if (_lockable == 3) then {
							_friendsArr = [[dayz_playerUID,toArray (name player)]];
							_tmpbuilt setVariable ["doorfriends", _friendsArr, true];
							PVDZ_obj_Publish = [_combination,_tmpbuilt,[_dir,_location,dayz_playerUID,_vector],_friendsArr,player,dayz_authKey];
						};
					} else {
						PVDZ_obj_Publish = [_combination,_tmpbuilt,[_dir,_location, _vector],[],player,dayz_authKey];
					};
					publicVariableServer "PVDZ_obj_Publish";

					[format[localize "str_epoch_player_140",_combinationDisplay,_text],1] call dayz_rollingMessages; //display new combination
					systemChat format[localize "str_epoch_player_140",_combinationDisplay,_text];

				} else { //if not lockable item
					_tmpbuilt setVariable ["CharacterID",dayz_characterID,true];
					// fire?
					if (_tmpbuilt isKindOf "Land_Fire_DZ") then { //if campfire, then spawn, but do not publish to database
						[_tmpbuilt,true] call dayz_inflame;
						_tmpbuilt spawn player_fireMonitor;
					} else {
						if (DZE_permanentPlot) then {
							_tmpbuilt setVariable ["ownerPUID",dayz_playerUID,true];
							if (_canBuild select 1) then {
								_friendsArr = [[dayz_playerUID,toArray (name player)]];
								_tmpbuilt setVariable ["plotfriends", _friendsArr, true];
								PVDZ_obj_Publish = [dayz_characterID,_tmpbuilt,[_dir,_location,dayz_playerUID,_vector],_friendsArr,player,dayz_authKey];
							} else {
								PVDZ_obj_Publish = [dayz_characterID,_tmpbuilt,[_dir,_location,dayz_playerUID,_vector],[],player,dayz_authKey];
							};
						} else {
							PVDZ_obj_Publish = [dayz_characterID,_tmpbuilt,[_dir,_location, _vector],[],player,dayz_authKey];
						};
						publicVariableServer "PVDZ_obj_Publish";
					};
				};
				if (DZE_GodModeBase && {!(_classname in DZE_GodModeBaseExclude)}) then {
					_tmpbuilt addEventHandler ["HandleDamage",{false}];
				};
			} else { //if magazine was not removed, cancel publish
				deleteVehicle _tmpbuilt;
				localize "str_epoch_player_46" call dayz_rollingMessages;
			};

		} else { //if player was interrupted cancel publish
			deleteVehicle _tmpbuilt;
			localize "str_epoch_player_46" call dayz_rollingMessages;
		};

	} else { //cancel build if passed _cancel arg was true or building on roads/trader city
		format[localize "str_epoch_player_47",_text,_reason] call dayz_rollingMessages;
	};
};

dayz_actionInProgress = false;
