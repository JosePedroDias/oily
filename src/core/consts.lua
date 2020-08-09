-- [[ set of constants for the game. I've been using it to attach additional globals too]] --
local M = {}

M.W = 1000
M.H = 750

M.x0 = 0
M.y0 = 0

M.host = "nc.xsl.pt"
-- M.host = "127.0.0.1"
M.port = 52225

M.version = "0.1.1" -- used for network, config compatibility and itch.io published deliverables
M.gitHash = "__GITHASH__"
M.gitDate = "__GITDATE__"

return M
