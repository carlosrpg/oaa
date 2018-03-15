swiper_thrust = class( AbilityBaseClass )

LinkLuaModifier( "swiper_dash_movement", "abilities/swiper/swiper_thrust.lua", LUA_MODIFIER_MOTION_HORIZONTAL )

function swiper_thrust:OnSpellStart(  )
  local caster = self:GetCaster()

  caster:RemoveModifierByName( "swiper_dash_movement" )

  local movement = (caster:GetCursorPosition() - caster:GetAbsOrigin())
  caster:SetForwardVector(movement:Normalized())
  caster:EmitSound( "Sohei.Dash" )
  caster:StartGesture( ACT_DOTA_RUN )
  caster:AddNewModifier( caster, self, "swiper_dash_movement", nil)
end

function swiper_thrust:IsPointInRectagle(cornerA, cornerB, cornerC, pointM  )
  local AB = cornerB - cornerA
  local AM = pointM - cornerA
  local BC = cornerC - cornerA
  local BM = pointM - cornerB
  local dotABAM = AB:Dot(AM);
  local dotABAB = AB:Dot(AB);
  local dotBCBM = BC:Dot(BM);
  local dotBCBC = BC:Dot(BC);

  return 0 <= dotABAM and dotABAM <= dotABAB and 0 <= dotBCBM and dotBCBM <= dotBCBC;
end


--------------------------------------------------------------------------------

-- Dash movement modifier
swiper_dash_movement = class( ModifierBaseClass )

--------------------------------------------------------------------------------

function swiper_dash_movement:IsDebuff()
	return false
end

function swiper_dash_movement:IsHidden()
	return true
end

function swiper_dash_movement:IsPurgable()
	return false
end

function swiper_dash_movement:IsStunDebuff()
	return false
end

function swiper_dash_movement:GetPriority()
	return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST
end

--------------------------------------------------------------------------------

function swiper_dash_movement:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}

	return state
end

--------------------------------------------------------------------------------

if IsServer() then
	function swiper_dash_movement:OnCreated( event )
    -- Movement parameters

    local caster = self:GetCaster()
    local movement = (caster:GetCursorPosition() - caster:GetAbsOrigin())
    self.targetPos = caster:GetCursorPosition()
		self.distance = movement:Length2D()
		self.direction = movement:Normalized()
		self.speed = self:GetAbility():GetSpecialValueFor( "speed" )
    self.tree_radius = self:GetAbility():GetSpecialValueFor( "tree_radius" )
    self.previous_position = caster:GetAbsOrigin()

		if self:ApplyHorizontalMotionController() == false then
			self:Destroy()
			return
		end

		-- Trail particle
		local trail_pfx = ParticleManager:CreateParticle( "particles/econ/items/juggernaut/bladekeeper_omnislash/_dc_juggernaut_omni_slash_trail.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( trail_pfx, 0, caster:GetAbsOrigin() )
		ParticleManager:SetParticleControl( trail_pfx, 1, caster:GetAbsOrigin() + movement )
		ParticleManager:ReleaseParticleIndex( trail_pfx )
	end

--------------------------------------------------------------------------------

	function swiper_dash_movement:OnDestroy()
		local parent = self:GetParent()

    -- remove run animation
		parent:FadeGesture( ACT_DOTA_RUN )
		parent:RemoveHorizontalMotionController( self )
		ResolveNPCPositions( parent:GetAbsOrigin(), 128 )
	end

--------------------------------------------------------------------------------

	function swiper_dash_movement:UpdateHorizontalMotion( parent, deltaTime )
    local parentOrigin = parent:GetAbsOrigin()

		local tickSpeed = self.speed * deltaTime
		tickSpeed = math.min( tickSpeed, self.distance )
		local tickOrigin = parentOrigin + ( tickSpeed * self.direction )

		parent:SetAbsOrigin( tickOrigin )

		self.distance = self.distance - tickSpeed

    GridNav:DestroyTreesAroundPoint( tickOrigin, self.tree_radius, false )

    if (tickOrigin - self.targetPos):Length2D() < 30 then
      self:Destroy(  )
    end
	end

--------------------------------------------------------------------------------

	function swiper_dash_movement:OnHorizontalMotionInterrupted()
		self:Destroy()
	end
end
