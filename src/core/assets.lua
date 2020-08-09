-- [[ basic asset loading ]] --
local utils = require "src.core.utils"

local M = {fonts = {}, sfx = {}, music = {}, gfx = {}}

local LG = love.graphics
local LA = love.audio

local fontDir = "assets/font/"
local gfxDir = "assets/gfx"
local sfxDir = "assets/sfx"

M.load = function()
  M.fonts["main"] = LG.newFont(fontDir .. "/NotoSans-Regular.ttf", 18)
  M.fonts["smaller"] = LG.newFont(fontDir .. "/NotoSans-Regular.ttf", 13)
  love.graphics.setFont(M.fonts["main"])
  -- print('fonts #' .. utils.countKeys(M.fonts))

  M.gfx["player1"] = LG.newImage(gfxDir .. "/player-red.png")
  M.gfx["player2"] = LG.newImage(gfxDir .. "/player-blue.png")
  M.gfx["tower1"] = LG.newImage(gfxDir .. "/tower-red.png")
  M.gfx["tower2"] = LG.newImage(gfxDir .. "/tower-blue.png")
  -- print('gfx #' .. utils.countKeys(M.gfx))

  M.sfx["motor1"] = LA.newSource(sfxDir .. "/motor.ogg", "static") -- todo hack
  M.sfx["motor2"] = LA.newSource(sfxDir .. "/motor.ogg", "static")

  M.sfx["setMode"]      = LA.newSource(sfxDir .. "/setMode.ogg",      "static")
  M.sfx["setModeEmpty"] = LA.newSource(sfxDir .. "/setModeEmpty.ogg", "static")

  
  
  -- print('sfx #' .. utils.countKeys(M.sfx))

  -- local swingjedingMusic = love.audio.newSource("sounds/swingjeding.ogg", "stream")
  -- M.music["swingjeding"] = swingjedingMusic
  -- print('music #' .. utils.countKeys(M.music))
end

return M
