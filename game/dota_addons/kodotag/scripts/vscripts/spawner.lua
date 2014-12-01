require("phase")
if Spawner == nil then
	Spawner = class({})
end

function Spawner:Init()
	self.startTime=0
	self.playerCount=1
	self.difficulty=1
	self.initialSpawnDelay=20
	self.lastSpawnTime=GameRules:GetGameTime()
	self.currentPhase=1
	self.unitsAlive={}
end

function Spawner:Think()
	if(self.phases and not self.phases[self.currentPhase]) then return end--there are no more phases
	if(self.startTime==0)then self.startTime=GameRules:GetGameTime() end
	local currTime=GameRules:GetGameTime()
	if(currTime < self.startTime+self.initialSpawnDelay)then return end
	if(not self.phases)then
		self:InitPhases()
	end
	if((self.lastSpawnTime+self.phases[self.currentPhase].spawnInterval) < currTime)then
		local entIndex=self.phases[self.currentPhase]:Spawn()
		if(not entIndex)then
			self.currentPhase=self.currentPhase+1
			self.spawnedAmount=0
			print("moving on to another phase")
		else
			table.insert(self.unitsAlive,entIndex)
		end
		self.lastSpawnTime=currTime
		print("spawned kodos for phase"..self.currentPhase)
	end
end

function Spawner:InitPhases()
	local difficulty=GameRules.KodoTagGameMode:GetDifficulty()
	local playerCount=#GameRules.KodoTagGameMode.players
	self.phases=
	{
				--(float spawnInterval,int phaseSize,string unitName,string spawner) these should be dependant on difficulty and playercount
		Phase:new(15/(playerCount*difficulty),math.floor(10*difficulty*playerCount),"kodo_1","kodo_spawner_1"),--phase 1
		Phase:new(15/(playerCount*difficulty),math.floor(3*difficulty*playerCount),"kodo_2","kodo_spawner_1"),--phase 2
		Phase:new(15/(playerCount*difficulty),math.floor(10*difficulty*playerCount),"kodo_2","kodo_spawner_1")--phase 3
						
	}
end

