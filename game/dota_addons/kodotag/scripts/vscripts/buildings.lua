
function createBuilding(keys)
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], keys.HullRadius, keys.caster)
	-- Create model and do general initiation.
	if point ~= -1 then
		local building = CreateUnitByName(keys.Unit, point, false,  nil,keys.caster, keys.caster:GetTeam())
		BuildingHelper:AddBuilding(building)
		if pay(keys.caster,keys.Cost,(keys.WoodCost or 0),(keys.FoodCost or 0)) then
			building:UpdateHealth(keys.BuildTime,true,keys.Scale)
			building:SetHullRadius(keys.HullRadius*32)
			building._hullRadius = keys.HullRadius
			building:SetOwner(keys.caster)
			if building.SetInvulnCount ~=nil then
				building:SetInvulnCount(0)
			end
			building.goldInvestReturn = keys.Cost/2
			building.woodInvestReturn=(keys.WoodCost or 0)/2
			building.buildTime=keys.BuildTime
			if keys.Castle then
				table.insert(GameRules.KodoTagGameMode._bases,building)
				building._castle=true
			end
		else
			building:RemoveBuilding(keys.HullRadius,true)
			FireGameEvent("error_msg",{player_ID=keys.caster:GetPlayerOwnerID(),_error="Can't afford building"})
		end
	else
		FireGameEvent("error_msg",{player_ID=keys.caster:GetPlayerOwnerID(),_error="Can't place building there"})
		print("fired game event, cant place building there")
	end
end
function destroyBuilding(keys)
	local owner=keys.caster:GetOwnerEntity()
	if(keys.caster._castle) then 
		removeFromArray(GameRules.KodoTagGameMode._bases,keys.caster)
	end
	owner:SetGold(owner:GetGold()+keys.caster.goldInvestReturn,false)
	owner.wood=owner.wood+keys.caster.woodInvestReturn
	keys.caster:RemoveBuilding(keys.caster._hullRadius,true)
end

function upgradeBuilding(keys)
	local owner=keys.caster:GetOwnerEntity()
	local loc = keys.caster:GetAbsOrigin()
	local oldGoldInvest=keys.caster.goldInvestReturn
	local oldWoodInvest=keys.caster.woodInvestReturn
	local oldBuildTime=keys.caster.buildTime
	local oldHullRadius = keys.caster._hullRadius
	local building = CreateUnitByName(keys.Unit, loc, false, nil, keys.caster:GetOwnerEntity(), owner:GetTeam())
	if keys.Castle then
		removeFromArray(GameRules.KodoTagGameMode._bases,keys.caster)
		table.insert(GameRules.KodoTagGameMode._bases,building)
		building._castle=true
	end
	keys.caster:RemoveBuilding(oldHullRadius,true)
	BuildingHelper:AddBuildingToGrid(loc, oldHullRadius, owner)
	BuildingHelper:AddBuilding(building)
	--building:UpdateHealth(keys.BuildTime,true,keys.Scale)
	building:SetHullRadius(oldHullRadius*32)
	building._hullRadius = oldHullRadius
	if building.SetInvulnCount ~=nil then
		building:SetInvulnCount(0)
	end
	building:SetOwner(owner)
	building:SetControllableByPlayer(owner:GetPlayerID(),true)
	building.goldInvestReturn=keys.Cost/2+oldGoldInvest
	building.woodInvestReturn=(keys.WoodCost or 0)/2+oldWoodInvest
	building.buildTime=keys.ability:GetChannelTime()*1.15+oldBuildTime
	
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

function round(number)
	return math.ceil(number-0.5)
end
function attemptRepair(keys)
	local building=keys.target
	local healAmount=(keys.ability:GetChannelTime()/building.buildTime)*building:GetMaxHealth()
	local goldCost=round(healAmount/building:GetMaxHealth()*(building.goldInvestReturn*2*0.35))
	local woodCost=round(healAmount/building:GetMaxHealth()*(building.woodInvestReturn*2*0.35))
	if building:GetOwnerEntity()==getAbsoluteParent(keys.caster) and pay(keys.caster,goldCost,woodCost,0) 
	and building:GetHealth()<building:GetMaxHealth() then
		building:Heal(healAmount,keys.caster)
	else
		keys.caster:Stop()
	end	
end

function buildingCleanup(keys)
	keys.caster:RemoveBuilding(keys.caster._hullRadius,true)
end

function increaseMaxFood(keys)
	local owner=getAbsoluteOwner(keys.caster)
	keys.caster.foodIncrease=(keys.caster.foodIncrease or 0)+keys.Amount
	owner.foodMax=owner.foodMax+keys.Amount
end

