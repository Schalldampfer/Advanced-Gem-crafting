/*
DayZ Custom Buildables
Made for DayZ Epoch please ask permission to use/edit/distrubute email vbawol@veteranbastards.com.

Edits by Mike of http://www.petuniaserver.com/ - Original file & all kudos to the EPOCH devs! http://www.dayzepoch.com
Edits and re-writes by hogscraper:
Added code to see if player has tools and materials required to build item
Removed a lot of code referencing lockables, plot pole placement and construction multiplier since part of that code was already removed
Cleaned up a lot of old code that wasn't needed any more for this custom crafting
Removed irrelevant variables from private block
This file is called with zero parameters
*/
private ["_AdminCraft","_HM_temp","_HT_temp","_IsNearPlot","_RM_temp","_RT_temp","_activatingPlayer","_buildcheck","_canBuild","_canBuildOnPlot","_canDo","_cancel","_charID","_classname","_counter","_dir","_distance","_exitWith","_found","_friendlies","_hasMaterials","_hasTools","_hasmaterials","_hastools","_helperColor","_inVehicle","_isAllowedUnderGround","_isOk","_isfriendly","_isowner","_lbIndex","_location","_location1","_location2","_mags","_message","_nearestPole","_needText","_objHDiff","_object","_objectHelper","_objectHelperDir","_objectHelperPos","_offset","_onLadder","_ownerID","_playerUID","_plotcheck","_position","_reason","_requiredmaterials","_requiredtools","_requireplot","_rotate","_text","_tmp_Pos","_tmpbuilt","_vehicle","_weaps","_zheightchanged","_zheightdirection"];

_AdminCraft=false;

_lbIndex = lbCurSel 3901;
_classname = lbText [3901,_lbIndex];

if(dayz_actionInProgress) exitWith { localize "str_epoch_player_40" call dayz_rollingMessages; };
dayz_actionInProgress = true;

_onLadder = (getNumber (configFile >> "CfgMovesMaleSdr" >> "States" >> (animationState player) >> "onLadder")) == 1;
_cancel = false;
_reason = "";
_canBuildOnPlot = false;
_playerUID = getPlayerUID player;

if(_playerUID in Admin_Crafting) then {
	_AdminCraft=true;
};

//create arrays for checking whether or not the player
//has the correct tools and materials to make the desired item
_requiredtools = getArray (missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> _classname >> "requiredtools");
_requiredmaterials = getArray (missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> _classname >> "requiredmaterials");
_RT_temp=getArray (missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> _classname >> "requiredtools");
_RM_temp=getArray (missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> _classname >> "requiredmaterials");
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
}
forEach _RT_temp;

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
}
forEach _RM_temp;
_requiredmaterials=_requiredmaterials-[objNull];
_mags=_mags-[objNull];

if(((count _requiredmaterials) == 0) or (_AdminCraft)) then {
	_hasmaterials=true;
};
if(((count _requiredtools) == 0) or (_AdminCraft)) then {
	_hastools=true;
};

//Create the message to display if player is missing any of the required tools
if (!_hasTools) then{
	_HT_temp="You are missing the following tools:";
	{  
		_HT_temp=_HT_temp+" " + getText (configFile >> "CfgWeapons" >> _x >> "displayName");
	}foreach _requiredtools;
};

//Create the message to display if player is missing any of the required materials
if (!_hasMaterials) then{
	_HM_temp="You are missing the following materials:";
	{  
		if(getText (configFile >> "CfgMagazines" >> _x >> "displayName")=="Supply Crate") then{
			_HM_temp=_HM_temp+" " + getText (configFile >> "CfgMagazines" >> _x >> "descriptionShort");
		}else{
			_HM_temp=_HM_temp+" " + getText (configFile >> "CfgMagazines" >> _x >> "displayName");
		};
	}foreach _requiredmaterials;
};

_vehicle = vehicle player;
_inVehicle = (_vehicle != player);
helperDetach = false;
_canDo = (!r_drag_sqf and !r_player_unconscious);

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

call gear_ui_init;
closeDialog 1;

if (dayz_isSwimming) exitWith {dayz_actionInProgress = false; localize "str_player_26" call dayz_rollingMessages;};
if (_inVehicle) exitWith {dayz_actionInProgress = false; localize "str_epoch_player_42" call dayz_rollingMessages;};
if (_onLadder) exitWith {dayz_actionInProgress = false; localize "str_player_21" call dayz_rollingMessages;};
if (player getVariable["combattimeout",0] >= diag_tickTime) exitWith {dayz_actionInProgress = false; localize "str_epoch_player_43" call dayz_rollingMessages;};


