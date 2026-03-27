library ItemLib requires Monday

// 创建物品给单位，支持设置物品使用次数
// 开启自动堆叠的情况下，若单位持有同类型物品且持有物品的使用次数大于0，则直接增加使用次数
// 若单位不存在，则创建物品在坐标(x, y)处
function CreateItemWithCharges takes integer charges, integer itemId, unit whichUnit, boolean autoStack, real x, real y returns item
    local item newItem
    local item existingItem
    local real itemX
    local real itemY
    local integer i = 0
    local boolean found = false
    
    // 检查单位是否存在，并且需要自动堆叠
    if whichUnit != null and autoStack then
        // 遍历单位物品栏，查找相同类型的物品
        loop
            exitwhen i >= 6 or found
            
            set existingItem = UnitItemInSlot(whichUnit, i)
            
            if existingItem != null then
                if GetItemTypeId(existingItem) == itemId then
                    // 检查物品是否有使用次数
                    if GetItemCharges(existingItem) >= 1 then
                        // 增加现有物品的使用次数
                        call SetItemCharges(existingItem, GetItemCharges(existingItem) + charges)
                        set newItem = existingItem
                        set found = true
                    endif
                endif
            endif
            
            set i = i + 1
        endloop
    endif
    
    // 如果没有找到符合条件的现有物品，或者不需要自动堆叠，创建新物品
    if not found then
        // 确定物品创建位置
        if whichUnit != null then
            set itemX = GetUnitX(whichUnit)
            set itemY = GetUnitY(whichUnit)
        else
            set itemX = x
            set itemY = y
        endif
        
        // 创建物品
        set newItem = CreateItem(itemId, itemX, itemY)
        
        // 设置使用次数（如果大于0）
        if charges > 0 then
            call SetItemCharges(newItem, charges)
        endif
        
        // 如果单位存在，尝试给予物品
        if whichUnit != null then
            call UnitAddItem(whichUnit, newItem)
        endif
    endif
    
    return newItem
endfunction

// 修改物品使用次数
function SetItemChargesSimple takes item whichItem, integer option, integer charges returns nothing
	if option == 0 then
        call SetItemCharges(whichItem, GetItemCharges(whichItem) + charges)
    elseif option == 1 then
        if GetItemCharges(whichItem) - charges > 0 then
			call SetItemCharges(whichItem, GetItemCharges(whichItem) - charges)
		else
			call RemoveItem(whichItem)
		endif
    endif
endfunction

// 创建物品在矩形区域
function CreateItemAtRectPosition takes integer itemType, rect whichRect, integer positionType returns item
    local item newItem
    
    // 检查参数是否有效
    if itemType == 0 or whichRect == null then
        return null
    endif

    // 创建物品
    return CreateItem(itemType, GetRectPositionX(whichRect, positionType), GetRectPositionY(whichRect, positionType))
endfunction

// 移动物品到矩形区域
function MoveItemToRectPosition takes item whichItem, rect whichRect, integer positionType returns boolean
    local real array targetPos
    
    // 检查参数是否有效
    if whichItem == null or whichRect == null then
        return false
    endif
    
    // 移动物品到目标位置
    call SetItemPosition(whichItem, GetRectPositionX(whichRect, positionType), GetRectPositionY(whichRect, positionType))
    
    return true
endfunction

endlibrary