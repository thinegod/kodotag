

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

