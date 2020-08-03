local gc = require "src.game.consts"

local M = {}

local function neighbors(pos)
    return {
        {pos[1]-1, pos[2]},
        {pos[1]+1, pos[2]},
        {pos[1], pos[2]-1},
        {pos[1], pos[2]+1}
    }
end

local function frontier(m, cells)
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
        local ok, v = pcall(function()
            return m[c[1]][c[2]]
        end)
        if ok and v == gc.materials.earth then
            table.insert(res, c)
        end
    end

    return res
end

local function bleed(m, cells)
    local newCells = frontier(m, cells)
    for _, nc in ipairs(newCells) do
        m[nc[1]][nc[2]] = gc.materials.oil
        table.insert(cells, nc)
    end
end

local function posCanBePlayer(pPos, pMat, m)
    local v = m[pPos[1]][pPos[2]]
    return v == gc.materials.earth or v == gc.materials.dirt or v == pMat
end

local function isPlayerPosValid(player, pIndex, m)
    local pPos = player.pos
    local pMat = gc.materials.player[pIndex]
    local x = pPos[1]
    local y = pPos[2]
    if not posCanBePlayer(pPos,       pMat, m) then return false end
    if not posCanBePlayer({x+1, y},   pMat, m) then return false end
    if not posCanBePlayer({x,   y+1}, pMat, m) then return false end
    if not posCanBePlayer({x+1, y+1}, pMat, m) then return false end
    return true
end

local function carvePlayer(pPos, mat, m)
    local x = pPos[1]
    local y = pPos[2]
    m[x  ][y  ] = mat
    m[x+1][y  ] = mat
    m[x  ][y+1] = mat
    m[x+1][y+1] = mat
end


M.bleed = bleed
M.carvePlayer = carvePlayer
M.isPlayerPosValid = isPlayerPosValid
M.frontier = frontier

return M