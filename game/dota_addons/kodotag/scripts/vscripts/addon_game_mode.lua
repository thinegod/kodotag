

GOLD_MINE_THINK_TIME=0.2
if KodoTagGameMode == nil then
	KodoTagGameMode = class({})
end
require("buildinghelper")
require("buildings")
require("triggers")
require("units")
require("util")

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	
	PrecacheUnitByNameAsync("worker",context)
	PrecacheUnitByNameAsync("barricade_1",context)
	PrecacheUnitByNameAsync("barricade_2",context)
	PrecacheResource("ranged_tower_good","particles/folder",context)
	PrecacheResource("coins.vsnd","sounds/ui",context)
	PrecacheUnitByNameAsync("basic_tower",context)
	PrecacheUnitByNameAsync("farm",context)
	PrecacheUnitByNameAsync("castle_1",context)
	PrecacheUnitByNameAsync("castle_2",context)
	--PrecacheModel("npc_dota_creature_gnoll_assassin",context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.KodoTagGameMode = KodoTagGameMode()
	GameRules.KodoTagGameMode:InitGameMode()
	Convars:RegisterCommand( "buildingGrid", Dynamic_Wrap(KodoTagGameMode, 'DisplayBuildingGrids'), "blah", 0 )
end

function KodoTagGameMode:InitGameMode()
	self.goldMiners={}
	self.goldReturn={}
	self.goldGain=10
	GameRules:SetTimeOfDay( 0.75 )
	GameRules:SetHeroSelectionTime( 5.0 )
	GameRules:SetPreGameTime( 5.0 )
	GameRules:SetPostGameTime( 60.0 )
	GameRules:SetTreeRegrowTime( 60.0 )
	--GameRules:SetMinimapHeroIconScale( 800 )
	GameRules:SetCreepMinimapIconScale( 0.7 )
	GameRules:SetRuneMinimapIconScale( 0.7 )
	GameRules:SetGoldTickTime( 60.0 )
	GameRules:SetGoldPerTick( 0 )
	GameRules:SetSameHeroSelectionEnabled(true)
	--KodoTagGameMode:DisplayBuildingGrids()
	GameRules:GetGameModeEntity():SetThink("goldGeneration",self,"goldGeneration",GOLD_MINE_THINK_TIME)
	BuildingHelper:BlockGridNavSquares(16384)
	--[[local creature = CreateUnitByName( "npc_dota_creature_gnoll_assassin" , Entities:FindByName(nil,"kodo_spawner_1"):GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	creature:SetInitialGoalEntity(  Entities:FindByName(nil,"waypoint_1_1") )
	creature = CreateUnitByName( "npc_dota_creature_gnoll_assassin" , Entities:FindByName(nil,"kodo_spawner_1"):GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	creature:SetInitialGoalEntity(  Entities:FindByName(nil,"waypoint_1_1") )]]
	--GameRules:GetGameModeEntity():SetThink("OnMineGold",self,"MineGold")
end


function KodoTagGameMode:goldGeneration()
local basePos=nil
local playerPos=nil
local base=nil
	for key,value in ipairs(self.goldMiners) do
		base=Entities:FindByClassnameNearest("npc_dota_building",value.activator:GetAbsOrigin(),10000)--this needs to change
		
		if(base==nil) then
			if(not value.activator.showNoBaseWarning) then
				value.activator.showNoBaseWarning=true
				--ShowGenericPopupToPlayer(value.activator:GetOwner(),"title","content","","",1)--this only displays an empty box..??
				GameRules:SendCustomMessage("You cannot mine gold without a nearby base",0,1)
			end
			return GOLD_MINE_THINK_TIME
		end
		basePos=base:GetAbsOrigin()
		playerPos=value.activator:GetAbsOrigin()
		goldReturnVal={["player"]=self.goldMiners[key].activator,["goldMine"]=self.goldMiners[key].goldMine}
		if in_array(self.goldReturn,goldReturnVal) then
			value.activator:MoveToPosition(basePos)
		elseif  value.count>=3  then
			table.insert(self.goldReturn,goldReturnVal)
			table.remove(self.goldMiners,key)
			value.activator:MoveToPosition(basePos)
		else
			self.goldMiners[key].count=self.goldMiners[key].count+GOLD_MINE_THINK_TIME
		end
	end
	for key,array in ipairs(self.goldReturn) do
		base=Entities:FindByClassnameNearest("npc_dota_building",array.player:GetAbsOrigin(),10000)
		basePos=base:GetAbsOrigin()
		playerPos=array.player:GetAbsOrigin()
		if (basePos-playerPos):Length2D()<200 and (base:GetOwner()==array.player or base:GetOwner()==array.player:GetOwner()) then
			if (array.player:GetOwner().SetGold==nil) then
				array.player:SetGold(array.player:GetGold()+self.goldGain,false)
			else 
				array.player:GetOwner():SetGold(array.player:GetOwner():GetGold()+self.goldGain,false)
			end
			--EmitSoundOnClient("sounds/bagdrop.vsnd_c", array.player:GetOwner()) This needs fixing
			array.player:MoveToPosition(array.goldMine)
			table.remove(self.goldReturn,key)
		end
	end
	return GOLD_MINE_THINK_TIME
end

function in_array(array,element)--someone make this work..
return false
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
	else
		for i=1,#array do
			if array[i]==element then
			return true
			end
		end
		return false
	end]]
end
function KodoTagGameMode:DisplayBuildingGrids()
  print( '******* Displaying Building Grids ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
		for i,v in ipairs(BUILDING_SQUARES) do
			for i2,v2 in ipairs(v) do
				BuildingHelper:PrintSquareFromCenterPoint(v2)
			end
		end
    end
  end
  print( '*********************************************' )
end







