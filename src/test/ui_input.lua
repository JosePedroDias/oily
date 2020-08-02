local aux = require "src.test._aux"

local Input = require "src.ui.input"
local G = love.graphics

local M = {}

local canvas
local W = 200
local H = 40

function M:setup()
  canvas = G.newCanvas(W, H)
end

function M:testUnfocused()
  local i = Input:new({
    x = 0,
    y = 0,
    width = 200,
    height = 40,
    value = "starting"
  })

  aux.drawAndSaveImage(canvas, function()
    i:draw()
  end, "ui_input_unfocused.png")
end

function M:testFocused()
  local i = Input:new({
    x = 0,
    y = 0,
    width = 200,
    height = 40,
    focused = true,
    value = "starting"
  })

  aux.drawAndSaveImage(canvas, function()
    i:draw()
  end, "ui_input_focused.png")
end

function M:testLongValue()
  local i = Input:new({
    x = 10, -- to check if it clips
    y = 0,
    width = 180,
    height = 40,
    focused = true,
    value = "this is a very long string"
  })

  aux.drawAndSaveImage(canvas, function()
    i:draw()
  end, "ui_input_long_value.png")
end

return M
