library ItemPoolLib requires IntListLib

// ============================================================================
// 增强版物品池（ItemPoolEx）
// 基于 IntList 的薄封装，提供物品类型专用的语义接口
// ============================================================================

// 根据两个通用整数键获取固定物品池ID
// 同一 keyType 和 keyValue 组合在当前游戏中始终返回同一个全局不重复的池ID
function ItemPoolExGetKey takes integer keyType, integer keyValue returns integer
    return IntListGetKey(keyType, keyValue)
endfunction

// 销毁物品池
function ItemPoolExDestroy takes integer poolId returns nothing
    call IntListDestroy(poolId)
endfunction

// 添加物品类型到池中
// unique 为 true 时，若池中已存在相同 itemId 则跳过
function ItemPoolExAdd takes integer poolId, integer weight, integer itemId, boolean unique returns nothing
    call IntListAdd(poolId, weight, itemId, unique)
endfunction

// 从池中移除指定物品类型
function ItemPoolExRemove takes integer poolId, integer itemId returns nothing
    call IntListRemove(poolId, itemId)
endfunction

// 获取池中物品类型数量
function ItemPoolExGetSize takes integer poolId returns integer
    return IntListGetSize(poolId)
endfunction

// 获取池中指定索引的物品类型
// index 从1开始；池为空或索引无效时返回0
function ItemPoolExGetItemCode takes integer poolId, integer index returns integer
    return IntListGetValue(poolId, index)
endfunction

// 打乱池中物品类型顺序
function ItemPoolExShuffle takes integer poolId returns nothing
    call IntListShuffle(poolId)
endfunction

// 更新指定物品类型的权重
// 若物品类型不存在于池中，则不做任何操作
function ItemPoolExSetWeight takes integer poolId, integer itemId, integer weight returns nothing
    call IntListSetWeight(poolId, itemId, weight)
endfunction

// 随机返回一个物品类型ID
// useWeight 为 true 时按权重随机，false 时等概率随机；池为空时返回0
function ItemPoolExGetRandomItemCode takes integer poolId, boolean useWeight returns integer
    return IntListGetRandom(poolId, useWeight)
endfunction

// 随机创建物品
// useWeight 为 true 时按权重随机，false 时等概率随机；池为空时返回 null
function ItemPoolExPlaceItem takes integer poolId, real x, real y, boolean useWeight returns item
    local integer itemId = ItemPoolExGetRandomItemCode(poolId, useWeight)

    if itemId == 0 then
        return null
    endif

    return CreateItem(itemId, x, y)
endfunction

endlibrary