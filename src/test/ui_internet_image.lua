local aux = require "src.test._aux"

local fetchRemoteImage = require "src.ui.internet_image"
local G = love.graphics

local M = {}

local canvas
local W = 64
local H = 64

function M:setUp()
  canvas = G.newCanvas(W, H)
end

function M:testInternetImage()
  local i = fetchRemoteImage(
              "https://www.gravatar.com/avatar/ca6f59bfc40276294269bba0aed97029?s=64")

  aux.drawAndSaveImage(canvas, function()
    G.draw(i, 0, 0)
  end, "ui_internet_image.png")
end

return M
