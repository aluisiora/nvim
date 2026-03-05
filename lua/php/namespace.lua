local M = {}

function M.generate()
  local file_path = vim.fn.expand("%:p:h")
  local current_dir = file_path
  local composer_path = nil
  local composer_content = nil

  -- 1. Traverse upwards to find composer.json
  while current_dir ~= "/" and current_dir ~= "" do
    local f = io.open(current_dir .. "/composer.json", "r")
    if f then
      composer_content = f:read("*a")
      f:close()
      composer_path = current_dir
      break
    end
    current_dir = vim.fn.fnamemodify(current_dir, ":h")
  end

  -- Fallback if no composer.json is found
  if not composer_path then return "" end

  -- 2. Safely parse the composer.json file
  local ok, composer_json = pcall(vim.fn.json_decode, composer_content)
  if not ok or type(composer_json) ~= "table" then return "" end

  -- 3. Extract PSR-4 mappings
  local psr4_mappings = {}
  for _, section in ipairs({ "autoload", "autoload-dev" }) do
    if composer_json[section] and composer_json[section]["psr-4"] then
      for ns, paths in pairs(composer_json[section]["psr-4"]) do
        -- paths can be a string or an array in composer.json
        if type(paths) == "string" then paths = { paths } end
        for _, path in ipairs(paths) do
          table.insert(psr4_mappings, { namespace = ns, dir = path })
        end
      end
    end
  end

  -- 4. Match the current file's directory against the PSR-4 definitions
  local relative_dir = file_path:sub(#composer_path + 1):gsub("^/", "")
  if relative_dir ~= "" then relative_dir = relative_dir .. "/" end

  for _, map in ipairs(psr4_mappings) do
    local mapped_dir = map.dir:gsub("^%./", "") -- normalize e.g., "./src/" -> "src/"
    if mapped_dir ~= "" and mapped_dir:sub(-1) ~= "/" then
      mapped_dir = mapped_dir .. "/"
    end

    if relative_dir:sub(1, #mapped_dir) == mapped_dir then
      local sub_path = relative_dir:sub(#mapped_dir + 1)
      local sub_ns = sub_path:gsub("/", "\\")

      -- Clean up trailing slashes/backslashes
      sub_ns = sub_ns:gsub("\\$", "")
      local final_ns = map.namespace:gsub("\\$", "")

      if sub_ns ~= "" then final_ns = final_ns .. "\\" .. sub_ns end

      return final_ns
    end
  end

  return ""
end

return M
