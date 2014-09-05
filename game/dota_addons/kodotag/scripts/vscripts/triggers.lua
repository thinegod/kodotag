require("util")

function startArea(keys)

	if(not in_array(GameRules.KodoTagGameMode._zeroGoldArray,keys.activator)) then
		keys.activator:SetGold(0,false)
		--removeAllAbilities(keys.activator)
		upgradeAllAbilities(keys.activator)
		-- for i=1,4 do
			-- keys.activator:HeroLevelUp(false)
		-- end
		
		table.insert(GameRules.KodoTagGameMode._zeroGoldArray,keys.activator)
	end
end

function miningGold(keys)	
	local base=GameRules.KodoTagGameMode:findClosestBase(keys.activator)
	if(base==nil) then
		--ShowGenericPopupToPlayer(value.activator:GetOwner(),"title","content","123","456",1)--this only displays an empty box..??
		GameRules:SendCustomMessage("You cannot mine gold without a nearby base",0,1)
	else 
		keys.activator._closestBase=base
	end
	local t = {["activator"]=keys.activator,["count"]=0,["goldMine"]=keys.caller:GetAbsOrigin()}
	table.insert(GameRules.KodoTagGameMode.goldMiners,t)
end

function stopMiningGold(keys)
	local base=GameRules.KodoTagGameMode:findClosestBase(keys.activator)
	keys.activator._closestBase=base
	removeFromArray(GameRules.KodoTagGameMode.goldMiners,keys.activator)
end

function testTest(keys)
	print("fdgsdfgsfgdhfgd")
	--PrintCircle(keys.target_points[1],keys.Radius)
	PrintTable(keys)
	--PrintSquare(keys.target_points[1],keys.Size)

end



