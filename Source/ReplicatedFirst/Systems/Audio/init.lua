local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")

local AudioData = require(script.AudioData)

export type AudioProps = {
	PlayOnRemove: boolean?,
	RollOffMaxDistance: number?,
	RollOffMinDistance: number?,
	RollOffMode: Enum.RollOffMode?,
	Looped: boolean?,
	PlaybackRegionsEnabled: boolean?,
	PlaybackSpeed: number?,
	Playing: boolean?,
	TimePosition: number?,
	Volume: number?,
}

export type Audio = {
	Sound: Sound,
	ThreeDPart: BasePart?,
	Play: (self: Audio) -> (),
}

export type SoundChildren = {
	PitchShiftSoundEffect: {
		Octave: number?,
	}?,
}?

local SUPPORTED_SOUND_CHILDREN = {
	PitchShiftSoundEffect = true,
}

local DEFAULT_PROPS = {
	["PlayOnRemove"] = false,
	["RollOffMaxDistance"] = 1000,
	["RollOffMinDistance"] = 10,
	["RollOffMode"] = Enum.RollOffMode.LinearSquare,
	["Looped"] = false,
	["PlaybackRegionsEnabled"] = false,
	["PlaybackSpeed"] = 1,
	["Playing"] = false,
	["TimePosition"] = 0,
	["Volume"] = 1,
}

local function preloadAudioData()
	local tempFolder = Instance.new("Folder")
	tempFolder.Name = "PreloadAudio"
	tempFolder.Parent = SoundService

	for _, soundType in AudioData do
		for soundName, soundId in soundType do
			local sound = Instance.new("Sound")
			sound.Name = soundName
			sound.SoundId = soundId
			sound.Parent = tempFolder
		end
	end

	ContentProvider:PreloadAsync(tempFolder:GetChildren())
	while ContentProvider.RequestQueueSize > 0 do
		task.wait()
	end
end

local function createSound(
	soundId: string,
	props: AudioProps?,
	threeD: (BasePart | Vector3)?,
	group: SoundGroup?,
	children: SoundChildren?
): (Sound, BasePart?)
	local sound = Instance.new("Sound")
	sound.Name = soundId
	sound.SoundId = soundId

	for property in DEFAULT_PROPS do
		sound[property] = props and props[property] or DEFAULT_PROPS[property]
	end

	if group then
		local groupInstance = SoundService:FindFirstChild(group)
		if not groupInstance then
			groupInstance = Instance.new("SoundGroup")
			groupInstance.Name = group
			groupInstance.Parent = SoundService
			group = groupInstance
		end

		sound.SoundGroup = groupInstance
	end

	local threeDPart
	if typeof(threeD) == "Vector3" then
		threeDPart = Instance.new("Part")
		threeDPart.Transparency = 1
		threeDPart.Size = Vector3.new(1, 1, 1)
		threeDPart.Position = threeD
		threeDPart.CanCollide = false
		threeDPart.CanQuery = false
		threeDPart.CanTouch = false
		threeDPart.Anchored = true
		threeDPart.Parent = workspace
		sound.Parent = threeDPart
	elseif typeof(threeD) == "Instance" and threeD:IsA("BasePart") then
		sound.Parent = threeD
	else
		sound.Parent = SoundService
	end

	return sound, threeDPart
end

local audioObject = {}

function audioObject.Play(self: Audio)
	self.Sound:Play()
end

function newAudio(soundId: string, props: AudioProps?, threeD: (BasePart | Vector3)?, group: SoundGroup?)
	assert(typeof(soundId) == "string", "Expected soundId to be a string")
	assert(typeof(props) == "table" or props == nil, "Expected props to be a table or nil")
	assert(typeof(group) == "SoundGroup" or group == nil, "Expected group to be a SoundGroup or nil")
	assert(
		threeD == nil or typeof(threeD) == "Vector3" or typeof(threeD) == "Instance" and threeD:IsA("BasePart"),
		"Expected threeD to be a Vector3 or BasePart"
	)

	local sound, threeDPart = createSound(soundId, props, threeD, group)

	local instance = setmetatable({
		Sound = sound,
		ThreeDPart = threeDPart,
	}, { __index = audioObject })

	return instance
end

local Audio = {
	Ids = AudioData,
	Props = {
		PlayOnRemove = "PlayOnRemove",
		RollOffMaxDistance = "RollOffMaxDistance",
		RollOffMinDistance = "RollOffMinDistance",
		RollOffMode = "RollOffMode",
		Looped = "Looped",
		PlaybackRegionsEnabled = "PlaybackRegionsEnabled",
		PlaybackSpeed = "PlaybackSpeed",
		Playing = "Playing",
		TimePosition = "TimePosition",
		Volume = "Volume",
	},
}

function Audio:Play(soundId: string, props: AudioProps?, threeD: (BasePart | Vector3)?, group: SoundGroup?): Audio
	if not RunService:IsRunning() then
		return nil :: any
	end
	local audio = newAudio(soundId, props, threeD, group)
	audio:Play()
	audio.Sound.Ended:Once(function()
		if audio.ThreeDPart then
			audio.ThreeDPart:Destroy()
			audio.ThreeDPart = nil
		end
		audio.Sound:Destroy()
	end)

	return audio
end

function Audio:PlayWithChildren(
	soundId: string,
	props: AudioProps?,
	threeD: (BasePart | Vector3)?,
	group: SoundGroup?,
	children: SoundChildren?
): Audio
	if not RunService:IsRunning() then
		return nil :: any
	end
	local audio = newAudio(soundId, props, threeD, group)
	audio.Sound.Ended:Once(function()
		if audio.ThreeDPart then
			audio.ThreeDPart:Destroy()
			audio.ThreeDPart = nil
		end
		audio.Sound:Destroy()
	end)

	if children then
		for childName, childProps in children do
			if not SUPPORTED_SOUND_CHILDREN[childName] then
				error(string.format("Unsupported sound child: %s", childName))
			end
			local child = Instance.new(childName)
			for propName, propValue in childProps do
				if child[propName] == nil then
					error(string.format("Unsupported property '%s' for sound child '%s'", propName, childName))
				end
				child[propName] = propValue
			end
			child.Parent = audio.Sound
		end
	end

	audio:Play()
	return audio
end

function Audio:Create(soundId: string, props: AudioProps?, threeD: (BasePart | Vector3)?, group: SoundGroup?): Audio
	local audio = newAudio(soundId, props, threeD, group)
	return audio
end

function Audio:Init()
	preloadAudioData()
end

return Audio
