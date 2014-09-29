if Phase == nil then
	Phase = class({})
end

function Phase:new(spawnInterval,phaseSize,unitName,spawner)
	local newPhase={["spawnInterval"]=spawnInterval,["phaseSize"]=phaseSize
	,["unitName"]=unitName,["spawner"]=spawner,["spawnedAmount"]=0,["unitsAlive"]={}}
	self.__index=self
	return setmetatable(newPhase,self)
end

function Phase:Spawn()
	if(self.spawnedAmount<self.phaseSize)then
		local creature = CreateUnitByName( self.unitName , Entities:FindByName(nil,self.spawner):GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
		creature:MoveToPositionAggressive(GameRules.KodoTagGameMode.players[1]:GetAbsOrigin())
		self.spawnedAmount=self.spawnedAmount + 1
		return creature:entindex()
	else
		return false
	end
end

