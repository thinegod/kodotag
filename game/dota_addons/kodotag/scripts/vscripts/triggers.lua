require("util")
WOOD_COUNT=50
function startArea(keys)
	--not currently used mimi
end

function miningGold(keys)
	print(keys.activator._woodReturn)
	print(keys.activator._chopping)
	if(keys.activator._woodReturn or keys.activator._chopping)then return end
	local base=GameRules.KodoTagGameMode:findClosestBase(keys.activator)
	keys.activator:Stop()
	if(base==nil) then
		FireGameEvent("error_msg",{player_ID=getAbsoluteParent(keys.activator):GetPlayerID(),_error="You cannot mine gold without a nearby base"})
		return nil
	else 
		keys.activator._closestBase=base
	end
	if(not in_array(GameRules.KodoTagGameMode.goldMines,keys.caller)) then
		table.insert(GameRules.KodoTagGameMode.goldMines,keys.caller)
		keys.caller.goldMiners={}
	end
	keys.activator._lastGoldMinePos=keys.caller:GetAbsOrigin()
	keys.activator.count=0

	table.insert(keys.caller.goldMiners,keys.activator)
end

function stopMiningGold(keys)
	local base=GameRules.KodoTagGameMode:findClosestBase(keys.activator)
	keys.activator._closestBase=base

	if(keys.caller.goldMiners~=nil and #keys.caller.goldMiners>0 and in_array(keys.caller.goldMiners,keys.activator)) then
		removeFromArray(keys.caller.goldMiners,keys.activator)
	end
end

function chopWood(keys)
	keys.caster._lastTreeChopTime=GameRules:GetGameTime()
	keys.caster._woodReturn=true
	local base=GameRules.KodoTagGameMode:findClosestBase(keys.caster)
	if(base==nil) then
		FireGameEvent("error_msg",{player_ID=getAbsoluteParent(keys.caster):GetPlayerID(),_error="You cannot chop wood without a nearby base"})
		return nil
	else
		keys.caster._closestBase=base
		table.insert(GameRules.KodoTagGameMode.returnStuff,keys.caster)
		keys.caster:MoveToPosition(keys.caster._closestBase:GetAbsOrigin())
	end
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
		keys.target:CutDown(DOTA_GC_TEAM_GOOD_GUYS)
		local newTree=nil
		local treeDistance
		for _,v in ipairs(Entities:FindAllByClassnameWithin("ent_dota_tree",pos,600))do
			if(v:IsStanding() and (v._woodCount==nil or v._woodCount>0)) then
				if(newTree)then
					if(distance(v,keys.target)<treeDistance)then
							treeDistance=distance(v,keys.target)
							newTree=v
					end
				else
					treeDistance=distance(v,keys.target)
					newTree=v
				end	
			end
		end
		if(newTree~=nil)then 
			if(newTree.treeChoppers==nil) then
				newTree.treeChoppers={}
			end
			for k,val in ipairs(keys.target.treeChoppers) do
				val._tree=newTree
				if(not in_array(GameRules.KodoTagGameMode.returnStuff,val) and GameRules:GetGameTime()-val._lastTreeChopTime<10)then
					val:CastAbilityOnTarget(val._tree,val:FindAbilityByName("chop_wood"),getAbsoluteParent(val):GetPlayerID())
				else
					table.insert(newTree.treeChoppers,val)
				end
			end
		end
	end


	
end
function testTest(keys)


end

function rescue(keys)
	for _,v in ipairs(Entities:FindAllByModel("models/props_structures/test_flag/test_flag.vmdl")) do
		local point = v:GetAbsOrigin()
		local hero=PlayerResource:GetPlayer(v:GetOwner():GetPlayerID()):GetAssignedHero()
		hero.food=hero.food+1
		hero:SetControllableByPlayer(v:GetOwner():GetPlayerID(),true)
		hero:RespawnUnit()
		GameRules.KodoTagGameMode:initAbilities(hero)
		v:Destroy()
		hero:SetAbsOrigin(point)
	end
	
end



