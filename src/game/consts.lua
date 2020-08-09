local M = {}

M.W = 167 -- (screenW/S)
M.H = 125

M.S = 6 -- size of a cell in game pixels

M.colors = {
    earth = {0.4, 0.2, 0.1},
    dirt = {0.6, 0.3, 0.15},
    sky = {0.6, 0.8, 0.8},
    rock = {0.4, 0.4, 0.4},
    oil = {0, 0, 0}
}

M.materials = {
    player = { 1, 2 },
    sink = { 3, 4 },
    earth = 5,
    dirt = 6,
    sky = 7,
    rock = 8,
    oil = 9
}

M.ahead = {}
M.ahead['0,0']   = {}
M.ahead['1,0']   = { { 2, 0}, { 2, 1} }
M.ahead['-1,0']  = { {-1, 0}, {-1, 1} }
M.ahead['0,1']   = { { 0, 2}, { 1, 2} }
M.ahead['0,-1']  = { { 0,-1}, { 1,-1} }
M.ahead['1,1']   = { { 2, 2}, { 2, 1}, { 1, 2} }
M.ahead['-1,1']  = { {-1, 2}, {-1, 1}, { 0, 2} }
M.ahead['1,-1']  = { { 2,-1}, { 1,-1}, { 2, 0} }
M.ahead['-1,-1'] = { {-1,-1}, {-1, 0}, { 0,-1} }

return M