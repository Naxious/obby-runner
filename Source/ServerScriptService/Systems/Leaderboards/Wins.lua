local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local PlayerData = require(ServerScriptService.Systems.PlayerData)
local WinsLeader = require(ServerScriptService.Systems.Leaderboards.WinsLeader)

type leaderBoard = BasePart & {
	SurfaceGui: SurfaceGui & {
		Frame: Frame & {
			ScrollingFrame: ScrollingFrame & {
				UIListLayout: UIListLayout,
				Template: Frame & {
					NameFrame: Frame & {
						TextLabel: TextLabel & {
							UICorner: UICorner,
						},
						UICorner: UICorner,
					},
					Score: Frame & {
						TextLabel: TextLabel & {
							UICorner: UICorner,
						},
						UICorner: UICorner,
					},
					Rank: Frame & {
						TextLabel: TextLabel & {
							UICorner: UICorner,
						},
						UICorner: UICorner,
					},
					Avatar: Frame & {
						ImageLabel: ImageLabel & {
							UICorner: UICorner,
						},
						UICorner: UICorner,
					},
				},
			},
		},
	},
}

local playerWins = {} :: { [number]: number }
local leaderboard = {} :: { userId: number, wins: number }

local Wins = {}

function Wins:UpdateSigns()
	local signs = CollectionService:GetTagged("Leaderboard")
	for _, sign: leaderBoard in signs do
		local frame = sign.SurfaceGui.Frame
		local scrollingFrame = frame.ScrollingFrame
		local template = scrollingFrame.Template

		for _, child in scrollingFrame:GetChildren() do
			if child:IsA("Frame") and child.Name ~= "Template" then
				child:Destroy()
			end
		end

		for i, playerData in leaderboard do
			local newEntry = template:Clone()
			newEntry.Name = `Entry_{i}`
			newEntry.Visible = true
			newEntry.NameFrame.TextLabel.Text = Players:GetNameFromUserIdAsync(playerData.userId)
			newEntry.Score.TextLabel.Text = tostring(playerData.wins)
			newEntry.Rank.TextLabel.Text = tostring(i)

			newEntry.Avatar.ImageLabel.Image = `rbxthumb://type=AvatarHeadShot&id={playerData.userId}&w=420&h=420`

			newEntry.Parent = scrollingFrame

			newEntry.LayoutOrder = i
		end
	end
end

function Wins:UpdateLeaderboard()
	playerWins = {}
	for _, player in Players:GetPlayers() do
		local profile = PlayerData:GetProfile(player)
		if profile then
			playerWins[player.UserId] = profile.Data.Game.totalWins
		end
	end

	leaderboard = {}
	for userId, wins in playerWins do
		table.insert(leaderboard, {
			userId = userId,
			wins = wins,
		})
	end

	table.sort(leaderboard, function(a, b)
		return a.wins > b.wins
	end)

	Wins:UpdateSigns()
	WinsLeader:Update(leaderboard)
end

function Wins:Init()
	Players.PlayerAdded:Connect(function(player)
		Wins:UpdateLeaderboard()
	end)

	task.spawn(function()
		while true do
			Wins:UpdateLeaderboard()
			task.wait(60)
		end
	end)

	WinsLeader:Init()
end

return Wins
