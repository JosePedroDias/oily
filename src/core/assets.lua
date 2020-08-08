-- [[ basic asset loading ]] --
local utils = require "src.core.utils"

local M = {fonts = {}, sfx = {}, music = {}, gfx = {}}

local LG = love.graphics
local LA = love.audio

local fontDir = "assets/font/"
local gfxDir = "assets/gfx"
local sfxDir = "assets/sfx"

M.load = function()
  local mainF = LG.newFont(fontDir .. "/NotoSans-Regular.ttf", 18)
  love.graphics.setFont(mainF)
  M.fonts["main"] = mainF
  -- print('fonts #' .. utils.countKeys(M.fonts))

  M.gfx["player1"] = LG.newImage(gfxDir .. "/player-red.png")
  M.gfx["player2"] = LG.newImage(gfxDir .. "/player-blue.png")
  M.gfx["tower1"] = LG.newImage(gfxDir .. "/tower-red.png")
  M.gfx["tower2"] = LG.newImage(gfxDir .. "/tower-blue.png")
  -- print('gfx #' .. utils.countKeys(M.gfx))

  M.sfx["motor1"] = LA.newSource(sfxDir .. "/motor1.ogg", "static")
  M.sfx["motor2"] = LA.newSource(sfxDir .. "/motor2.ogg", "static")
  M.sfx["dirt"] = LA.newSource(sfxDir .. "/dirt.ogg", "static")
  M.sfx["oil"] = LA.newSource(sfxDir .. "/oil.ogg", "static")
  -- print('sfx #' .. utils.countKeys(M.sfx))

  -- local swingjedingMusic = love.audio.newSource("sounds/swingjeding.ogg", "stream")
  -- M.music["swingjeding"] = swingjedingMusic
  -- print('music #' .. utils.countKeys(M.music))
end

return M
