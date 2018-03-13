function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	-- thisEntity.SmashAbility = thisEntity:FindAbilityByName( "ogre_tank_boss_melee_smash" )
	-- thisEntity.JumpAbility = thisEntity:FindAbilityByName( "ogre_tank_boss_jump_smash" )
	-- thisEntity.OgreSummonSeers = { }

	thisEntity:SetContextThink( "SwiperBossThink", SwiperBossThink, 1 )
end

function SwiperBossThink()
  return 1
end

