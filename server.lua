local generateServer = require("EnetServer")

local flood = require "src.game.flood"
local gc = require "src.game.consts"
local raster = require "src.game.raster"
local utils = require "src.core.utils"
local consts = require "src.core.consts"

math.randomseed(os.time())

-- local lovebird = require("lovebird")
-- lovebird.init()

local srv = {}

----

local cx = math.ceil(gc.W / 2)
local dx = 70
local skyY = 10
local initialPositions = {
    { cx-dx, 80 },
    { cx+dx, 80 }
}

local sinks = {
    { {cx-dx, skyY} },
    { {cx+dx, skyY} }
}

local players

local clientIdToPlayerIdx

local nextPlayerMoveDt = 0.04
local nextPlayerMoveT = nextPlayerMoveDt
local nextBleedDt = 0.2
local nextBleedT
local winCapture = 300
local bleedSpeedFactor
local gameGoingOn

local oilCells
local m

local mm = {
    s = function(x, y, v)
        if m[x][y] == v then return end
        m[x][y] = v
        srv.broadcast('sm ' .. x .. ',' .. y .. ',' .. v)
    end,
    srect = function(x, y, w, h, v)
        for xi = x, w - x + 1 do
            for yi = y, h - y + 1 do
                m[xi][yi] = v
            end
        end
        srv.broadcast('sr ' .. x .. ',' .. y .. ',' .. w .. ',' .. h .. ',' .. v)
    end,
    g = function (x, y)
        local col = m[x]
        return col and col[y]
    end
}

local T = 0