if (!_hasTools) exitWith {dayz_actionInProgress = false; format["%1",_HT_temp] call dayz_rollingMessages;};
if (!_hasMaterials) exitWith {dayz_actionInProgress = false; format["%1",_HM_temp] call dayz_rollingMessages;};

_text =  getText (configFile >> "CfgVehicles" >> _classname >> "displayName");

_requireplot = DZE_requireplot;
if(isNumber (missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> _classname >> "requireplot")) then {
	_requireplot = getNumber(missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> _classname >> "requireplot");
};
if(_AdminCraft) then {
	_requireplot=0;
};

_offset =  getArray (missionConfigFile >> "Custom_Buildables" >> "Buildables" >> ComboBoxResult >> _classname >> "offset");
if((count _offset) <= 0) then {
	_offset = [0,3,0];
};

_distance = DZE_PlotPole select 0;
_needText = localize "str_epoch_player_246";

_canBuild = false;
_nearestPole = objNull;
_ownerID = 0;
_friendlies = [];

_plotcheck = [player, false] call FNC_find_plots;
_distance = DZE_PlotPole select 0;

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
			_friendlies	= player getVariable ["friendlyTo",[]];
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

_location = [0,0,0];
_isOk = true;

// get inital players position
_location1 = getPosATL player;
_dir = getDir player;

_object = createVehicle [_classname, _location, [], 0, "CAN_COLLIDE"];
//Build gizmo
_objectHelper = "Sign_sphere10cm_EP1" createVehicle _location;
_helperColor = "#(argb,8,8,3)color(0,0,0,0,ca)";
_objectHelper setobjecttexture [0,_helperColor];
_objectHelper attachTo [player,_offset];
_object attachTo [_objectHelper,[0,0,0]];
_position = getPosATL _objectHelper;

if(_AdminCraft) then{
} else {
	{
		player removeMagazine _x;
	} foreach _RM_temp;
};

