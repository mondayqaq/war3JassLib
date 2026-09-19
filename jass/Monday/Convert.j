library ConvertLib

native EXGetEventDamageData takes integer edd_type returns integer

// 将编辑器中的中文伤害类型名称转换为伤害类型
function ConvertStringToDamageType takes string damageTypeName returns damagetype
    if damageTypeName == "未知" then
        return DAMAGE_TYPE_UNKNOWN
    elseif damageTypeName == "普通" then
        return DAMAGE_TYPE_NORMAL
    elseif damageTypeName == "强化" then
        return DAMAGE_TYPE_ENHANCED
    elseif damageTypeName == "火焰" then
        return DAMAGE_TYPE_FIRE
    elseif damageTypeName == "冰冻" then
        return DAMAGE_TYPE_COLD
    elseif damageTypeName == "闪电" then
        return DAMAGE_TYPE_LIGHTNING
    elseif damageTypeName == "毒药" then
        return DAMAGE_TYPE_POISON
    elseif damageTypeName == "疾病" then
        return DAMAGE_TYPE_DISEASE
    elseif damageTypeName == "神圣" then
        return DAMAGE_TYPE_DIVINE
    elseif damageTypeName == "魔法" then
        return DAMAGE_TYPE_MAGIC
    elseif damageTypeName == "音速" then
        return DAMAGE_TYPE_SONIC
    elseif damageTypeName == "酸性" then
        return DAMAGE_TYPE_ACID
    elseif damageTypeName == "力量" then
        return DAMAGE_TYPE_FORCE
    elseif damageTypeName == "死亡" then
        return DAMAGE_TYPE_DEATH
    elseif damageTypeName == "精神" then
        return DAMAGE_TYPE_MIND
    elseif damageTypeName == "植物" then
        return DAMAGE_TYPE_PLANT
    elseif damageTypeName == "防御" then
        return DAMAGE_TYPE_DEFENSIVE
    elseif damageTypeName == "破坏" then
        return DAMAGE_TYPE_DEMOLITION
    elseif damageTypeName == "慢性毒药" then
        return DAMAGE_TYPE_SLOW_POISON
    elseif damageTypeName == "灵魂链接" then
        return DAMAGE_TYPE_SPIRIT_LINK
    elseif damageTypeName == "暗影突袭" then
        return DAMAGE_TYPE_SHADOW_STRIKE
    elseif damageTypeName == "通用" then
        return DAMAGE_TYPE_UNIVERSAL
    endif

    return DAMAGE_TYPE_UNKNOWN
endfunction

// 将伤害类型转换为编辑器中的中文名称
function ConvertDamageTypeToString takes damagetype damageType returns string
    if damageType == DAMAGE_TYPE_UNKNOWN then
        return "未知"
    elseif damageType == DAMAGE_TYPE_NORMAL then
        return "普通"
    elseif damageType == DAMAGE_TYPE_ENHANCED then
        return "强化"
    elseif damageType == DAMAGE_TYPE_FIRE then
        return "火焰"
    elseif damageType == DAMAGE_TYPE_COLD then
        return "冰冻"
    elseif damageType == DAMAGE_TYPE_LIGHTNING then
        return "闪电"
    elseif damageType == DAMAGE_TYPE_POISON then
        return "毒药"
    elseif damageType == DAMAGE_TYPE_DISEASE then
        return "疾病"
    elseif damageType == DAMAGE_TYPE_DIVINE then
        return "神圣"
    elseif damageType == DAMAGE_TYPE_MAGIC then
        return "魔法"
    elseif damageType == DAMAGE_TYPE_SONIC then
        return "音速"
    elseif damageType == DAMAGE_TYPE_ACID then
        return "酸性"
    elseif damageType == DAMAGE_TYPE_FORCE then
        return "力量"
    elseif damageType == DAMAGE_TYPE_DEATH then
        return "死亡"
    elseif damageType == DAMAGE_TYPE_MIND then
        return "精神"
    elseif damageType == DAMAGE_TYPE_PLANT then
        return "植物"
    elseif damageType == DAMAGE_TYPE_DEFENSIVE then
        return "防御"
    elseif damageType == DAMAGE_TYPE_DEMOLITION then
        return "破坏"
    elseif damageType == DAMAGE_TYPE_SLOW_POISON then
        return "慢性毒药"
    elseif damageType == DAMAGE_TYPE_SPIRIT_LINK then
        return "灵魂链接"
    elseif damageType == DAMAGE_TYPE_SHADOW_STRIKE then
        return "暗影突袭"
    elseif damageType == DAMAGE_TYPE_UNIVERSAL then
        return "通用"
    endif

    return "未知"
endfunction

// 获取当前伤害事件的伤害类型
function GetEventDamageType takes nothing returns damagetype
    return ConvertDamageType(EXGetEventDamageData(4))
endfunction

// 获取当前伤害事件的攻击类型
function GetEventAttackType takes nothing returns attacktype
    return ConvertAttackType(EXGetEventDamageData(6))
endfunction

// 将攻击类型转换为编辑器中的中文名称
function ConvertAttackTypeToString takes attacktype attackType returns string
    if attackType == ATTACK_TYPE_NORMAL then
        return "法术"
    elseif attackType == ATTACK_TYPE_MELEE then
        return "普通"
    elseif attackType == ATTACK_TYPE_PIERCE then
        return "穿刺"
    elseif attackType == ATTACK_TYPE_SIEGE then
        return "攻城"
    elseif attackType == ATTACK_TYPE_MAGIC then
        return "魔法"
    elseif attackType == ATTACK_TYPE_CHAOS then
        return "混乱"
    elseif attackType == ATTACK_TYPE_HERO then
        return "英雄"
    endif

    return "普通"
endfunction

// 将编辑器中的中文攻击类型名称转换为攻击类型
function ConvertStringToAttackType takes string attackTypeName returns attacktype
    if attackTypeName == "法术" then
        return ATTACK_TYPE_NORMAL
    elseif attackTypeName == "普通" then
        return ATTACK_TYPE_MELEE
    elseif attackTypeName == "穿刺" then
        return ATTACK_TYPE_PIERCE
    elseif attackTypeName == "攻城" then
        return ATTACK_TYPE_SIEGE
    elseif attackTypeName == "魔法" then
        return ATTACK_TYPE_MAGIC
    elseif attackTypeName == "混乱" then
        return ATTACK_TYPE_CHAOS
    elseif attackTypeName == "英雄" then
        return ATTACK_TYPE_HERO
    endif

    return ATTACK_TYPE_MELEE
endfunction

// 获取单位护甲类型的中文名称
function GetUnitDefenseTypeString takes unit whichUnit returns string
    local integer defenseType

    if whichUnit == null then
        return "未知"
    endif

    set defenseType = R2I(GetUnitState(whichUnit, ConvertUnitState(0x50)))
    if defenseType == 0 then
        return "小型"
    elseif defenseType == 1 then
        return "中型"
    elseif defenseType == 2 then
        return "大型"
    elseif defenseType == 3 then
        return "城墙"
    elseif defenseType == 4 then
        return "普通"
    elseif defenseType == 5 then
        return "英雄"
    elseif defenseType == 6 then
        return "神圣"
    elseif defenseType == 7 then
        return "无装甲"
    endif

    return "未知"
endfunction

endlibrary
