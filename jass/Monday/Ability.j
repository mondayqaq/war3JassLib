library AbilityLib

// 提升单位的技能等级
function IncAbilityLevel takes unit targetUnit, integer abilityId, integer levels returns nothing
    local integer currentLevel = GetUnitAbilityLevel(targetUnit, abilityId)
    if currentLevel == 0 then
        call UnitAddAbility(targetUnit, abilityId)
        if levels > 1 then
            call SetUnitAbilityLevel(targetUnit, abilityId, levels)
        endif
    else
        call SetUnitAbilityLevel(targetUnit, abilityId, currentLevel + levels)
    endif
endfunction

// 添加技能给单位并设置技能等级
function SetAbilityLevel takes unit targetUnit, integer abilityId, integer levels returns nothing
    local integer currentLevel = GetUnitAbilityLevel(targetUnit, abilityId)
    if currentLevel == 0 then
        call UnitAddAbility(targetUnit, abilityId)
        if levels > 1 then
            call SetUnitAbilityLevel(targetUnit, abilityId, levels)
        endif
    else
        if levels >= 1 and levels != currentLevel then
            call SetUnitAbilityLevel(targetUnit, abilityId, levels)
        endif
    endif
endfunction

endlibrary