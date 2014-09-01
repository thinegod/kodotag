

GOLD_MINE_THINK_TIME=0.2
if KodoTagGameMode == nil then
	KodoTagGameMode = class({})
end
require("buildinghelper")
require("buildings")
require("triggers")

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	
	PrecacheUnitByNameAsync("npc_dota_creature_gnoll_assassin",context)
	PrecacheUnitByNameAsync("barricade_1",context)
	PrecacheUnitByNameAsync("barricade_2",context)
	PrecacheResource("ranged_tower_good","particles/folder",context)
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
	--GameRules:SetHeroMinimapIconSize( 800 )
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
	for key,value in ipairs(self.goldMiners) do
		basePos=Entities:FindByClassnameNearest("npc_dota_base",value.activator:GetAbsOrigin(),10000):GetAbsOrigin()
		playerPos=value.activator:GetAbsOrigin()
		goldReturnVal={["player"]=self.goldMiners[key].activator,["goldMine"]=self.goldMiners[key].goldMine}
		if in_array(self.goldReturn,goldReturnVal) or value.count>=3  then-- this doesnt work properly
			table.insert(self.goldReturn,goldReturnVal)
			table.remove(self.goldMiners,key)
			value.activator:MoveToPosition(basePos)
		else
			self.goldMiners[key].count=self.goldMiners[key].count+GOLD_MINE_THINK_TIME
		end
	end
	for key,array in ipairs(self.goldReturn) do
		basePos=Entities:FindByClassnameNearest("npc_dota_base",array.player:GetAbsOrigin(),10000):GetAbsOrigin()
		playerPos=array.player:GetAbsOrigin()
		if (basePos-playerPos):Length2D()<200 then
			array.player:SetGold(player[1]:GetGold()+self.goldGain,false)
			array.player:MoveToPosition(array.goldMine)
			table.remove(self.goldReturn,key)
		end
	end
	return GOLD_MINE_THINK_TIME
end

function in_array(array,element)
	for i=1,#array do
		if array[i]==element then
		return true
		end
	end
	return nil
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







