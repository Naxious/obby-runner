local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Network = require(ReplicatedStorage.Network)

local KNOWN_MAPS = {} :: { [string]: Folder }
local MAP_ALIGNMENT = workspace.MAP_ALIGNMENT :: WedgePart

local loadedMap = nil
local loadingMap = false
local mapWorkspaceFolder = Instance.new("Folder")

local function verifyMap(map: Folder)
	if not map:IsA("Folder") then
		return false
	end

	local alignmentPart = map:FindFirstChild("ALIGNMENT")
	if not alignmentPart then
		warn(`Map "{map.Name}" is missing the ALIGNMENT part.`)
		return false
	elseif not alignmentPart:IsA("BasePart") then
		warn(`Map "{map.Name}" has an invalid ALIGNMENT part.`)
		return false
	end

	return true
end

local function populateKnownMaps()
	for _, map in ServerStorage.Maps:GetChildren() do
		if verifyMap(map) then
			KNOWN_MAPS[map.Name] = map
		end
	end
end

local Mapper = {}

function Mapper:GetCurrentMap()
	return loadedMap
end

function Mapper:UnloadMap()
	if loadedMap then
		loadedMap:Destroy()
		loadedMap = nil
	end
end

function Mapper:LoadMap(mapName: string)
	local knownMap = KNOWN_MAPS[mapName]
	if not knownMap then
		if workspace:FindFirstChild(mapName) then
			warn(`Map "{mapName}" is in workspace, remember to move to ServerStorage/Maps.`)
			knownMap = workspace:FindFirstChild(mapName)
		else
			warn(`Map "{mapName}" is not known.`)
			return
		end
	end

	if loadingMap then
		warn(`Map loading in progress. Please wait.`)
		return
	end
	loadingMap = true

	Mapper:UnloadMap()

	local folderClone = knownMap:Clone()
	local mapModel = Instance.new("Model")
	folderClone.Parent = mapModel

	local alignmentPart = folderClone:FindFirstChild("ALIGNMENT")
	if alignmentPart then
		mapModel.PrimaryPart = alignmentPart
	end

	mapModel:PivotTo(MAP_ALIGNMENT:GetPivot())
	mapModel.Name = `LoadedMap_{mapName}`

	mapModel.Parent = mapWorkspaceFolder
	loadedMap = mapModel

	print(`Map loaded: {mapName}`)
	loadingMap = false
end

function Mapper:Init()
	mapWorkspaceFolder.Name = "MapWorkspace"
	mapWorkspaceFolder.Parent = workspace

	populateKnownMaps()

	Network.mapTest.OnServerEvent:Connect(function(player)
		Mapper:LoadMap("TestMap") -- Replace "MapName" with the desired map name
	end)
end

return Mapper
