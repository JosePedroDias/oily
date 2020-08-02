local aux = require "src.test._aux"

local ArcMenu = require "src.ui.arcmenu"
local G = love.graphics

local M = {}

local canvas
local W = 320
local H = 320

function M:setup()
  canvas = G.newCanvas(W, H)
end

function M:test3WCancel()
  local i = ArcMenu:new({
    x = 160,
    y = 160,
    dismissableFirst = true,
    labels = {"one", "two", "three"}
  })

  aux.drawAndSaveImage(canvas, function()
    i:draw()
  end, "ui_arcmenu_3_w_cancel.png")
end

function M:test3WoCancel()
  local i = ArcMenu:new({
    x = 160,
    y = 160,
    dismissableFirst = false,
    labels = {"one", "two", "three"}
  })

  aux.drawAndSaveImage(canvas, function()
    i:draw()
  end, "ui_arcmenu_3_wo_cancel.png")
end

function M:test12WoCancel()
  local i = ArcMenu:new({
    x = 160,
    y = 160,
    dismissableFirst = false,
    labels = {
      "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
      "ten", "eleven", "twelve"
    }
  })

  aux.drawAndSaveImage(canvas, function()
    i:draw()
  end, "ui_arcmenu_12_wo_cancel.png")
end

return M
