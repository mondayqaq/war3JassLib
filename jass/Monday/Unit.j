library UnitLib requires CommonLib

// 判断单位是否面向指定坐标
// angle 为总角度范围（如 90 表示左右各 45 度）
function IsUnitFacingCoordinate takes unit whichUnit, real x, real y, real angle returns boolean
    local real unitX = GetUnitX(whichUnit)
    local real unitY = GetUnitY(whichUnit)
    local real unitFacing = GetUnitFacing(whichUnit)
    local real targetAngle = Atan2BJ(y - unitY, x - unitX)
    local real angleDiff
    
    // 计算角度差
    set angleDiff = targetAngle - unitFacing
    
    // 处理角度差为负数的情况
    if angleDiff < 0 then
        set angleDiff = -angleDiff
    endif
    
    // 处理 360 度边界情况（如 350° 和 10° 差值应为 20° 而非 340°）
    if angleDiff > 180 then
        set angleDiff = 360 - angleDiff
    endif
    
    // 判断是否在角度范围内
    return angleDiff <= angle / 2.0
endfunction

// 获取两个单位之间的角度
function getAngleBetweenUnits takes unit u1, unit u2 returns real 
    local real x = GetUnitX(u1)
    local real y = GetUnitY(u1)
    local real x1 = GetUnitX(u2)
    local real y1 = GetUnitY(u2)
    return Atan2BJ(y1 - y, x1 - x)
endfunction

// 创建临时单位
function CreateTemporaryUnit takes player id, integer abilityId, real duration, integer buffId, integer unitId, real x, real y, real face returns unit
    local unit u = CreateUnit(id, unitId, x, y, face)
    call UnitAddAbility(u, abilityId)
    call UnitApplyTimedLife(u, buffId, duration)
    return u
endfunction

// 创建临时单位（无技能）
function CreateTemporaryUnit2 takes player id, real duration, integer buffId, integer unitId, real x, real y, real face returns unit
    local unit u = CreateUnit(id, unitId, x, y, face)
    call UnitApplyTimedLife(u, buffId, duration)
    return u
endfunction

// 设置单位尺寸（单参数）
function SetUnitScaleSingle takes unit u, real size returns nothing
    if size > 0 then
        call SetUnitScale(u, size, size, size)
    endif 
endfunction

// 单位是否无敌
function IsUnitInvulnerable takes unit u returns boolean
    if (((GetUnitAbilityLevel(u, 'Bvul') > 0) or (GetUnitAbilityLevel(u, 'BHds') > 0) or (GetUnitAbilityLevel(u, 'BOvd') > 0) or (GetUnitAbilityLevel(u, 'Avul') > 0))) then
        return true
    else
        return false
    endif
endfunction

// 获取以坐标(x, y)为中心，radius为半径范围内的随机敌对单位
function GetRandomEnemyUnitInRange takes player sourcePlayer, real x, real y, real radius returns unit
    local group enemyGroup
    local unit randomUnit
    local unit array validUnits
    local integer validCount = 0
    local integer i
    
    // 初始化变量
    set enemyGroup = CreateGroup()
    set randomUnit = null
    
    // 枚举指定点半径范围内的所有单位
    call GroupEnumUnitsInRange(enemyGroup, x, y, radius, null)
    
    // 收集所有符合条件的单位
    loop
        set randomUnit = FirstOfGroup(enemyGroup)
        exitwhen randomUnit == null
        
        // 检查单位是否符合条件：非死亡、非无敌、是敌方单位
        if IsUnitEnemy(randomUnit, sourcePlayer) and not IsUnitType(randomUnit, UNIT_TYPE_DEAD) and not IsUnitType(randomUnit, UNIT_TYPE_ETHEREAL) and GetUnitAbilityLevel(randomUnit, 'Avul') == 0 then
            // 将符合条件的单位添加到数组
            set validUnits[validCount] = randomUnit
            set validCount = validCount + 1
        endif
        
        // 从组中移除当前单位，继续处理下一个
        call GroupRemoveUnit(enemyGroup, randomUnit)
    endloop
    
    // 如果有符合条件的单位，随机选择一个
    if validCount > 0 then
        set i = GetRandomInt(0, validCount - 1)
        set randomUnit = validUnits[i]
    else
        set randomUnit = null
    endif
    
    // 清理组并返回结果
    call DestroyGroup(enemyGroup)
    set enemyGroup = null
    
    return randomUnit
endfunction

// 移动单位到矩形区域
function MoveUnitToRectPosition takes unit whichUnit, rect whichRect, integer positionType returns boolean
    local real array targetPos
    
    // 检查参数是否有效
    if whichUnit == null or whichRect == null then
        return false
    endif
    
    // 移动单位到目标位置
    call SetUnitX(whichUnit, GetRectPositionX(whichRect, positionType))
    call SetUnitY(whichUnit, GetRectPositionY(whichRect, positionType))
    
    return true
endfunction

endlibrary