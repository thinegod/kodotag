function createBuilding(keys)
	--keys.caster:SetHullRadius(3)
	--Entities:FindByName(nil,"npc_dota_hero_templar_assassin"))
	BuildingHelper:AddUnit(keys.caster)
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, keys.caster)
	-- Create model and do general initiation.
	if point ~= -1 then
		if pay(keys.caster,keys.Cost) then
		local building = CreateUnitByName(keys.Unit, point, false, nil, nil, keys.caster:GetTeam())
		BuildingHelper:AddBuilding(building)
		building:UpdateHealth(keys.BuildTime,true,keys.Scale)
		building:SetHullRadius(keys.HullRadius)
		if building.SetInvulnCount ~=nil then
			building:SetInvulnCount(0)
		end
		building:SetOwner(keys.caster)
		building:SetControllableByPlayer( keys.caster:GetPlayerID(), true )
		building.Cost = keys.Cost
		--print(building:GetClassname())--Someone didn't fucking get the naming convention..
		--print(building:GetModelName())
		end
	else
		--Fire a game event here and use Actionscript to let the player know he can't place a building at this spot.
	end
end
function destroyBuilding(keys)
	local owner=keys.caster:GetOwner()
	owner:SetGold(owner:GetGold()+keys.caster.Cost/2,false)
	keys.caster:RemoveBuilding(64,true)
end

function upgradeBuilding(keys)
	local owner=keys.caster:GetOwner()
	if owner:GetGold()-keys.Cost >= 0 then
	owner:SetGold(owner:GetGold()-keys.Cost,false)
	local oldcost=keys.caster.Cost
	keys.caster:RemoveBuilding(64,true)
	local building = CreateUnitByName(keys.Unit, keys.target_points[1], false, nil, nil, owner:GetTeam())
	BuildingHelper:AddBuilding(building)
	building:UpdateHealth(keys.BuildTime,true,keys.Scale)
	building:SetHullRadius(keys.HullRadius)
	building:SetInvulnCount(0)
	building:SetOwner(owner)
	building:SetControllableByPlayer( owner:GetPlayerID(), true )
	building.Cost=keys.Cost+oldcost
	end
end



