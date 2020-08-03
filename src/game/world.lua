--[[ world ]] --

local utils = require "src.core.utils"
local consts = require "src.core.consts"
local gc = require "src.game.consts"
local flood = require "src.game.flood"

local G = love.graphics

local World = {x=0, y=0, width=consts.W, height=consts.H}

local S = 6

local t = 0
local nextPlayerMoveDt = 0.1
local nextPlayerMoveT = nextPlayerMoveDt
local nextBleedDt = 0.075
local nextBleedT

local players = {}
players[1] = {
    color = { 1, 0, 0 },
    pos = { 30, 80 },
    dPos = { 0, 0 },
    bindings = { 'left', 'right', 'up', 'down' }
}
players[2] = {
    color = { 0, 1, 0 },
    pos = { 130, 80 },
    dPos = { 0, 0 },
    bindings = { 'a', 'd', 'w', 's' }
}

local oilCells = {}
table.insert(oilCells, {80, 80})



local updateNextBleedT = function(m)
    nextBleedT = nextBleedDt * #flood.frontier(m, oilCells) + t
end

function World:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.m = utils.matrixCreate(160, 120, gc.materials.dirt)
  for x = 1, #o.m do
    for y = 1, 4 do
        o.m[x][y] = gc.materials.sky
    end
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

    local isDirty = false

    if t >= nextPlayerMoveT then
        nextPlayerMoveT = t + nextPlayerMoveDt
        for pIdx = 1, #players do
            local player = players[pIdx]

            if player.dPos[1] ~= 0 or player.dPos[2] ~= 0 then
                isDirty = true

                local oldPos = { player.pos[1], player.pos[2] }

                player.pos[1] = player.pos[1] + player.dPos[1]
                player.pos[2] = player.pos[2] + player.dPos[2]

                local ok, isValid = pcall(flood.isPlayerPosValid, player, pIdx, self.m)
                if not ok or (ok and not isValid) then
                    player.pos = oldPos
                else
                    flood.carvePlayer(oldPos,     gc.materials.earth,        self.m)
                    flood.carvePlayer(player.pos, gc.materials.player[pIdx], self.m)
                end
            end
        end
    end

    if t >= nextBleedT then
        isDirty = true
        flood.bleed(self.m, oilCells)
        updateNextBleedT(self.m)
    end

    if isDirty then
        self:redraw()
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
        for i, k in ipairs(player.bindings) do
            if key == k then
                player.dPos = gc.pChanges[i]
            end
        end
    end
end

function World:onKeyUp(key)
    for pIdx = 1, #players do
        local player = players[pIdx]
        for i, k in ipairs(player.bindings) do
            if key == k then
                player.dPos = { 0, 0 }
            end
        end
    end
end

return World