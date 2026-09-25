library ItemPoolLib requires CommonLib

// ============================================================================
// 增强版物品池（ItemPoolEx）
// 基于独立哈希表实现，解决原生 itempool 无法获取数量和无法只获取类型ID的问题
//
// 数据结构（parentKey = 池ID）：
//   childKey 0            → size（当前条目数量）
//   childKey 1,2,3...     → 物品类型ID（integer）
//   childKey -1,-2,-3...  → 对应位置的权重（integer）
//   childKey -8191        → 总权重（integer）
// ============================================================================

globals
    hashtable ItemPoolHash = InitHashtable()
    private hashtable ItemPoolKeyHash = InitHashtable()
    private constant integer ITEM_POOL_EX_KEY_USED_MARKER = -2147483647
endglobals

// 登记已使用的池ID，避免全局随机键与手工传入的池ID重复
private function ItemPoolExRegisterKey takes integer poolId returns nothing
    call SaveBoolean(ItemPoolKeyHash, poolId, ITEM_POOL_EX_KEY_USED_MARKER, true)
endfunction

// 生成一个当前游戏内全局不重复的随机正整数键
private function ItemPoolExCreateUniqueKey takes nothing returns integer
    local integer poolId

    loop
        set poolId = GetRandomInt(1, 2000000000)
        exitwhen not HaveSavedBoolean(ItemPoolKeyHash, poolId, ITEM_POOL_EX_KEY_USED_MARKER)
    endloop

    call ItemPoolExRegisterKey(poolId)
    return poolId
endfunction

// 根据两个通用整数键获取固定物品池ID
// keyValue 不可使用保留值 -2147483647
// 同一 keyType 和 keyValue 组合在当前游戏中始终返回同一个随机且全局不重复的池ID
function ItemPoolExGetKey takes integer keyType, integer keyValue returns integer
    local integer poolId

    if HaveSavedInteger(ItemPoolKeyHash, keyType, keyValue) then
        return LoadInteger(ItemPoolKeyHash, keyType, keyValue)
    endif

    set poolId = ItemPoolExCreateUniqueKey()
    call SaveInteger(ItemPoolKeyHash, keyType, keyValue, poolId)
    return poolId
endfunction

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
// 清除指定池ID下的所有物品和权重数据，但保留通用键到池ID的映射
function ItemPoolExDestroy takes integer poolId returns nothing
    call ItemPoolExRegisterKey(poolId)
    call FlushChildHashtable(ItemPoolHash, poolId)
endfunction

// 添加物品类型到池中
// unique 为 true 时，若池中已存在相同 itemId 则跳过
function ItemPoolExAdd takes integer poolId, integer weight, integer itemId, boolean unique returns nothing
    local integer size

    call ItemPoolExRegisterKey(poolId)

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
    local integer index
    local integer size
    local integer removedWeight

    call ItemPoolExRegisterKey(poolId)
    set index = ItemPoolExFindIndex(poolId, itemId)

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
    call ItemPoolExRegisterKey(poolId)
    return LoadInteger(ItemPoolHash, poolId, 0)
endfunction

// 获取池中指定索引的物品类型
// index 从1开始；池为空或索引无效时返回0
function ItemPoolExGetItemCode takes integer poolId, integer index returns integer
    local integer size

    call ItemPoolExRegisterKey(poolId)
    set size = LoadInteger(ItemPoolHash, poolId, 0)

    if index < 1 or index > size then
        return 0
    endif

    return LoadInteger(ItemPoolHash, poolId, index)
endfunction

// 打乱池中物品类型顺序
// 使用 Fisher-Yates 算法；物品类型与对应权重会成对交换，总权重保持不变
function ItemPoolExShuffle takes integer poolId returns nothing
    local integer size
    local integer i
    local integer randomIndex
    local integer itemId
    local integer weight

    call ItemPoolExRegisterKey(poolId)
    set size = LoadInteger(ItemPoolHash, poolId, 0)
    set i = size

    loop
        exitwhen i <= 1
        set randomIndex = GetRandomInt(1, i)

        if randomIndex != i then
            set itemId = LoadInteger(ItemPoolHash, poolId, i)
            set weight = LoadInteger(ItemPoolHash, poolId, -i)
            call SaveInteger(ItemPoolHash, poolId, i, LoadInteger(ItemPoolHash, poolId, randomIndex))
            call SaveInteger(ItemPoolHash, poolId, -i, LoadInteger(ItemPoolHash, poolId, -randomIndex))
            call SaveInteger(ItemPoolHash, poolId, randomIndex, itemId)
            call SaveInteger(ItemPoolHash, poolId, -randomIndex, weight)
        endif

        set i = i - 1
    endloop
endfunction

// 更新指定物品类型的权重
// 若物品类型不存在于池中，则不做任何操作
function ItemPoolExSetWeight takes integer poolId, integer itemId, integer weight returns nothing
    local integer index
    local integer oldWeight

    call ItemPoolExRegisterKey(poolId)
    set index = ItemPoolExFindIndex(poolId, itemId)

    if index != 0 then
        set oldWeight = LoadInteger(ItemPoolHash, poolId, -index)
        call SaveInteger(ItemPoolHash, poolId, -index, weight)
        call SaveInteger(ItemPoolHash, poolId, -8191, LoadInteger(ItemPoolHash, poolId, -8191) - oldWeight + weight)
    endif
endfunction

// 随机返回一个物品类型ID
// useWeight 为 true 时按权重随机，false 时所有条目等概率随机；池为空时返回0
function ItemPoolExGetRandomItemCode takes integer poolId, boolean useWeight returns integer
    local integer size
    local integer totalWeight
    local integer roll
    local integer cumulative = 0
    local integer i = 1

    call ItemPoolExRegisterKey(poolId)
    set size = LoadInteger(ItemPoolHash, poolId, 0)

    if size == 0 then
        return 0
    endif

    if not useWeight then
        return LoadInteger(ItemPoolHash, poolId, GetRandomInt(1, size))
    endif

    set totalWeight = LoadInteger(ItemPoolHash, poolId, -8191)
    if totalWeight <= 0 then
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

// 随机创建物品
// useWeight 为 true 时按权重随机，false 时所有条目等概率随机；池为空时返回 null
function ItemPoolExPlaceItem takes integer poolId, boolean useWeight, real x, real y returns item
    local integer itemId

    call ItemPoolExRegisterKey(poolId)
    set itemId = ItemPoolExGetRandomItemCode(poolId, useWeight)

    if itemId == 0 then
        return null
    endif

    return CreateItem(itemId, x, y)
endfunction

endlibrary
