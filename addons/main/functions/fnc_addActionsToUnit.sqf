#include "script_component.hpp"
if (GVAR(aceMedicalLoaded)) exitWith {};
params ["_unit"];

private _arr = [_unit, localize "str_heal", "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_reviveMedic_ca.paa", "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_reviveMedic_ca.paa",
    // condition show
    format ["_this getUnitTrait 'Medic' && { !(_target getVariable ['%2', false] && {alive (_target getVariable ['%3', objNull])}) && {[_this, _originalTarget] call %1}}", QFUNC(canRevive), QGVAR(beingRevived), QGVAR(revivingUnit)],
    "alive _target && {(lifeState _target) == 'INCAPACITATED' && {alive _this && {(lifeState _this) != 'INCAPACITATED'}}}", {
    // code start
    params ["_target", "_caller", "", "_arguments"];
    _arguments params ["_time"];
    private _isProne = stance _caller == "PRONE";
    _caller setVariable [QGVAR(wasProne), _isProne];
    private _medicAnim = ["AinvPknlMstpSlayW[wpn]Dnon_medicOther", "AinvPpneMstpSlayW[wpn]Dnon_medicOther"] select _isProne;
    private _wpn = ["non", "rfl", "lnr", "pst"] param [["", primaryWeapon _caller, secondaryWeapon _caller, handgunWeapon _caller] find currentWeapon _caller, "non"];
    _medicAnim = [_medicAnim, "[wpn]", _wpn] call CBA_fnc_replace;
    _caller setVariable [QGVAR(medicAnim), _medicAnim];
    if (_medicAnim != "") then {
        _caller playMove _medicAnim;
    };
    [format [LLSTRING(reviveUnit), name _target], _time] call FUNC(createProgressBar);
    _target setVariable [QGVAR(beingRevived), true, true];
    _target setVariable [QGVAR(revivingUnit), _caller, true];
}, {
    // code progress
    params ["_target", "_caller"];
    if !(_target getVariable [QGVAR(beingRevived), false]) then {
        _target setVariable [QGVAR(beingRevived), true, true];
        _target setVariable [QGVAR(revivingUnit), _caller, true];
    };
    private _medicAnim = _caller getVariable [QGVAR(medicAnim), ""];
    if (_medicAnim != "" && { animationState _caller != _medicAnim }) then {
        _caller playMove _medicAnim;
    };
}, {
    // codeCompleted
    params ["_target", "_caller"];
    call FUNC(deleteProgressBar);
    [QGVAR(revive), [_target, _caller, true], _target] call CBA_fnc_targetEvent;
    private _anim = ["amovpknlmstpsloww[wpn]dnon", "amovppnemstpsrasw[wpn]dnon"] select (_caller getVariable [QGVAR(wasProne), false]);
    private _wpn = ["non", "rfl", "lnr", "pst"] param [["", primaryWeapon _caller, secondaryWeapon _caller, handgunWeapon _caller] find currentWeapon _caller, "non"];
    _anim = [_anim, "[wpn]", _wpn] call CBA_fnc_replace;
    [QGVAR(switchMove), [_caller, _anim]] call CBA_fnc_globalEvent;
    _target setVariable [QGVAR(beingRevived), nil, true];
    _target setVariable [QGVAR(revivingUnit), nil, true];
}, {
    // code interrupted
    params ["_target", "_caller"];
    call FUNC(deleteProgressBar);
    private _anim = ["amovpknlmstpsloww[wpn]dnon", "amovppnemstpsrasw[wpn]dnon"] select (_caller getVariable [QGVAR(wasProne), false]);
    private _wpn = ["non", "rfl", "lnr", "pst"] param [["", primaryWeapon _caller, secondaryWeapon _caller, handgunWeapon _caller] find currentWeapon _caller, "non"];
    _anim = [_anim, "[wpn]", _wpn] call CBA_fnc_replace;
    [QGVAR(switchMove), [_caller, _anim]] call CBA_fnc_globalEvent;
    _target setVariable [QGVAR(beingRevived), nil, true];
    _target setVariable [QGVAR(revivingUnit), nil, true];
}, [GVAR(medicReviveTime)], GVAR(medicReviveTime), 15, false, false, true];

_arr call BIS_fnc_holdActionAdd;
private _arr2 = +_arr;
_arr2 set [4, format ["!(_this getUnitTrait 'Medic') && { !(_target getVariable ['%2', false] && {alive (_target getVariable ['%3', objNull])}) && {[_this, _originalTarget] call %1}}", QFUNC(canRevive), QGVAR(beingRevived), QGVAR(revivingUnit)]];
_arr2 set [10, [GVAR(noneMedicReviveTime)]];
_arr2 set [11, GVAR(noneMedicReviveTime)];
_arr2 call BIS_fnc_holdActionAdd;


// if (isPlayer _unit && {_unit isNotEqualTo player}) then {
// if (_unit isNotEqualTo player) then {
    // workaround for mods or missions healing the default a3 damage while the internal health is not at max
    // First Aid action for healing others
    private _id = _unit addAction ["<img image='\A3\ui_f\data\igui\cfg\actions\heal_ca.paa' size='1.8' shadow=2 />", {
        params ["", "_caller"];
        private _isProne = stance _caller == "PRONE";
        private _medicAnim = ["AinvPknlMstpSlayW[wpn]Dnon_medicOther", "AinvPpneMstpSlayW[wpn]Dnon_medicOther"] select _isProne;
        private _wpn = ["non", "rfl", "lnr", "pst"] param [["", primaryWeapon _caller, secondaryWeapon _caller, handgunWeapon _caller] find currentWeapon _caller, "non"];
        _medicAnim = [_medicAnim, "[wpn]", _wpn] call CBA_fnc_replace;
        if (_medicAnim != "") then {
            _caller playMove _medicAnim;
        };
        [{
            params ["_target", "_caller"];
            if (!alive _target || {!alive _caller || {_caller getVariable [QGVAR(unconscious), false]}}) exitWith {};
            [QGVAR(heal), [_target, _caller, true], _target] call CBA_fnc_targetEvent;
        }, _this, 5] call CBA_fnc_waitAndExecute;
    }, [], 10, true, true, "", format ["alive _originalTarget && { _originalTarget isNotEqualTo _this && {(damage _originalTarget) isEqualTo 0 && {(_originalTarget getVariable ['%1' , %2]) < (%2 * ([%4, %5] select (_this getUnitTrait 'Medic'))) && {([_this] call %3) > 0}}}}", QGVAR(hp), QGVAR(maxPlayerHP), QFUNC(hasHealItems), QGVAR(maxHealRifleman), QGVAR(maxHealMedic)], 2];
    _unit setUserActionText [_id, format [localize "str_a3_cfgactions_healsoldier0", getText ((configOf _unit) >> "displayName")], "<img image='\A3\ui_f\data\igui\cfg\actions\heal_ca.paa' size='1.8' shadow=2 />"];
// };
