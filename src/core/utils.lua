--[[ Swiss army knife of sorts ]] --
local M = {}

M.toFixed = function(n, digits)
  return string.format("%." .. tostring(digits) .. "f", n)
end

M.tableToString = function(tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs(tt) do
      table.insert(sb, string.rep(" ", indent)) -- indent it
      if type(value) == "table" and not done[value] then
        done[value] = true
        table.insert(sb, key .. " = {\n")
        table.insert(sb, M.tableToString(value, indent + 2, done))
        table.insert(sb, string.rep(" ", indent)) -- indent it
        table.insert(sb, "}\n")
      elseif "number" == type(key) then
        if (type(value) == "string") then
          table.insert(sb, string.format("%s = \"%s\"\n", tostring(key),
                                         tostring(value)))
        else
          table.insert(sb, string.format("%s = %s\n", tostring(key),
                                         tostring(value)))
        end
      else
        if (type(value) == "string") then
          table.insert(sb, string.format("\"%s\" = \"%s\"\n", tostring(key),
                                         tostring(value)))
        else
          table.insert(sb, string.format("\"%s\" = %s\n", tostring(key),
                                         tostring(value)))
        end
      end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

M.toString = function(tbl)
  if "nil" == type(tbl) then
    return tostring(nil)
  elseif "table" == type(tbl) then
    return M.tableToString(tbl)
  elseif "string" == type(tbl) then
    return "\"" .. tbl .. "\""
  else
    return tostring(tbl)
  end
end

M.keyValueToString = function(tbl)
  local s = ""
  for k, v in pairs(tbl) do s = s + k .. " -> " .. v .. "\n" end
  return s
end

M.arrayToString = function(tbl)
  local s = ""
  local len = M.tableLength(tbl)
  local i = 1
  for _, v in pairs(tbl) do
    if type(v) == "string" then v = "\"" .. v .. "\"" end
    if i < len then
      s = s .. v .. ", "
    else
      s = s .. v
    end
    i = i + 1
  end
  return s
end

M.push = function(arr, item)
  table.insert(arr, item)
  return arr
end

M.pop = function(arr)
  return table.remove(arr, #arr)
end

M.shift = function(arr, item)
  table.insert(arr, 1, item)
  return arr
end

M.unshift = function(arr)
  return table.remove(arr, 1)
end

M.slice = function(arr, start, stop)
  local res = {}
  start = start or 1
  stop = stop or #arr
  for i = start, stop do table.insert(res, arr[i]) end
  return res
end

M.times = function(n, first, fn)
  first = first or 1
  fn = fn or function(i)
    return i
  end
  local arr = {}
  for i = first, n + first - 1 do table.insert(arr, fn(i)) end
  return arr
end

M.split = function(st, sep)
  if sep == nil then sep = "%s" end
  local matches = {}
  for subSt in string.gmatch(st, "([^" .. sep .. "]+)") do
    table.insert(matches, subSt)
  end
  return matches
end

M.splitLines = function(st)
  return M.split(st, "\n")
end

M.tableLength = function(tbl)
  local len = 0
  for _, _ in pairs(tbl) do len = len + 1 end
  return len
end

M.has = function(tbl, item)
  for _, v in pairs(tbl) do if v == item then return true end end
  return false
end

M.hasKey = function(tbl, key)
  return tbl[key] ~= nil
end

M.keys = function(tbl)
  local res = {}
  for k, _ in pairs(tbl) do table.insert(res, k) end
  return res
end

M.countKeys = function(tbl)
  local res = 0
  for _, _ in pairs(tbl) do res = res + 1 end
  return res
end

M.indexOf = function(tbl, item)
  for i, v in ipairs(tbl) do if v == item then return i end end
end

M.find = M.indexOf

M.findByAttribute = function(tbl, attrName, attrValue)
  for i, v in ipairs(tbl) do if v[attrName] == attrValue then return v, i end end
  return nil, 0
end

M.filter = function(tbl, cb)
  local res = {}
  for i, v in ipairs(tbl) do if cb(v, i) then table.insert(res, v) end end
  return res
end

M.map = function(tbl, cb)
  local res = {}
  for i, v in ipairs(tbl) do table.insert(res, cb(v, i)) end
  return res
end

M.shallowCopy = function(tbl)
  local tbl2 = {}
  for k, v in pairs(tbl) do tbl2[k] = v end
  return tbl2
end

M.countStringOccurrences = function(whereS, whichS)
  local count = 0
  for _ in string.gmatch(whereS, whichS) do
    count = count + 1
  end
  return count
end

M.join = function(tbl, sep)
  sep = sep or ""
  return table.concat(tbl, sep)
end

M.explodeString = function(st)
  local len = string.len(st)
  local arr = {}
  for i = 1, len do table.insert(arr, string.sub(st, i, i)) end
  return arr
end

-- ignores function values and meta
local function eq(o1, o2)
  if o1 == o2 then return true end
  local o1Type = type(o1)
  local o2Type = type(o2)
  if o1Type ~= o2Type then return false end
  if o1Type ~= "table" then return false end

  local keySet = {}

  for key1, value1 in pairs(o1) do
    local value2 = o2[key1]
    if type(value1) ~= "function" and type(value2) ~= "function" then
      if value2 == nil or eq(value1, value2) == false then return false end
      keySet[key1] = true
    end
  end

  for key2, value3 in pairs(o2) do
    if type(value3) ~= "function" then
      if not keySet[key2] then return false end
    end
  end
  return true
end

M.eq = eq

M.trim = function(s)
  return s:gsub("^%s*(.-)%s*$", "%1")
end

M.deepEqual = function(t1, t2)
  local t = type(t1)
  if t ~= type(t2) then
    print("different type: " .. t .. " ~= " .. type(t2))
    return false
  end
  if t ~= "table" then
    if t1 ~= t2 then print("values differ: " .. t1 .. " ~= " .. t2) end
    return t1 == t2
  end

  for k1, v1 in pairs(t1) do
    local v2 = t2[k1]
    if not M.deepEqual(v1, v2) then return false end
  end

  for k2, v2 in pairs(t2) do
    local v1 = t1[k2]
    if v2 and not v1 then
      print("ommitted key in 1st table: " .. k2)
      return false
    end
  end

  return true
end

M.round = function(n)
  return math.floor(n + 0.5)
end

M.dist = function(x, y, xx, yy)
  return math.sqrt(math.pow(x - xx, 2) + math.pow(y - yy, 2))
end

M.distSquared = function(x, y, xx, yy)
  return math.pow(x - xx, 2) + math.pow(y - yy, 2)
end

-- https://gist.github.com/Uradamus/10323382
function M.shuffle(t)
  local tbl = {}
  for i = 1, #t do tbl[i] = t[i] end
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

function M.lerp(a, b, i)
  return a * (1 - i) + b * i
end

-- https://github.com/JosePedroDias/scorespace8/blob/master/src/utils.ts

M.polarMove = function(pos, r, angle)
  -- return {pos[1] + math.cos(angle) * r, pos[2] + math.sin(angle) * r}
  return {
    M.round(pos[1] + math.cos(angle) * r), M.round(pos[2] + math.sin(angle) * r)
  }
end

local randomChars =
  "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
M.randomString = function(numChars, rndFun)
  local s = ""
  for i = 1, numChars do
    local l = rndFun(1, #randomChars)
    s = s .. string.sub(randomChars, l, l)
  end
  return s
end

M.matrixCreate = function(w, h, defaultValue)
  local m = {}
  for x = 1, w do
    m[x] = {}
    for y = 1, h do
      m[x][y] = defaultValue
    end
  end
  return m
end

-----

M.isMobile = function()
  local os = love.system.getOS()
  return os == "Android" or os == "iOS"
end

return M
