--[[ static text ]] --
local G = love.graphics

local Label = {x = 0, y = 0, width = 30, height = 30, value = nil}

function Label:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.font = o.font or G.getFont()
  o.color = o.color or {1, 1, 1, 1}
  o.background = o.background or {0, 0, 0, 0}
  o.canvas = G.newCanvas(o.width, o.height)
  o:redraw()
  return o
end

function Label:setValue(value)
    self.value = value
    self:redraw()
end
  
function Label:getValue()
    return self.value
end

function Label:draw()
  G.setColor(1, 1, 1, 1)
  G.draw(self.canvas, self.x, self.y)
end

function Label:redraw()
  G.setCanvas(self.canvas)

  pcall(G.clear, self.background)

  if self.value then
    local f = self.font
    G.setFont(f)
    local dx = f:getWidth(self.value)
    local dy = f:getHeight()
    pcall(G.setColor, self.color)
    G.print(self.value, (self.width - dx) / 2, (self.height - dy) / 2)
  end

  G.setCanvas()
end

return Label
