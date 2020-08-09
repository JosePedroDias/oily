-- [[ title screen ]] --
-- local Client = require "src.game.client"
local utils = require "src.core.utils"
local assets = require "src.core.assets"
-- local consts = require "src.core.consts"
local gc = require "src.game.consts"
local M = {}

local G = love.graphics

local colorMap = {
    {gc.colors.sky, gc.materials.sky},
    {gc.colors.earth, gc.materials.earth},
    {gc.colors.dirt, gc.materials.dirt},
    {gc.colors.oil, gc.materials.oil}
}

local function colorToMaterial(r, g, b)
    local bestDist = 3
    local bestMat
    for _, pair in ipairs(colorMap) do
        local clr = pair[1]
        local dist = math.abs(clr[1] - r) + math.abs(clr[2] - g) + math.abs(clr[2] - b)
        if dist < bestDist then
            bestDist = dist
            bestMat = pair[2]
        end
    end
    -- print(r, g, b, bestMat, bestDist)
    return bestMat
end

M.load = function()

  M.titleGfx = assets.gfx.title
  M.titleGfx:setFilter("nearest", "nearest")

  local m = utils.matrixCreate(gc.W, gc.H, gc.materials.dirt)

  M.titleGfxID = assets.gfxID.title
  for x = 1, gc.W do
    for y = 1, gc.H do
        local r, g, b = M.titleGfxID:getPixel(x-1, y-1)
        local mat = colorToMaterial(r, g, b)
        m[x][y] = mat
        --print(x, y, mat)
    end
  end
  love.filesystem.write('title.lua', utils.serialize(m))
  --love.filesystem.write('title.lua', utils.serialize({a=2, b=true, c={3,true,'a'}}))

end

M.unload = function()
end

M.update = function(dt)
end

M.draw = function()
  -- M.w:draw()
  G.setColor(1, 1, 1, 1)
  G.draw(M.titleGfx, 1, 1, 0, gc.S, gc.S)
end

M.onKey = function(key)
  if key == "escape" then love.event.quit() end
end

M.onKeyUp = function(key)
end

return M
