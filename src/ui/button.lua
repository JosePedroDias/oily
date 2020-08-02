--[[ button - allows action activation ]] --
local G = love.graphics

local Button = {x = 0, y = 0, width = 30, height = 30, label = nil}

function Button:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.font = o.font or G.getFont()
  o.color = o.color or {0, 0, 0, 1}
  o.background = o.background or {0.75, 0.75, 0.75, 1}
  o.canvas = G.newCanvas(o.width, o.height)
  o:redraw()
  return o
end

function Button:draw()
  G.setColor(1, 1, 1, 1)
  G.draw(self.canvas, self.x, self.y)
end

function Button:redraw()
  G.setCanvas(self.canvas)

  pcall(G.clear, self.background)

  if self.label then
    local f = self.font
    G.setFont(f)
    local dx = f:getWidth(self.label)
    local dy = f:getHeight()
    pcall(G.setColor, self.color)
    G.print(self.label, (self.width - dx) / 2, (self.height - dy) / 2)
  end

  G.setCanvas()
end

function Button:onPointer(x, y)
  if x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y +
    self.height then if self.onClick then self.onClick(self.value) end end
end

return Button
