require("phase")
if Spawner == nil then
	Spawner = class({})
end

function Spawner:Init()
	self.startTime=GameRules:GetGameTime()
	self.playerCount=1
	self.difficulty=1
	self.initialSpawnDelay=20
	self.lastSpawnTime=GameRules:GetGameTime()
	self.currentPhase=1
	self.unitsAlive={}
	self.phases=
	{
				--(spawnInterval,phaseSize,unitName,spawner) these should be dependant on difficulty and playercount
		Phase:new(15,15,"kodo_1","kodo_spawner_1"),--phase 1
		Phase:new(15,5,"kodo_2","kodo_spawner_1"),--phase 2
		Phase:new(15,15,"kodo_1","kodo_spawner_1")--phase 3
						
	}
end

function Spawner:Think()
	if(not self.phases[self.currentPhase]) then return end--You're done with the game, basically
	local currTime=GameRules:GetGameTime()
	if(currTime < self.startTime+self.initialSpawnDelay)then return end
	if(self.lastSpawnTime+self.phases[self.currentPhase].spawnInterval < currTime)then
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

