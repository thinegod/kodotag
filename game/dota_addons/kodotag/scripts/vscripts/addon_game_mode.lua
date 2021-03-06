

GATHER_THINK_TIME=0.2
GOLD_MINE_TIME=3
ON_THINK_TIME=0.2
SURVIVE_TIME=45--in minutes
if KodoTagGameMode == nil then
	KodoTagGameMode = class({})
end
require("buildinghelper")
require("buildings")
require("triggers")
require("units")
require("util")
require("spawner")
require("timers")
require("ai")

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	PrecacheUnitByNameSync("worker",context)
	for i=1,6 do 
		PrecacheUnitByNameSync("barricade_"..i,context)
	end
	PrecacheResource("particle_folder","particles/base_attacks",context)
	--PrecacheResource("soundfile","coins.vsnd",context)
	PrecacheUnitByNameSync("tower_1",context)
	PrecacheUnitByNameSync("farm",context)
	PrecacheUnitByNameSync("castle_1",context)
	PrecacheUnitByNameSync("castle_2",context)
	PrecacheUnitByNameSync("npc_dota_hero_invoker",context)
	PrecacheResource("particle","particles/generic_gameplay/lasthit_coins.vpcf",context)
	PrecacheResource("particle","particles/items2_fx/hand_of_midas_coin_shape.vpcf",context)
	PrecacheResource("particle_folder","particles/units/heroes/hero_jakiro",context)
	PrecacheUnitByNameSync("kodo_1",context)
	PrecacheUnitByNameSync("rallypoint",context)
	PrecacheUnitByNameSync("flag",context)
	PrecacheResource("particle_folder","particles/neutral_fx",context)
	
	
	
	--PrecacheModel("npc_dota_creature_gnoll_assassin",context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.KodoTagGameMode = KodoTagGameMode()
	GameRules.KodoTagGameMode:InitGameMode()
	Convars:RegisterCommand( "buildingGrid", Dynamic_Wrap(KodoTagGameMode, 'DisplayBuildingGrids'), "blah", 0 )
end

function KodoTagGameMode:GetDifficulty()
	local count=-1
	local key=1
	local c=1
	for k,v in pairs(self.voteTable) do
		if(v>count)then
			count=v
			key=c
		end
		c=c+1
	end
	return key
end

function KodoTagGameMode:InitGameMode()
	self.goldMines={}
	self.returnStuff={}
	self._bases={}
	self.players={}
	self.voteTable={Noob=0,Easy=0,Normal=0,Hard=0,Extreme=0}
	self.goldGain=10
	self.woodGain=10
	GameRules:SetTimeOfDay( 0.75 )
	GameRules:SetHeroSelectionTime( 0.0 )
	GameRules:SetPreGameTime( 5.0 )
	GameRules:SetPostGameTime( 60.0 )
	GameRules:SetTreeRegrowTime( 60.0 )
	--GameRules:SetMinimapHeroIconScale( 800 )
	GameRules:SetCreepMinimapIconScale( 0.7 )
	GameRules:SetRuneMinimapIconScale( 0.7 )
	GameRules:SetGoldTickTime( 60.0 )
	GameRules:SetGoldPerTick( 0 )
	GameRules:SetSameHeroSelectionEnabled(true)
	GameRules:SetHeroRespawnEnabled(false)
	GameRules:GetGameModeEntity():SetThink("OnThink",self,"OnThink",ON_THINK_TIME)
	BuildingHelper:BlockGridNavSquares(16384)
	GameRules:SetTreeRegrowTime(15000)
	ListenToGameEvent("entity_killed",Dynamic_Wrap(KodoTagGameMode,"OnEntityKilled"),self)
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(KodoTagGameMode, 'OnPlayerConnectFull'), self)
	ListenToGameEvent('dota_player_killed', Dynamic_Wrap(KodoTagGameMode, 'OnPlayerKilled'), self)
	Convars:RegisterCommand("difficultyVote",function(...) return self:difficultyVote(...) end,"difficultyVote",0)
	Convars:RegisterCommand("addWood",function(...) return self:addWood(...) end,"addWood",0)
	self:initGoldMines()
	Spawner:Init()

