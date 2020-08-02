local aux = require "src.test._aux"

local Console = require "src.ui.console"
local G = love.graphics

local M = {}

local canvas
local W = 200
local H = 160

function M:setup()
  canvas = G.newCanvas(W, H)
end

function M:testFirst()
    local c = Console:new({
      x = 0,
      y = 0,
      width = 200,
      height = 160,
      maxLines=2
    })
  
    c:addLine('first')
  
    aux.drawAndSaveImage(canvas, function()
      c:draw()
    end, "ui_console_first.png")
  end

function M:testCycle()
  local c = Console:new({
    x = 0,
    y = 0,
    width = 200,
    height = 160,
    maxLines=2
  })

  c:addLine('first')
  c:addLine('second')
  c:addLine('third')

  aux.drawAndSaveImage(canvas, function()
    c:draw()
  end, "ui_console_cycle.png")
end

function M:testLongLine()
    local c = Console:new({
      x = 0,
      y = 0,
      width = 200,
      height = 160,
      maxLines=2
    })
  
    c:addLine('first')
    --c:addLine('this is a very long line')
    c:addLine('1 2 3 4 5 6 7 8 9 0 1 22 3')
  
    aux.drawAndSaveImage(canvas, function()
      c:draw()
    end, "ui_console_long_line.png")
  end

return M
