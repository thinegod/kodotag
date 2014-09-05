require("util")

function startArea(keys)

	if(not in_array(GameRules.KodoTagGameMode._zeroGoldArray,keys.activator)) then
		keys.activator:SetGold(0,false)
		--removeAllAbilities(keys.activator)
		-- keys.activator:AddAbility("build")
		-- keys.activator:FindAbilityByName("build"):UpgradeAbility()
		-- keys.activator:AddAbility("chop_wood")
		-- keys.activator:FindAbilityByName("chop_wood"):UpgradeAbility()
		-- keys.activator:AddAbility("repair")
		-- keys.activator:FindAbilityByName("repair"):UpgradeAbility()
		-- keys.activator:AddAbility("damage")
		-- keys.activator:FindAbilityByName("damage"):UpgradeAbility()
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
	keys.activator._lastGoldMinePos=keys.caller:GetAbsOrigin()--this could be an entity if we give the gold mine a model
	keys.activator.count=0
	table.insert(GameRules.KodoTagGameMode.goldMiners,keys.activator)
end

function stopMiningGold(keys)
	local base=GameRules.KodoTagGameMode:findClosestBase(keys.activator)
	keys.activator._closestBase=base
	removeFromArray(GameRules.KodoTagGameMode.goldMiners,keys.activator)
end

function chopWood(keys)
	local woodGain=GameRules.KodoTagGameMode.woodGain
	keys.caster._tree=keys.target
	if(keys.target._woodCount==nil) then
		keys.target._woodCount=30
	end
		keys.target._woodCount=keys.target._woodCount-woodGain
	if (keys.target._woodCount<=0) then
		local pos=keys.target:GetAbsOrigin()
		keys.target:SetAbsOrigin(Vector(0,0,-500))
		keys.caster._tree=Entities:FindByClassnameNearest("ent_dota_tree",pos,600)
		keys.target:SetAbsOrigin(pos)
		keys.target:CutDown(DOTA_GC_TEAM_GOOD_GUYS)
	end
	keys.caster._woodReturn=true
	keys.caster._closestBase=GameRules.KodoTagGameMode:findClosestBase(keys.caster)
	table.insert(GameRules.KodoTagGameMode.returnStuff,keys.caster)
	keys.caster:MoveToPosition(keys.caster._closestBase:GetAbsOrigin())
	
end
function testTest(keys)
	print("fdgsdfgsfgdhfgd")
	--PrintCircle(keys.target_points[1],keys.Radius)
	PrintTable(keys)
	print(keys.target:GetHealth())
	--PrintSquare(keys.target_points[1],keys.Size)

end



