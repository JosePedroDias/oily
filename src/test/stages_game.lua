local aux = require "src.test._aux"

local assets = require "src.core.assets"
local consts = require "src.core.consts"
local settings = require "src.core.settings"

local game = require "src.stages.game"

local G = love.graphics

local M = {}

local canvas
local W = consts.W
local H = consts.H

local PLAYERS = {"p1", "p2", "p3", "p4"}

function M:setUp()
  canvas = G.newCanvas(W, H)
  settings.username = PLAYERS[1]
  assets.load()
end

function M.run(n, gameName)
  game.load()

  consts.roster = {}
  consts.userData[PLAYERS[1]] = {color = 1, email = "p1@a.com", rotation = 0}
  if n > 1 then
    table.insert(consts.roster, PLAYERS[2])
    consts.userData[PLAYERS[2]] = {color = 2, email = "p2@a.com", rotation = 0}
  end
  if n > 2 then
    table.insert(consts.roster, PLAYERS[3])
    consts.userData[PLAYERS[3]] = {color = 4, email = "p3@a.com", rotation = 0}
  end
  if n > 3 then
    table.insert(consts.roster, PLAYERS[4])
    consts.userData[PLAYERS[4]] = {color = 5, email = "p4@a.com", rotation = 0}
  end

  for username, ud in pairs(consts.userData) do
    game.obtainAvatar(username, ud.email)
  end

  local gamesModule = require("src.games." .. gameName)
  gamesModule.setup()

  aux.drawAndSaveImage(canvas, function()
    game.draw()
  end, "game_" .. gameName .. "_" .. tostring(n) .. ".png")
end

function M:testGoFish()
  M.run(2, "go-fish")
  M.run(3, "go-fish")
  M.run(4, "go-fish")
end

function M:testCheckers()
  M.run(2, "checkers")
end

function M:testChess()
  M.run(2, "chess")
end

return M
