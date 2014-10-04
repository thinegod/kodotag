
function createBuilding(keys)
	if(keys.caster:IsUnselectable())then return end
	if (not keys.caster:IsHero()) then
		keys.caster.GetPlayerID=function() return keys.caster:entindex() end
		BuildingHelper:AddUnit(keys.caster)
	end
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], keys.HullRadius, keys.caster)
	-- Create model and do general initiation.
	if point ~= -1 then
		if pay(keys.caster,keys.Cost,(keys.WoodCost or 0),(keys.FoodCost or 0)) then
			local building = CreateUnitByName(keys.Unit, point, false,  nil,keys.caster, keys.caster:GetTeam())
			BuildingHelper:AddBuilding(building)
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
			elseif keys.FoodIncrease then
				Timers:CreateTimer(keys.BuildTime,
				function()
					increaseMaxFood(building,keys.FoodIncrease)
				end)
			end
			unitDisable(keys.caster)
			local attackCapability=building:GetAttackCapability()
			building:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
			keys.caster:AddNoDraw()
			Timers:CreateTimer(keys.BuildTime,
			function()
				unitEnable(keys.caster)
				building:SetAttackCapability(attackCapability)
				keys.caster:RemoveNoDraw()
			end
			)
		else
			BuildingHelper:RemoveFromGrid(point,keys.HullRadius)
			FireGameEvent("error_msg",{player_ID=keys.caster:GetPlayerOwnerID(),_error="Can't afford building"})
		end
	else
		FireGameEvent("error_msg",{player_ID=keys.caster:GetPlayerOwnerID(),_error="Can't place building there"})
	end
end
function destroyBuilding(keys)
	local owner=getAbsoluteParent(keys.caster:GetOwnerEntity())
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
	local oldHealthFraction = keys.caster:GetHealth()/keys.caster:GetMaxHealth()
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
	building:SetHealth(oldHealthFraction*building:GetMaxHealth())
	building:SetControllableByPlayer(owner:GetPlayerID(),true)
	building._hullRadius = oldHullRadius
	if building.SetInvulnCount ~=nil then
		building:SetInvulnCount(0)
	end
	building:SetOwner(owner)
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
	local fGoldCost=healAmount/building:GetMaxHealth()*(building.goldInvestReturn*2*0.35)
	local fWoodCost=healAmount/building:GetMaxHealth()*(building.woodInvestReturn*2*0.35)
	building._cumulativeRepairGoldCost=(building._cumulativeRepairGoldCost or 0)+fGoldCost
	building._cumulativeRepairWoodCost=(building._cumulativeRepairWoodCost or 0)+fWoodCost
	local goldCost=math.floor(building._cumulativeRepairGoldCost)
	local woodCost=math.floor(building._cumulativeRepairWoodCost)
	if building:GetOwnerEntity()==getAbsoluteParent(keys.caster)
	and building:GetHealth()<building:GetMaxHealth() 
	and pay(keys.caster,goldCost,woodCost,0)  then
		building:Heal(healAmount,keys.caster)
	else
		keys.caster:Stop()
	end	
	building._cumulativeRepairGoldCost=building._cumulativeRepairGoldCost-goldCost
	building._cumulativeRepairWoodCost=building._cumulativeRepairWoodCost-woodCost
end

function buildingCleanup(keys)
	keys.caster:RemoveBuilding(keys.caster._hullRadius,true)
end

function increaseMaxFood(building, amount)
	local owner=getAbsoluteParent(building)
	building.foodIncrease=(building.foodIncrease or 0)+amount
	owner.foodMax=owner.foodMax+amount
end


function createRallypoint(keys)
	local rp
	local pos
	if keys.target~=nil then
		pos=keys.target:GetAbsOrigin()
		rp=CreateUnitByName("rallypoint",Vector(pos.x,pos.y,-200),false,nil,nil,keys.caster:GetTeam())
		rp:SetAbsOrigin(pos)
		keys.caster._rallypoint=keys.target
	else
		pos=keys.target_points[1]
		rp=CreateUnitByName("rallypoint",Vector(pos.x,pos.y,-200),false,nil,nil,keys.caster:GetTeam())
		rp:SetAbsOrigin(pos)
		keys.caster._rallypoint=pos
	end
	
	Timers:CreateTimer(3,
	function()
		rp:AddNoDraw()
	end)
	if lastRp~=nil then
		lastRp:Destroy()
	end

	lastRp=rp
	
end

