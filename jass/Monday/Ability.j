library AbilityLib requires Monday

native EXGetUnitAbility takes unit u, integer abilcode returns ability
native EXSetAbilityState takes ability a, integer state_type, real value returns boolean

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

// 添加技能给单位并设置技能等级和初始冷却时间
function AddAbilityWithCooldown takes unit targetUnit, integer abilityId, integer levels, real cooldown returns nothing
    local integer currentLevel = GetUnitAbilityLevel(targetUnit, abilityId)
    if currentLevel == 0 then
        call UnitAddAbility(targetUnit, abilityId)
    endif
    if levels > 1 then
        call SetUnitAbilityLevel(targetUnit, abilityId, levels)
    endif
    if cooldown > 0 then
        call EXSetAbilityState(EXGetUnitAbility(targetUnit, abilityId), 1, cooldown)
    endif
endfunction

// 计时器回调 - 复原被替换的技能
function RestoreReplacedAbility takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local unit u = LoadUnitHandle(GlobalHash, id, 0)
    local integer origAbilId = LoadInteger(GlobalHash, id, 1)
    local integer origLevel = LoadInteger(GlobalHash, id, 2)
    local integer newAbilId = LoadInteger(GlobalHash, id, 3)
    local real cooldown = LoadReal(GlobalHash, id, 4)
    
    // 如果单位还拥有替换后的技能，则移除并恢复原技能
    if GetUnitAbilityLevel(u, newAbilId) > 0 then
        call UnitRemoveAbility(u, newAbilId)
        call AddAbilityWithCooldown(u, origAbilId, origLevel, cooldown)
    endif
    
    call FlushChildHashtable(GlobalHash, id)
    call DestroyTimer(t)
    set t = null
    set u = null
endfunction

// 替换单位技能，可选继承等级，X秒后复原，支持设置复原后的冷却时间
function ReplaceAbilityTimed takes unit targetUnit, integer origAbilId, integer newAbilId, boolean inheritLevel, real duration, real cooldown returns nothing
    local integer origLevel = GetUnitAbilityLevel(targetUnit, origAbilId)
    local integer newLevel = 1
    local timer t
    local integer id
    
    // 原技能不存在则不处理
    if origLevel == 0 then
        return
    endif
    
    if inheritLevel then
        set newLevel = origLevel
    endif
    
    // 移除原技能，添加新技能
    call UnitRemoveAbility(targetUnit, origAbilId)
    call UnitAddAbility(targetUnit, newAbilId)
    if newLevel > 1 then
        call SetUnitAbilityLevel(targetUnit, newAbilId, newLevel)
    endif
    
    // 设置计时器用于复原
    if duration > 0 then
        set t = CreateTimer()
        set id = GetHandleId(t)
        call SaveUnitHandle(GlobalHash, id, 0, targetUnit)
        call SaveInteger(GlobalHash, id, 1, origAbilId)
        call SaveInteger(GlobalHash, id, 2, origLevel)
        call SaveInteger(GlobalHash, id, 3, newAbilId)
        call SaveReal(GlobalHash, id, 4, cooldown)
        call TimerStart(t, duration, false, function RestoreReplacedAbility)
        set t = null
    endif
endfunction

endlibrary