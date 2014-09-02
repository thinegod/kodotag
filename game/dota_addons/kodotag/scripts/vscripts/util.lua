

function pay(player,cost)
	if (player:GetGold()-cost >= 0) then
		player:SetGold(player:GetGold()-cost,false)
		return true
	end
	return false
end

function distance(eA,eB)
	assert(eA and eB,"distance recieved nil values")
	return (eA:GetAbsOrigin()-eB:GetAbsOrigin()):Length2D()

end