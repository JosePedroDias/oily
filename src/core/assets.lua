-- [[ basic asset loading ]] --
local utils = require "src.core.utils"

local M = {fonts = {}, sfx = {}, music = {}, gfx = {}, gfxID = {}}

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

  M.gfxID['title'] = love.image.newImageData(gfxDir .. "/title.png")
  M.gfx["title"] = LG.newImage(M.gfxID['title'])
  -- print('gfx #' .. utils.countKeys(M.gfx))

  M.sfx["motor1"] = LA.newSource(sfxDir .. "/motor.ogg", "static")
  M.sfx["motor2"] = LA.newSource(sfxDir .. "/motor.ogg", "static") -- two samples same source (to manage state)

  M.sfx["setMode"]      = LA.newSource(sfxDir .. "/setMode.ogg",      "static")
  M.sfx["setModeEmpty"] = LA.newSource(sfxDir .. "/setModeEmpty.ogg", "static")
  M.sfx["extract"]      = LA.newSource(sfxDir .. "/extract.ogg",      "static")
  M.sfx["oil"]          = LA.newSource(sfxDir .. "/oil.ogg",          "static")

  M.sfx["go"]           = LA.newSource(sfxDir .. "/go.ogg",          "static")
  M.sfx["win-solo"]     = LA.newSource(sfxDir .. "/win-solo.ogg",    "static")
  M.sfx["win-p1"]       = LA.newSource(sfxDir .. "/win-p1.ogg",      "static")
  M.sfx["win-p2"]       = LA.newSource(sfxDir .. "/win-p2.ogg",      "static")


  
  -- print('sfx #' .. utils.countKeys(M.sfx))

  -- local swingjedingMusic = love.audio.newSource("sounds/swingjeding.ogg", "stream")
  -- M.music["swingjeding"] = swingjedingMusic
  -- print('music #' .. utils.countKeys(M.music))
end

return M
