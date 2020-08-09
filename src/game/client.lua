--[[ Client ]] --

local enet = require "enet"
local utils = require "src.core.utils"
local consts = require "src.core.consts"
local gc = require "src.game.consts"
local assets = require "src.core.assets"
local Label = require "src.ui.label"

local HOST = "127.0.0.1"
-- local HOST = 'nc.xsl.pt'
local PORT = 52225

local host = enet.host_create()
local peer = host:connect(HOST .. ":" .. PORT)

local G = love.graphics

local D2R = math.pi / 180

local Client = {x=0, y=0, width=consts.W, height=consts.H}

local S = 6 -- cell size in pixels
local t = 0
local connected = false
local winnerIdx

local keyBindings = { 'left', 'right', 'up', 'down', 'space', 'r' }

local players

local gPlayers
local gTowers

function Client:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  print('oily client ' .. consts.version)

  local lColor = {0.1, 0.1, 0.1}
  -- local lBg = {0,0,0,0.3}
  local lBg = nil

  gPlayers = { assets.gfx.player1,  assets.gfx.player2 }
  gTowers = { assets.gfx.tower1,  assets.gfx.tower2 }

  o.l   = Label:new({x=consts.W/2-100, y=0, width=200, color=lColor, background=lBg})
  o.lp1 = Label:new({x=0,              y=0, width=300, color=lColor, background=lBg})
  o.lp2 = Label:new({x=consts.W-300,   y=0, width=300, color=lColor, background=lBg})
  
  o.canvas = G.newCanvas(o.width, o.height)

  --o:reset()
  o:redraw()

  return o
end

function Client:reset()
  print('new game!')

  players = {}
  players[1] = {
      color = { 1, 0, 0 },
      dir = { 1, 0 }
  }
  players[2] = {
      color = { 0, 1, 0 },
      dir = { -1, 0 }
  }
  
  self.m = utils.matrixCreate(gc.W, gc.H, gc.materials.dirt)
  self:updateLabel()
  self:updateLabelPlayer(1)
  self:updateLabelPlayer(2)
end

function Client:update(dt)
    t = t + dt

    local isDirty = false
    -- NETWORK RECEIVE CODE
    local event
    while true do
        event = host:service()
        if not event then break end
        if event.type == "receive" then
            local data = event.data
            local cmd = data:sub(1, 2)
            local args = utils.split(data:sub(4), ',')
            if cmd == 'sm' then
                isDirty = true
                self.m[tonumber(args[1])][tonumber(args[2])] = tonumber(args[3])
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
            elseif cmd == 'ca' then
              isDirty = true
              local pIdx = tonumber(args[1])
              players[pIdx].captured = tonumber(args[2])
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
            elseif cmd == 'wo' then
              isDirty = true
              local pIdx = tonumber(args[1])
              winnerIdx = pIdx
              self:updateLabel()
            elseif cmd == 'ng' then
              -- isDirty = true
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
  local txt = 'connected?' .. (connected and 'Y' or 'N')

  if winnerIdx then
    txt = 'player #' .. winnerIdx .. ' won!'
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

    pcall(G.clear, {0, 0, 0, 0})

    local w = gc.W
    local h = gc.H

    local pPos = { false, false }
    local tPos = {}

    for x = 1, w do
        for y = 1, h do
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
            -- color = { 0.3, 0.3, 0.3 }
            color = gc.colors.sky
            isTower = true
          end

          local X = (x-1) * S
          local Y = (y-1) * S

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

          pcall(G.setColor, color)
          G.rectangle("fill", X, Y, S, S)
        end
      end

      G.setColor(1, 1, 1)
      
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
end

function Client:onKey(key)
    if key == 'escape' then
        peer:disconnect_now()
        love.event.quit()
    end

    for _, k in ipairs(keyBindings) do
        if key == k then
            peer:send("kd " .. key)
        end
    end
end

function Client:onKeyUp(key)
    for _, k in ipairs(keyBindings) do
        if key == k then
            peer:send("ku " .. key)
        end
    end
end

return Client