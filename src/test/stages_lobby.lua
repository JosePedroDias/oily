local aux = require "src.test._aux"

local consts = require "src.core.consts"

local lobby = require "src.stages.lobby"

local G = love.graphics

local M = {}

local canvas
local W = consts.W
local H = consts.H

function M:setUp()
  canvas = G.newCanvas(W, H)
end

function M:test()
  lobby.load()

  aux.drawAndSaveImage(canvas, function()
    lobby.draw()
  end, "stages_lobby.png")
end

return M
