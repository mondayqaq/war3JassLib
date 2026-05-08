library Monday

globals
    hashtable GlobalHash = InitHashtable()
endglobals

// 获取两个单位之间的角度
function getAngleBetweenUnits takes unit u1, unit u2 returns real 
    local real x = GetUnitX(u1)
    local real y = GetUnitY(u1)
    local real x1 = GetUnitX(u2)
    local real y1 = GetUnitY(u2)
    return Atan2BJ(y1 - y, x1 - x)
endfunction

// 显示DEBUG信息
function showDebugInfo takes boolean b, string info returns nothing
    if b then
        call DisplayTextToPlayer( Player(0), 0, 0, info )
    else 
        call DoNothing(  )
    endif
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

// 获取矩形区域内的随机X坐标
function GetRectRandomX takes rect r returns real
    return GetRectMinX(r) + GetRandomReal(0, GetRectWidthBJ(r))
endfunction

// 获取矩形区域内的随机Y坐标
function GetRectRandomY takes rect r returns real
    return GetRectMinY(r) + GetRandomReal(0, GetRectHeightBJ(r))
endfunction

// 获取 0 ~ 3 中的随机数
function getRandom0To3 takes integer p1, integer p2, integer p3, integer p4 returns integer
    local integer total = p1 + p2 + p3 + p4
    local integer random = GetRandomInt(1, total)
    local integer result = 0
    if random <= p1 then
        set result = 0
    elseif random <= p1 + p2 then
        set result = 1
    elseif random <= p1 + p2 + p3 then
        set result = 2
    else
        set result = 3
    endif
    return result
endfunction

// 创建漂浮文本
function createFloatText takes string str, real height, integer red, integer green, integer blue, integer alpha, real x, real y, real z, real lifespan returns nothing
    local texttag text = CreateTextTag()
    call SetTextTagText(text, str, height)
    call SetTextTagColor(text, red, green, blue, alpha)
    call SetTextTagPos(text, x, y, z)
    call SetTextTagLifespan(text, lifespan)
    call SetTextTagPermanent(text, false)
    call SetTextTagVisibility(text, true)
endfunction    

// 坐标是否在矩形区域内
function isCoordinateInRect takes rect r, real x, real y returns boolean
    if x <= GetRectMaxX(r) and x >= GetRectMinX(r) and y <= GetRectMaxY(r) and y >= GetRectMinY(r) then
        return true
    else
        return false
    endif
endfunction

// 设置单位尺寸（单参数）
function SetUnitScaleSingle takes unit u, real size returns nothing
    if size > 0 then
        call SetUnitScale(u, size, size, size)
    endif 
endfunction	

// 转换整型数据为武器类型（声音）
function ConvertIntToWeaponType takes integer i returns weapontype
    if i == 0 then
        return WEAPON_TYPE_WHOKNOWS
    elseif i == 1 then
        return WEAPON_TYPE_METAL_LIGHT_CHOP
    elseif i == 2 then
        return WEAPON_TYPE_METAL_MEDIUM_CHOP
    elseif i == 3 then
        return WEAPON_TYPE_METAL_HEAVY_CHOP
    elseif i == 4 then
        return WEAPON_TYPE_METAL_LIGHT_SLICE
    elseif i == 5 then
        return WEAPON_TYPE_METAL_MEDIUM_SLICE
    elseif i == 6 then
        return WEAPON_TYPE_METAL_HEAVY_SLICE
    elseif i == 7 then
        return WEAPON_TYPE_METAL_MEDIUM_BASH
    elseif i == 8 then
        return WEAPON_TYPE_WOOD_LIGHT_BASH
    elseif i == 9 then
        return WEAPON_TYPE_WOOD_MEDIUM_BASH
    elseif i == 10 then
        return WEAPON_TYPE_WOOD_HEAVY_BASH
    elseif i == 11 then
        return WEAPON_TYPE_AXE_MEDIUM_CHOP
    elseif i == 12 then
        return WEAPON_TYPE_ROCK_HEAVY_BASH
    endif
    // 默认返回未知类型
    return WEAPON_TYPE_WHOKNOWS
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

// 比较两个整数
function CompareIntegers takes integer a, integer opType, integer b returns boolean
    // 定义关系运算符常量
    local integer OP_GREATER_OR_EQUAL = 0  // >=
    local integer OP_GREATER = 1           // >
    local integer OP_EQUAL = 2             // ==
    local integer OP_LESS = 3              // <
    local integer OP_LESS_OR_EQUAL = 4     // <=
    local integer OP_NOT_EQUAL = 5         // !=
    
    // 根据运算符类型进行比较
    if opType == OP_GREATER_OR_EQUAL then
        return a >= b
    elseif opType == OP_GREATER then
        return a > b
    elseif opType == OP_EQUAL then
        return a == b
    elseif opType == OP_LESS then
        return a < b
    elseif opType == OP_LESS_OR_EQUAL then
        return a <= b
    elseif opType == OP_NOT_EQUAL then
        return a != b
    endif
    
    // 默认情况（理论上不会执行到这里）
    return false
