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

local oilCells = {}
table.insert(oilCells, oily)

local t = 0
local nextBleedDt = 0.2
local nextBleedT = t + nextBleedDt
local bleedCells = 1



local function neighbors(pos)
    return {
        {pos[1]-1, pos[2]},
        {pos[1]+1, pos[2]},
        {pos[1], pos[2]-1},
        {pos[1], pos[2]+1}
    }
    --[[ return {
        {pos[1]-1, pos[2]-1},
        {pos[1], pos[2]-1},
        {pos[1]+1, pos[2]-1},
        {pos[1]-1, pos[2]},
        {pos[1]+1, pos[2]},
        {pos[1]-1, pos[2]+1},
        {pos[1], pos[2]+1},
        {pos[1]+1, pos[2]+1},
    } ]]
end

local function frontier(cells)
    local candidates = {}
    for _, c in ipairs(cells) do
        local neighs = neighbors(c)
        for _, n in ipairs(neighs) do
            candidates[ tostring(n[1] .. ',' .. n[2]) ] = n
        end
    end

    for _, c in ipairs(cells) do
        candidates[ tostring(c[1] .. ',' .. c[2]) ] = nil
    end

    local res = {}
    for _, c in pairs(candidates) do
        table.insert(res, c)
    end

    return res
end

local function bleed(m, cells)
    local alreadyBled = 0
    local newCells = utils.shuffle( frontier(cells) )
    for _, nc in ipairs(newCells) do
        local ok, v = pcall(function()
            return m[nc[1]][nc[2]]
        end)

        if ok and v == EARTH then
            m[nc[1]][nc[2]] = OIL
            table.insert(cells, nc)
            alreadyBled = alreadyBled + 1
            if alreadyBled >= bleedCells then
                return
            end
        end
    end
end

local function carvePlayer(pPos, m)
    local x = pPos[1]
    local y = pPos[2]
    m[x][y] = EARTH
    m[x+1][y] = EARTH
    m[x][y+1] = EARTH
    m[x+1][y+1] = EARTH
end

local function posCanBePlayer(pPos, m)
    local v = m[pPos[1]][pPos[2]]
    return v == EARTH or v == DIRT
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

  o.m = utils.matrixCreate(160, 120, DIRT)
  for x = 1, #o.m do
    o.m[x][1] = SKY
    o.m[x][2] = SKY
  end

  o.m[oily[1]][oily[2]] = OIL

  carvePlayer(pPos, o.m)

  o.canvas = G.newCanvas(o.width, o.height)
  o:redraw()
  return o
end

function World:update(dt)
    t = t + dt
    if t >= nextBleedT then
        bleed(self.m, oilCells)
        self:redraw()
        nextBleedT = t + nextBleedDt
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
        bleed(self.m, oilCells)
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

    carvePlayer(pPos, self.m)

    self:redraw()
end

return World