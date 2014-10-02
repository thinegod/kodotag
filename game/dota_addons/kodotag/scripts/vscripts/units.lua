require("util")

function createUnit(keys)
	local unit=CreateUnitByName(keys.Unit,(keys.caster:GetAbsOrigin()+ RandomVector( RandomFloat( 200, 300 ))),true,keys.caster:GetOwner(),nil,DOTA_TEAM_GOODGUYS)
	unit:SetControllableByPlayer(keys.caster:GetOwner():GetPlayerOwnerID(),true)
	unit.foodCost=keys.FoodCost or 0
	upgradeAllAbilities(unit)
	unit:SetOwner(keys.caster:GetOwner())
	print(keys.caster._rallypoint)
	Timers:CreateTimer(0.1,		--dont ask why this has to be here..
	function()
		if keys.caster._rallypoint then
			if keys.caster._rallypoint.x  then--this means it is a vector
				unit:MoveToPosition(keys.caster._rallypoint)
			elseif unit:FindAbilityByName("chop_wood") then--else it is a tree, we need to make sure unit can chop 
				unit:CastAbilityOnTarget(keys.caster._rallypoint,unit:FindAbilityByName("chop_wood"),keys.caster:GetOwnerEntity():GetPlayerID())
			else-- no choperino - just move to tree
				unit:MoveToPosition(key.caster._rallypoint:GetAbsPosition())
			end
		end
	end)
end