endfunction

// 比较两个实数
function CompareReals takes real a, integer opType, real b returns boolean
    // 定义关系运算符常量
    local integer OP_GREATER_OR_EQUAL = 0  // >=
    local integer OP_GREATER = 1           // >
    local integer OP_EQUAL = 2             // ==
    local integer OP_LESS = 3              // <
    local integer OP_LESS_OR_EQUAL = 4     // <=
    local integer OP_NOT_EQUAL = 5         // !=
    
    // 根据运算符类型进行比较
    if opType == OP_GREATER_OR_EQUAL then
        return a >= b
    elseif opType == OP_GREATER then
        return a > b
    elseif opType == OP_EQUAL then
        return a == b
    elseif opType == OP_LESS then
        return a < b
    elseif opType == OP_LESS_OR_EQUAL then
        return a <= b
    elseif opType == OP_NOT_EQUAL then
        return a != b
    endif
    
    // 默认情况（理论上不会执行到这里）
    return false
endfunction

// 根据布尔值选择返回整数
function SelectInteger takes boolean condition, integer a, integer b returns integer
    if condition then
        return a
    else
        return b
    endif
endfunction

// 根据布尔值选择返回实数
function SelectReal takes boolean condition, real a, real b returns real
    if condition then
        return a
    else
        return b
    endif
endfunction

// 计时器回调函数 - 恢复单位
function ResumeUnitAfterBirth takes nothing returns nothing
    local timer expiredTimer = GetExpiredTimer()
    local integer timerId = GetHandleId(expiredTimer)
    local unit whichUnit = LoadUnitHandle(GlobalHash, timerId, 0)
    
    // 检查单位是否仍然有效
    if whichUnit != null and GetUnitTypeId(whichUnit) != 0 then
        // 恢复单位
        call PauseUnit(whichUnit, false)
        // 重置单位动画
        call ResetUnitAnimation(whichUnit)
    endif
    
    // 清理哈希表数据
    call RemoveSavedHandle(GlobalHash, timerId, 0)
    
    // 销毁计时器
    call DestroyTimer(expiredTimer)
    
    // 清理变量
    set expiredTimer = null
    set whichUnit = null
endfunction

// 播放单位出生动画
function PlayUnitBirthAnimation takes unit whichUnit, real seconds returns nothing
    local timer resumeTimer
    local integer timerId
    
    if seconds <= 0 then
        return
    endif
    
    // 检查单位是否有效
    if whichUnit == null or GetUnitTypeId(whichUnit) == 0 then
        return
    endif
    
    // 暂停单位
    call PauseUnit(whichUnit, true)
    
    // 播放出生动画
    call SetUnitAnimation(whichUnit, "birth")
    
    // 创建计时器用于恢复单位
    set resumeTimer = CreateTimer()
    set timerId = GetHandleId(resumeTimer)
    
    // 将单位保存到哈希表中
    call SaveUnitHandle(GlobalHash, timerId, 0, whichUnit)
    
    // 设置计时器，在指定时间后执行恢复操作
    call TimerStart(resumeTimer, seconds, false, function ResumeUnitAfterBirth)
    
    // 清理计时器变量
    set resumeTimer = null
endfunction

// 生成区间内排除某个值的随机整数
function GetRandomIntExclude takes integer minVal, integer maxVal, integer excludeVal returns integer
    local integer randomVal
    local integer rangeSize
    
    // 确保 minVal <= maxVal
    if minVal > maxVal then
        set randomVal = minVal
        set minVal = maxVal
        set maxVal = randomVal
    endif
    
    // 计算区间大小
    set rangeSize = maxVal - minVal + 1
    
    // 特殊情况处理：区间内只有一个值且等于排除值，返回0
    if rangeSize == 1 and minVal == excludeVal then
        return 0
    endif
    
    // 如果排除值不在区间内，直接生成随机数
    if excludeVal < minVal or excludeVal > maxVal then
        return GetRandomInt(minVal, maxVal)
    endif
    
    // 如果排除值在区间内，调整随机数生成范围
    set randomVal = GetRandomInt(minVal, maxVal - 1)
    
    // 如果随机数大于等于排除值，则加1
    if randomVal >= excludeVal then
        set randomVal = randomVal + 1
    endif
    
    return randomVal
endfunction

