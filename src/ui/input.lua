--[[ input - allows for editing and submitting text ]] --
local G = love.graphics

local Input = {
  x = 0,
  y = 0,
  width = 100,
  height = 30,
  padding = 5,
  value = "",
  focused = false
}

function Input:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.font = o.font or G.getFont()
  o.color = o.color or {0, 0, 0, 1}
  o.background = o.background or {1, 1, 1, 1}
  o.backgroundUnfocused = o.backgroundUnfocused or {0.75, 0.75, 0.75, 1}
  o.canvas = G.newCanvas(o.width, o.height)
  o:redraw()
  return o
end

function Input:setValue(value)
  self.value = value
  self:redraw()
end

function Input:getValue()
  return self.value
end

function Input:clear()
  self:setValue("")
end

function Input:draw()
  G.setColor(1, 1, 1, 1)
  G.draw(self.canvas, self.x, self.y)
end

function Input:redraw()
  G.setCanvas(self.canvas)

  local bg = self.backgroundUnfocused
  if self.focused then bg = self.background end
  pcall(G.clear, bg)

  pcall(G.setColor, self.color)
  G.setFont(self.font)
  local suffix = ""
  if self.focused then suffix = "|" end
  local text = self.value .. suffix
  local w = self.font:getWidth(text)
  local x = self.padding
  if self.width - w < self.padding then
    x = self.width - w
  end
  G.print(text, x, self.padding)

  G.setCanvas()
end

function Input:onKey(key)
  if not self.focused then return false end
  if key == "backspace" then
    self.value = string.sub(self.value, 1, #self.value - 1)
    if self.onChange then self.onChange(self.value, self) end
    self:redraw()
  elseif key == "return" then
    if self.onSubmit then self.onSubmit(self.value, self) end
  end
  return true
end

function Input:onTextInput(text)
  if not self.focused then return false end
  self.value = self.value .. text
  if self.onChange then self.onChange(self.value, self) end
  self:redraw()
  return true
end

function Input:onPointer(x, y)
  local isHit = false
  if x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y +
    self.height then isHit = true end

  if self.focused and not isHit then
    self.focused = false
    self:redraw()
  elseif not self.focused and isHit then
    self.focused = true
    self:redraw()
  end

  return isHit
end

return Input