local updateNextBleedT = function(bleedCount)
    if bleedCount > 0 then
        nextBleedDt = math.max(nextBleedDt * bleedSpeedFactor, 0.01)
    end

    local n = math.max(#flood.frontier(mm, oilCells), 1)
    nextBleedT = T + (nextBleedDt * n)

    -- print('nextBleedT:' .. nextBleedT .. ' speed:' .. nextBleedDt .. ' bleedCount:' ..bleedCount)
end

local function newGame()
    print('new game!')
    srv.broadcast('ng')

    gameGoingOn = true
    bleedSpeedFactor = 0.98
    T = 0
    srv.setTime(T)

    local numClients = srv.getNumClients()

    -- matrix
    m = utils.matrixCreate(gc.W, gc.H, gc.materials.dirt)

    mm.srect(1, 1, gc.W, skyY, gc.materials.sky)

    -- terrain
    --raster.line(60, 60, 80, 80, mm, gc.materials.earth)

    -- caves with perlin noise
    local ns = 0.05
    for x = 1, gc.W do
        for y = skyY+1, gc.H do
            local v = raster.noise(x*ns, y*ns, 0)
            if v > 0.1 then
                mm.s(x, y, gc.materials.earth)
            end
        end
    end

    -- rocks
    for _ = 1, 3 do
        local r = math.floor( math.random() * 15 ) + 5
        local x = math.ceil( math.random() * (gc.W - r*2) ) + r
        local y = math.ceil( math.random() * (gc.H - skyY - r*2) ) + skyY + r
        raster.filledCircle(x, y, r, mm, gc.materials.rock)
    end

    -- oil
    oilCells = {}
    for _ = 1, 2 do
        while true do
            local x = math.ceil( math.random() * (gc.W) )
            local y = math.ceil( math.random() * (gc.H - skyY-1) ) + skyY + 1
            if mm.g(x, y) == gc.materials.dirt then
                table.insert(oilCells, {x, y})
                break
            end
        end
    end

    for _, c in ipairs(oilCells) do
        mm.s(c[1], c[2], gc.materials.oil)
    end

    -- sinks
    for pIdx = 1, numClients do
        for _, si in ipairs(sinks[pIdx]) do
            mm.s(si[1], si[2], gc.materials.sink[pIdx])
        end
    end

    -- players
    players = {}
    for pIdx = 1, numClients do
        local pos = initialPositions[pIdx]
        local pl = {
            pos = { pos[1], pos[2] },
            dPos = { 0, 0 },
            captured = 0,
            digging = false,
            holesLeft = 400
        }
        table.insert(players, pl)

        srv.broadcast('ca ' .. pIdx .. ',' .. pl.captured)
        srv.broadcast('hl ' .. pIdx .. ',' .. pl.holesLeft)
        srv.broadcast('di ' .. pIdx .. ',f')
    end

    for pIdx = 1, numClients do
        local pl = players[pIdx]
        flood.carveHole(pl.pos, gc.materials.player[pIdx], mm)
    end

    --[[ Z = {}
    Z.players = players
    Z.oilCells = oilCells
    Z.m = m ]]

    -- set oil velocity
    updateNextBleedT(0)
end

local function update(t)
    -- lovebird.update()

    T = t

    if not gameGoingOn then
        return
    end

    if t >= nextPlayerMoveT then
        nextPlayerMoveT = t + nextPlayerMoveDt
        for pIdx = 1, #players do
            local player = players[pIdx]

            if player then
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

                        local deltaDirt = 0
                        local aux = gc.ahead[ player.dPos[1] .. ',' .. player.dPos[2] ]
                        for _, p in ipairs(aux) do
                            local x = player.pos[1] + p[1]
                            local y = player.pos[2] + p[2]
                            local v = mm.g(x, y)
                            if player.digging and v == gc.materials.dirt then
                                deltaDirt = deltaDirt - 1
                            elseif not player.digging and v == gc.materials.earth then
                                deltaDirt = deltaDirt + 1
                            end
                        end

                        local skipCarve = false
                        local holesLeft = player.holesLeft + deltaDirt
                        if holesLeft < 0 then
                            player.pos = oldPos
                            player.digging = false
                            srv.broadcast('di ' .. pIdx .. ',f')
                            skipCarve = true
                        elseif deltaDirt == 0 then
                        else
                            player.holesLeft = holesLeft
                            srv.broadcast('hl ' .. pIdx .. ',' .. player.holesLeft)
                        end

                        if not skipCarve then
                            flood.carveHole(oldPos,     leftMat,                   mm)
                            flood.carveHole(player.pos, gc.materials.player[pIdx], mm)
                        end
                    end
                end
            else
                print('player not found in update')
            end
        end
    end

    if t >= nextBleedT then
        local bleedCount = flood.bleed(mm, oilCells)
        updateNextBleedT(bleedCount)

        -- handle sinks
        for pIdx = 1, #players do
          local pl = players[pIdx]

          if pl then
            for _, si in ipairs(sinks[pIdx]) do
                if m[si[1]][si[2]] == gc.materials.oil then
                    mm.s(si[1], si[2], gc.materials.sink[pIdx])
                    
                    -- remove from oil cells so it can be filled again
                    local iToRemove
                    for i, v in ipairs(oilCells) do
                    if v[1] == si[1] and v[2] == si[2] then
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
                    gameGoingOn = false
                    --love.event.quit()
                    end
                end
            end
          else
            print('player not found in update2')
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

print('oily server ' .. consts.version)
generateServer({
  api = srv,
  port = 52225,
  fps = 40,
  --debug = true,
  onUpdate = function(t)
    if nextBleedT then
        update(t)
    end
  end,
  onNewClient = function(clientId, t)
    srv.send('ve ' .. consts.version, clientId)
    local numClients = srv.getNumClients()
    print('#clients '.. numClients)
    updateClientIdToPlayerIdx()
    newGame()
  end,
  onClientLeft = function(clientId, t)
    local numClients = srv.getNumClients()
    print('#clients '.. numClients)
    updateClientIdToPlayerIdx()
    if numClients > 0 then
        newGame()
    end
  end,
  onReceive = function(data, clientId, t)
    -- NETWORK RECEIVE CODE

    -- to allow restart from finished games
    if data == 'kd r' then
        newGame()
        return
    end

    if not gameGoingOn then
        return
    end

    -- print('received [' .. data .. '] from ' .. clientId)

    -- which player sent this?
    local pIdx = clientIdToPlayerIdx[clientId]
    local player = players[pIdx]

    if not player then
        print('onReceive: player not found')
        return
    end

    local cmd = data:sub(1, 2)
    local key = data:sub(4)

    local prevDPos = { player.dPos[1], player.dPos[2] }

    if cmd == 'kd' then
        if key == 'space' then
            if player.digging or player.holesLeft >= 4 then
                player.digging = not player.digging
                srv.broadcast('di ' .. pIdx .. ',' .. (player.digging and 't' or 'f') )
                if player.digging then
                    player.holesLeft = player.holesLeft - 4
                else
                    player.holesLeft = player.holesLeft + 4
                end
                srv.broadcast('hl '.. pIdx .. ',' .. player.holesLeft)
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

    if player.dPos[1] ~= prevDPos[1] or player.dPos[2] ~= prevDPos[2] then
        if player.dPos[1] ~= 0 or player.dPos[2] ~= 0 then
            srv.broadcast('pd '.. pIdx ..',' .. player.dPos[1] .. ',' .. player.dPos[2])
        end
    end
  end,
  onEnd = function()
      print('leaving...')
  end
})

