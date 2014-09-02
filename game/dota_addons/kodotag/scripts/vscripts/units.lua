

function createUnit(keys)
	print("okfgdhofgh")
	if pay(keys.caster:GetOwner(),keys.Cost) then
		local unit=CreateUnitByName(keys.Unit,(keys.caster:GetAbsOrigin()+ RandomVector( RandomFloat( 200, 300 ))),true,keys.caster:GetOwner(),nil,DOTA_TEAM_GOODGUYS)
		unit:SetControllableByPlayer(keys.caster:GetOwner():GetPlayerOwnerID(),true)
		unit:SetOwner(keys.caster:GetOwner())
	else
		--display something to inform user cant afford unit
	end
end