

function startArea(keys)
		print (keys.activator:GetGold())-- wat is dis
end




function checkKeys(keys)
        for key, value in pairs(keys) do
                print (key,value)
                checkType(value)
        end
end    
function checkType(stuff)
        if (type(stuff)=="table") then
                for k, v in pairs(stuff) do
                        print(k,v)
                        checkType(v)
                end
        end
end

function miningGold(keys)
	print("Someone is mining")
	local t = {["activator"]=keys.activator,["count"]=0,["goldMine"]=keys.caller:GetAbsOrigin()}--ska vara positionen av guldgruvan
	table.insert(GameRules.KodoTagGameMode.goldMiners,t)
	print(#GameRules.KodoTagGameMode.goldMiners)
end

function stopMiningGold(keys)
	print("Someone stopped mining")
	for i,v in ipairs(GameRules.KodoTagGameMode.goldMiners) do
		if keys.activator == v.activator then
			table.remove(GameRules.KodoTagGameMode.goldMiners,i)
			return nil
		end
	end
	
end

function testTest(keys)
	print("fdgsdfgsfgdhfgd")
	--PrintCircle(keys.target_points[1],keys.Radius)
	checkKeys(keys)
	--PrintSquare(keys.target_points[1],keys.Size)

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


