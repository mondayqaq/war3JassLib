library UnitStateLib

globals
    // 属性名
    constant string ATTRIBUTE_MAX_HP = "最大生命值"
    constant string ATTRIBUTE_MAX_MP = "最大魔法值"
    constant string ATTRIBUTE_CURRENT_HP = "当前生命值"
    constant string ATTRIBUTE_CURRENT_MP = "当前魔法值"
    constant string ATTRIBUTE_LOST_HP = "已损失生命值"
    constant string ATTRIBUTE_LOST_MP = "已损失魔法值"
    constant string ATTRIBUTE_HP_PERCENT = "生命值百分比"
    constant string ATTRIBUTE_MP_PERCENT = "魔法值百分比"
    constant string ATTRIBUTE_LOST_HP_PERCENT = "已损失生命值百分比"
    constant string ATTRIBUTE_LOST_MP_PERCENT = "已损失魔法值百分比"
    constant string ATTRIBUTE_LEVEL = "等级"
    constant string ATTRIBUTE_ATK = "攻击力"
    constant string ATTRIBUTE_DEF = "护甲"
    // 单位状态
    constant unitstate UNIT_STATE_BASE_DAMAGE = ConvertUnitState(0x12)
    constant unitstate UNIT_STATE_MIN_ATK = ConvertUnitState(0x14)
    constant unitstate UNIT_STATE_MAX_ATK = ConvertUnitState(0x15)
    constant unitstate UNIT_STATE_DEF = ConvertUnitState(0x20)
endglobals

// 根据字符串获取单位属性
function GetUnitStateByString takes unit whichUnit, string attributeName returns real
    
    if whichUnit == null or GetUnitTypeId(whichUnit) == 0 then
        return 0.0
    endif
    
    // 最大生命值
    if attributeName == ATTRIBUTE_MAX_HP then
        return GetUnitState(whichUnit, UNIT_STATE_MAX_LIFE)
    
    // 最大魔法值
    elseif attributeName == ATTRIBUTE_MAX_MP then
        return GetUnitState(whichUnit, UNIT_STATE_MAX_MANA)

    // 当前生命值
    elseif attributeName == ATTRIBUTE_CURRENT_HP then
        return GetUnitState(whichUnit, UNIT_STATE_LIFE)
    
    // 当前魔法值    
    elseif attributeName == ATTRIBUTE_CURRENT_MP then
        return GetUnitState(whichUnit, UNIT_STATE_MANA)
    
    // 已损失生命值    
    elseif attributeName == ATTRIBUTE_LOST_HP then
        return GetUnitState(whichUnit, UNIT_STATE_MAX_LIFE) - GetUnitState(whichUnit, UNIT_STATE_LIFE)
    
    // 已损失魔法值    
    elseif attributeName == ATTRIBUTE_LOST_MP then
        return GetUnitState(whichUnit, UNIT_STATE_MAX_MANA) - GetUnitState(whichUnit, UNIT_STATE_MANA)
    
    // 生命值百分比    
    elseif attributeName == ATTRIBUTE_HP_PERCENT then
        return GetUnitLifePercent(whichUnit)
    
    // 魔法值百分比
    elseif attributeName == ATTRIBUTE_MP_PERCENT then
        return GetUnitManaPercent(whichUnit)
    
    // 已损失生命百分比    
    elseif attributeName == ATTRIBUTE_LOST_HP_PERCENT then
        return 100.0 - GetUnitLifePercent(whichUnit)

    // 已损失生命百分比    
    elseif attributeName == ATTRIBUTE_LOST_MP_PERCENT then
        return 100.0 - GetUnitManaPercent(whichUnit)

    // 攻击力    
    elseif attributeName == ATTRIBUTE_ATK then
        return GetRandomReal(GetUnitState(whichUnit, UNIT_STATE_MIN_ATK), GetUnitState(whichUnit, UNIT_STATE_MAX_ATK) )
    
    // 护甲    
    elseif attributeName == ATTRIBUTE_DEF then
        return GetUnitState(whichUnit, UNIT_STATE_DEF)

    // 等级    
    elseif attributeName == ATTRIBUTE_LEVEL then
        return I2R(GetUnitLevel(whichUnit))
    
    else
        call BJDebugMsg("错误: 不支持的属性名: " + attributeName)
        return 0.0
    endif
endfunction

/**
 * 获取单位衍生属性
 * params - attrType -> UnitAttributes
 */
function GetUnitDerivedAttribute takes unit whichUnit, integer attrType returns real
    local real maxValue
    local real currentValue
    local real lostValue
    
    // 检查单位是否有效
    if whichUnit == null or GetUnitTypeId(whichUnit) == 0 then
        return 0.0
    endif
    
    // 已损失生命值
    if attrType == 0 then
        set maxValue = GetUnitState(whichUnit, UNIT_STATE_MAX_LIFE)
        set currentValue = GetUnitState(whichUnit, UNIT_STATE_LIFE)
        return maxValue - currentValue
    // 已损失魔法值    
    elseif attrType == 1 then
        // 获取已损失魔法值
        set maxValue = GetUnitState(whichUnit, UNIT_STATE_MAX_MANA)
        set currentValue = GetUnitState(whichUnit, UNIT_STATE_MANA)
        return maxValue - currentValue
    // 单位等级    
    elseif attrType == 2 then
        return I2R(GetUnitLevel(whichUnit))
    else
        return 0.0
    endif
endfunction

/**
 * 获取英雄属性（实数）
 * params - attrType -> HeroAttributes
 */
function GetHeroAttribute takes unit hero, integer attrType, boolean includeBonuses returns real
    // 检查单位是否为英雄
    if hero == null or not IsUnitType(hero, UNIT_TYPE_HERO) then
        return 0.0
    endif
    
    // 根据 attrType 参数返回相应的属性
    if attrType == 0 then
        return I2R(GetHeroStr(hero, includeBonuses))
    elseif attrType == 1 then
        return I2R(GetHeroAgi(hero, includeBonuses))
    elseif attrType == 2 then
        return I2R(GetHeroInt(hero, includeBonuses))
    elseif attrType == 3 then
        return I2R(GetHeroLevel(hero))
    else    
        return 0.0
    endif
endfunction

// 自增单位属性值
function AddUnitState takes unit whichUnit, unitstate whichState, real value returns nothing
    call SetUnitState(whichUnit, whichState, GetUnitState(whichUnit, whichState) + value)
endfunction

endlibrary