

function pay(player,cost)
	if (player:GetGold()-cost >= 0) then
		player:SetGold(player:GetGold()-cost,false)
		return true
	end
	return false
end