end

function KodoTagGameMode:OnEntityKilled(keys)
	local killedUnit=EntIndexToHScript(keys.entindex_killed)
	local owner=getAbsoluteParent(killedUnit)
	if(killedUnit._castle) then
		removeFromArray(GameRules.KodoTagGameMode._bases,killedUnit)
	end
	if(killedUnit.foodCost) then
		owner.food=owner.food-killedUnit.foodCost
	end
	if(killedUnit.foodIncrease) then
		owner.foodMax=owner.foodMax-killedUnit.foodIncrease
	end

end

function KodoTagGameMode:OnThink()
	self:checkForReconnects()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		if(GameRules:GetGameTime()>(SURVIVE_TIME*60))then
			GameRules:MakeTeamLose(DOTA_TEAM_BADGUYS)
			return
		end
		self:CheckForDefeat()
		Spawner:Think()
		AI:Think()
		self:gatherThinker()
		for _,val in ipairs(GameRules.KodoTagGameMode.players) do
			FireGameEvent("updateResourcePanel",{player_ID=val:GetPlayerID(),wood=val.wood,food=val.food,foodMax=val.foodMax,gold=val:GetGold()})
		end
	end
	return ON_THINK_TIME
	
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
	self.voteTable[difficulty]=self.voteTable[difficulty]+1
	PrintTable(self.voteTable)
end
function KodoTagGameMode:initGoldMines()
	for k,v in ipairs(Entities:FindAllByName("Goldmine*")) do
		BuildingHelper:AddBuildingToGrid(v:GetAbsOrigin(), 12, nil)
	end
	
