--[[ abstracts real resolution, electing working one
take a look at main.lua to check how this is set up ]] --
-- https://github.com/JosePedroDias/7min/blob/master/src/screen.moon
-- https://github.com/Ulydev/push

local consts = require "src.core.consts"

local G = love.graphics
local W = love.window

local M = {}

local scale, x, y, canvas

M.getCurrentResolution = function()
  local sW, sH, scl
  sW, sH = W.getMode()
  scl = W.getDPIScale() or 1
  return sW / scl, sH / scl
end

M.getLowestResolution = function()
  local wi = 100000
  local hi = 100000
  local area = 100000 * 100000
  local modes = W.getFullscreenModes()
  for _, m in pairs(modes) do
    local areaT = m.width * m.height
    if areaT < area then
      wi = m.width
      hi = m.height
      area = areaT
    end
  end
  return wi, hi
end

M.getHighestResolution = function()
  local wi = 0
  local hi = 0
  local area = 0
  local modes = W.getFullscreenModes()
  for _, m in pairs(modes) do
    local areaT = m.width * m.height
    if areaT > area then
      wi = m.width
      hi = m.height
      area = areaT
    end
  end
  return wi, hi
end

M.setSize = function(WW, H, w, h, fullscreen)
  local AR = WW / H
  local ar = w / h

  if AR > ar then
    scale = H / h
    y = 0
    x = (WW - w * scale) / 2
  else
    scale = WW / w
    x = 0
    y = (H - h * scale) / 2
  end

  W.setMode(WW, H, {fullscreen = fullscreen, highdpi = true})

  canvas = G.newCanvas(w, h)
  -- G.setBlendMode("alpha", "alphamultiply") -- premultiplied alphamultiply
  -- canvas.setFilter('nearest')
  G.setDefaultFilter("nearest", "nearest") -- min mag (linear / nearest) ani
end

M.startDraw = function()
  G.setCanvas(canvas)
  G.clear(0, 0, 0, 0)
  -- G.setColor(1, 1, 1, 1)
end

M.endDraw = function()
  G.setCanvas()
  G.draw(canvas, x, y, 0, scale, scale)
end

M.coords = function(_x, _y)
  return (_x - x) / scale, (_y - y) / scale
end

-- M.initialW
-- M.initialH

M.setFullscreenState = function(bool)
  if not M.initialW then
    M.initialW, M.initialH = M.getCurrentResolution()
  end

  if not bool then
    local WW = 1024 -- TODO: game logic, should not be here...
    M.setSize(WW, WW * 0.75, consts.W, consts.H, false)
  else
    -- local sW, sH = M.getCurrentResolution()
    M.setSize(M.initialW, M.initialH, consts.W, consts.H, true)
  end
end

return M
