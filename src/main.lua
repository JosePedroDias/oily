-- [[ main file! ]] --
local assets = require "src.core.assets"
local consts = require "src.core.consts"
local screen = require "src.core.screen"
local stages = require "src.core.stages"
local settings = require "src.core.settings"

-- local title = require "src.stages.title"
local game = require "src.stages.game"

function love.load(arg)
  -- load resources
  assets.load()

  settings.load()

  -- love.keyboard.setKeyRepeat(true)

  love.window.setTitle("oily " .. consts.version)
  -- love.window.setTitle("oily " .. consts.version .. " | " .. consts.host)

  screen.setFullscreenState(settings.fullscreen)

  -- stages.setStage("title", title)
  stages.setStage("game", game)
  stages.toStage("game")
end

function love.focus(f)
  stages.currentStage.focus(f)
end

function love.update(dt)
  stages.currentStage.update(dt)
end

function love.draw()
  screen.startDraw()
  stages.currentStage.draw()
  screen.endDraw()
end

function love.keypressed(key, scancode, isRepeat)
  stages.currentStage.onKey(key, scancode, isRepeat)
end

function love.keyreleased(key, scancode)
  stages.currentStage.onKeyUp(key, scancode)
end

-- NOT IN USE IN THIS GAME
--[[ function love.mousepressed(_x, _y)
  local x, y = screen.coords(_x, _y)
  stages.currentStage.onPointer(x, y)
end

function love.mousemoved(_x, _y)
  local x, y = screen.coords(_x, _y)
  stages.currentStage.onPointerMove(x, y)
end

function love.mousereleased(_x, _y)
  local x, y = screen.coords(_x, _y)
  stages.currentStage.onPointerUp(x, y)
end

function love.textinput(text)
  stages.currentStage.onTextInput(text)
end ]]

local function error_printer(msg, layer)
  print(debug.traceback("Error: " .. tostring(msg), 1 + (layer or 1)):gsub(
          "\n[^\n]+$", ""))
end

-- custom error handling to notify server I'm leaving
function love.errorhandler(msg)
  msg = tostring(msg)
  error_printer(msg, 2)

  -- pcall(SendEvent, "status", "out")
  love.event.quit()
end
