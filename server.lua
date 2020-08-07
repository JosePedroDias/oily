local generateServer = require("EnetServer")

local flood = require "src.game.flood"
local gc = require "src.game.consts"
local utils = require "src.core.utils"

local srv = {}

----

local players = {}
players[1] = {
    pos =  { 130, 80 },
    sink = { 130,  4 },
    dPos = { 0, 0 },
    captured = 0
}
players[2] = {
    pos = {  30, 80 },
    sink = { 30,  4 },
    dPos = { 0, 0 },
    captured = 0
}

local clientIdToPlayerIdx = {}

local nextPlayerMoveDt = 0.05
local nextPlayerMoveT = nextPlayerMoveDt
local nextBleedDt = 0.1
local nextBleedT
local winCapture = 300

local oilCells
local m

local mm = {
    s = function(x, y, v)
        m[x][y] = v
        srv.broadcast('sm ' .. x .. ',' .. y .. ',' .. v)
    end,
    g = function (x, y)
        return m[x][y]
    end
}

local T = 0

local updateNextBleedT = function()
    nextBleedT = nextBleedDt * #flood.frontier(mm, oilCells) + T
end

local function newGame()
    oilCells = {}
    table.insert(oilCells, {80, 80})

    m = utils.matrixCreate(160, 120, gc.materials.dirt)

    for x = 1, #m do
        for y = 1, 4 do
            mm.s(x, y, gc.materials.sky)
        end
    end

    for _, c in ipairs(oilCells) do
        mm.s(c[1], c[2], gc.materials.oil)
    end

    for pIdx = 1, #players do
        local pl = players[pIdx]
        local sink = pl.sink
        flood.carveHole(pl.pos, gc.materials.player[pIdx], mm)
        mm.s(sink[1], sink[2], gc.materials.sink[pIdx])
    end

    updateNextBleedT()
end

local function update(t)
    T = t

    if t >= nextPlayerMoveT then
        nextPlayerMoveT = t + nextPlayerMoveDt
        for pIdx = 1, #players do
            local player = players[pIdx]

            if player.dPos[1] ~= 0 or player.dPos[2] ~= 0 then
                local oldPos = { player.pos[1], player.pos[2] }

                player.pos[1] = player.pos[1] + player.dPos[1]
                player.pos[2] = player.pos[2] + player.dPos[2]

                local ok, isValid = pcall(flood.isHoleValid, player.pos, gc.materials.player[pIdx], mm)
                if not ok or (ok and not isValid) then
                    player.pos = oldPos
                else
                    flood.carveHole(oldPos,     gc.materials.earth,        mm)
                    flood.carveHole(player.pos, gc.materials.player[pIdx], mm)
                end
            end
        end
    end

    if t >= nextBleedT then
        flood.bleed(mm, oilCells)
        updateNextBleedT()

        for pIdx = 1, #players do
          local pl = players[pIdx]
          local sink = pl.sink
          if m[sink[1]][sink[2]] == gc.materials.oil then
            mm.s(sink[1], sink[2], gc.materials.sink[pIdx])
            
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
            --print('player ' .. pIdx .. ' captured ' .. pl.captured .. ' oil')
            srv.broadcast('ca ' .. pIdx ',' .. pl.captured)

            if pl.captured >= winCapture then
              --print('player ' .. pIdx .. ' won!')
              srv.broadcast('wo ' .. pIdx)
              --love.event.quit()
            end
          end
        end
    end
end

----

generateServer({
  api = srv,
  port = 52225,
  fps = 60,
  -- debug = true,
  onUpdate = function(t)
    if nextBleedT then
        update(t)
    end
  end,
  onNewClient = function(clientId, t)
    table.insert(clientIdToPlayerIdx, clientId)
    -- print('#clients '.. #clientIdToPlayerIdx)
    if #clientIdToPlayerIdx == 2 then
        newGame()
    end
  end,
  onReceive = function(data, clientId, t)
    local pIdx = 2 -- TODO 
    if clientId == clientIdToPlayerIdx[1] then
        pIdx = 1
    end
    local player = players[pIdx]

    local cmd = data:sub(1, 2)
    local key = data:sub(4)

    if cmd == 'kd' then
        if key == 'return' then
            local hPos = {
              player.pos[1] + 2*player.dPosOld[1],
              player.pos[2] + 2*player.dPosOld[2]
            }
            local ok, isValid = pcall(flood.isHoleValid, hPos, 0, mm)
            if ok and isValid then
                flood.carveHole(hPos, gc.materials.dirt, mm)
            end
        elseif key == 'left' then
            player.dPos[1] = -1
        elseif key == 'right' then
            player.dPos[1] = 1
        elseif key == 'up' then
            player.dPos[2] = -1
        elseif key == 'down' then
            player.dPos[2] = 1
        end
    elseif cmd == 'ku' then
        if key == 'up' or key == 'down' then
            player.dPosOld = {player.dPos[1], player.dPos[2]}
            player.dPos[2] = 0
        elseif key == 'left' or key == 'right' then
            player.dPosOld = {player.dPos[1], player.dPos[2]}
            player.dPos[1] = 0
        end
    else
        print(data)
    end
  end
})

