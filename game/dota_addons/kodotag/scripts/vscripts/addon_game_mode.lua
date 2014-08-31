-- Generated from template




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
	--PrecacheModel("npc_dota_creature_gnoll_assassin",context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.KodoTagGameMode = KodoTagGameMode()
	GameRules.KodoTagGameMode:InitGameMode()
end

function KodoTagGameMode:InitGameMode()
	
	GameRules:SetTimeOfDay( 0.75 )
	GameRules:SetHeroSelectionTime( 5.0 )
	GameRules:SetPreGameTime( 5.0 )
	GameRules:SetPostGameTime( 60.0 )
	GameRules:SetTreeRegrowTime( 60.0 )
	GameRules:SetHeroMinimapIconSize( 800 )
	GameRules:SetCreepMinimapIconScale( 0.7 )
	GameRules:SetRuneMinimapIconScale( 0.7 )
	GameRules:SetGoldTickTime( 60.0 )
	GameRules:SetGoldPerTick( 0 )
	--KodoTagGameMode:DisplayBuildingGrids()
	
	BuildingHelper:BlockGridNavSquares(16384)
	--[[local creature = CreateUnitByName( "npc_dota_creature_gnoll_assassin" , Entities:FindByName(nil,"kodo_spawner_1"):GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	creature:SetInitialGoalEntity(  Entities:FindByName(nil,"waypoint_1_1") )
	creature = CreateUnitByName( "npc_dota_creature_gnoll_assassin" , Entities:FindByName(nil,"kodo_spawner_1"):GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	creature:SetInitialGoalEntity(  Entities:FindByName(nil,"waypoint_1_1") )]]
	GameRules:GetGameModeEntity():SetThink("OnMineGold",self,"MineGold")
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

miningGold={}
function KodoTagGameMode:OnMineGold()
print ("test")
print (miningGold[1])
	for I=1,#miningGold do
		print(miningGold[I])
		end
	return 3
end

function startMineGold(keys)
	table.insert(miningGold,keys.activator)
	 print ("added someone to mininGold")

end

function stopMineGold(keys)
	table.remove(miningGold,1)
end






