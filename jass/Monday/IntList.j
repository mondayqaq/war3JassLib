#ifndef MondayIntListIncluded
#define MondayIntListIncluded

library IntListLib requires CommonLib

// ============================================================================
// 整数列表（IntList）
// 基于独立哈希表实现的通用带权重整数集合
// 可用于物品池、单位池等各种需要整数集合 + 权重随机的场景
//
// 数据结构（parentKey = 列表ID）：
//   childKey 0            → size（当前条目数量）
//   childKey 1,2,3...     → 整数值（integer）
//   childKey -1,-2,-3...  → 对应位置的权重（integer）
//   childKey -8191        → 总权重（integer）
// ============================================================================

globals
    hashtable IntListHash = InitHashtable()
    private hashtable IntListKeyHash = InitHashtable()
    private integer IntListNextKey = 1000
endglobals

// 生成一个当前游戏内全局不重复的自增整数键
// 从1000开始自增，1~999保留给用户手动指定
private function IntListCreateUniqueKey takes nothing returns integer
    local integer listId = IntListNextKey
    set IntListNextKey = IntListNextKey + 1
    return listId
endfunction

// 根据两个通用整数键获取固定列表ID
// 同一 keyType 和 keyValue 组合在当前游戏中始终返回同一个全局不重复的列表ID
function IntListGetKey takes integer keyType, integer keyValue returns integer
    local integer listId

    if HaveSavedInteger(IntListKeyHash, keyType, keyValue) then
        return LoadInteger(IntListKeyHash, keyType, keyValue)
    endif

    set listId = IntListCreateUniqueKey()
    call SaveInteger(IntListKeyHash, keyType, keyValue, listId)
    return listId
endfunction

// 查找整数值在列表中的索引，不存在返回0
private function IntListFindIndex takes integer listId, integer value returns integer
    local integer size = LoadInteger(IntListHash, listId, 0)
    local integer i = 1

    loop
        exitwhen i > size
        if LoadInteger(IntListHash, listId, i) == value then
            return i
        endif
        set i = i + 1
    endloop

    return 0
endfunction

// 销毁列表
// 清除指定列表ID下的所有数据
function IntListDestroy takes integer listId returns nothing
    call FlushChildHashtable(IntListHash, listId)
endfunction

// 添加整数值到列表中
// unique 为 true 时，若列表中已存在相同值则跳过
function IntListAdd takes integer listId, integer weight, integer value, boolean unique returns nothing
    local integer size

    if unique and IntListFindIndex(listId, value) != 0 then
        return
    endif

    set size = LoadInteger(IntListHash, listId, 0) + 1
    call SaveInteger(IntListHash, listId, size, value)
    call SaveInteger(IntListHash, listId, -size, weight)
    call SaveInteger(IntListHash, listId, 0, size)
    call SaveInteger(IntListHash, listId, -8191, LoadInteger(IntListHash, listId, -8191) + weight)
endfunction

// 添加整数值到列表中（简化版，权重默认100，不去重）
function IntListAddDefault takes integer listId, integer value returns nothing
    call IntListAdd(listId, 100, value, false)
endfunction

// 将连续整数区间填充进列表（权重默认100，不去重）
// 例如 startVal=1, endVal=10 则填充 1,2,3...10
// 例如 startVal=10, endVal=1 则填充 10,9,8...1
function IntListAddRange takes integer listId, integer startVal, integer endVal returns nothing
    local integer i = startVal

    if startVal <= endVal then
        loop
            exitwhen i > endVal
            call IntListAdd(listId, 100, i, false)
            set i = i + 1
        endloop
    else
        loop
            exitwhen i < endVal
            call IntListAdd(listId, 100, i, false)
            set i = i - 1
        endloop
    endif
endfunction

// 从列表中移除指定整数值
// 将末尾条目移到被删位置，保持连续存储
function IntListRemove takes integer listId, integer value returns nothing
    local integer index
    local integer size
    local integer removedWeight

    set index = IntListFindIndex(listId, value)

    if index == 0 then
        return
    endif

    set size = LoadInteger(IntListHash, listId, 0)
    set removedWeight = LoadInteger(IntListHash, listId, -index)

    // 用末尾条目覆盖被删位置
    if index < size then
        call SaveInteger(IntListHash, listId, index, LoadInteger(IntListHash, listId, size))
        call SaveInteger(IntListHash, listId, -index, LoadInteger(IntListHash, listId, -size))
    endif

    // 移除末尾条目
    call RemoveSavedInteger(IntListHash, listId, size)
    call RemoveSavedInteger(IntListHash, listId, -size)
    call SaveInteger(IntListHash, listId, 0, size - 1)
    call SaveInteger(IntListHash, listId, -8191, LoadInteger(IntListHash, listId, -8191) - removedWeight)
