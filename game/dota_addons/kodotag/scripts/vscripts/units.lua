require("util")

function createUnit(keys)
	local unit=CreateUnitByName(keys.Unit,(keys.caster:GetAbsOrigin()+ RandomVector( RandomFloat( 200, 300 ))),true,keys.caster:GetOwner(),nil,DOTA_TEAM_GOODGUYS)
	unit:SetControllableByPlayer(keys.caster:GetOwner():GetPlayerOwnerID(),true)
	upgradeAllAbilities(unit)
	unit:SetOwner(keys.caster:GetOwner())	
end

function attemptCreateUnit(keys)
	if pay(keys.caster:GetOwner(),keys.Cost) then
		keys.caster._couldAfford=true
		--do nothing
	else
		keys.caster._couldAfford=nil
		keys.caster:Stop()
		--display something to inform user cant afford unit
	end
end