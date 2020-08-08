local generateServer = require("EnetServer")

local flood = require "src.game.flood"
local gc = require "src.game.consts"
local utils = require "src.core.utils"

local srv = {}

----

local initialPositions = {
    {  30, 80 },
    { 130, 80 }
}

local initialSinks = {
    {  30, 4 },
    { 130, 4 }
}

local players

local clientIdToPlayerIdx

local nextPlayerMoveDt = 0.05
local nextPlayerMoveT = nextPlayerMoveDt
local nextBleedDt = 0.025
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
    print('new game!')
    srv.broadcast('ng')

    srv.setTime(0)

    players = {}

    local numClients = srv.getNumClients()

    for pIdx = 1, numClients do
        local pl = {
            pos = utils.tableShallowClone( initialPositions[pIdx] ),
            sink = utils.tableShallowClone( initialSinks[pIdx] ),
            dPos = { 0, 0 },
            captured = 0,
            digging = false,
            holesLeft = 50
        }
        table.insert(players, pl)

        srv.broadcast('ca ' .. pIdx .. ',' .. pl.captured)
    end

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
                    local leftMat = gc.materials.dirt
                    if player.digging then
                        leftMat = gc.materials.earth
                    end
                    flood.carveHole(oldPos,     leftMat,                   mm)
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
            srv.broadcast('ca ' .. pIdx .. ',' .. pl.captured)

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

local function updateClientIdToPlayerIdx()
    local clients = srv.getClients()
    clientIdToPlayerIdx = {}
    local i = 1
    for clientId, _ in pairs(clients) do
        clientIdToPlayerIdx[clientId] = i
        print(clientId .. ' ~> ' .. i)
        i = i + 1
    end
end

generateServer({
  api = srv,
  port = 52225,
  fps = 60,
  --debug = true,
  onUpdate = function(t)
    if nextBleedT then
        update(t)
    end
  end,
  onNewClient = function(clientId, t)
    local numClients = srv.getNumClients()
    print('#clients '.. numClients)
    updateClientIdToPlayerIdx()
    --if numClients == 1 then
        newGame()
    --end
  end,
  onClientLeft = function(clientId, t)
    local numClients = srv.getNumClients()
    print('#clients '.. numClients)
    updateClientIdToPlayerIdx()
    newGame()
  end,
  onReceive = function(data, clientId, t)
    print('received [' .. data .. '] from ' .. clientId)

    -- which player sent this?
    local pIdx = clientIdToPlayerIdx[clientId]
    local player = players[pIdx]

    local cmd = data:sub(1, 2)
    local key = data:sub(4)

    if cmd == 'kd' then
        if key == 'space' then
            player.digging = not player.digging
            print('digging: ' .. (player.digging and 'Y' or 'N'))
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
  end,
  onEnd = function()
      print('leaving...')
  end
})

