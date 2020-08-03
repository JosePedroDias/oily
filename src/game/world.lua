--[[ world ]] --

local utils = require "src.core.utils"
local consts = require "src.core.consts"
local gc = require "src.game.consts"
local flood = require "src.game.flood"

local G = love.graphics

local World = {x=0, y=0, width=consts.W, height=consts.H}

local S = 6

local players = {}
players[1] = {
    color = { 1, 0, 0 },
    pos = { 80, 80 },
    bindings = { 'left', 'right', 'up', 'down' }
}
players[2] = {
    color = { 0, 1, 0 },
    pos = { 20, 80 },
    bindings = { 'a', 'd', 'w', 's' }
}

local oilCells = {}
table.insert(oilCells, {50, 80})

local t = 0
local nextBleedDt = 0.1
local nextBleedT

local updateNextBleedT = function(m)
    nextBleedT = nextBleedDt * #flood.frontier(m, oilCells) + t
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

  for _, c in ipairs(oilCells) do
    o.m[c[1]][c[2]] = gc.materials.oil
  end

  for pIdx = 1, #players do
    flood.carvePlayer(players[pIdx].pos, gc.materials.player[pIdx], o.m)
  end
  
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
          elseif v == gc.materials.player[1] then
            color = players[1].color
          elseif v == gc.materials.player[2] then
            color = players[2].color
          end

          local X = (x-1) * S
          local Y = (y-1) * S
          pcall(G.setColor, color)
          G.rectangle("fill", X, Y, S, S)
        end
      end

    G.setCanvas()
end

function World:draw()
  G.setColor(1, 1, 1, 1)
  G.draw(self.canvas, self.x, self.y)
end

function World:onKey(key)
    if key == 'escape' then
        love.event.quit()
        return
    end

    for pIdx = 1, #players do
        local player = players[pIdx]
        local dPos = {0, 0}
        for i, k in ipairs(player.bindings) do
            if key == k then
                dPos = gc.pChanges[i]
            end
        end

        if dPos[1] ~= 0 or dPos[2] ~= 0 then
            local oldPos = { player.pos[1], player.pos[2] }

            player.pos[1] = player.pos[1] + dPos[1]
            player.pos[2] = player.pos[2] + dPos[2]

            local ok, isValid = pcall(flood.isPlayerPosValid, player, pIdx, self.m)
            if not ok or (ok and not isValid) then
                player.pos = oldPos
            else
                flood.carvePlayer(oldPos,     gc.materials.earth,        self.m)
                flood.carvePlayer(player.pos, gc.materials.player[pIdx], self.m)
            end
        end
    end

    self:redraw()
end

return World