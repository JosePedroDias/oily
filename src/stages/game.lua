-- [[ game screen handling ]] --
local Client = require "src.game.client"
local utils = require "src.core.utils"

local M = {}

M.load = function()
  M.w = Client:new({})
end

M.unload = function()
end

M.update = function(dt)
  M.w:update(dt)
end

M.draw = function()
  M.w:draw()
end

M.onKey = function(key)
  M.w:onKey(key)
end

M.onKeyUp = function(key)
  M.w:onKeyUp(key)
end

return M
