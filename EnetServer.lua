-- same as in my lua-networking repo :D
-- .
local socket = require "socket" -- luarocks install luasocket BECAUSE OF SLEEP
local enet = require "enet" -- luarocks install enet
local signal = require("posix.signal") -- luarocks install luaposix

local function _print(s)
  local d = os.date("%H:%M:%S ")
  -- local d = os.date("%H:%M:%S " .. os.clock() .. " ")
  print(d .. s)
end

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

  -- https://leafo.net/lua-enet/#enethost_createbind_address_peer_count_channel_count_in_bandwidth_out_bandwidth
  local host = enet.host_create("*:" .. opts.port, 2, 1, 0, 0)
  -- TODO THIS IS ENFORCING MAX 2 PLAYERS IN A SINGLE CHANNEL. ANY OTHER CLIENTS WILL WAIT THEIR SLOT TO CONNECT

  -- bytes/sec
  -- host:bandwidth_limit(incoming, outgoing)

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

  local function getNumClients()
    local clients = getClients()

    local n = 0
    local i = next(clients)
    while i do
      n = n + 1
      i = next(clients, i)
    end

    return n
  end

  local function send(data, clientId)
    local clients = getClients()
    local peer = host:get_peer(clients[clientId])
    if opts.debug then
      _print("server: sending [" .. data .. "] to " .. clientId)
    end
    peer:send(data)
  end

  local function broadcast(data)
    if opts.debug then _print("server: broadcasting [" .. data .. "]") end
    host:broadcast(data)
  end

  local function stopRunning()
    if opts.onEnd then opts.onEnd() end
    running = false
  end

  local function setTime(t_)
    t = t_
  end

  signal.signal(signal.SIGINT, stopRunning)

  opts.api.broadcast = broadcast
  opts.api.getClients = getClients
  opts.api.getNumClients = getNumClients
  opts.api.send = send
  opts.api.setTime = setTime
  opts.api.stopRunning = stopRunning

  local function logTranferredData()
    _print("sent:" .. host:total_sent_data() .. ", received:" ..
             host:total_received_data())
  end

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
          _print("server: received [" .. event.data .. "] from " ..
                   event.peer:connect_id())
        end
        if opts.onReceive then
          opts.onReceive(event.data, event.peer:connect_id(), t)
        end
      elseif event.type == "connect" then
        if opts.debug then
          _print("server: new client " .. event.peer:connect_id())
          logTranferredData() -- TODO
        end
        logTranferredData()
        if opts.onNewClient then
          opts.onNewClient(event.peer:connect_id(), t)
        end
      elseif event.type == "disconnect" then
        if opts.debug then
          _print("server: client left" .. event.peer:connect_id())
          logTranferredData()
        end
        logTranferredData() -- TODO
        if opts.onClientLeft then
          opts.onClientLeft(event.peer:connect_id(), t)
        end
      end
    end
  end

  local clients = getClients()
  for _, peerIdx in pairs(clients) do
    local peer = host:get_peer(peerIdx)
    peer:disconnect_now()
  end
end

return generateServer
