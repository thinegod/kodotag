

function startArea(keys)
		print (keys.activator:GetGold())
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
	--[[for i,v in ipairs(GameRules.KodoTagGameMode.goldMiners) do
		if keys.activator == v.activator then
			v.count=v.count+1
			print ("PRINTEN "..v.count)
			return nil
		end
	end]]
	local t = {["activator"]=keys.activator,["count"]=0}
	table.insert(GameRules.KodoTagGameMode.goldMiners,t)
end

function stopMiningGold(keys)
	for i,v in ipairs(GameRules.KodoTagGameMode.goldMiners) do
		if keys.activator == v.activator then
			table.remove(GameRules.KodoTagGameMode.goldMiners,i)
			return nil
		end
	end
	
end


