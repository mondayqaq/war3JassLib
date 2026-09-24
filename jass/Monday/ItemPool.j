library ItemPoolLib requires CommonLib

// ============================================================================
// 增强版物品池（ItemPoolEx）
// 基于独立哈希表实现，解决原生 itempool 无法获取数量和无法只获取类型ID的问题
// 
// 数据结构（parentKey = 池ID，由用户传入）：
//   childKey 0            → size（当前条目数量）
//   childKey 1,2,3...     → 物品类型ID（integer）
//   childKey -1,-2,-3...  → 对应位置的权重（integer）
//   childKey -8191        → 总权重（integer）
// ============================================================================

globals
    hashtable ItemPoolHash = InitHashtable()
endglobals

// 查找物品类型在池中的索引，不存在返回0
private function ItemPoolExFindIndex takes integer poolId, integer itemId returns integer
    local integer size = LoadInteger(ItemPoolHash, poolId, 0)
    local integer i = 1

    loop
        exitwhen i > size
        if LoadInteger(ItemPoolHash, poolId, i) == itemId then
            return i
        endif
        set i = i + 1
    endloop

    return 0
endfunction

// 销毁物品池
// 清除指定池ID下的所有哈希表数据
function DestroyItemPoolEx takes integer poolId returns nothing
    call FlushChildHashtable(ItemPoolHash, poolId)
endfunction

// 添加物品类型到池中
// unique 为 true 时，若池中已存在相同 itemId 则跳过
function ItemPoolExAdd takes integer poolId, integer itemId, integer weight, boolean unique returns nothing
    local integer size

    if unique and ItemPoolExFindIndex(poolId, itemId) != 0 then
        return
    endif

    set size = LoadInteger(ItemPoolHash, poolId, 0) + 1
    call SaveInteger(ItemPoolHash, poolId, size, itemId)
    call SaveInteger(ItemPoolHash, poolId, -size, weight)
    call SaveInteger(ItemPoolHash, poolId, 0, size)
    call SaveInteger(ItemPoolHash, poolId, -8191, LoadInteger(ItemPoolHash, poolId, -8191) + weight)
endfunction

// 从池中移除指定物品类型
// 将末尾条目移到被删位置，保持连续存储
function ItemPoolExRemove takes integer poolId, integer itemId returns nothing
    local integer index = ItemPoolExFindIndex(poolId, itemId)
    local integer size
    local integer removedWeight

    if index == 0 then
        return
    endif

    set size = LoadInteger(ItemPoolHash, poolId, 0)
    set removedWeight = LoadInteger(ItemPoolHash, poolId, -index)

    // 用末尾条目覆盖被删位置
    if index < size then
        call SaveInteger(ItemPoolHash, poolId, index, LoadInteger(ItemPoolHash, poolId, size))
        call SaveInteger(ItemPoolHash, poolId, -index, LoadInteger(ItemPoolHash, poolId, -size))
    endif

    // 移除末尾条目
    call RemoveSavedInteger(ItemPoolHash, poolId, size)
    call RemoveSavedInteger(ItemPoolHash, poolId, -size)
    call SaveInteger(ItemPoolHash, poolId, 0, size - 1)
    call SaveInteger(ItemPoolHash, poolId, -8191, LoadInteger(ItemPoolHash, poolId, -8191) - removedWeight)
endfunction

// 获取池中物品类型数量
function ItemPoolExGetSize takes integer poolId returns integer
    return LoadInteger(ItemPoolHash, poolId, 0)
endfunction

// 更新指定物品类型的权重
// 若物品类型不存在于池中，则不做任何操作
function ItemPoolExSetWeight takes integer poolId, integer itemId, integer weight returns nothing
    local integer index = ItemPoolExFindIndex(poolId, itemId)
    local integer oldWeight

    if index != 0 then
        set oldWeight = LoadInteger(ItemPoolHash, poolId, -index)
        call SaveInteger(ItemPoolHash, poolId, -index, weight)
        call SaveInteger(ItemPoolHash, poolId, -8191, LoadInteger(ItemPoolHash, poolId, -8191) - oldWeight + weight)
    endif
endfunction

// 按权重随机返回一个物品类型ID
// 池为空时返回0
function ItemPoolExGetRandomId takes integer poolId returns integer
    local integer size = LoadInteger(ItemPoolHash, poolId, 0)
    local integer totalWeight = LoadInteger(ItemPoolHash, poolId, -8191)
    local integer roll
    local integer cumulative = 0
    local integer i = 1

    if size == 0 or totalWeight <= 0 then
        return 0
    endif

    set roll = GetRandomInt(1, totalWeight)

    loop
        exitwhen i > size
        set cumulative = cumulative + LoadInteger(ItemPoolHash, poolId, -i)
        if roll <= cumulative then
            return LoadInteger(ItemPoolHash, poolId, i)
        endif
        set i = i + 1
    endloop

    // 兜底，返回最后一个条目
    return LoadInteger(ItemPoolHash, poolId, size)
endfunction

// 按权重随机创建物品
// 池为空时返回 null
function PlaceRandomItemEx takes integer poolId, real x, real y returns item
    local integer itemId = ItemPoolExGetRandomId(poolId)

    if itemId == 0 then
        return null
    endif

    return CreateItem(itemId, x, y)
endfunction

endlibrary
