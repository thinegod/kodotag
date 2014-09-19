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
			print("kodo"..unit:entindex().." moving to:")
			print(GameRules.KodoTagGameMode.players[1]:GetAbsOrigin())
			unit:MoveToPositionAggressive(GameRules.KodoTagGameMode.players[1]:GetAbsOrigin())
		end
	end
end