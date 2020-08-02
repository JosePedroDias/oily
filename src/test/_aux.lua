local M = {}

local G = love.graphics

M.drawAndSaveImage = function(canvas, fnToDraw, name)
  G.setCanvas(canvas)
  fnToDraw()
  G.setCanvas()
  canvas:newImageData():encode("png", "tests/" .. name)
end

return M
