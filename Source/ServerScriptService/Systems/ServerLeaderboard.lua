local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local PlayerData = require(ServerScriptService.Systems.PlayerData)

type leaderBoard = BasePart & {
	SurfaceGui: SurfaceGui & {
		Frame: Frame & {
			ScrollingFrame: ScrollingFrame & {
				UIListLayout: UIListLayout,
				Template: Frame & {
					Name: Frame & {
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

local playerWins = {}
local leaderboard = {}

local ServerLeaderboard = {}

function ServerLeaderboard:UpdateSigns() end

function ServerLeaderboard:UpdateLeaderboard()
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

	ServerLeaderboard:UpdateSigns()
end

function ServerLeaderboard:Init()
	Players.PlayerAdded:Connect(function(player)
		ServerLeaderboard:UpdateLeaderboard()
	end)
end

return ServerLeaderboard
