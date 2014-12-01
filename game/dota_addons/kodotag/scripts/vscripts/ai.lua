if AI == nil then
	AI = class({})
end

function AI:Think()
	local unit
	for k,v in ipairs(Spawner.unitsAlive)do
		unit=EntIndexToHScript(v)
		if(unit==nil)then
			table.remove(Spawner.unitsAlive,k)
		elseif(unit:IsIdle()) then
			if(not unit.targetPlayer or not unit.targetPlayer:IsAlive())then
				unit.targetPlayer=self:SelectTarget()
			end
			if(unit.targetPlayer)then
				unit:MoveToPositionAggressive(unit.targetPlayer:GetAbsOrigin())
			end
		end
	end
end

function AI:SelectTarget()
	local possibleTargets={}
	for i=1,10 do			--try to find a player that is alive but not forever.	
		if(not GameRules.KodoTagGameMode.players[i])then break end
		if(GameRules.KodoTagGameMode.players[i]:IsAlive())then
			table.insert(possibleTargets,GameRules.KodoTagGameMode.players[i])
		end
	end
	return possibleTargets[math.random(#possibleTargets)]
end