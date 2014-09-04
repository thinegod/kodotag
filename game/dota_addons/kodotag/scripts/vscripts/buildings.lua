
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
			building.investreturn = keys.Cost/2
			if keys.Castle then
				table.insert(GameRules.KodoTagGameMode._bases,building)
				building._castle=true
			end
		end
	else
		--Fire a game event here and use Actionscript to let the player know he can't place a building at this spot.
	end
end
function destroyBuilding(keys)
	local owner=keys.caster:GetOwnerEntity()
	if(keys.caster._castle) then 
		removeFromArray(GameRules.KodoTagGameMode._bases,keys.caster)
	end
	owner:SetGold(owner:GetGold()+keys.caster.investreturn,false)
	keys.caster:RemoveBuilding(2,true)
end

function upgradeBuilding(keys)
	local owner=keys.caster:GetOwnerEntity()
	local loc = keys.caster:GetAbsOrigin()
	if owner:GetGold()-keys.Cost >= 0 then
		owner:SetGold(owner:GetGold()-keys.Cost,false)
		local oldinvest=keys.caster.investreturn
		local building = CreateUnitByName(keys.Unit, loc, false, nil, keys.caster:GetOwnerEntity(), owner:GetTeam())
		if keys.Castle then
			removeFromArray(GameRules.KodoTagGameMode._bases,keys.caster)
			table.insert(GameRules.KodoTagGameMode._bases,building)
			building._castle=true
		end
		keys.caster:RemoveBuilding(2,true)
		BuildingHelper:AddBuildingToGrid(loc, 2, owner)
		BuildingHelper:AddBuilding(building)
		building:UpdateHealth(keys.BuildTime,true,keys.Scale)
		building:SetHullRadius(keys.HullRadius)
		if building.SetInvulnCount ~=nil then
			building:SetInvulnCount(0)
		end
		building:SetOwner(owner)
		building.investreturn=keys.Cost/2+oldinvest

	end
end

function continueRepair(keys)
	local playerId 
	if(keys.caster.GetPlayerID==nil) then
		playerId=keys.caster:GetOwner():GetPlayerID()
	else 
		playerId=keys.caster:GetPlayerID()
	end
	keys.caster:CastAbilityOnTarget(keys.target,keys.caster:FindAbilityByName("repair"),playerId)
end

function attemptRepair(keys)
	local building=keys.target
	local hp=keys.HealAmount
	local cost=hp/building:GetMaxHealth()*building.Cost
	if (building:GetOwnerEntity()==keys.caster or building:GetOwnerEntity()==keys.caster:GetOwner()) and pay(keys.caster,cost) 
	and building:GetHealth()<building:GetMaxHealth() then
	--do nothing
		
	else
		keys.caster:Stop()
	end	
end


