function createBuilding(keys)
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, keys.caster)
	-- Create model and do general initiation.
	if point ~= -1 then
		if pay(keys.caster,keys.Cost) then
			local building = CreateUnitByName(keys.Unit, point, false,  nil,keys.caster, keys.caster:GetTeam())
			BuildingHelper:AddBuilding(building)
			building:UpdateHealth(keys.BuildTime,true,keys.Scale)
			building:SetHullRadius(keys.HullRadius)
			building:SetOwner(keys.caster)
			if building.SetInvulnCount ~=nil then
				building:SetInvulnCount(0)
			end
			building.Cost = keys.Cost
			print(keys.Castle)
			print(keys.Castle)
			if keys.Castle then
				print("added base")
				table.insert(GameRules.KodoTagGameMode._bases,building)
			end
		end
	else
		--Fire a game event here and use Actionscript to let the player know he can't place a building at this spot.
	end
end
function destroyBuilding(keys)
	local owner=keys.caster:GetOwnerEntity()
	if(keys.caster._castle) then 
		for i=1,#GameRules.KodoTagGameMode._bases do
			if(keys.caster==GameRules.KodoTagGameMode._bases[i]) then
				print("removed base")
				table.remove(GameRules.KodoTagGameMode._bases,i)
			end
		end
	end
	owner:SetGold(owner:GetGold()+keys.caster.Cost/2,false)
	keys.caster:RemoveBuilding(64,true)
end

function upgradeBuilding(keys)
	local owner=keys.caster:GetOwnerEntity()
	if owner:GetGold()-keys.Cost >= 0 then
		owner:SetGold(owner:GetGold()-keys.Cost,false)
		local oldcost=keys.caster.Cost
		keys.caster:RemoveBuilding(64,true)
		local building = CreateUnitByName(keys.Unit, keys.target_points[1], false, nil, keys.caster:GetOwnerEntity(), owner:GetTeam())
		BuildingHelper:AddBuilding(building)
		building:UpdateHealth(keys.BuildTime,true,keys.Scale)
		building:SetHullRadius(keys.HullRadius)
		building:SetInvulnCount(0)
		building:SetOwner(owner)
		building.Cost=keys.Cost+oldcost
		if keys.Castle=="1" then
			table.insert(GameRules.KodoTagGameMode._bases,building)
			print("added base")
			building._castle=true
		end
	end
end



