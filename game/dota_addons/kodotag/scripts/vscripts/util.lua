
function pay(unit,cost,woodCost,foodCost)
	local player
	player=getAbsoluteParent(unit)	
	if (player:GetGold()-cost >= 0 and player.wood-woodCost>=0 and (player.food+foodCost<=player.foodMax or foodCost==0)) then
		player:SetGold(player:GetGold()-cost,false)
		player.wood=player.wood-woodCost
		player.food=player.food+foodCost
		return true
	end
	return false
end

function addAbility(keys)
	if(string.find(keys.Ability,",")==nil) then 
		keys.caster:AddAbility(keys.Ability)
		keys.caster:FindAbilityByName(keys.Ability):UpgradeAbility()
		return nil
	end
	for abilityName in string.gmatch(keys.Ability,"[%w_]+") do
		keys.caster:AddAbility(abilityName)
		keys.caster:FindAbilityByName(abilityName):UpgradeAbility()
	end
end
function upgradeAllAbilities(maybeUnit)
	local unit
	if (maybeUnit.caster~=nil) then 
		unit=maybeUnit.caster
	else
		unit = maybeUnit
	end
	for i=0,unit:GetAbilityCount() do
		if(unit:GetAbilityByIndex(i)==nil) then break end
		unit:GetAbilityByIndex(i):UpgradeAbility()
	end
end
function unitDisable(unit)
	unit:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
	unit:AddNewModifier(unit,nil,"modifier_invulnerable",nil)
	unit:AddAbility("unselectable")
	unit:FindAbilityByName("unselectable"):UpgradeAbility()
	--setHiddenAllAbilities(unit,true)
end
function unitEnable(unit)
	unit:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
	unit:RemoveModifierByName("modifier_invulnerable")
	unit:RemoveModifierByName("modifier_unselectable")
	unit:RemoveAbility("unselectable")
	setHiddenAllAbilities(unit,false)
end
function removeAllAbilities(maybeUnit)
	local unit
	if (maybeUnit.caster~=nil) then 
		unit=maybeUnit.caster
	else
		unit = maybeUnit
	end
	for i=0,unit:GetAbilityCount() do
		if(unit:GetAbilityByIndex(i)==nil) then break end
		unit:RemoveAbility(unit:GetAbilityByIndex(i):GetAbilityName())
	end
end

function setHiddenAllAbilities(unit,hidden)
	assert(unit.GetAbilityCount~=nil,"unit passed to hideallabilities is borked")
	for i=0,unit:GetAbilityCount() do
		if(unit:GetAbilityByIndex(i)==nil) then break end
		unit:GetAbilityByIndex(i):SetHidden(hidden)
	end
end


function distance(eA,eB)
	assert(eA and eB,"distance recieved nil values")
	return (eA:GetAbsOrigin()-eB:GetAbsOrigin()):Length2D()

end

function PrintSquare(v,size)
	DebugDrawLine(Vector(v.x-size,v.y+size,v.z+50), Vector(v.x+size,v.y+size,v.z+50), 255, 0, 0, false, 30)
	DebugDrawLine(Vector(v.x-size,v.y+size,v.z+50), Vector(v.x-size,v.y-size,v.z+50), 255, 0, 0, false, 30)
	DebugDrawLine(Vector(v.x-size,v.y-size,v.z+50), Vector(v.x+size,v.y-size,v.z+50), 255, 0, 0, false, 30)
	DebugDrawLine(Vector(v.x+size,v.y-size,v.z+50), Vector(v.x+size,v.y+size,v.z+50), 255, 0, 0, false, 30)
end

function PrintCircle(v,radius)
		DebugDrawCircle(v,Vector(255,0,0),BH_Z,radius,false,60)
end

function removeFromArray(array,element)
	print("remove from array")
	print(element)
	for i=1,#array do
		if(element==array[i]) then
			print(i)
			print(element)
			print(array[i])
			print(#array)
			table.remove(array,i)
		end
	end
end


function in_array(array,element)
	for i=1,#array do
		if array[i]==element then
		return true
		end
	end
	return false
end

function PrintTable(t, indent, done)
    if type(t) ~= "table" then return end

    done = done or {}
    done[t] = true
    indent = indent or 0

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    table.sort(l)
    for k, v in ipairs(l) do
        -- Ignore FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..":")
                PrintTable (value, indent + 2, done)
            elseif type(value) == "userdata" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
            else
                if t.FDesc and t.FDesc[v] then
                    print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
                else
                    print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                end
            end
        end
    end
end
function reimburse(keys)
	local absParent=getAbsoluteParent(keys.caster)
	if(keys.ability._couldAfford) then
		absParent:SetGold(absParent:GetGold()+keys.Cost,false)
		if(keys.WoodCost~=nil)then 
			absParent.wood=absParent.wood+keys.WoodCost
		end
		if(keys.FoodCost~=nil) then
			absParent.food=absParent.food-keys.FoodCost
		end
		keys.ability._couldAfford=nil
	end
end
function isAbsoluteParent(child,parent)
	if (child==nil) then
		return false
	end
	if (child==parent) then
		return true
	end
	return isAbsoluteParent(child:GetOwner(),parent)
end

function getAbsoluteParent(unit)
	if (unit==nil) then
		return nil
	end
	if(unit.IsHero and unit:IsHero()) then
		return unit
	end
	-- if (unit:GetOwner()==nil and unit:GetOwnerEntity()==nil) then
		-- return unit
	-- end
	return getAbsoluteParent(unit:GetOwner() or unit:GetOwnerEntity())
end

function attemptBuy(keys)
	if pay(keys.caster:GetOwner(),keys.Cost or 0,keys.WoodCost or 0,keys.FoodCost or 0) then
		keys.ability._couldAfford=true
		--do nothing
	else
		keys.ability._couldAfford=nil
		keys.caster:Stop()
		FireGameEvent("error_msg",{player_ID=keys.caster:GetPlayerOwnerID()
		,_error="Can't afford "..keys.ability:GetAbilityName()})
	end
end

function isFacing(entA,entB)
	local correctDirection=(entB:GetAbsOrigin()-entA:GetAbsOrigin()):Normalized()
	if(entA:GetForwardVector()==correctDirection)then
		
	end
	print(makeVectorString(correctDirection).."  blablal  "..makeVectorString(entA:GetForwardVector()))
	print(entA:GetForwardVector():Length2D())
	print(correctDirection:Length2D())
 end