// 获取矩形区域指定位置的 X 坐标（1=中心 2=随机坐标 3=左上角 4=右上角 5=左下角 6=右上角）
function GetRectPositionX takes rect whichRect, integer positionType returns real
    local real minX = GetRectMinX(whichRect)
    local real maxX = GetRectMaxX(whichRect)
    
    if positionType == 2 then
        return GetRandomReal(minX, maxX)
    elseif positionType == 3 or positionType == 5 then
        return minX 
    elseif positionType == 4 or positionType == 6 then
        return maxX
    else
        return (minX + maxX) / 2.0
    endif
endfunction

// 获取矩形区域指定位置的 Y 坐标（1=中心 2=随机坐标 3=左上角 4=右上角 5=左下角 6=右上角）
function GetRectPositionY takes rect whichRect, integer positionType returns real
    local real minY = GetRectMinY(whichRect)
    local real maxY = GetRectMaxY(whichRect)
    
    if positionType == 2 then
        return GetRandomReal(minY, maxY)
    elseif positionType == 3 or positionType == 5 then
        return maxY
    elseif positionType == 4 or positionType == 6 then
        return minY
    else
        return (minY + maxY) / 2.0
    endif
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

// ============================================================================
// 数学运算
// 提供实数和整数的混合运算功能
// ============================================================================

// 算数运算（实数与实数）
private function CalculateRealWithReal takes real realNum1, integer operatorType, real realNum2 returns real
    if operatorType == 0 then
        return realNum1 + realNum2
    elseif operatorType == 1 then
        return realNum1 - realNum2
    elseif operatorType == 2 then
        return realNum1 * realNum2
    elseif operatorType == 3 and realNum2 != 0.0 then
        return realNum1 / realNum2
    endif
    return 0.0
endfunction

// 算数运算（实数与整数）
function CalculateRealWithInt takes real realNum, integer operatorType, integer intNum returns real
    return CalculateRealWithReal(realNum, operatorType, I2R(intNum))
endfunction

// 算数运算（实数与实数与整数）
function CalculateRealWithIntExtended takes real realNum1, integer operatorType1, real realNum2, integer operatorType2, integer intNum returns real
    // 先乘除后加减
    if operatorType2 == 2 or operatorType2 == 3 then
        return CalculateRealWithReal(realNum1, operatorType1, CalculateRealWithInt(realNum2, operatorType2, intNum))
    else
        return CalculateRealWithInt(CalculateRealWithReal(realNum1, operatorType1, realNum2), operatorType2, intNum)
    endif
endfunction

// ============================================================================
// 默认值工具函数
// ============================================================================

/**
 * 获取实数默认值：若第一个实数为0，则返回第二个实数，否则返回第一个实数
 * 
 * @param value 要检查的实数
 * @param defaultValue 默认值
 * @returns 若value为0则返回defaultValue，否则返回value
 * 
 */
function GetRealOrDefault takes real value, real defaultValue returns real
    if value == 0.0 then
        return defaultValue
    endif
    return value
endfunction

/**
 * 获取整数默认值：若第一个整数为0，则返回第二个整数，否则返回第一个整数
 * 
 * @param value 要检查的整数
 * @param defaultValue 默认值
 * @returns 若value为0则返回defaultValue，否则返回value
 * 
 */
function GetIntegerOrDefault takes integer value, integer defaultValue returns integer
    if value == 0 then
        return defaultValue
    endif
    return value
endfunction

/**
 * 计算二次函数值：k * (a * n^2 + b * n + c)
 * 
 * @param k 系数（如 2/5 则传入 0.4）
 * @param a 二次项系数
 * @param b 一次项系数
 * @param c 常数项
 * @param n 变量（如等级）
 * @returns 计算结果
 */
function QuadraticFunction takes real k, real a, real b, real c, real n returns real
    return k * (a * n * n + b * n + c)
endfunction

// 拼接字符串（中间插入整数）
function ConcatStringInt takes string prefix, integer value, string suffix returns string
    return prefix + I2S(value) + suffix
endfunction

// 拼接字符串（中间插入实数，保留指定位数小数）
function ConcatStringReal takes string prefix, real value, integer decimals, string suffix returns string
    if decimals <= 0 then
        return prefix + I2S(R2I(value)) + suffix
    endif
    return prefix + R2SW(value, 0, decimals) + suffix
endfunction

/**
 * 逻辑与运算
 * 
 * @param a 第一个布尔值
 * @param b 第二个布尔值
 * @returns 两个布尔值的与运算结果
 */
function BooleanAnd takes boolean a, boolean b returns boolean
    return a and b
endfunction

/**
 * 逻辑或运算
 * 
 * @param a 第一个布尔值
 * @param b 第二个布尔值
 * @returns 两个布尔值的或运算结果
 */
function BooleanOr takes boolean a, boolean b returns boolean
    return a or b
endfunction

endlibrary 