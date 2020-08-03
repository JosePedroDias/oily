--[[ world ]] --

local utils = require "src.core.utils"
local consts = require "src.core.consts"
local gc = require "src.game.consts"
local flood = require "src.game.flood"

local G = love.graphics

local World = {x=0, y=0, width=consts.W, height=consts.H}

local S = 6

-- players
local pPos = {80, 80}

local oily = {20, 80}

local oilCells = {}
table.insert(oilCells, oily)

local t = 0
local nextBleedDt = 0.2
local nextBleedT -- = t + nextBleedDt
-- local bleedCells = 1

local updateNextBleedT = function(m)
    nextBleedT = nextBleedDt * #flood.frontier(m, oilCells) + t
end


local function posCanBePlayer(pPos, m)
    local v = m[pPos[1]][pPos[2]]
    return v == gc.materials.earth or v == gc.materials.dirt
end

local function isPlayerPosValid(pPos, m)
    local x = pPos[1]
    local y = pPos[2]
    if not posCanBePlayer(pPos, m) then return false end
    if not posCanBePlayer({x+1, y}, m) then return false end
    if not posCanBePlayer({x, y+1}, m) then return false end
    if not posCanBePlayer({x+1, y+1}, m) then return false end
    return true
end

function World:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.m = utils.matrixCreate(160, 120, gc.materials.dirt)
  for x = 1, #o.m do
    o.m[x][1] = gc.materials.sky
    o.m[x][2] = gc.materials.sky
  end

  o.m[oily[1]][oily[2]] = gc.materials.oil

  flood.carvePlayer(pPos, o.m)

  updateNextBleedT(o.m)

  o.canvas = G.newCanvas(o.width, o.height)
  o:redraw()
  return o
end

function World:update(dt)
    t = t + dt
    if t >= nextBleedT then
        flood.bleed(self.m, oilCells)
        self:redraw()
        -- nextBleedT = t + nextBleedDt
        updateNextBleedT(self.m)
    end
end

function World:redraw()
    G.setCanvas(self.canvas)

    pcall(G.clear, {0, 0, 0, 0})
    --pcall(G.clear, {1, 0, 0, 255})

    local w = #self.m
    local h = #self.m[1]

    -- draw cells
    for x = 1, w do
        for y = 1, h do
          local v = self.m[x][y]
          local color
          if v == gc.materials.earth then
            color = gc.colors.earth
          elseif v == gc.materials.dirt then
            color = gc.colors.dirt
          elseif v == gc.materials.oil then
            color = gc.colors.oil
        elseif v == gc.materials.sky then
            color = gc.colors.sky
          end

          local X = (x-1) * S
          local Y = (y-1) * S
          pcall(G.setColor, color)
          G.rectangle("fill", X, Y, S, S)
        end
      end

      -- draw player
      local X = (pPos[1]-1) * S
      local Y = (pPos[2]-1) * S
        pcall(G.setColor, gc.pColors[1]) -- TODO
        G.rectangle("fill", X, Y, S*2, S*2)
    

    G.setCanvas()
end

function World:draw()
  G.setColor(1, 1, 1, 1)
  G.draw(self.canvas, self.x, self.y)
end

function World:onKey(key)
    local pPosOld = { pPos[1], pPos[2] }

    if key == 'left' then
        pPos[1] = pPos[1] - 1
    elseif key == 'right' then
        pPos[1] = pPos[1] + 1
    elseif key == 'up' then
        pPos[2] = pPos[2] - 1
    elseif key == 'down' then
        pPos[2] = pPos[2] + 1
    elseif key == 'space' then
        flood.bleed(self.m, oilCells)
    elseif key == 'escape' then
        love.event.quit()
        return
    else
        print(key)
    end

    local ok, isValid = pcall(isPlayerPosValid, pPos, self.m)
    if not ok or (ok and not isValid) then
        pPos = pPosOld
    end

    --if not isPlayerPosValid(pPos, self.m) then
    --    pPos = pPosOld
    --end

    flood.carvePlayer(pPos, self.m)

    self:redraw()
end

return World