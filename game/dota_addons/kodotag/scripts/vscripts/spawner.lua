require("ai")

if Spawner == nil then
	Spawner = class({})
end

PHASE1={}
PHASE2={}
PHASE3={}
PHASE4={}
PHASE5={}
function Spawner:Init()
	self.startTime=GameRules:GetGameTime()
	self.spawnedAmount=0
	self.unitsAlive={}
	self.playerCount=1
	self.difficulty=1
	self.initialSpawnDelay=20
	self.spawnInterval=15
	self.lastSpawnTime=GameRules:GetGameTime()
	self.currentPhase=1
end

function Spawner:Think()
	local currTime=GameRules:GetGameTime()
	if(currTime < self.startTime+self.initialSpawnDelay)then return end
	local done=false
	AI:Think()
	if(self.lastSpawnTime+self.spawnInterval < currTime)then
		done=self["phase"..self.currentPhase](self)
		if(done)then--this should not trigger like this, instead we should
--		move to a new phase after some time has passed..this is for testing purposes
			self.currentPhase=self.currentPhase+1
			self.spawnedAmount=0
			print("moving on to another phase")
		end
		self.lastSpawnTime=currTime
		print("spawned kodos for phase"..self.currentPhase)
	end
end

function Spawner:phase1()
	
	if(self.spawnedAmount<15)then
		local creature = CreateUnitByName( "kodo_1" , Entities:FindByName(nil,"kodo_spawner_1"):GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
		creature:MoveToPositionAggressive(GameRules.KodoTagGameMode.players[1]:GetAbsOrigin())
		table.insert(self.unitsAlive,creature:entindex())
		self.spawnedAmount=self.spawnedAmount + 1
		return false
	else
		return true
	end
end

function Spawner:phase2()
	if(self.spawnedAmount<5)then
		local creature = CreateUnitByName( "kodo_2" , Entities:FindByName(nil,"kodo_spawner_1"):GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
		creature:MoveToPositionAggressive(GameRules.KodoTagGameMode.players[1]:GetAbsOrigin())
		table.insert(self.unitsAlive,creature:entindex())
		self.spawnedAmount=self.spawnedAmount + 1
		return false
	else
		return true
	end
end

function Spawner:phase3()
	return false
end