LinkLuaModifier( "modifier_carnage_blood_spray_thinker", "abilities/carnage_blood_spray.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_carnage_blood_spray_modifier", "abilities/carnage_blood_spray.lua", LUA_MODIFIER_MOTION_HORIZONTAL )

carnage_blood_spray = class ( {})

function carnage_blood_spray:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local team_id = caster:GetTeamNumber()
    local thinker = CreateModifierThinker(caster, self, "modifier_carnage_blood_spray_thinker", {duration = self:GetSpecialValueFor("duration")}, point, team_id, false)
end

modifier_carnage_blood_spray_thinker = class ({})

function modifier_carnage_blood_spray_thinker:OnCreated(event)
    if IsServer() then
        local thinker = self:GetParent()
        local ability = self:GetAbility()
        local target = self:GetAbility():GetCaster():GetCursorPosition()
        local radius = self:GetAbility():GetSpecialValueFor("radius")
   
        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf", PATTACH_CUSTOMORIGIN, thinker )
        ParticleManager:SetParticleControl( nFXIndex, 0, target)
        ParticleManager:SetParticleControl( nFXIndex, 1, Vector(radius, radius, 0))
        ParticleManager:SetParticleControl( nFXIndex, 15, Vector(227, 0, 0))
        ParticleManager:SetParticleControl( nFXIndex, 16, Vector(227, 0, 0))
        self:AddParticle( nFXIndex, false, false, -1, false, true )

        EmitSoundOn("Hero_Alchemist.AcidSpray", thinker)
        
        AddFOWViewer( thinker:GetTeam(), target, 1500, 5, false)
        GridNav:DestroyTreesAroundPoint(target, 1500, false)
    end
end

function modifier_carnage_blood_spray_thinker:CheckState()
    return {[MODIFIER_STATE_PROVIDES_VISION] = true}
end

function modifier_carnage_blood_spray_thinker:IsAura()
    return true
end

function modifier_carnage_blood_spray_thinker:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_carnage_blood_spray_thinker:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_carnage_blood_spray_thinker:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING
end

function modifier_carnage_blood_spray_thinker:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
end

function modifier_carnage_blood_spray_thinker:GetModifierAura()
    return "modifier_carnage_blood_spray_modifier"
end

if modifier_carnage_blood_spray_modifier == nil then modifier_carnage_blood_spray_modifier = class({}) end

function modifier_carnage_blood_spray_modifier:IsPurgeException()
    return true
end

function modifier_carnage_blood_spray_modifier:GetStatusEffectName()
    return "particles/units/heroes/hero_visage/status_effect_visage_chill_slow.vpcf"
end

--------------------------------------------------------------------------------

function modifier_carnage_blood_spray_modifier:StatusEffectPriority()
    return 1000
end

--------------------------------------------------------------------------------

function modifier_carnage_blood_spray_modifier:GetEffectName()
    return "particles/items_fx/diffusal_slow.vpcf"
end

--------------------------------------------------------------------------------

function modifier_carnage_blood_spray_modifier:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

--------------------------------------------------------------------------------

function modifier_carnage_blood_spray_modifier:OnCreated( kv )
    if IsServer() then
        self:GetParent():Purge(true, false, false, false, false)
        self:OnIntervalThink()
        self:StartIntervalThink(1)
    end
end

function modifier_carnage_blood_spray_modifier:OnIntervalThink()
   if IsServer() then 
        local vl = self:GetAbility():GetAbilityDamage()
        if self:GetParent():IsBuilding() then 
            vl = vl / 4
        end
        local damage = {
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = self:GetAbility():GetAbilityDamage(),
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self:GetAbility()
        }
        ApplyDamage( damage )
   end
end

--------------------------------------------------------------------------------

function modifier_carnage_blood_spray_modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_carnage_blood_spray_modifier:GetModifierPreAttack_BonusDamage()
    return (-1) * self:GetAbility():GetSpecialValueFor("damage_reduction")
end

function modifier_carnage_blood_spray_modifier:GetModifierPhysicalArmorBonus()
    return (-1) * self:GetAbility():GetSpecialValueFor("armor_reduction")
end