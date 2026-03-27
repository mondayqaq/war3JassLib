library GroupLib requires Monday

/**
 * 获取范围内符合条件的单位组
 * params - alliedUnits -> PlayerFaction
 */
function GetUnitGroupInRangeEx takes real x, real y, real radius, player whichPlayer, boolean alliedUnits, boolean excludeDead, boolean excludeStructures, boolean excludeInvulnerable, boolean includeNeutral returns group
    local group filteredGroup = CreateGroup()
    local group tempGroup = CreateGroup()
    local unit currentUnit
    local player unitOwner
    local integer playerId
    local boolean isEnemy
    local boolean isAlly
    local boolean isNeutral
    local boolean isValid
    
    // 枚举指定范围内的所有单位
    call GroupEnumUnitsInRange(tempGroup, x, y, radius, null)
    
    // 遍历所有单位，根据条件筛选
    loop
        set currentUnit = FirstOfGroup(tempGroup)
        exitwhen currentUnit == null
        
        set isValid = true
        
        // 检查是否排除死亡单位
        if excludeDead and IsUnitType(currentUnit, UNIT_TYPE_DEAD) then
            set isValid = false
        endif
        
        // 检查是否排除建筑单位
        if isValid and excludeStructures and IsUnitType(currentUnit, UNIT_TYPE_STRUCTURE) then
            set isValid = false
        endif
        
        // 检查是否排除无敌单位
        if isValid and excludeInvulnerable and IsUnitInvulnerable(currentUnit) then
            set isValid = false
        endif
        
        // 检查玩家关系
        if isValid then
            set unitOwner = GetOwningPlayer(currentUnit)
            set playerId = GetPlayerId(unitOwner)
            
            // 判断是否中立单位（玩家ID 12-23）
            set isNeutral = (playerId >= 12 and playerId <= 23)
            
            // 判断是否敌方或友方
            set isEnemy = IsUnitEnemy(currentUnit, whichPlayer)
            set isAlly = IsUnitAlly(currentUnit, whichPlayer)
            
            // 根据 alliedUnits 参数决定返回友方还是敌方单位
            if alliedUnits then
                // 返回友方单位
                if not isAlly or (isNeutral and not includeNeutral) then
                    set isValid = false
                endif
            else
                // 返回敌方单位
                if not isEnemy and not (isNeutral and includeNeutral) then
                    set isValid = false
                endif
            endif
        endif
        
        // 如果单位符合所有条件，添加到结果组
        if isValid then
            call GroupAddUnit(filteredGroup, currentUnit)
        endif
        
        call GroupRemoveUnit(tempGroup, currentUnit)
    endloop
    
    // 清理临时单位组和变量
    call DestroyGroup(tempGroup)
    set tempGroup = null
    set unitOwner = null
    
    return filteredGroup
endfunction

/**
 * 计算单位组中符合条件的单位数量
 * 
 * @param whichGroup            要遍历的单位组
 * @param whichPlayer           用于判断敌友关系的玩家
 * @param alliedUnits           true = 计数友方单位，false = 计数敌方单位
 * @param excludeDead           是否排除死亡单位
 * @param excludeStructures     是否排除建筑单位
 * @param excludeInvulnerable   是否排除无敌单位
 * @param includeNeutral        是否包含中立单位
 * @return 符合条件的单位数量
 */
function CountUnitsInGroupEx takes group whichGroup, player whichPlayer, boolean alliedUnits, boolean excludeDead, boolean excludeStructures, boolean excludeInvulnerable, boolean includeNeutral returns integer
    local integer count = 0
    local group tempGroup = CreateGroup()
    local unit currentUnit
    local player unitOwner
    local integer playerId
    local boolean isEnemy
    local boolean isAlly
    local boolean isNeutral
    local boolean isValid

    // 复制原单位组，避免修改原组
    call GroupAddGroup(whichGroup, tempGroup)

    loop
        set currentUnit = FirstOfGroup(tempGroup)
        exitwhen currentUnit == null

        set isValid = true

        // 排除死亡单位
        if excludeDead and IsUnitType(currentUnit, UNIT_TYPE_DEAD) then
            set isValid = false
        endif

        // 排除建筑单位
        if isValid and excludeStructures and IsUnitType(currentUnit, UNIT_TYPE_STRUCTURE) then
            set isValid = false
        endif

        // 排除无敌单位
        if isValid and excludeInvulnerable and IsUnitInvulnerable(currentUnit) then
            set isValid = false
        endif

        // 玩家关系筛选
        if isValid then
            set unitOwner = GetOwningPlayer(currentUnit)
            set playerId = GetPlayerId(unitOwner)
            set isNeutral = (playerId >= 12 and playerId <= 23)
            set isEnemy = IsUnitEnemy(currentUnit, whichPlayer)
            set isAlly = IsUnitAlly(currentUnit, whichPlayer)

            if alliedUnits then
                // 计数友方单位：必须是友方，并且如果是中立单位则必须允许包含中立
                if not isAlly or (isNeutral and not includeNeutral) then
                    set isValid = false
                endif
            else
                // 计数敌方单位：必须是敌方，或者如果是中立且允许包含中立
                if not isEnemy and not (isNeutral and includeNeutral) then
                    set isValid = false
                endif
            endif
        endif

        if isValid then
            set count = count + 1
        endif

        call GroupRemoveUnit(tempGroup, currentUnit)
    endloop

    call DestroyGroup(tempGroup)
    set tempGroup = null
    set unitOwner = null

    return count
endfunction

endlibrary