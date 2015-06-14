// F3 - ACRE Clientside Initialisation
// Credits: Please see the F3 online manual (http://www.ferstaberinde.com/f3/en/)
// ====================================================================================

// DECLARE VARIABLES AND FUNCTIONS

private ["_presetName","_ret","_unit","_typeOfUnit"];

// ====================================================================================

// Set up the radio presets according to side.
_presetName = switch(side player) do {
	case west:{"default2"};
	case east:{"default3"};
	case resistance:{"default4"};
	default {"default"};
};
if (f_radios_settings_acre2_disableFrequencySplit) then {
	_presetName = "default";
};

_ret = ["ACRE_PRC343", _presetName ] call acre_api_fnc_setPreset;
_ret = ["ACRE_PRC148", _presetName ] call acre_api_fnc_setPreset;
_ret = ["ACRE_PRC152", _presetName ] call acre_api_fnc_setPreset;
_ret = ["ACRE_PRC117F", _presetName ] call acre_api_fnc_setPreset;
_ret = ["ItemRadio", _presetName ] call acre_api_fnc_setPreset;


// if dead, set spectator and exit
if(!alive player) exitWith {[true] call acre_api_fnc_setSpectator;};

_unit = player;

// ====================================================================================

// Set language of the units depending on side (BABEL API)
switch (side _unit) do {
	case blufor: {
		f_radios_settings_acre2_language_blufor call acre_api_fnc_babelSetSpokenLanguages;
		[f_radios_settings_acre2_language_blufor select 0] call acre_api_fnc_babelSetSpeakingLanguage;
	};
	case opfor: {
		f_radios_settings_acre2_language_opfor call acre_api_fnc_babelSetSpokenLanguages;
		[f_radios_settings_acre2_language_opfor select 0] call acre_api_fnc_babelSetSpeakingLanguage;
	};
	case independent: {
		f_radios_settings_acre2_language_indfor call acre_api_fnc_babelSetSpokenLanguages;
		[f_radios_settings_acre2_language_indfor select 0] call acre_api_fnc_babelSetSpeakingLanguage;
	};
	default {
		f_radios_settings_acre2_language_indfor call acre_api_fnc_babelSetSpokenLanguages;
		[f_radios_settings_acre2_language_indfor select 0] call acre_api_fnc_babelSetSpeakingLanguage;
	};
};

// ====================================================================================

// RADIO ASSIGNMENT

// Wait for gear assignation to take place
waitUntil{(player getVariable ["f_var_assignGear_done", false])};
_typeOfUnit = _unit getVariable ["f_var_assignGear", "NIL"];

// REMOVE ALL RADIOS
// Wait for ACRE2 to initialise any radios the unit has in their inventory, and then
// remove them to ensure that duplicate radios aren't added by accident.
waitUntil{uiSleep 0.3; !("ItemRadio" in (items _unit + assignedItems _unit))};
uiSleep 1;

waitUntil{[] call acre_api_fnc_isInitialized};
{_unit removeItem _x;} forEach ([] call acre_api_fnc_getCurrentRadioList);
// ====================================================================================

// ASSIGN RADIOS TO UNITS
// Depending on the loadout used in the assignGear component, each unit is assigned
// a set of radios.

if(_typeOfUnit != "NIL") then {

  // If radios are enabled in the settings
  if(!f_radios_settings_acre2_disableRadios) then {
      // Everyone gets a short-range radio by default
      if(isnil "f_radios_settings_acre2_shortRange") then
      {
		if (_unit canAdd f_radios_settings_acre2_standardSHRadio) then
		{
			_unit addItem f_radios_settings_acre2_standardSHRadio;
		} else {
			f_radios_settings_acre2_standardSHRadio call f_radios_acre2_giveRadioAction;
		};
      }
      else
      {
        if(_typeOfUnit in f_radios_settings_acre2_shortRange) then
        {
			if (_unit canAdd f_radios_settings_acre2_standardSHRadio) then
			{
				_unit addItem f_radios_settings_acre2_standardSHRadio;
			} else {
				f_radios_settings_acre2_standardSHRadio call f_radios_acre2_giveRadioAction;
			};
        };
      };

      // If unit is in the above list, add a 148
      if(_typeOfUnit in f_radios_settings_acre2_longRange) then {
		if (_unit canAdd f_radios_settings_acre2_standardLRRadio) then
		{
			_unit addItem f_radios_settings_acre2_standardLRRadio;
		} else {
			f_radios_settings_acre2_standardLRRadio call f_radios_acre2_giveRadioAction;
		};

        // If unit is in the list of units that receive an extra long-range radio, add another 148
        if(_typeOfUnit in f_radios_settings_acre2_extraRadios) then {
			if (_unit canAdd f_radios_settings_acre2_extraRadio) then
			{
				_unit addItem f_radios_settings_acre2_extraRadio;
			} else {
				f_radios_settings_acre2_extraRadio call f_radios_acre2_giveRadioAction;
			};
        };

      };

  };
};