end
function KodoTagGameMode:goldMineAutomation()
local basePos=nil
local playerPos=nil
local base=nil
	for _,value in ipairs(self.goldMines) do
		if(#value.goldMiners>0) then
			if(not value._mining) then
				ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas_coin_shape.vpcf",PATTACH_ABSORIGIN_FOLLOW,value.goldMiners[1])
				value.goldMiners[1]:AddNoDraw()
				unitDisable(value.goldMiners[1])
				value.count=0
				value._mining=value.goldMiners[1]
			elseif(value.count>=1) then
				local miner=value._mining
				miner:RemoveNoDraw()
				unitEnable(miner)
				table.insert(self.returnStuff,miner)
				miner:AddNewModifier(value.goldMiners[1],nil,"modifier_phased",{duration=5})
				miner._goldReturn=true
				miner:MoveToPosition(value.goldMiners[1]._closestBase:GetAbsOrigin())
				removeFromArray(value.goldMiners,miner)
				value._mining=false
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
					unit._chopping=true
					Timers:CreateTimer(distance(unit,unit._tree)/unit:GetBaseMoveSpeed(),
					function()
						unit._chopping=false
					end
					)
				end
					base:GetOwnerEntity().wood=base:GetOwnerEntity().wood+self.woodGain
			end
			--EmitSoundOnClient("sounds/bagdrop.vsnd_c", unit:GetOwner()) This needs fixing
			
			table.remove(self.returnStuff,key)
		end
	end
	return GATHER_THINK_TIME
end


function KodoTagGameMode:addWood(_,amount)
	local cmdPlayer=Convars:GetCommandClient()
	if cmdPlayer then
		local playerID = cmdPlayer:GetPlayerID()
		if playerID ~= nil and playerID ~= -1 then
			cmdPlayer:GetAssignedHero().wood=cmdPlayer:GetAssignedHero().wood+amount
		end
	end
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
function KodoTagGameMode:checkForReconnects()
	--[[if(not self._checkTime)then 
		self._checkTime=0
	else
		self._checkTime=self._checkTime+1
	end
	if((self._checkTime%1)==0) then]]
		for _,hero in pairs( Entities:FindAllByClassname( "npc_dota_hero_invoker")) do
			if hero:GetPlayerOwnerID() == -1 then
				local id = hero:GetPlayerOwner():GetPlayerID()
				if id ~= -1 then
					print("Reconnecting hero for player " .. id)
					hero:SetControllableByPlayer(id, true)
					hero:SetPlayerID(id)
					self:playerInit(hero)
				end
			end
		end
	--end
end
function KodoTagGameMode:playerInit(hero)
	if(hero:IsHero() and not in_array(GameRules.KodoTagGameMode.players,hero)) then
		hero:SetGold(0,false)
		hero.wood=0
		hero.food=1
		hero.foodMax=4
		hero.foodCost=1
		self:initAbilities(hero)
		SendToServerConsole("sv_cheats 1")
		SendToConsole('dota_sf_hud_inventory 0')
		--SendToConsole('dota_sf_hud_top 0')
		SendToConsole('dota_render_crop_height 0')
		SendToConsole('dota_render_y_inset 0')
		SendToConsole("dota_player_smart_multiunit_cast 1")--this is for using the 
		--same ability with many selected units
		--SendToServerConsole("sv_cheats 0")--this should be uncommented for a release version
		table.insert(GameRules.KodoTagGameMode.players,hero)
		FireGameEvent("start_vote",{player_ID=hero:GetPlayerID()})
	--[[else
		PrintTable(self.players)
		print(hero)
		print("konstigt, hero finns redan i players")
		self:initAbilities(hero)
		FireGameEvent("start_vote",{player_ID=hero:GetPlayerID()})]]
	end
end

function KodoTagGameMode:initAbilities(hero)
	removeAllAbilities(hero)
	hero:AddAbility("build")
	hero:AddAbility("chop_wood")
	hero:AddAbility("repair")
	hero:AddAbility("wind_walk")
	hero:AddAbility("farsight")
	upgradeAllAbilities(hero)
end
function KodoTagGameMode:OnPlayerConnectFull(keys)
	local player = PlayerInstanceFromIndex(keys.index + 1)
    CreateHeroForPlayer('npc_dota_hero_invoker', player)
end


function KodoTagGameMode:OnPlayerKilled(keys)
	local player=PlayerResource:GetPlayer(keys.PlayerID)
	local point=Entities:FindByName(nil,"rescue_zone"):GetAbsOrigin()+RandomVector( RandomFloat( 200, 300 ))
	local flag=CreateUnitByName("flag",point,false,nil,nil,DOTA_TEAM_GOODGUYS)
	flag:SetOwner(player)
	flag:SetControllableByPlayer(keys.PlayerID,true)
	Timers:CreateTimer(1,
	function() 
		PlayerResource:SetCameraTarget(keys.PlayerID,flag)
	end)
	Timers:CreateTimer(4,
	function()
		PlayerResource:SetCameraTarget(keys.PlayerID,nil)
	end)
	for _,v in ipairs(Entities:FindAllByName("*"))do
		if(v~=player:GetAssignedHero() and getAbsoluteParent(v)==player:GetAssignedHero())then
			if(v.RemoveBuilding)then
				v:RemoveBuilding(v._hullRadius,true)
			elseif(v.foodCost)then
				v:Kill(nil,nil)
			end
		end
	end
end

function KodoTagGameMode:CheckForDefeat()
	if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		return
	end
	local bAllPlayersDead = true
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			local hero = PlayerResource:GetPlayer( nPlayerID ):GetAssignedHero()
			if hero and hero:IsAlive() then
				--print("some hero is alive")
				bAllPlayersDead = false
			end
		end
	end

	if bAllPlayersDead then
		GameRules:MakeTeamLose( DOTA_TEAM_GOODGUYS )
	end
end
