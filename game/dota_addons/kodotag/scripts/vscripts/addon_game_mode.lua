

GATHER_THINK_TIME=0.2
GOLD_MINE_TIME=3
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
	PrecacheUnitByNameSync("worker",context)
	PrecacheUnitByNameSync("barricade_1",context)
	PrecacheUnitByNameSync("barricade_2",context)
	PrecacheResource("ranged_tower_good","particles/folder",context)
	PrecacheResource("coins.vsnd","sounds/ui",context)
	PrecacheUnitByNameSync("basic_tower",context)
	PrecacheUnitByNameSync("farm",context)
	PrecacheUnitByNameSync("castle_1",context)
	PrecacheUnitByNameSync("castle_2",context)
	PrecacheResource("particle","particles/generic_gameplay/lasthit_coins.vpcf",context)
	PrecacheResource("particle","particles/items2_fx/hand_of_midas_coin_shape.vpcf",context)
	PrecacheResource("particle_folder","particles/units/heroes/hero_jakiro",context)
	
	--PrecacheModel("npc_dota_creature_gnoll_assassin",context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.KodoTagGameMode = KodoTagGameMode()
	GameRules.KodoTagGameMode:InitGameMode()
	Convars:RegisterCommand( "buildingGrid", Dynamic_Wrap(KodoTagGameMode, 'DisplayBuildingGrids'), "blah", 0 )
end

function KodoTagGameMode:InitGameMode()
	self.goldMines={}
	self.returnStuff={}
	self._bases={}
	self._zeroGoldArray={}
	self._voteTable={Noob=0,Easy=0,Normal=0,Hard=0,Extreme=0}
	self.goldGain=10
	self.woodGain=10
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
	GameRules:GetGameModeEntity():SetThink("gatherThinker",self,"gatherThinker",GATHER_THINK_TIME)
	GameRules:GetGameModeEntity():SetThink("OnThink",self,"OnThink",0.25)
	BuildingHelper:BlockGridNavSquares(16384)
	GameRules:SetTreeRegrowTime(932458)
	ListenToGameEvent("entity_killed",Dynamic_Wrap(KodoTagGameMode,"OnEntityKilled"),self)
	Convars:RegisterCommand("difficultyVote",function(...) return self:difficultyVote(...) end,"difficultyVote",0)
	--[[local creature = CreateUnitByName( "npc_dota_creature_gnoll_assassin" , Entities:FindByName(nil,"kodo_spawner_1"):GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	creature:SetInitialGoalEntity(  Entities:FindByName(nil,"waypoint_1_1") )
	creature = CreateUnitByName( "npc_dota_creature_gnoll_assassin" , Entities:FindByName(nil,"kodo_spawner_1"):GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	creature:SetInitialGoalEntity(  Entities:FindByName(nil,"waypoint_1_1") )]]
	--GameRules:GetGameModeEntity():SetThink("OnMineGold",self,"MineGold")
end

function KodoTagGameMode:OnEntityKilled(keys)
	local killedUnit=EntIndexToHScript(keys.entindex_killed)
	if(killedUnit._castle) then
		removeFromArray(GameRules.KodoTagGameMode._bases,killedUnit)
		print("removed base from base-array")
	end
	print(in_array(GameRules.KodoTagGameMode._bases,killedUnit))

end

function KodoTagGameMode:OnThink()
	for _,val in ipairs(GameRules.KodoTagGameMode._zeroGoldArray) do
		FireGameEvent("updateResourcePanel",{player_ID=val:GetPlayerID(),wood=val.wood,0})
	end
	return 0.25
	
end
function KodoTagGameMode:findClosestBase(unit)
	if(#self._bases==0) then return nil end
	if(#self._bases==1) then return self._bases[1] end
	local base=self._bases[1]
	local dist=500000
	for i=1,#self._bases do
		if distance(self._bases[i],unit)<dist and isAbsoluteParent(unit,self._bases[i]:GetOwner())--[[(self._bases[i]:GetOwner()==unit or self._bases[i]:GetOwner()==unit:GetOwner())]] then
			base=self._bases[i]
			dist=distance(self._bases[i],unit)
		end
	end
	
	if dist~=500000 then
		return base
	else
		return nil
	end

end

function KodoTagGameMode:difficultyVote(_,difficulty)
	self._voteTable[difficulty]=self._voteTable[difficulty]+1
	PrintTable(self._voteTable)
end

function KodoTagGameMode:goldMineAutomation()
local basePos=nil
local playerPos=nil
local base=nil
	for _,value in ipairs(self.goldMines) do
		if(#value.goldMiners>0) then
			if(not value._mining) then
				ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas_coin_shape.vpcf",PATTACH_ABSORIGIN_FOLLOW,value.goldMiners[1])
				value.lastPos=value.goldMiners[1]:GetAbsOrigin()
				value.goldMiners[1]:AddNoDraw()
				value.goldMiners[1]:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
				value.count=0
				value._mining=true
			elseif(value.count>=2) then
				value.goldMiners[1]:RemoveNoDraw()
				value.goldMiners[1]:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
				value._mining=false
				table.insert(self.returnStuff,value.goldMiners[1])
				value.goldMiners[1]._goldReturn=true
				value.goldMiners[1]:MoveToPosition(value.goldMiners[1]._closestBase:GetAbsOrigin())
				table.remove(value.goldMiners,1)
			else
				value.count=value.count+GATHER_THINK_TIME
			end
		end
	end
end

function KodoTagGameMode:gatherThinker()
local basePos=nil
local playerPos=nil
local returnPos=nil
	self:goldMineAutomation()
	
	for key,unit in ipairs(self.returnStuff) do
		base=unit._closestBase
		if base==nil then return GATHER_THINK_TIME end
		basePos=base:GetAbsOrigin()
		unitPos=unit:GetAbsOrigin()
		if (basePos-unitPos):Length2D()<200 and isAbsoluteParent(unit,base:GetOwnerEntity()) then
			if ( unit._goldReturn) then
				base:GetOwnerEntity():SetGold(base:GetOwnerEntity():GetGold()+self.goldGain,false)
				unit:MoveToPosition(unit._lastGoldMinePos)
				unit._goldReturn=false
			elseif (unit._woodReturn) then
				unit._woodReturn=false
				if (unit._tree~=nil) then
					unit:CastAbilityOnTarget(unit._tree,unit:FindAbilityByName("chop_wood"),base:GetOwnerEntity():GetPlayerID())
				end
				if(base:GetOwnerEntity().wood==nil) then
					base:GetOwnerEntity().wood=self.woodGain
				else
					base:GetOwnerEntity().wood=base:GetOwnerEntity().wood+self.woodGain
					
				end
			end
			--EmitSoundOnClient("sounds/bagdrop.vsnd_c", unit:GetOwner()) This needs fixing
			
			table.remove(self.returnStuff,key)
		end
	end
	return GATHER_THINK_TIME
end



function KodoTagGameMode:DisplayBuildingGrids()
  print( '******* Displaying Building Grids ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
		for vectString,b in pairs(BUILDING_SQUARES) do
			if b then
				local i = vectString:find(",")
				local x = tonumber(vectString:sub(1,i-1))
				local y = tonumber(vectString:sub(i+1))
				print("x: " .. x .. "y: " .. y)
				--PrintVector(square)
				BuildingHelper:PrintSquareFromCenterPoint(Vector(x,y,BH_Z))
			end
		end
    end
  end
  print( '*********************************************' )
end




