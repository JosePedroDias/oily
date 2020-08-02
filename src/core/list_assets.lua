local function tree(dir)
  local n = #dir + 1
  local results = {}
  local pfile = io.popen("tree -ifF \"" .. dir .. "\"")
  for filename in pfile:lines() do
    if filename:sub(-1) ~= "/" then table.insert(results, filename:sub(n)) end
  end

  pfile:close()
  return results
end

local function toAssets(dir, tpl)
  local assets = tree(dir)
  for _, file in pairs(assets) do
    local i = string.find(file, ".", 1, true)
    if i ~= nil then
      local key = file:sub(2):sub(1, i - 2):gsub("/", "_")
      -- print("{'" .. key .. "','" .. file .. "'},")
      local l = tpl:gsub("S1", key):gsub("S2", file)
      print(l)
    end
  end
end

toAssets("assets/gfx", "M.gfx[\"S1\"] = LG.newImage(gfxDir .. \"S2\")")
toAssets("assets/sfx",
         "M.sfx[\"S1\"] = LA.newSource(sfxDir .. \"S2\", \"static\")")
