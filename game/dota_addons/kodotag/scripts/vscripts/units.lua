

function createUnit(keys)
	if pay(keys.caster:GetOwner(),keys.Cost) then
		local unit=CreateUnitByName(keys.Unit,(keys.caster:GetAbsOrigin()+ RandomVector( RandomFloat( 200, 300 ))),true,keys.caster:GetOwner(),nil,DOTA_TEAM_GOODGUYS)
		unit:SetControllableByPlayer(keys.caster:GetOwner():GetPlayerOwnerID(),true)
		for i=0,10 do
			if(unit:GetAbilityByIndex(i)==nil) then break end
			unit:GetAbilityByIndex(i):UpgradeAbility()
		end
		unit:SetOwner(keys.caster:GetOwner())
	else
		--display something to inform user cant afford unit
	end
end