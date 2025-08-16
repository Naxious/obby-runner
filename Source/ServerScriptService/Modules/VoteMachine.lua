local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerObservers = require(ServerScriptService.ServerObservers)
local AreaService = require(ServerScriptService.Systems.AreaService)
local Maps = require(ReplicatedStorage.Data.Maps)

type voteGui = SurfaceGui & {
	Frame: Frame & {
		Frame: Frame & {
			MapName: TextLabel,
			VoteCount: TextLabel,
		},
		ImageLabel: ImageLabel,
	},
}

type voteMachine = Model & {
	["1"]: BasePart & {
		SurfaceGui: voteGui,
	},
	["2"]: BasePart & {
		SurfaceGui: voteGui,
	},
	["3"]: BasePart & {
		SurfaceGui: voteGui,
	},
}

local voteMachines = CollectionService:GetTagged("VoteMachine")
local voteMachine = voteMachines[1] :: voteMachine
local voteConnections = {} :: { [number]: RBXScriptConnection }
local votes = {
	[1] = 0,
	[2] = 0,
	[3] = 0,
}
local selectedMaps = {}

local voted = {} :: { [Player]: number }

local VoteMachine = {}

function VoteMachine:StopVote(): string
	for i = 1, #voteConnections do
		voteConnections[i]:Disconnect()
	end
	voteConnections = {}

	local highestVote = 0
	for i = 1, #votes do
		if votes[i] > highestVote then
			highestVote = votes[i]
		end
	end

	local tiedIndexes = {}
	for i = 1, #votes do
		if votes[i] == highestVote then
			table.insert(tiedIndexes, i)
		end
	end

	local winningIndex = tiedIndexes[math.random(1, #tiedIndexes)]
	return selectedMaps[winningIndex]
end

function VoteMachine:UpdateVotes(clear: boolean?)
	for i = 1, #votes do
		local screen: voteGui = voteMachine[i].SurfaceGui
		if clear then
			screen.Frame.Frame.VoteCount.Text = "Votes: 0"
		else
			screen.Frame.Frame.VoteCount.Text = "Votes: " .. votes[i]
		end
	end
end

function VoteMachine:UpdateMaps(maps: { string }, clear: boolean?)
	for i = 1, #votes do
		local screen: voteGui = voteMachine[i].SurfaceGui
		if clear then
			screen.Frame.Frame.MapName.Text = "Awaiting Next Vote"
			screen.Frame.ImageLabel.Image = "rbxassetid://10653378249"
		else
			local mapImage = Maps[maps[i]].Image
			local mapName = Maps[maps[i]].Name
			print("Updating map " .. i .. ": " .. mapName, mapImage)
			screen.Frame.Frame.MapName.Text = mapName
			screen.Frame.ImageLabel.Image = mapImage
		end
	end
end

function VoteMachine:ShowMaps()
	local mapNames = {}
	for i, map in Maps do
		table.insert(mapNames, map.Name)
	end

	local shuffledMaps = {}
	for i, mapName in mapNames do
		local randomIndex = math.random(1, #shuffledMaps + 1)
		table.insert(shuffledMaps, randomIndex, mapName)
	end

	selectedMaps = {}
	for i = 1, #votes do
		table.insert(selectedMaps, shuffledMaps[i])
	end

	VoteMachine:UpdateMaps(selectedMaps)
end

function VoteMachine:ResetVoteMachine()
	for i = 1, #voteConnections do
		voteConnections[i]:Disconnect()
	end
	voteConnections = {}

	for i = 1, #votes do
		votes[i] = 0
	end
	voted = {}
	VoteMachine:UpdateVotes(true)
	VoteMachine:UpdateMaps({}, true)
end

function VoteMachine:StartVote()
	VoteMachine:ResetVoteMachine()
	VoteMachine:ShowMaps()

	local voteConnection = ServerObservers.enteredArea:Connect(function(player: Player, area: string)
		if area == "Vote_1" then
			VoteMachine:CastVote(player, 1)
		elseif area == "Vote_2" then
			VoteMachine:CastVote(player, 2)
		elseif area == "Vote_3" then
			VoteMachine:CastVote(player, 3)
		end
	end)
	table.insert(voteConnections, voteConnection)

	for i = 1, #votes do
		local playersInArea = AreaService:GetPlayersInArea("Vote_" .. i)
		for _, player in playersInArea do
			VoteMachine:CastVote(player, i)
		end
	end
end

function VoteMachine:CastVote(player: Player, vote: number)
	if not player or not vote or vote < 1 or vote > #votes then
		return
	end

	if not votes[vote] then
		return
	end

	if voted[player] then
		votes[voted[player]] -= 1
	end

	votes[vote] += 1
	voted[player] = vote

	VoteMachine:UpdateVotes()
end

function VoteMachine:Init()
	if not voteMachine then
		error("No vote machine found")
	end

	VoteMachine:ResetVoteMachine()
end

return VoteMachine
