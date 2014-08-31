

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

goldMiners={}

function miningGold(keys)
print ("INNE I miningGold")
	for i,v in ipairs(goldMiners) do
		if keys.activator == v.activator then
			v.count=v.count+1
			print ("PRINTEN "..v.count)
			return nil
		end
	end
	local t = {["activator"]=keys.activator,["count"]=0}
	table.insert(goldMiners,t)
	 print ("added someone to goldMiners")
end

function stopMiningGold(keys)
print ("INNE I stopMiningGold")
	for i,v in ipairs(goldMiners) do
		if keys.activator == v.activator then
			table.remove(goldMiners,i)
			return nil
		end
	end
	
end