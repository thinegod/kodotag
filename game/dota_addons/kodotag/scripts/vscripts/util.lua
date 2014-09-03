

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
--
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