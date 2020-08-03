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

local function carvePlayer(pPos, m)
    local x = pPos[1]
    local y = pPos[2]
    m[x][y] = gc.materials.earth
    m[x+1][y] = gc.materials.earth
    m[x][y+1] = gc.materials.earth
    m[x+1][y+1] = gc.materials.earth
end

M.frontier = frontier
M.bleed = bleed
M.carvePlayer = carvePlayer

return M