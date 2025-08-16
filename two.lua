local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")


local CAMERA_SHAKE_STRENGTH = 1
local ZOOM_FOV = 60
local DEFAULT_FOV = 70
local FOV_TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
local BAR_FILL_TWEEN_INFO = TweenInfo.new(1.5, Enum.EasingStyle.Linear)

local localPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local BarTemplate = script:WaitForChild("Bar")
local GrabHoldEvent = ReplicatedStorage.Remotes:WaitForChild("GrabHold")
local GrabHold = ReplicatedStorage.BindableEvents:WaitForChild("Grabhold")
local VampireAbilityEvent = ReplicatedStorage.VampireSystem.VampireAbility

local cameraShakeConnection
local elapsedTime = 0
local activeBar
local barFillTween

local function getCharacterTorso(character)
	if not character then return nil end
	return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
end

local function cleanupEffects()
	if cameraShakeConnection then
		cameraShakeConnection:Disconnect()
		cameraShakeConnection = nil
	end

	if barFillTween then
		barFillTween:Cancel()
		barFillTween = nil
	end

	if activeBar then
		activeBar:Destroy()
		activeBar = nil
	end
end



GrabHoldEvent.OnClientEvent:Connect(function(eventType, enemyCharacter)
	if eventType == "Start" then

		-- Only show for the grabbed player
		if localPlayer.Character ~= enemyCharacter then 
			return 
		end

		cleanupEffects()

		localPlayer.PlayerGui.Escape.Enabled = true

		local torso = getCharacterTorso(enemyCharacter)
		if not torso then return end

		local TargetPlayerGUI = localPlayer:FindFirstChild("PlayerGui")
		if not TargetPlayerGUI then return end

		local ChokeScreen = TargetPlayerGUI:FindFirstChild("ChokeScreen")
		if not ChokeScreen then return end

		local BlackScreenProgress = 0
		local BlackScreen = ChokeScreen:FindFirstChild("MainFrame")

		if not BlackScreen then return end
		local escapeAttempts = 0
		local escapeTarget = math.random(5, 11)
		local escapeSuccess = false

		local function onEscapeInput()
			if escapeSuccess then return end
			escapeSuccess = true
		end

		localPlayer.Character:SetAttribute("Grabbing", enemyCharacter.Name)

		if UserInputService.TouchEnabled then
			ChokeScreen.PHONE_Prompt.Visible = true
			ChokeScreen.PC_Prompt.Visible = false
			ChokeScreen.PHONE_Prompt.MouseButton1Click:Connect(onEscapeInput)

		else
			ChokeScreen.PHONE_Prompt.Visible = false
			ChokeScreen.PC_Prompt.Visible = true
			
			local escapeConnection
			escapeConnection = UserInputService.InputBegan:Connect(function(input, isTyping)
				if isTyping then return end
				if input.KeyCode == Enum.KeyCode.E then
					escapeAttempts += 1

					local shakeOffset = Vector3.new(
						math.random(1, 5),
						math.random(1, 5),
						math.random(1, 5) * CAMERA_SHAKE_STRENGTH)

					Camera.CFrame = Camera.CFrame * CFrame.new(shakeOffset)
					print("[CLIENT] E pressed: "..escapeAttempts.."/"..escapeTarget)

					if escapeAttempts >= escapeTarget then
						escapeConnection:Disconnect()
						print("[CLIENT] Escape success, firing Release")

						VampireAbilityEvent:FireServer("Release", localPlayer.Character)
						escapeSuccess = true
						escapeAttempts = 0

						BlackScreen.Transparency = 1
					end
				end
			end)
		end

		elapsedTime = 0
		activeBar = BarTemplate:Clone()
		activeBar.Amount.Size = UDim2.new(0, 0, 1, 0)
		activeBar.Parent = torso

		barFillTween = TweenService:Create(activeBar.Amount, BAR_FILL_TWEEN_INFO, {Size = UDim2.new(1, 0, 1, 0)})
		barFillTween:Play()
		TweenService:Create(Camera, FOV_TWEEN_INFO, {FieldOfView = ZOOM_FOV}):Play()

		cameraShakeConnection = RunService.RenderStepped:Connect(function(deltaTime)
			elapsedTime += deltaTime
		end)

		while BlackScreenProgress < 1 do
			if escapeSuccess then
				BlackScreen.Transparency = 1
				break
			end

			BlackScreenProgress += 0.01
			BlackScreen.Transparency = BlackScreenProgress
			task.wait(0.035)
		end

	elseif eventType == "End" then
		localPlayer.PlayerGui.Escape.Enabled = false
		cleanupEffects()
		TweenService:Create(Camera, FOV_TWEEN_INFO, {FieldOfView = DEFAULT_FOV}):Play()
	end

end)


local function escape()
	Players.LocalPlayer.PlayerGui.Escape.Enabled = false
	cleanupEffects()
	TweenService:Create(Camera, FOV_TWEEN_INFO, {FieldOfView = DEFAULT_FOV}):Play()
end

GrabHold.OnInvoke = function()
	escape()
end
