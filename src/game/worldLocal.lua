--[[ world ]] --

local utils = require "src.core.utils"
local consts = require "src.core.consts"
local gc = require "src.game.consts"
local flood = require "src.game.flood"

local G = love.graphics

local World = {x=0, y=0, width=consts.W, height=consts.H}

local S = 6

local t = 0
local nextPlayerMoveDt = 0.05
local nextPlayerMoveT = nextPlayerMoveDt
local nextBleedDt = 0.1
local nextBleedT
local winCapture = 300

local players = {}
players[1] = {
    color = { 1, 0, 0 },
    pos =  { 130, 80 },
    sink = { 130,  4 },
    dPos = { 0, 0 },
    captured = 0,
    bindings = { 'left', 'right', 'up', 'down', 'return' }
}
players[2] = {
    color = { 0, 1, 0 },
    pos = {  30, 80 },
    sink = { 30,  4 },
    dPos = { 0, 0 },
    captured = 0,
    bindings = { 'a', 'd', 'w', 's', 'space' }
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
    local pl = players[pIdx]
    local sink = pl.sink
    flood.carveHole(pl.pos, gc.materials.player[pIdx], o.m)
    o.m[sink[1]][sink[2]] = gc.materials.sink[pIdx]
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

                local ok, isValid = pcall(flood.isHoleValid, player.pos, gc.materials.player[pIdx], self.m)
                if not ok or (ok and not isValid) then
                    player.pos = oldPos
                else
                    flood.carveHole(oldPos,     gc.materials.earth,        self.m)
                    flood.carveHole(player.pos, gc.materials.player[pIdx], self.m)
                end
            end
        end
    end

    if t >= nextBleedT then
        isDirty = true
        flood.bleed(self.m, oilCells)
        updateNextBleedT(self.m)

        for pIdx = 1, #players do
          local pl = players[pIdx]
          local sink = pl.sink
          if self.m[sink[1]][sink[2]] == gc.materials.oil then
            self.m[sink[1]][sink[2]] = gc.materials.sink[pIdx]
            
            -- remove from oil cells so it can be filled again
            local iToRemove
            for i, v in ipairs(oilCells) do
              if v[1] == sink[1] and v[2] == sink[2] then
                iToRemove = i
                break
              end
            end
            table.remove(oilCells, iToRemove)

            pl.captured = pl.captured + 1
            print('player ' .. pIdx .. ' captured ' .. pl.captured .. ' oil')

            if pl.captured >= winCapture then
              print('player ' .. pIdx .. ' won!')
              love.event.quit()
            end
          end
        end
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
          elseif v == gc.materials.sink[1] or v == gc.materials.sink[2] then
            color = { 0.3, 0.3, 0.3 }
            -- color = gc.colors.sky
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

    local isDirty = false
    for pIdx = 1, #players do
        local player = players[pIdx]
        
        for i, k in ipairs(player.bindings) do
            if key == k then
                if i == 5 then
                  local hPos = {
                    player.pos[1] + 2*player.dPosOld[1],
                    player.pos[2] + 2*player.dPosOld[2]
                  }
                  local ok, isValid = pcall(flood.isHoleValid, hPos, 0, self.m)
                  if ok and isValid then
                      isDirty = true
                      flood.carveHole(hPos, gc.materials.dirt, self.m)
                  end
                else
                  player.dPos = gc.pChanges[i]
                end
            end
        end
    end

    if isDirty then
      self:redraw()
    end
end

function World:onKeyUp(key)
    for pIdx = 1, #players do
        local player = players[pIdx]
        for _, k in ipairs(player.bindings) do
            if key == k and (player.dPos[1] ~= 0 or player.dPos[2] ~= 0) then
                player.dPosOld = player.dPos
                player.dPos = { 0, 0 } -- TODO TIH IS WRONG
            end
        end
    end
end

return World