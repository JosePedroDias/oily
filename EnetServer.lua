-- same as in my lua-networking repo :D
-- .
local socket = require "socket" -- luarocks install luasocket BECAUSE OF SLEEP
local enet = require "enet" -- luarocks install enet
local signal = require("posix.signal") -- luarocks install luaposix

local function isInt(n)
  return type(n) == "number" and n == math.floor(n)
end

local function generateServer(opts)
  -- required
  assert(opts.port and isInt(opts.port), "port must be defined as a number")
  assert(opts.fps and isInt(opts.fps), "fps must be defined as a number")
  assert(opts.api and type(opts.api) == "table",
         "api must be defined as an object")

  -- optional
  if opts.onUpdate then
    assert(type(opts.onUpdate) == "function", "onUpdate should be a function")
  end
  if opts.onNewClient then
    assert(type(opts.onNewClient) == "function",
           "onNewClient should be a function")
  end
  if opts.onReceive then
    assert(type(opts.onReceive) == "function", "onReceive should be a function")
  end
  if opts.onEnd then
    assert(type(opts.onEnd) == "function", "onEnd should be a function")
  end

  local host = enet.host_create("*:" .. opts.port)

  local running = true
  local dt = 1 / opts.fps
  local t = 0

  local function getClients()
    local clients = {}
    local i = 1
    while true do
      local ok, peer = pcall(host.get_peer, host, i)
      if not ok then break end
      local id = peer:connect_id()
      if id == 0 then break end
      clients[id] = i
      i = i + 1
    end
    return clients
  end

  local function send(data, clientId)
    local clients = getClients()
    local peer = host:get_peer(clients[clientId])
    peer:send(data)
  end

  local function broadcast(data)
    host:broadcast(data)
  end

  local function stopRunning()
    if opts.onEnd then opts.onEnd() end
    running = false
  end

  signal.signal(signal.SIGINT, stopRunning)

  opts.api.broadcast = broadcast
  opts.api.getClients = getClients
  opts.api.send = send
  opts.api.stopRunning = stopRunning

  while running do
    if opts.onUpdate then opts.onUpdate(t) end

    socket.sleep(dt)
    t = t + dt

    local event
    while true do
      event = host:service()
      if not event then break end
      if event.type == "receive" then
        if opts.debug then
          print("server: received [" .. event.data .. "] from " ..
                  event.peer:connect_id())
        end
        if opts.onReceive then
          opts.onReceive(event.data, event.peer:connect_id(), t)
        end
      elseif event.type == "connect" then
        if opts.debug then
          print("server: new client " .. event.peer:connect_id())
        end
        if opts.onNewClient then
          opts.onNewClient(event.peer:connect_id(), t)
        end
      elseif event.type == "disconnect" then
        if opts.debug then
          print("server: client left" .. event.peer:connect_id())
        end
        if opts.onClientLeft then
          opts.onClientLeft(event.peer:connect_id(), t)
        end
      end
    end
  end
end

return generateServer
