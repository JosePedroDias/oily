local lu = require "src.ext.luaunit"
local utils = require "src.core.utils"

local testTrim = function()
  lu.assertEquals(utils.trim(" cenas   "), "cenas")
end

return testTrim
