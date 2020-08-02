local lu = require "src.ext.luaunit"
local md5 = require "src.ext.md5"

local M = {}

function M:test()
  lu.assertEquals("0bc83cb571cd1c50ba6f3e8a78ef1346",
                  md5.sumhexa("myemailaddress@example.com"), "md5.1")
  lu.assertEquals("ca6f59bfc40276294269bba0aed97029",
                  md5.sumhexa("jose.pedro.dias@gmail.com"), "md5.2")
end

return M