_position = getPosATL _object;
localize "str_epoch_player_45" call dayz_rollingMessages;
_objHDiff = 0;

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
		if (helperDetach) then {
			_dir = -45;
		} else {
			_dir = 180;
		};
	};
	if (DZE_6) then {
		_rotate = true;
		DZE_6 = false;
		if (helperDetach) then {
			_dir = 45;
		} else {
			_dir = 0;
		};
	};
	//Number keys above qwerty
	//1=turn clockwise 1/16th of a circle
	//2=detaches object from player - OBJECT MUST BE COMPLETELY ABOVE GROUND OR IT WILL DISAPPEAR!!
	//3=turn counter clockwise 1/16th of a circle
	if (AAC_1) then {
		_rotate = true;
		AAC_1 = false;
		if (helperDetach) then {
			_dir = -45;
		} else {
			_dir = _dir + 22.5;;
		};
	};

	if (AAC_3) then {
		_rotate = true;
		AAC_3 = false;
		if (helperDetach) then {
			_dir = -45;
		} else {
			_dir = _dir - 22.5;
		};
	};
	
	if (DZE_F and _canDo) then {   
		if (helperDetach) then {
			_objectHelperDir = getDir _objectHelper;
			_objectHelper attachTo [player];
			_objectHelper setDir _objectHelperDir-(getDir player);
			helperDetach = false;
		} else {
			_objectHelperPos = getPosATL _objectHelper;
			detach _objectHelper;                  
			_objectHelper setPosATL _objectHelperPos;
			_objectHelperDir = getDir _objectHelper;
			_objectHelper setVelocity [0,0,0]; //fix sliding glitch
			helperDetach = true;
		};
		DZE_F = false;
	};

	if(_rotate) then {
		if (helperDetach) then {
			_objectHelperDir = getDir _objectHelper;
			_objectHelperPos = getPosATL _objectHelper;
			_objectHelper setDir _objectHelperDir+_dir;
			_objectHelper setPosATL _objectHelperPos;
		} else {
			_objectHelper setDir _dir;
			_objectHelper setPosATL _position;
			//diag_log format["DEBUG Rotate BUILDING POS: %1", _position];                 
		};

	};

	if(_zheightchanged) then {
		if (!helperDetach) then {
			detach _objectHelper;
		};

		_position = getPosATL _objectHelper;

		if(_zheightdirection == "up") then {
			_position set [2,((_position select 2)+0.1)];
			_objHDiff = _objHDiff + 0.1;
		};
		if(_zheightdirection == "down") then {
			_position set [2,((_position select 2)-0.1)];
			_objHDiff = _objHDiff - 0.1;
		};

		if(_zheightdirection == "up_alt") then {
			_position set [2,((_position select 2)+1)];
			_objHDiff = _objHDiff + 1;
		};
		if(_zheightdirection == "down_alt") then {
			_position set [2,((_position select 2)-1)];
			_objHDiff = _objHDiff - 1;
		};

		if(_zheightdirection == "up_ctrl") then {
			_position set [2,((_position select 2)+0.01)];
			_objHDiff = _objHDiff + 0.01;
		};
		if(_zheightdirection == "down_ctrl") then {
			_position set [2,((_position select 2)-0.01)];
			_objHDiff = _objHDiff - 0.01;
		};

		_objectHelper setDir (getDir _objectHelper);

		_objectHelper setPosATL _position;

		//diag_log format["DEBUG Change BUILDING POS: %1", _position];

		if (!helperDetach) then {
			_objectHelper attachTo [player];
		};
	};


	sleep 0.5;

	_location2 = getPosATL player;

	if(DZE_5) exitWith {
		_isOk = false;
		detach _object;
		_dir = getDir _object;
		_position = getPosATL _object;
		deleteVehicle _object;
		detach _objectHelper;
		deleteVehicle _objectHelper;
	};

	if(_location1 distance _location2 > DZE_buildMaxMoveDistance) exitWith {
		_isOk = false;
		_cancel = true;
		_reason = format[localize "STR_EPOCH_BUILD_FAIL_MOVED",DZE_buildMaxMoveDistance];
		detach _object;
		deleteVehicle _object;
		detach _objectHelper;
		deleteVehicle _objectHelper;
	};

	if(abs(_objHDiff) > DZE_buildMaxMoveDistance) exitWith {
		_isOk = false;
		_cancel = true;
		_reason = format[localize "STR_EPOCH_BUILD_FAIL_TOO_FAR",DZE_buildMaxMoveDistance];
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

if (!DZE_BuildOnRoads) then {
	if (isOnRoad _position) then { _cancel = true; _reason = localize "STR_EPOCH_BUILD_FAIL_ROAD"; };
};
if(!canbuild) then { _cancel = true; _reason = format[localize "STR_EPOCH_PLAYER_136",localize "STR_EPOCH_TRADER"]; };

if(!_cancel) then {

	// Start Build
	_tmpbuilt = createVehicle [_classname, _location, [], 0, "CAN_COLLIDE"];

	_tmpbuilt setdir _dir;

	// Get position based on object
	_location = _position;

	_tmpbuilt setPosATL _location;

	format[localize "str_epoch_player_138",_text] call dayz_rollingMessages;

	player playActionNow "Medic";
	[player,"repair",0,false,10] call dayz_zombieSpeak;
	[player,10,true,(getPosATL player)] spawn player_alertZombies;

	format[localize "str_build_01",_text] call dayz_rollingMessages;

	_tmpbuilt setVariable ["OEMPos",_location,true];
	_tmpbuilt setVariable ["CharacterID",dayz_characterID,true];
	_tmpbuilt setVariable ["ownerPUID",_playerUID,true];
	_charID = dayz_characterID;
	_activatingPlayer = player;
  
  	if (DZE_permanentPlot) then {
        	_tmpbuilt setVariable ["ownerPUID",dayz_playerUID,true];
        	PVDZ_obj_Publish = [dayz_characterID,_tmpbuilt,[_dir,_location,dayz_playerUID],[],player,dayz_authKey];
   	} else {
        	PVDZ_obj_Publish = [dayz_characterID,_tmpbuilt,[_dir,_location],[],player,dayz_authKey];
   	}; 
	publicVariableServer "PVDZ_obj_Publish";
	"Your build was successful!" call dayz_rollingMessages;

	player reveal _tmpbuilt;
	dayz_actionInProgress = false;

} else {
	format[localize "str_epoch_player_47",_text,_reason] call dayz_rollingMessages;
	dayz_actionInProgress = false;
	if(_AdminCraft) then {
	} else {
		{
			//Since player had items removed we need to give them back
			player addMagazine _x;
		} foreach _RM_temp;
	};
};

dayz_actionInProgress = false;
