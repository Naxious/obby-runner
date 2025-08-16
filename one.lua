local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

local VampireSystem = ReplicatedStorage.VampireSystem
local VampireAbilityEvent = VampireSystem.VampireAbility
local VampireFunctions = require(ServerStorage.Modules.VampireFunctions)
local GrabHold = game.ReplicatedStorage.Remotes:FindFirstChild("GrabHold")
local VampireSettings = require(ReplicatedStorage.VampireSystem:WaitForChild("VampireSettings"))
local CHOKE_SOUND_ID = 9113800064

local function onGrabRequest(vampirePlayer, targetCharacter)
	local character = vampirePlayer.Character
	if not character or not targetCharacter then return end
	if not vampirePlayer:GetAttribute("IsVampire") then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
	if not humanoid or not targetHumanoid or targetHumanoid.Health <= 0 then return end

	local enemyRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
	local RootPart = character:FindFirstChild("HumanoidRootPart")
	local chokeSound = Instance.new("Sound")
	chokeSound.SoundId = "rbxassetid://" .. CHOKE_SOUND_ID
	chokeSound.Volume = 0.8
	chokeSound.Parent = character:FindFirstChild("Head") or workspace
	chokeSound:Play()
	chokeSound.Ended:Connect(function() chokeSound:Destroy() end)

	local grabbingAnim = Instance.new("Animation")
	grabbingAnim.AnimationId = "rbxassetid://" .. VampireSettings.Animations.Grabbing
	local grabbingTrack = humanoid.Animator:LoadAnimation(grabbingAnim)
	grabbingTrack:Play()

	local gettingGrabbedAnim = Instance.new("Animation")
	gettingGrabbedAnim.AnimationId = "rbxassetid://" .. VampireSettings.Animations.GettingGrabbed
	local gettingGrabbedTrack = targetHumanoid.Animator:LoadAnimation(gettingGrabbedAnim)
	gettingGrabbedTrack:Play()
end

local function addDefaultPrompt(target)
	local hrp = target:FindFirstChild("HumanoidRootPart")
	if not hrp or hrp:FindFirstChild("DefaultGrabPrompt") then return end

	local player = Players:GetPlayerFromCharacter(target)
	if player and player:GetAttribute("IsVampire") then return end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "DefaultGrabPrompt"
	prompt.ObjectText = target.Name
	prompt.ActionText = "Grab"
	prompt.KeyboardKeyCode = Enum.KeyCode.E 
	prompt.HoldDuration = 0
	prompt.Style = Enum.ProximityPromptStyle.Custom
	prompt.MaxActivationDistance = 15
	prompt.RequiresLineOfSight = false
	prompt.Parent = hrp

	prompt.Triggered:Connect(function(triggeringPlayer)
		local grabbedPlayer = Players:GetPlayerFromCharacter(target)
		if not grabbedPlayer then return end
		
		triggeringPlayer.Character:FindFirstChild("HumanoidRootPart").DefaultGrabPrompt.Enabled = false
		grabbedPlayer.Character:FindFirstChild("HumanoidRootPart").DefaultGrabPrompt.Enabled = false
		print("[SERVER] Firing GrabHold Start event to grabbed player: " .. grabbedPlayer.Name)

		local ObjectValue = Instance.new("ObjectValue")
		ObjectValue.Name = "GrabbedBy"
		ObjectValue.Value = triggeringPlayer
		ObjectValue.Parent = grabbedPlayer.Character
		GrabHold:FireClient(grabbedPlayer, "Start", target)
		
		VampireFunctions.onGrabRequest(triggeringPlayer, target)
		
		task.wait(8)
		if not ObjectValue:IsDescendantOf(grabbedPlayer.Character) then
			return
		end
		
		triggeringPlayer.Character:FindFirstChild("HumanoidRootPart").DefaultGrabPrompt.Enabled = true
		grabbedPlayer.Character:FindFirstChild("HumanoidRootPart").DefaultGrabPrompt.Enabled = true
		grabbedPlayer.PlayerGui:FindFirstChild("Escape").Enabled = false
		print("[SERVER] Auto-ending grab for " .. grabbedPlayer.Name)
		GrabHold:FireClient(grabbedPlayer, "End", target)
	end)
end

for _, child in ipairs(workspace:GetChildren()) do
	if child:IsA("Model") and child:FindFirstChild("Humanoid") then
		addDefaultPrompt(child)
	end
end

workspace.ChildAdded:Connect(function(child)
	if child:IsA("Model") and child:FindFirstChild("Humanoid") then
		addDefaultPrompt(child)
	end
end)

VampireAbilityEvent.OnServerEvent:Connect(function(player, action, target)
	if action == "Release" then
		print("[SERVER] Release triggered by "..player.Name)
		
		local grabbedPlayer = (function() 
			if typeof(target) == "Instance" and target:IsA("Model") then
				return Players:GetPlayerFromCharacter(target)
			end
			
			return nil
		end)() 
		
		if not grabbedPlayer then
			print("[SERVER] Could not find grabbed player for release.")
			return
		end
		
		local grabbedBy = grabbedPlayer.Character:FindFirstChild("GrabbedBy")
		local humanoidRootPart = grabbedPlayer.Character and grabbedPlayer.Character:FindFirstChild("HumanoidRootPart")
		local prompt = humanoidRootPart:FindFirstChild("DefaultGrabPrompt")
		if prompt then prompt.Enabled = true end
		
		if grabbedPlayer.PlayerGui:FindFirstChild("Escape") then
			grabbedPlayer.PlayerGui.Escape.Enabled = false
		end
		
		print(player, player.Character, grabbedBy.Value)
		local Motor6D = grabbedBy.Value.Character:FindFirstChild("VampireGrabMotor", true)
		if Motor6D then Motor6D:Destroy() end
		
		local trackList1 = grabbedPlayer.Character.Humanoid.Animator:GetPlayingAnimationTracks()
		local trackList2 = grabbedBy.Value.Character.Humanoid.Animator:GetPlayingAnimationTracks()
		
		grabbedBy:Destroy()
		for _, Track in {unpack(trackList1), unpack(trackList2)} do
			if table.find({"Grabbing", "Grabbed"}, Track.Name) then
				continue
			end
			
			Track:Stop()
		end
		
		for _, part in grabbedPlayer.Character:GetDescendants() do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.CollisionGroup = "Default"
				part.Massless = part:GetAttribute("Massless")
				part.CanCollide = true
			end
		end
		
		print("[SERVER] Grab successfully released for "..grabbedPlayer.Name)
		GrabHold:FireClient(grabbedPlayer, "End", grabbedPlayer.Character)
	end
end)
