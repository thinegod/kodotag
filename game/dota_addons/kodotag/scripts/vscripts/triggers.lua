require("util")
WOOD_COUNT=30
function startArea(keys)
	if(keys.activator:IsHero() and not in_array(GameRules.KodoTagGameMode._zeroGoldArray,keys.activator)) then
		keys.activator:SetGold(0,false)
			FireGameEvent("start_vote",{player_ID=keys.activator:GetPlayerID()})
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
	ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas_coin_shape.vpcf",PATTACH_ABSORIGIN_FOLLOW,keys.activator)
	local base=GameRules.KodoTagGameMode:findClosestBase(keys.activator)
	if(base==nil) then
		FireGameEvent("custom_error_show",{player_ID=getAbsoluteParent(keys.activator):GetPlayerID(),_error="You cannot mine gold without a nearby base"})
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
	if(keys.target.treeChoppers==nil) then
		keys.target.treeChoppers={}
	end
	if(not in_array(keys.target.treeChoppers,keys.caster)) then
		table.insert(keys.target.treeChoppers,keys.caster)
	end
	if(keys.target._woodCount==nil) then
		keys.target._woodCount=WOOD_COUNT
	end
		keys.target._woodCount=keys.target._woodCount-woodGain
	if (keys.target._woodCount<=0) then
		local pos=keys.target:GetAbsOrigin()
		keys.target:SetAbsOrigin(Vector(0,0,-500))
		local newTree=Entities:FindByClassnameNearest("ent_dota_tree",pos,1000)
		for k,val in ipairs(keys.target.treeChoppers) do
			val._tree=newTree
			table.insert(newTree,val)
		end
		keys.target:SetAbsOrigin(pos)
		keys.target:CutDown(DOTA_GC_TEAM_GOOD_GUYS)
	end
	keys.caster._woodReturn=true
	local base=GameRules.KodoTagGameMode:findClosestBase(keys.caster)
	if(base==nil) then
		FireGameEvent("custom_error_show",{player_ID=getAbsoluteParent(keys.caster):GetPlayerID(),_error="You cannot chop wood without a nearby base"})
	else
		keys.caster._closestBase=base
		table.insert(GameRules.KodoTagGameMode.returnStuff,keys.caster)
		keys.caster:MoveToPosition(keys.caster._closestBase:GetAbsOrigin())
	end

	
end
function testTest(keys)
	print("fdgsdfgsfgdhfgd")
	--PrintCircle(keys.target_points[1],keys.Radius)
	PrintTable(keys)
	print(keys.target:GetHealth())
	--PrintSquare(keys.target_points[1],keys.Size)

end



