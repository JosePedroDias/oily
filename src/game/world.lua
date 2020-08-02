--[[ world ]] --

local utils = require "src.core.utils"
local consts = require "src.core.consts"

local G = love.graphics

local World = {x=0, y=0, width=consts.W, height=consts.H}

local S = 6

local blueSky = {0.5, 0.9, 0.9}
local earthBg = {0.6, 0.3, 0}
local dirt = {0.9, 0.4, 0}
local oil = {0, 0, 0}
local player = {0, 1, 0}

local EARTH = 1
local DIRT = 2
local SKY = 3
local OIL = 4

local pPos = {80, 80}

local oily = {20, 80}

function World:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.m = utils.matrixCreate(160, 120, DIRT)
  for x = 1, #o.m do
    o.m[x][1] = SKY
    o.m[x][2] = SKY
  end
  -- o.m[1][3] = EARTH

  o.m[oily[1]][oily[2]] = OIL

  o:carvePlayer()
  
  -- print(utils.tableToString(o.m))

  o.canvas = G.newCanvas(o.width, o.height)
  o:redraw()
  return o
end

function World:update(dt)
end

function World:carvePlayer()
    local x = pPos[1]
    local y = pPos[2]
    self.m[x][y] = EARTH
    self.m[x+1][y] = EARTH
    self.m[x][y+1] = EARTH
    self.m[x+1][y+1] = EARTH
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
          if v == EARTH then
            color = earthBg
          elseif v == DIRT then
            color = dirt
          elseif v == OIL then
            color = oil
        elseif v == SKY then
            color = blueSky
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
        pcall(G.setColor, player)
        G.rectangle("fill", X, Y, S*2, S*2)
    

    G.setCanvas()
end

function World:draw()
  G.setColor(1, 1, 1, 1)
  G.draw(self.canvas, self.x, self.y)
end

function World:onKey(key)
    if key == 'left' then
        pPos[1] = pPos[1] - 1
    elseif key == 'right' then
        pPos[1] = pPos[1] + 1
    elseif key == 'up' then
        pPos[2] = pPos[2] - 1
    elseif key == 'down' then
        pPos[2] = pPos[2] + 1
    elseif key == 'escape' then
        love.event.quit()
        return
    end
    self:carvePlayer()
    self:redraw()
end

return World