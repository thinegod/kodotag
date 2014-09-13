require("util")

function createUnit(keys)
	local unit=CreateUnitByName(keys.Unit,(keys.caster:GetAbsOrigin()+ RandomVector( RandomFloat( 200, 300 ))),true,keys.caster:GetOwner(),nil,DOTA_TEAM_GOODGUYS)
	unit:SetControllableByPlayer(keys.caster:GetOwner():GetPlayerOwnerID(),true)
	unit.foodCost=keys.FoodCost or 0
	upgradeAllAbilities(unit)
	unit:SetOwner(keys.caster:GetOwner())	
end

