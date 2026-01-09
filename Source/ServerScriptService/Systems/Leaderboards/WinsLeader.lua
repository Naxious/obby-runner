local Players = game:GetService("Players")

local CHARACTER_SCALE = 2

local spawnLocations = {} :: { [number]: BasePart }
local spawnedModels = {} :: { [number]: {
	characterModel: Model,
} }
local danceAnimations = {
	[1] = "rbxassetid://507771019",
	[2] = "rbxassetid://507776720",
	[3] = "rbxassetid://507777451",
}

local function applyAnimation(characterModel: Model, animationId: string)
	local humanoid = characterModel:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChild("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local newAnimation = Instance.new("Animation")
	newAnimation.AnimationId = animationId

	local animationTrack = animator:LoadAnimation(newAnimation)
	animationTrack:Play()
end

local function scaleCharacter(characterModel: Model, scale: number?)
	local humanoid = characterModel:FindFirstChildOfClass("Humanoid")
	if humanoid then
		if humanoid:FindFirstChild("BodyHeightScale") then
			humanoid.BodyHeightScale.Value = scale or CHARACTER_SCALE
		end
		if humanoid:FindFirstChild("BodyWidthScale") then
			humanoid.BodyWidthScale.Value = scale or CHARACTER_SCALE
		end
		if humanoid:FindFirstChild("BodyDepthScale") then
			humanoid.BodyDepthScale.Value = scale or CHARACTER_SCALE
		end
		if humanoid:FindFirstChild("HeadScale") then
			humanoid.HeadScale.Value = scale or CHARACTER_SCALE
		end
	end
end

local function spawnCharacterModel(characterModel: Model, location: number)
	local spawnLocation = spawnLocations[location]
	if not spawnLocation then
		return
	end

	local scales = {
		[1] = 2,
		[2] = 1.5,
		[3] = 1,
	}

	scaleCharacter(characterModel, scales[location])

	local humanoidRootPart = characterModel:FindFirstChild("HumanoidRootPart")
	if humanoidRootPart then
		humanoidRootPart.Anchored = true
	end

	local humanoid = characterModel:FindFirstChildOfClass("Humanoid") :: Humanoid
	if not humanoid then
		characterModel:Destroy()
		warn("No humanoid found in character model")
		return
	end
	humanoid.HealthDisplayDistance = 1
	humanoid.NameDisplayDistance = 1
	humanoid.DisplayName = " "

	characterModel.Parent = workspace

	local characterSize = characterModel:GetExtentsSize()
	local spawnLocationSize = spawnLocation.Size
	local yOffset = spawnLocationSize.Y + characterSize.Y / 2

	characterModel:PivotTo(spawnLocation:GetPivot() + Vector3.new(0, yOffset, 0))

	applyAnimation(characterModel, danceAnimations[location])
end

local function getCharacterModel(userId: number)
	return Players:CreateHumanoidModelFromUserId(userId)
end

local function setupSpawnLocations()
	local winsPodiums = workspace.LeaderboardLeaders.Wins
	if not winsPodiums then
		return
	end

	for _, podium: BasePart in winsPodiums:GetChildren() do
		if not podium:IsA("BasePart") then
			warn("Non-BasePart found in winsPodiums")
			continue
		end

		local podiumNumber = tonumber(podium.Name)
		spawnLocations[podiumNumber] = podium
		podium.Transparency = 1
	end
end

local WinsLeader = {}

function WinsLeader:Update(leaderboard: { userId: number, wins: number })
	for index, playerData in leaderboard do
		if playerData.userId == spawnedModels[index] then
			continue
		end

		local currentModel = spawnedModels[index] and spawnedModels[index].characterModel
		if currentModel then
			currentModel:Destroy()
		end

		local characterModel = getCharacterModel(playerData.userId)
		if not characterModel then
			warn(`Failed to get character model for userId {playerData.userId}`)
			continue
		end

		characterModel.Name = `{index}_{playerData.userId}`

		spawnCharacterModel(characterModel, index)
		spawnedModels[index] = {
			characterModel = characterModel,
		}
	end
end

function WinsLeader:Init()
	setupSpawnLocations()
end

return WinsLeader
