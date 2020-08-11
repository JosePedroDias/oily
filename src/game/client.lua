--[[ Client ]] --

local enet = require "enet"

local utils = require "src.core.utils"
local consts = require "src.core.consts"
local settings = require "src.core.settings"
local assets = require "src.core.assets"
local screen = require "src.core.screen"
local gc = require "src.game.consts"
local Label = require "src.ui.label"

local G = love.graphics

local KEY_BINDINGS = { 'left', 'right', 'up', 'down', 'space', 'r' }
local D2R = math.pi / 180
local REVIEW_SAMPLES_DT = 0.5

local host = enet.host_create()
local peer = host:connect(consts.host .. ":" .. consts.port)

local t = 0
local connected = false
local winnerIdx

local players

local gPlayers
local gTowers

local nextReviewSamplesT
local eventFrequencies -- holds histogram of relevant events to set or stop oil/extract sound

local Client = {x=0, y=0, width=consts.W, height=consts.H}

function Client:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  print('oily client ' .. consts.version)

  local darkClr = {0.1, 0.1, 0.1}
  local whiteClr = {1, 1, 1}
  
  local lBg = nil
  local l2Bg = {0,0,0,0.3}

  -- sfx
  assets.sfx.motor1:setLooping(true)
  assets.sfx.motor1:setPitch(1.1)
  assets.sfx.motor2:setLooping(true)
  assets.sfx.motor1:setVolume(0.2)
  assets.sfx.motor2:setVolume(0.2)

  assets.sfx.setMode:setVolume(1)
  assets.sfx.setModeEmpty:setVolume(1)

  assets.sfx.extract:setLooping(true)
  assets.sfx.oil:setLooping(true)

  -- gfx
  gPlayers = { assets.gfx.player1,  assets.gfx.player2 }
  gTowers = { assets.gfx.tower1,  assets.gfx.tower2 }

  -- overlays
  o.l   = Label:new({x=consts.W/2-100, y=0, width=200, color=darkClr, background=lBg})
  o.lp1 = Label:new({x=0,              y=0, width=300, color=darkClr, background=lBg})
  o.lp2 = Label:new({x=consts.W-300,   y=0, width=300, color=darkClr, background=lBg})
  local extra = 'oily ver:' .. consts.version .. ' ' .. consts.gitDate .. ' | if you see a black screen you are waiting for a slot to be available | https://josepedrodias.itch.io/oily'
  o.lextra = Label:new({x=1, width=consts.W, y=consts.H-20, height=20, color=whiteClr, background=l2Bg, value=extra, font=assets.fonts["smaller"]})
  
  o.canvas = G.newCanvas(o.width, o.height)

  o:redraw()

  return o
end

function Client:reset()
  print('new game!')

  if settings.sfx then
    assets.sfx.go:play()
  end

  winnerIdx = nil

  players = {}
  players[1] = {
      color = { 1, 0, 0 },
      dir = { 1, 0 }
  }
  players[2] = {
      color = { 0, 1, 0 },
      dir = { -1, 0 }
  }

  eventFrequencies = {
    oil = 0,
    extract = 0
  }
  nextReviewSamplesT = REVIEW_SAMPLES_DT
  -- TODO CONFIRM t GETS TO 0
  
  self.m = utils.matrixCreate(gc.W, gc.H, gc.materials.dirt)
  self:updateLabel()
  self:updateLabelPlayer(1)
  self:updateLabelPlayer(2)
end

local function toggleSampleIfNecessary(sample, freq)
  if freq > 0 and not sample:isPlaying() then
    if settings.sfx then
      sample:play()
    end
  elseif freq == 0 and sample:isPlaying() then
    sample:stop()
  end
end

