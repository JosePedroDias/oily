-- [[ game screen handling ]] --
local World = require "src.game.world"
local utils = require "src.core.utils"

local M = {}

M.load = function()
  love.window.setTitle("oily")
  M.w = World:new({})
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

return M