// ====================================================================================

// ASSIGN DEFAULT CHANNELS TO RADIOS
// Depending on the squad joined, each radio is assigned a default starting channel

if(!f_radios_settings_acre2_disableRadios) then {

	private ["_presetArray","_presetLRArray","_radioSR","_radioLR","_radioExtra","_hasSR","_hasLR","_hasExtra","_groupID","_groupIDSplit","_groupChannelIndex","_groupLRChannelIndex","_groupName"];
	
	_presetArray = switch (side _unit) do {
  		case blufor: {f_radios_settings_acre2_sr_groups_blufor};
	  	case opfor: {f_radios_settings_acre2_sr_groups_opfor};
	  	case independent: {f_radios_settings_acre2_sr_groups_indfor};
	  	default {f_radios_settings_acre2_sr_groups_indfor};
	};

	_presetLRArray = switch (side _unit) do {
		case blufor: {f_radios_settings_acre2_lr_groups_blufor};
	  	case opfor: {f_radios_settings_acre2_lr_groups_opfor};
	  	case independent: {f_radios_settings_acre2_lr_groups_indfor};
		default {f_radios_settings_acre2_lr_groups_indfor};
	};
	
	_groupID = groupID (group _unit);
	_groupIDSplit = [_groupID, " "] call bis_fnc_splitString;

	_groupChannelIndex = -1;
  	_groupLRChannelIndex = -1;

  	if ((count _groupIDSplit) > 1) then {
		_groupName = toUpper (_groupIDSplit select (count _groupIDSplit - 1));
		if ((count _groupIDSplit) > 2) then {
			_groupName = toUpper (_groupIDSplit select (count _groupIDSplit - 2));
		};

		{
			if (_groupName in (_x select 1)) exitWith { _groupChannelIndex = _forEachIndex; };
		} forEach _presetArray;

		{
			if (_groupName in (_x select 1)) exitWith { _groupLRChannelIndex = _forEachIndex; };
		} forEach _presetLRArray;
	};

	if (_groupChannelIndex == -1) then {
		player sideChat format["[F3 ACRE2] Warning: Unknown group for short-range channel defaults (%1)", _groupID];
		_groupChannelIndex = 1;
	};

	if (_groupLRChannelIndex == -1) then {
  		player sideChat format["[F3 ACRE2] Warning: Unknown group for long-range channel defaults (%1)", _groupID];
	  	_groupLRChannelIndex = 1;
	};
	
	
	waitUntil {uiSleep 0.1; [] call acre_api_fnc_isInitialized};
	
	_radioSR = [f_radios_settings_acre2_standardSHRadio] call acre_api_fnc_getRadioByType;
	_radioLR = [f_radios_settings_acre2_standardLRRadio] call acre_api_fnc_getRadioByType;
	_radioExtra = [f_radios_settings_acre2_extraRadio] call acre_api_fnc_getRadioByType;

	_hasSR = ((!isNil "_radioSR") && {_radioSR != ""});
	_hasLR = ((!isNil "_radioLR") && {_radioLR != ""});
	_hasExtra = ((!isNil "_radioExtra") && {_radioExtra != ""});
	
	if (_hasSR) then {
		if (f_var_debugMode == 1) then
		{
			player sideChat format["DEBUG (f\radios\acre2\acre2_clientInit.sqf): Setting radio channel for '%1' to %2", _radioSR, _groupChannelIndex + 1];
		};
	    [_radioSR, (_groupChannelIndex + 1)] call acre_api_fnc_setRadioChannel;
	};


	if (_hasLR) then {
		if (f_var_debugMode == 1) then
		{
			player sideChat format["DEBUG (f\radios\acre2\acre2_clientInit.sqf): Setting radio channel for '%1' to %2", _radioLR, _groupLRChannelIndex + 1];
		};
	    [_radioLR, (_groupLRChannelIndex + 1)] call acre_api_fnc_setRadioChannel;
	};

	if (_hasExtra) then {
		if (f_var_debugMode == 1) then
		{
			player sideChat format["DEBUG (f\radios\acre2\acre2_clientInit.sqf): Setting radio channel for '%1' to %2", _radioExtra, _groupLRChannelIndex + 1];
		};
	    [_radioExtra, (_groupLRChannelIndex + 1)] call acre_api_fnc_setRadioChannel;
	};
	
	// ACRE2 BRIEFING PAGE
	_briefAssignedRadios = "<br/><br/><font size='16'>MY ASSIGNED RADIOS</font><br/>";
	_symbolForPresent = "<font color='#ff4747'>*</font>";
	_ltext = format["<font size='11'>Legend: %1 is used to denote a channel you are suppose to be on.<br/>Your radios will be automatically set to the coloured channels.<br/>I can speak any languages that are <font color='#ff4747'>highlighted</font>.</font><br/><br/>",_symbolForPresent];

	_ltext = _ltext + "<font size='16'>BABEL - LANGUAGES</font><br/>Languages spoken in this area:<br/>";
	_languagesSpoken = [];
	switch (side _unit) do {
		case blufor: { _languagesSpoken = f_radios_settings_acre2_language_blufor; };
		case opfor: { _languagesSpoken = f_radios_settings_acre2_language_opfor; };
		case independent: { _languagesSpoken = f_radios_settings_acre2_language_indfor; };
		default { _languagesSpoken = f_radios_settings_acre2_language_indfor; };
	};

	{
	  if (_forEachIndex != 0) then {_ltext = _ltext + ", "; };
	  if ((_x select 0) in _languagesSpoken) then {
		_ltext = _ltext + format["<font color='#ff4747'>%1</font>",_x select 1];
	  } else {
		_ltext = _ltext + format["%1",_x select 1];
	  };
	} forEach f_radios_settings_acre2_languages;


	_text = "<br/><font size='16'>RADIO SHORT RANGE CHANNEL LISTING</font><br />";
	{
		if ((_x select 1) isEqualTo []) exitWith {};
		_channelLine = format["CHN %1 - %2 ",(_forEachIndex +1),(_x select 0)];
		
		if (_groupChannelIndex == _forEachIndex) then {
			_channelLine = format[" %1 ",_symbolForPresent] + "<font color='#1AFF00'>" + _channelLine + "</font><br />";  
		} else {
			_channelLine = format["   "] + _channelLine + "<br />";
		};
		_text = _text + _channelLine;
	} forEach _presetArray;

	_text = _text + "<br/><font size='16'>RADIO LONG RANGE CHANNEL LISTING</font><br />";
	{
		if ((_x select 1) isEqualTo []) exitWith {};
		_channelLine = format["CHN %1 - %2 ",(_forEachIndex +1),(_x select 0)];
		
		if (_groupLRChannelIndex == _forEachIndex) then {
			_channelLine = format[" %1 ",_symbolForPresent] + "<font color='#0071FF'>" + _channelLine + "</font><br />";  
		} else {
			_channelLine = format["   "] + _channelLine + "<br />";
		};
		_text = _text + _channelLine;
	} forEach _presetLRArray;

	
	if (_hasSR) then {
		_briefAssignedRadios = _briefAssignedRadios + format["<font color='#1AFF00'>%1</font><br />",getText (configfile >> "CfgWeapons" >> f_radios_settings_acre2_standardSHRadio >> "displayName")];
	};
	if (_hasLR) then {
		_briefAssignedRadios = _briefAssignedRadios + format["<font color='#0071FF'>%1</font><br />",getText (configfile >> "CfgWeapons" >> f_radios_settings_acre2_standardLRRadio >> "displayName")];
	};
	if (_hasExtra) then {
		_briefAssignedRadios = _briefAssignedRadios + format["%1<br />",getText (configfile >> "CfgWeapons" >> f_radios_settings_acre2_extraRadio >> "displayName")];
	};

	//Provide instructions on the page. such as * to denote a channel you are suppose to be on, explain what the colours mean.
	_unit createDiaryRecord ["diary", ["ACRE2", (_ltext + _briefAssignedRadios + _text)]]; 

};