function Client:update(dt)
    t = t + dt

    if nextReviewSamplesT and t >= nextReviewSamplesT then
      toggleSampleIfNecessary(assets.sfx.oil,     eventFrequencies.oil)
      toggleSampleIfNecessary(assets.sfx.extract, eventFrequencies.extract)

      nextReviewSamplesT = t + REVIEW_SAMPLES_DT
      eventFrequencies = {
          oil = 0,
          extract = 0
      }
    end

    local isDirty = false
    -- NETWORK RECEIVE CODE
    local event
    while true do
        event = host:service()
        if not event then break end -- is this useful?
        if event.type == "receive" then
            local data = event.data
            local cmd = data:sub(1, 2)
            local args = utils.split(data:sub(4), ',')
            if cmd == 'sm' then
                isDirty = true
                local mat = tonumber(args[3])
                self.m[tonumber(args[1])][tonumber(args[2])] = mat
                if mat == gc.materials.oil then
                  eventFrequencies.oil = eventFrequencies.oil + 1
                end
            elseif cmd == 'sr' then
              isDirty = true
              local x = tonumber(args[1])
              local y = tonumber(args[2])
              local w = tonumber(args[3])
              local h = tonumber(args[4])
              local v = tonumber(args[5])
              for xi = x, w - x + 1 do
                for yi = y, h - y + 1 do
                    self.m[xi][yi] = v
                end
            end
          elseif cmd == 'pd' then
            isDirty = true
            local pIdx = tonumber(args[1])
            local dx = tonumber(args[2])
            local dy = tonumber(args[3])
            players[pIdx].dir = { dx, dy }
            self:updateLabelPlayer(pIdx)
          elseif cmd == 'pm' then
            local pIdx = tonumber(args[1])
            local isMoving = args[2] == 't'
            local sample = pIdx == 1 and assets.sfx.motor1 or assets.sfx.motor2
            if isMoving then
              if settings.sfx then
                love.audio.play(sample)
              end
            else
              sample:stop()
            end
          elseif cmd == 'ca' then
            isDirty = true
            local pIdx = tonumber(args[1])
            players[pIdx].captured = tonumber(args[2])
            eventFrequencies.extract = eventFrequencies.extract + 1
            self:updateLabelPlayer(pIdx)
          elseif cmd == 'hl' then
            isDirty = true
            local pIdx = tonumber(args[1])
            players[pIdx].holesLeft = tonumber(args[2])
            self:updateLabelPlayer(pIdx)
          elseif cmd == 'di' then
            isDirty = true
            local pIdx = tonumber(args[1])
            players[pIdx].digging = args[2] == 't'
            self:updateLabelPlayer(pIdx)
            -- play mode change queue (busted is different)
            local sample = players[pIdx].holesLeft < 4 and assets.sfx.setModeEmpty or assets.sfx.setMode
            if settings.sfx then
              love.audio.play(sample)
            end

            -- change pitch of motor sample
            sample = pIdx == 1 and assets.sfx.motor1 or assets.sfx.motor2
            local v = pIdx == 1 and 1.1 or 1
            if players[pIdx].digging then
              v = v * 0.75
            end
            sample:setPitch(v)
          elseif cmd == 'wo' then
            isDirty = true
            local pIdx = tonumber(args[1])
            winnerIdx = pIdx
            self:updateLabel()
            if settings.sfx then
              if #players == 1 then
                assets.sfx['win-solo']:play()
              else
                assets.sfx['win-p' .. winnerIdx]:play()
              end
            end
          elseif cmd == 'ng' then
            self:reset()
          elseif cmd == 've' then
            if (args[1] ~= consts.version) then
              local msg = 'Server has version ' .. args[1] .. ' while client ' .. consts.version .. '\n' .. '. you should update.'
              print(msg)
              love.window.showMessageBox('caution', msg, 'warning', true)
            end
          else
              print('did not process message: [' .. data .. ']')
          end
        elseif event.type == "connect" then
            connected = true
            self:updateLabel()
        elseif event.type == "disconnect" then
            connected = false
            self:updateLabel()
        else
            print('received unprocessed event:' .. event.type)
        end
    end

    if isDirty then
        self:redraw()
    end
end

function Client:updateLabel()
  local txt = ''
  if not connected then
    txt = 'lost connection to server. please restart game'
  elseif winnerIdx then
    if #players == 1 then
      txt = 'you win!' -- TODO: #players in currently constant as 2
    else
      txt = 'player #' .. winnerIdx .. ' wins!'
    end
  end
  self.l:setValue(txt)
end

function Client:updateLabelPlayer(idx)
  local pl = players[idx]
  if not pl.captured or not pl.holesLeft or pl.digging == nil then return end
  local action = pl.digging and 'dig' or 'place'
  local txt = 'P' .. idx .. ' ' ..  action .. ' oil:' .. pl.captured .. ' holes:' .. pl.holesLeft
  self['lp' .. idx]:setValue(txt)
end

