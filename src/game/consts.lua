local M = {}

M.pColors = {
    { 1, 0, 0 },
    { 0, 1, 0 },
}

M.pBindings = {
    {
        'left', 'right', 'up', 'down'
    },
    {
        'a', 'd', 'w', 's'
    }
}

M.pChanges = {
    { -1, 0 }, { 1, 0 }, { 0, -1 },  { 0, 1 }
}

M.colors = {
    sky = {0.5, 0.9, 0.9},
    earth = {0.6, 0.3, 0},
    dirt = {0.9, 0.4, 0},
    oil = {0, 0, 0},
}

M.materials = {
    earth = 1,
    dirt = 2,
    sky = 3,
    oil = 4
}

return M