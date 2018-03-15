swiper_backswipe = class( AbilityBaseClass )

function swiper_backswipe:OnSpellStart(  )
  local caster = self:GetCaster()
  local target_candidates = FindUnitsInRadius(
    caster:GetTeamNumber(),
    caster:GetAbsOrigin(),
    nil,
    self:GetSpecialValueFor( 'radius' ),
    self:GetAbilityTargetTeam(),
    self:GetAbilityTargetType(),
    self:GetAbilityTargetFlags(),
    FIND_ANY_ORDER,
    false
    )
  local particleName = 'particles/econ/items/troll_warlord/troll_warlord_ti7_axe/troll_ti7_axe_bash_explosion.vpcf'
  local particle = ParticleManager:CreateParticle(particleName,PATTACH_CUSTOMORIGIN,caster)
  ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin() + 100*caster:GetForwardVector())
  ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
  Timers:CreateTimer(3, function()
    ParticleManager:DestroyParticle( particle, false )
    ParticleManager:ReleaseParticleIndex(particle)
  end)

  for _,target in pairs(target_candidates) do
    local relativeVector = target:GetAbsOrigin() - caster:GetAbsOrigin()
    local dotProjection = relativeVector:Dot(caster:GetForwardVector())
    if dotProjection > 0 then
      -- it is in front of the caster
      self:ApplyEffectToTarget(target)
    end
  end
end

function swiper_backswipe:ApplyEffectToTarget(target)
  local damage = {
    victim = target,
    attacker = self:GetCaster(),
    damage = self:GetAbilityDamage(),
    damage_type = self:GetAbilityDamageType(),
    ability = self
  }
  ApplyDamage( damage )
end
