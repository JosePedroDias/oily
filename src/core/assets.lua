-- [[ basic asset loading ]] --
local M = {fonts = {}, sfx = {}, music = {}, gfx = {}}

local LG = love.graphics
local LA = love.audio

local fontDir = "assets/font/"
local gfxDir = "assets/gfx"
local sfxDir = "assets/sfx"

M.load = function()
  -- local mainF = LG.newFont(fontDir .. "/NotoSans-Regular.ttf", 20)
  -- love.graphics.setFont(mainF)
  -- M.fonts["main"] = mainF

  -- M.gfx["chess_w_rook"] = LG.newImage(gfxDir .. "/chess/w_rook.png")

  -- M.sfx["cards_place1"] = LA.newSource(sfxDir .. "/cards/place1.ogg", "static")

  -- local swingjedingMusic = love.audio.newSource("sounds/swingjeding.ogg", "stream")
  -- M.music["swingjeding"] = swingjedingMusic
end

return M
