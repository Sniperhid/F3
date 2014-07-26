// F3 - Assign Insignia
// Credits: Please see the F3 online manual (http://www.ferstaberinde.com/f3/en/)
// ====================================================================================
private ["_group","_badge","_groupBadges"];



// Note all badges must be defined in description.ext or be included your modpack.
// See: https://community.bistudio.com/wiki/Arma_3_Unit_Insignia

// This variable stores the final badge to use which will applied at the end of this script.
// A default badge can be set by changing this.

_badge = ""; 



// ====================================================================================

// This array stores a list of groups and the corresponding badge they will receive.

_groupBadges = [
	["GrpNATO_ASL","ABadge"],
	["GrpNATO_A1","A1Badge"],
	["GrpNATO_A2","A2Badge"],
	["GrpNATO_A3","A3Badge"],
	["GrpNATO_BSL","BBadge"],
	["GrpNATO_B1","B1Badge"],
	["GrpNATO_B2","B2Badge"],
	["GrpNATO_B3","B3Badge"],
	["GrpNATO_CSL","CBadge"],
	["GrpNATO_C1","C1Badge"],
	["GrpNATO_C2","C2Badge"],
	["GrpNATO_C3","C3Badge"]
];


// ====================================================================================

// Loop through the groups and match badges to the group _unit belongs to. Due to the groups being variables this requires calling formatted at runtime code.

_group = (group _unit);


{
	if(!isnil (_x select 0)) then {
			call compile format ["
				if (%1==_group) then {
					_badge = _x select 1;
				};
			",_x select 0];
	};
} forEach _groupBadges;


// ====================================================================================

// The following block will assign insignia based on the unit to role.


switch (_typeofUnit) do
{

// INSIGNIA: MEDIC
	case "m":
	{
		_badge = "MedicBadge";
	};
};

if (_badge != "") then {
	[_unit,_badge] call BIS_fnc_setUnitInsignia;
};