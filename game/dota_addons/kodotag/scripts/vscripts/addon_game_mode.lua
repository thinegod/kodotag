


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
	GameRules:GetGameModeEntity():SetThink("goldGeneration",self,"goldGeneration",1)
	BuildingHelper:BlockGridNavSquares(16384)
	--[[local creature = CreateUnitByName( "npc_dota_creature_gnoll_assassin" , Entities:FindByName(nil,"kodo_spawner_1"):GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	creature:SetInitialGoalEntity(  Entities:FindByName(nil,"waypoint_1_1") )
	creature = CreateUnitByName( "npc_dota_creature_gnoll_assassin" , Entities:FindByName(nil,"kodo_spawner_1"):GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	creature:SetInitialGoalEntity(  Entities:FindByName(nil,"waypoint_1_1") )]]
	--GameRules:GetGameModeEntity():SetThink("OnMineGold",self,"MineGold")
end


function KodoTagGameMode:goldGeneration()
	for key,value in ipairs(self.goldMiners) do
		if(value.count>2)then
			self.goldMiners[key].count=0
			value.activator:SetGold(value.activator:GetGold()+self.goldGain,false)
			print ("trying to find by model")
			print (Entities:FindByModel(value.activator,"building_racks_melee_reference"))--denna ska inte vara nil för då har vi inte hittat modellen
			value.activator:MoveToNPC(Entities:FindByModel(value.activator,"building_racks_melee_reference"))
			--value.activator:MoveToPosition(value.activator:GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ))
		else
			self.goldMiners[key].count=self.goldMiners[key].count+1
		end
	end
	return 1
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