endfunction

// 获取列表中的条目数量
function IntListGetSize takes integer listId returns integer
    return LoadInteger(IntListHash, listId, 0)
endfunction

// 获取列表中指定索引的整数值
// index 从1开始；列表为空或索引无效时返回0
function IntListGetValue takes integer listId, integer index returns integer
    local integer size

    set size = LoadInteger(IntListHash, listId, 0)

    if index < 1 or index > size then
        return 0
    endif

    return LoadInteger(IntListHash, listId, index)
endfunction

// 打乱列表中的条目顺序
// 使用 Fisher-Yates 算法；整数值与对应权重会成对交换，总权重保持不变
function IntListShuffle takes integer listId returns nothing
    local integer size
    local integer i
    local integer randomIndex
    local integer value
    local integer weight

    set size = LoadInteger(IntListHash, listId, 0)
    set i = size

    loop
        exitwhen i <= 1
        set randomIndex = GetRandomInt(1, i)

        if randomIndex != i then
            set value = LoadInteger(IntListHash, listId, i)
            set weight = LoadInteger(IntListHash, listId, -i)
            call SaveInteger(IntListHash, listId, i, LoadInteger(IntListHash, listId, randomIndex))
            call SaveInteger(IntListHash, listId, -i, LoadInteger(IntListHash, listId, -randomIndex))
            call SaveInteger(IntListHash, listId, randomIndex, value)
            call SaveInteger(IntListHash, listId, -randomIndex, weight)
        endif

        set i = i - 1
    endloop
endfunction

// 更新指定整数值的权重
// 若整数值不存在于列表中，则不做任何操作
function IntListSetWeight takes integer listId, integer value, integer weight returns nothing
    local integer index
    local integer oldWeight

    set index = IntListFindIndex(listId, value)

    if index != 0 then
        set oldWeight = LoadInteger(IntListHash, listId, -index)
        call SaveInteger(IntListHash, listId, -index, weight)
        call SaveInteger(IntListHash, listId, -8191, LoadInteger(IntListHash, listId, -8191) - oldWeight + weight)
    endif
endfunction

// 随机返回列表中的一个整数值
// useWeight 为 true 时按权重随机，false 时所有条目等概率随机；列表为空时返回0
function IntListGetRandom takes integer listId, boolean useWeight returns integer
    local integer size
    local integer totalWeight
    local integer roll
    local integer cumulative = 0
    local integer i = 1

    set size = LoadInteger(IntListHash, listId, 0)

    if size == 0 then
        return 0
    endif

    if not useWeight then
        return LoadInteger(IntListHash, listId, GetRandomInt(1, size))
    endif

    set totalWeight = LoadInteger(IntListHash, listId, -8191)
    if totalWeight <= 0 then
        return 0
    endif

    set roll = GetRandomInt(1, totalWeight)

    loop
        exitwhen i > size
        set cumulative = cumulative + LoadInteger(IntListHash, listId, -i)
        if roll <= cumulative then
            return LoadInteger(IntListHash, listId, i)
        endif
        set i = i + 1
    endloop

    // 兜底，返回最后一个条目
    return LoadInteger(IntListHash, listId, size)
endfunction

// 创建一个包含连续整数区间的列表，返回列表ID
// 支持从小到大或从大到小
function IntListCreateRange takes integer startVal, integer endVal returns integer
    local integer listId = IntListCreateUniqueKey()
    call IntListAddRange(listId, startVal, endVal)
    return listId
endfunction

// 创建一个包含连续整数区间的随机顺序列表，返回列表ID
// 先填充 startVal 到 endVal 的连续整数，再打乱顺序
function IntListCreateRandomRange takes integer startVal, integer endVal returns integer
    local integer listId = IntListCreateUniqueKey()
    call IntListAddRange(listId, startVal, endVal)
    call IntListShuffle(listId)
    return listId
endfunction

endlibrary

#endif // MondayIntListIncluded
