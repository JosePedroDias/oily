local lu = require "src.ext.luaunit"

local consts = require "src.core.consts"
local settings = require "src.core.settings"
local utils = require "src.core.utils"

local LF = love.filesystem
local FILE = "settings.json"

local M = {}

local originalData

function M:setUp()
  -- backup previous version
  local LF = love.filesystem
  originalData = LF.read(FILE)
end

function M:tearDown()
  -- restore it at the end
  if originalData then LF.write(FILE, originalData) end
end

function M:testLoadWithoutData()
  LF.write(FILE, "")

  lu.assertIsFalse(settings.load())
  lu.assertIsTrue(utils.eq(settings, {
    server = "acor.sl.pt",
    port = 1337,
    channel = "ch1",
    username = "john doe",
    email = "john.doe@somewhere.com",
    color = 1,
    version = consts.version
  }), lu.prettystr(settings))
end

function M:testLoadWithData()
  LF.write(FILE, "{\"color\":2, \"server\":\"localhost\"}")

  lu.assertIsTrue(settings.load())
  lu.assertIsTrue(utils.eq(settings, {
    server = "localhost",
    port = 1337,
    channel = "ch1",
    username = "john doe",
    email = "john.doe@somewhere.com",
    color = 2,
    version = consts.version
  }))
end

function M:testSaveWithoutData()
  LF.write(FILE, "")

  lu.assertIsFalse(settings.load())
  settings.username = "robin"
  lu.assertIsTrue(settings.save())
  local raw = LF.read(FILE)
  lu.assertEquals(raw,
                  "{\"server\":\"acor.sl.pt\",\"version\":\"" .. consts.version ..
                    "\",\"color\":1,\"email\":\"john.doe@somewhere.com\",\"username\":\"robin\",\"channel\":\"ch1\",\"port\":1337}")
end

function M:testSaveWithData()
  LF.write(FILE, "{\"color\":2, \"server\":\"localhost\"}")

  lu.assertIsTrue(settings.load())
  settings.username = "batman"
  lu.assertIsTrue(settings.save())
  local raw = LF.read(FILE)
  lu.assertEquals(raw,
                  "{\"server\":\"localhost\",\"version\":\"" .. consts.version ..
                    "\",\"color\":2,\"email\":\"john.doe@somewhere.com\",\"username\":\"batman\",\"channel\":\"ch1\",\"port\":1337}")
end

return M
