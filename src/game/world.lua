--[[ world ]] --

local utils = require "src.core.utils"
local consts = require "src.core.consts"
local gc = require "src.game.consts"
local enet = require "enet"
local Label = require "src.ui.label"

local HOST = "127.0.0.1"
-- local HOST = 'nc.xsl.pt'
local PORT = 52225

local host = enet.host_create()
host:connect(HOST .. ":" .. PORT)

local G = love.graphics

local World = {x=0, y=0, width=consts.W, height=consts.H}

local S = 7 -- cell size in pixels
local t = 0
local connected = false

local bindings = { 'left', 'right', 'up', 'down', 'return' }

local players = {}
players[1] = {
    color = { 1, 0, 0 },
    captured = 0
}
players[2] = {
    color = { 0, 1, 0 },
    captured = 0
}

function World:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.m = utils.matrixCreate(160, 120, gc.materials.dirt)

  o.l = Label:new({x=consts.W/2-100, y=0, width=200, background={0,0,0,0.2}})
  o:updateLabel()

  o.lp1 = Label:new({x=0, y=0, width=200, background={0,0,0,0.2}})
  o.lp2 = Label:new({x=consts.W-200, y=0, width=200, background={0,0,0,0.2}})
  o:updateLabelPlayer(1)
  o:updateLabelPlayer(2)
  
  o.canvas = G.newCanvas(o.width, o.height)
  o:redraw()

  return o
end

function World:update(dt)
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
            elseif cmd == 'ca' then
              isDirty = true
              local pIdx = tonumber(args[1])
              local capt = tonumber(args[2])
              print(pIdx)
              players[pIdx].captured = capt
              self:updateLabelPlayer(pIdx)
            else
                print(data)
            end
        elseif event.type == "connect" then
            connected = true
            self:updateLabel()
        elseif event.type == "disconnect" then
            connected = false
            self:updateLabel()
        else
            print(event.type)
        end
    end

    if isDirty then
        self:redraw()
    end
end

function World:updateLabel()
  local txt = 'connected?' .. (connected and 'Y' or 'N')
  self.l:setValue(txt)
end

function World:updateLabelPlayer(idx)
  local pl = players[idx]
  local txt = 'P' .. idx .. ' - captured:' .. pl.captured
  self['lp' .. idx]:setValue(txt)
end

function World:redraw()
    G.setCanvas(self.canvas)

    pcall(G.clear, {0, 0, 0, 0})

    local w = #self.m
    local h = #self.m[1]

    for x = 1, w do
        for y = 1, h do
          local v = self.m[x][y]
          local color
          if v == gc.materials.earth then
            color = gc.colors.earth
          elseif v == gc.materials.dirt then
            color = gc.colors.dirt
          elseif v == gc.materials.oil then
            color = gc.colors.oil
          elseif v == gc.materials.sky then
            color = gc.colors.sky
          elseif v == gc.materials.player[1] then
            color = players[1].color
          elseif v == gc.materials.player[2] then
            color = players[2].color
          elseif v == gc.materials.sink[1] or v == gc.materials.sink[2] then
            color = { 0.3, 0.3, 0.3 }
            -- color = gc.colors.sky
          end

          local X = (x-1) * S
          local Y = (y-1) * S
          pcall(G.setColor, color)
          G.rectangle("fill", X, Y, S, S)
        end
      end

    G.setCanvas()
end

function World:draw()
  G.setColor(1, 1, 1, 1)
  G.draw(self.canvas, self.x, self.y)

  self.l:draw()
  self.lp1:draw()
  self.lp2:draw()
end

function World:onKey(key)
    if key == 'escape' then
        -- host:disconnect_now()
        host:get_peer(1):disconnect_now()
        love.event.quit()
    end

    for _, k in ipairs(bindings) do
        if key == k then
            host:broadcast("kd " .. key)
        end
    end
end

function World:onKeyUp(key)
    for _, k in ipairs(bindings) do
        if key == k then
            host:broadcast("ku " .. key)
        end
    end
end

return World