function Client:redraw()
    if not self.m then
      return
    end

    G.setCanvas(self.canvas)

    pcall(G.clear, gc.colors.worldBg)

    local w = gc.W
    local h = gc.H
    local S = gc.S

    local pPos = { false, false }
    local tPos = {}

    local function drawCell(x, y, pass, d)
      local v = self.m[x][y]
          local color
          local isPlayer = false
          local isTower = false
          if v == gc.materials.earth then
            color = gc.colors.earth
          elseif v == gc.materials.dirt then
            color = gc.colors.dirt
          elseif v == gc.materials.oil then
            color = gc.colors.oil
          elseif v == gc.materials.sky then
            color = gc.colors.sky
          elseif v == gc.materials.rock then
            color = gc.colors.rock
          elseif v == gc.materials.player[1] or v == gc.materials.player[2] then
            local pIdx = v - gc.materials.player[1] + 1
            color  = players[pIdx].digging and gc.colors.earth or gc.colors.dirt
            isPlayer = true
          elseif v == gc.materials.sink[1] or v == gc.materials.sink[2] then
            color = gc.colors.sky
            isTower = true
          end

          local X = (x-1) * S
          local Y = (y-1) * S

          if pass == 1 then
            if isPlayer then
              local pIdx = v - gc.materials.player[1] + 1
              pPos[pIdx] = { X, Y }
            elseif isTower then
              local pIdx = v - gc.materials.sink[1] + 1
              table.insert(tPos, {
                pIdx,
                { X + S/2, Y + S/2 - 10 }
              })
            end
          end

          if pass == 1 and (v ~= gc.materials.earth and v ~= gc.materials.sky) then
            -- noop for drawing on 1st pass other stuff (just draw earth and sky)
          elseif pass == 2 and (v == gc.materials.earth or v == gc.materials.sky) then
            -- noop for drawing earth or sky on 2nd pass
          else
            pcall(G.setColor, color)
            G.rectangle("fill", X+d, Y+d, S, S)
          end
          
    end

    for x = 1, w do
      for y = 1, h do
        drawCell(x, y, 1, 3)
      end
    end

    for x = 1, w do
        for y = 1, h do
          drawCell(x, y, 2, 0)
        end
      end

      G.setColor(1, 1, 1)
      
      -- draw players
      local SP = 0.15
      for pIdx = 1, 2 do
        local p = pPos[pIdx]
        if p then
          local dir = players[pIdx].dir
          local MX = 1
          local rot = 0
          
          if dir[1] == 1 then
            MX = -1
          end

          if dir[1] == -1 and dir[2] == 0 then
            rot = 0
          elseif dir[1] == -1 and dir[2] == 1 then
            rot = -45
          elseif dir[1] == -1 and dir[2] == -1 then
            rot = 45
          elseif dir[2] == -1 and dir[1] == 0 then
            rot = 90
          elseif dir[2] == 1 and dir[1] == 0 then
            rot = -90
          elseif dir[2] == -1 and dir[1] == 1 then
            rot = -45
          elseif dir[2] == -1 and dir[1] == -1 then
            rot = 45
          elseif dir[2] == 1 and dir[1] == 1 then
            rot = 45
          end

          G.draw(gPlayers[pIdx], p[1], p[2], D2R * rot, SP*MX, SP, 136/2, 136/2)
        end
      end

      -- draw towers
      local TP = 0.2
      for _, pair in ipairs(tPos) do
        local pIdx = pair[1]
        local p = pair[2]
        G.draw(gTowers[pIdx], p[1], p[2], 0, TP, TP, 96/2, 158/2)
      end

    G.setCanvas()
end

function Client:draw()
  G.setColor(1, 1, 1, 1)
  G.draw(self.canvas, self.x, self.y)

  self.l:draw()
  self.lp1:draw()
  self.lp2:draw()
  self.lextra:draw()
end

function Client:toggleFullscreen()
  settings.fullscreen = not settings.fullscreen
  screen.setFullscreenState(settings.fullscreen)
  settings.save()

  local toRedraw = { self.l, self.lp1, self.lp2, self.lextra, self }
  for _, o in ipairs(toRedraw) do
    o:redraw()
  end
end

function Client:toggleSfx()
  settings.sfx = not settings.sfx
  settings.save()

  if not settings.sfx then
    for _, sample in pairs(assets.sfx) do
      sample:stop()
    end
  end
end

function Client:onKey(key)
  -- client handled keys
    if key == 'escape' then
        peer:disconnect()
        host:flush()
        love.event.quit()
    elseif key == 'f' then
      self:toggleFullscreen()
    elseif key == 's' then
      self:toggleSfx()
    end

    -- server handled keys
    for _, k in ipairs(KEY_BINDINGS) do
        if key == k then
            peer:send("kd " .. key)
        end
    end
end

function Client:onKeyUp(key)
  -- server handled keys
    for _, k in ipairs(KEY_BINDINGS) do
        if key == k then
            peer:send("ku " .. key)
        end
    end
end

return Client