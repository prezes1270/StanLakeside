/*
	
	
	Description:
	Allows cops to 'kick' in the door?
*/
private["_house","_door","_title","_titleText","_progressBar","_cpRate","_cP","_uid"];
_house = param [0,ObjNull,[ObjNull]];
if(isNull _house OR !(_house isKindOf "House_F")) exitWith {};

_uid = (_house getVariable "house_owner") select 0;

_door = [_house] call life_fnc_nearestDoor;
if(_door == 0) exitWith {[localize "STR_Cop_NotaDoor", false] spawn domsg;};

life_action_inUse = true;

//Setup the progress bar
disableSerialization;
_title = localize "STR_House_Raid_Progress";
5 cutRsc ["life_progress","PLAIN"];
_ui = uiNamespace getVariable "life_progress";
_progressBar = _ui displayCtrl 38201;
_titleText = _ui displayCtrl 38202;
_titleText ctrlSetText format["%2 (1%1)...","%",_title];
_progressBar progressSetPosition 0.01;
_cP = 0.01;
_cpRate = 0.0092;

[2,format[localize "STR_House_Raid_NOTF",(_house getVariable "house_owner") select 1]] remoteExecCall ["life_fnc_broadcast", -2];

while {true} do
{
	if(animationState player != "AinvPknlMstpSnonWnonDnon_medic_1") then {
		
		player playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1";
	};
	uiSleep 0.26;
	if(isNull _ui) then {
		5 cutRsc ["life_progress","PLAIN"];
		_ui = uiNamespace getVariable "life_progress";
	};
	_cP = _cP + _cpRate;
	_progressBar progressSetPosition _cP;
	_titleText ctrlSetText format["%3 (%1%2)...",round(_cP * 100),"%",_title];
	if(_cP >= 1 OR deadPlayer) exitWith {};
	if(life_interrupted) exitWith {};
};

//Kill the UI display and check for various states
5 cutText ["","PLAIN"];
player playActionNow "stop";
if(deadPlayer) exitWith {life_action_inUse = false;};
if(life_interrupted) exitWith {life_interrupted = false; [localize "STR_NOTF_ActionCancel", false] spawn domsg; life_action_inUse = false;};
life_action_inUse = false;
_house animate [format["door_%1_rot",_door],1];
_house setVariable[format["bis_disabled_Door_%1",_door],0,true]; //Unlock the door.
