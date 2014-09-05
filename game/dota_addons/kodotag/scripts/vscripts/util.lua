

function pay(unit,cost)
	local player
	if(unit.GetGold==nil) then
		player=unit:GetOwner()
	else
		player=unit
	end
	if (player:GetGold()-cost >= 0) then
		player:SetGold(player:GetGold()-cost,false)
		return true
	end
	return false
end

function payWood(unit,cost)
	local player
	if(unit.GetGold==nil) then
		player=unit:GetOwner()
	else
		player=unit
	end
	if (player.wood-cost >= 0) then
		player.wood=player.wood-cost
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
	for i=0,10 do
		if(unit:GetAbilityByIndex(i)==nil) then break end
		unit:GetAbilityByIndex(i):UpgradeAbility()
	end
end

function removeAllAbilities(maybeUnit)
	local unit
	if (maybeUnit.caster~=nil) then 
		unit=maybeUnit.caster
	else
		unit = maybeUnit
	end
	for i=0,10 do
		if(unit:GetAbilityByIndex(i)==nil) then break end
		unit:RemoveAbility(unit:GetAbilityByIndex(i):GetAbilityName())
	end
end

function distance(eA,eB)
	assert(eA and eB,"distance recieved nil values")
	return (eA:GetAbsOrigin()-eB:GetAbsOrigin()):Length2D()

end

function PrintSquare(v,size)
			DebugDrawLine(Vector(v.x-size,v.y+size,BH_Z), Vector(v.x+size,v.y+size,BH_Z), 255, 0, 0, false, 30)
			DebugDrawLine(Vector(v.x-size,v.y+size,BH_Z), Vector(v.x-size,v.y-size,BH_Z), 255, 0, 0, false, 30)
			DebugDrawLine(Vector(v.x-size,v.y-size,BH_Z), Vector(v.x+size,v.y-size,BH_Z), 255, 0, 0, false, 30)
			DebugDrawLine(Vector(v.x+size,v.y-size,BH_Z), Vector(v.x+size,v.y+size,BH_Z), 255, 0, 0, false, 30)
end

function PrintCircle(v,radius)
		DebugDrawCircle(v,Vector(255,0,0),BH_Z,radius,false,60)
end

function removeFromArray(array,element)
	for i=1,#array do
		if(element==array[i]) then
			table.remove(array,i)
		end
	end
end


function in_array(array,element)--someone make this work..
	--[[if(type(element)=="table" and #array>2) then
		for i=1,#array do
			for key,value in ipairs(element) do
				for k,v in ipairs(array[i]) do
					if(key==k and v~=value) then
					return false
					end
				end
			end
		end
		return true
	else]]
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
	print(absParent)
	-- PrintTable(absParent)
	-- print(type(absParent))
	-- for k, v in ipairs(absParent) do
		-- print(k)
		-- print(v)
	-- end
	if(keys.caster._couldAfford) then
		absParent:SetGold(absParent:GetGold()+keys.Cost,false)
		keys.caster._couldAfford=nil
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
	if(unit:IsHero()) then
		return unit
	end
	-- if (unit:GetOwner()==nil and unit:GetOwnerEntity()==nil) then
		-- return unit
	-- end
	return getAbsoluteParent(unit:GetOwner() or unit:GetOwnerEntity())
end