local aux = require "src.test._aux"

local assets = require "src.core.assets"
local consts = require "src.core.consts"
local settings = require "src.core.settings"

local Card = require "src.items.card"
local Checkers = require "src.items.checkers"

local game = require "src.stages.game"

local G = love.graphics

local M = {}

local canvas
local W = consts.W
local H = consts.H
local cx = W / 2
local cy = H / 2

function M:setUp()
  canvas = G.newCanvas(W, H)
  settings.username = "p1"
  assets.load()

  game.load()

  consts.roster = {}
  consts.userData = {}
  consts.userData["p1"] = {color = 1, email = "p1@a.com", rotation = 0}

  for username, ud in pairs(consts.userData) do
    game.obtainAvatar(username, ud.email)
  end

  consts.board:redrawOverlays()
end

function M.run(name)
  aux.drawAndSaveImage(canvas, function()
    game.draw()
  end, "board_menus_" .. name .. ".png")
end

function M.addItem(cls, opts)
  local it = cls:new(opts)
  table.insert(consts.board.items, it)
  consts.board:redraw()
end

function M:testMenuCreate()
  consts.board:onPointer(cx, cy)
  M.run("create")
end

function M:testMenuContextCard()
  M.addItem(Card, {x = cx, y = cy, suit = "d", value = "q"})
  consts.board:onPointer(cx, cy)
  consts.board:onPointerUp(cx, cy)
  M.run("context_card")
end

function M:testMenuContextCheckers()
  M.addItem(Checkers, {x = cx, y = cy, color = "black"})
  consts.board:onPointer(cx, cy)
  consts.board:onPointerUp(cx, cy)
  M.run("context_checkers")
end

return M
