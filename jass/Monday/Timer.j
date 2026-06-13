library Timer requires CommonLib

// ============================================================================
// 库初始化
// ============================================================================

globals
    private timer GameTimeTimer = null
    private real GameTime = 0.0
endglobals

// ============================================================================
// 游戏时间系统
// ============================================================================

// 游戏时间更新回调
private function UpdateGameTime takes nothing returns nothing
    set GameTime = GameTime + 0.1
endfunction

// 库初始化函数
function TimerLib_Init takes nothing returns nothing
    if GameTimeTimer == null then
        set GameTimeTimer = CreateTimer()
        call TimerStart(GameTimeTimer, 0.1, true, function UpdateGameTime)
    endif
endfunction

// 获取游戏时间（秒）
function GetGameTime takes nothing returns real
    return GameTime
endfunction

// ============================================================================
// 单位时间间隔系统
// 用于检查单位是否满足时间间隔要求（通用用途）
// 例如：伤害冷却、技能释放间隔、触发间隔等
// ============================================================================

/**
 * 检查单位是否满足时间间隔要求
 * 如果距离上次操作已超过指定间隔，自动更新时间戳并返回 true
 * 
 * @param u 目标单位
 * @param interval 最小时间间隔（秒）
 * @param key 存储键值（用于区分不同操作类型，默认填0）
 * @returns true = 可以执行操作，false = 时间间隔不足
 */
function CheckUnitTimeInterval takes unit u, real interval, integer key returns boolean
    local integer unitId = GetHandleId(u)
    local real lastTime = LoadReal(GlobalHash, unitId, key)
    
    // 如果没有记录时间或间隔已满足
    if lastTime == 0.0 or GameTime - lastTime >= interval then
        call SaveReal(GlobalHash, unitId, key, GameTime)
        return true
    endif
    return false
endfunction

/**
 * 重置单位的时间间隔记录
 * 
 * @param u 目标单位
 * @param key 存储键值
 */
function ResetUnitTimeInterval takes unit u, integer key returns nothing
    call RemoveSavedReal(GlobalHash, GetHandleId(u), key)
endfunction

/**
 * 清理单位所有时间间隔数据
 * 用于单位死亡时清理内存
 * 
 * @param u 目标单位
 */
function CleanUnitAllTimeIntervals takes unit u returns nothing
    call FlushChildHashtable(GlobalHash, GetHandleId(u))
endfunction

// ============================================================================
// 单位动画计时器系统
// ============================================================================

// 计时器回调函数 - 恢复单位
private function ResumeUnitAfterBirth takes nothing returns nothing
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

/**
 * 播放单位出生动画
 * 暂停单位并播放出生动画，指定时间后自动恢复
 * 
 * @param whichUnit 目标单位
 * @param seconds 持续时间（秒）
 */
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

endlibrary