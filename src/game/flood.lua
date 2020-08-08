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

local function frontier(mm, cells)
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
            return mm.g(c[1], c[2])
        end)
        if ok and (v == gc.materials.earth or v == gc.materials.sink[1] or v == gc.materials.sink[2]) then
            table.insert(res, c)
        end
    end

    return res
end

local function bleed(mm, cells)
    local newCells = frontier(mm, cells)
    for _, nc in ipairs(newCells) do
        mm.s(nc[1], nc[2], gc.materials.oil)
        table.insert(cells, nc)
    end
    return #newCells
end

local function getHole(pos)
    local x = pos[1]
    local y = pos[2]
    return {
        { x,   y,   },
        { x+1, y,   },
        { x,   y+1, },
        { x+1, y+1, },
    }
end

local function posCanBeFilled(pPos, pMat, mm)
    local v = mm.g(pPos[1], pPos[2])
    return v == gc.materials.earth or v == gc.materials.dirt or v == pMat
end

local function isHoleValid(pos, mat, mm)
    local holePs = getHole(pos)
    for _, p in ipairs(holePs) do
        if not posCanBeFilled(p, mat, mm) then return false end
    end
    return true
end

local function carveHole(pPos, mat, mm)
    local holePs = getHole(pPos)
    for _, p in ipairs(holePs) do
        mm.s(p[1], p[2], mat)
    end
end

M.bleed = bleed
M.getHole = getHole
M.carveHole = carveHole
M.isHoleValid = isHoleValid
M.frontier = frontier

return M