local ts_utils = require("nvim-treesitter.ts_utils")

local roots_cache = nil

local function load_psr4_mappings()
  if roots_cache then return roots_cache end

  local map = {}

  local function insert(ns, path)
    ns = ns:gsub("\\$", "")
    path = path:gsub("/$", "")
    map[ns] = map[ns] or {}
    table.insert(map[ns], path)
  end

  -- composer.json
  local cj = io.open("composer.json", "r")
  if cj then
    local ok, parsed = pcall(vim.fn.json_decode, cj:read("*a"))
    cj:close()
    if ok and parsed.autoload and parsed.autoload["psr-4"] then
      for ns, paths in pairs(parsed.autoload["psr-4"]) do
        if type(paths) == "table" then
          for _, p in ipairs(paths) do
            insert(ns, p)
          end
        else
          insert(ns, paths)
        end
      end
    end
  end

  -- composer.lock
  local cl = io.open("composer.lock", "r")
  if cl then
    local ok, parsed = pcall(vim.fn.json_decode, cl:read("*a"))
    cl:close()
    if ok and parsed.packages then
      for _, pkg in ipairs(parsed.packages) do
        local psr4 = pkg.autoload and pkg.autoload["psr-4"]
        if psr4 then
          for ns, paths in pairs(psr4) do
            if type(paths) == "table" then
              for _, rel in ipairs(paths) do
                insert(ns, "vendor/" .. pkg.name .. "/" .. rel)
              end
            else
              insert(ns, "vendor/" .. pkg.name .. "/" .. paths)
            end
          end
        end
      end
    end
  end

  roots_cache = map

  return map
end

local function parse_input(input)
  local class_part, member = input:gsub("^\\", ""):match("^([^:]+):?:?(.*)$")
  return class_part, member
end

local function fqcn_to_path(fqcn, psr4_map)
  local match = nil
  for ns in pairs(psr4_map) do
    if fqcn:find("^" .. ns) then
      if not match or #ns > #match then match = ns end
    end
  end

  if not match then return nil end

  local relative = fqcn:gsub("^" .. match, ""):gsub("\\", "/") .. ".php"
  for _, base in ipairs(psr4_map[match]) do
    local full = base .. "/" .. relative
    if vim.fn.filereadable(full) == 1 then return full end
  end
end

local function move_to_member(member)
  local patterns = {
    "\\vfunction\\s+" .. member .. "\\s*\\(",
    "\\v(public|private|protected).+" .. member:gsub("^%$", "\\$"),
    "\\vconst\\s+" .. member .. "\\s*;",
  }

  vim.schedule(function()
    vim.cmd("normal! gg")
    for _, pat in ipairs(patterns) do
      local lnum = vim.fn.search(pat, "W")
      if lnum and lnum > 0 then
        local line = vim.fn.getline(lnum)
        local col = line:find(member, 1, true)
        if col then vim.api.nvim_win_set_cursor(0, { lnum, col - 1 }) end
        return
      end
    end
    vim.notify("Member '" .. member .. "' not found", vim.log.levels.INFO)
  end)
end

local function get_treesitter_root()
  local parser = vim.treesitter.get_parser(0, "php")
  local tree = parser:parse()[1]

  return tree:root()
end

local function get_node_text(node) return vim.treesitter.get_node_text(node, 0) end

local function get_namespace_node_text()
  local root = get_treesitter_root()

  for node in root:iter_children() do
    if node:type() == "namespace_definition" then return get_node_text(node:field("name")[1]) end
  end

  return ""
end

local function get_class_node_text()
  local root = get_treesitter_root()

  for node in root:iter_children() do
    if node:type() == "class_declaration" then return get_node_text(node:field("name")[1]) end
  end

  return ""
end

local function get_fqcn()
  local class_text = get_class_node_text()
  if not class_text then return nil end

  local ns_text = get_namespace_node_text()
  if not ns_text then return class_text end

  return "\\" .. ns_text .. "\\" .. class_text
end

local function get_nearest_member_fqcn()
  local fqcn = get_fqcn()

  local cursor_node = ts_utils.get_node_at_cursor()
  if not cursor_node then return fqcn end

  local node = cursor_node
  while node do
    local t = node:type()
    if t == "method_declaration" then
      local name = get_node_text(node:field("name")[1])
      return fqcn .. "::" .. name
    end

    if t == "property_declaration" then
      for child in node:iter_children() do
        if child:type() == "property_element" then
          local name = get_node_text(child:field("name")[1])
          return fqcn .. "::" .. name
        end
      end
    end

    if t == "const_declaration" then
      for elements in node:iter_children() do
        if elements:type() == "const_element" then
          for child in elements:iter_children() do
            if child:type() == "name" then return fqcn .. "::" .. get_node_text(child) end
          end
        end
      end
    end

    node = node:parent()
  end

  return fqcn
end

local M = {}

function M.fqcn_navigate()
  vim.ui.input({ prompt = "PHP FQCN", completion = "file" }, function(input)
    if not input or input == "" then return end

    local roots = load_psr4_mappings()
    if vim.tbl_isempty(roots) then
      vim.notify("No PSR-4 mappings found in composer.json or composer.lock", vim.log.levels.ERROR)
      return
    end

    local fqcn, member = parse_input(input)

    local matched_root = nil
    for ns in pairs(roots) do
      if fqcn:find("^" .. ns) then
        matched_root = roots[ns]
        break
      end
    end

    if not matched_root then
      vim.notify("FQCN doesn’t match any PSR-4 namespace", vim.log.levels.WARN)
      return
    end

    local path = fqcn_to_path(fqcn, roots)
    if not path or vim.fn.filereadable(path) == 0 then
      vim.notify("Class file not found for: " .. fqcn, vim.log.levels.WARN)
      return
    end

    vim.cmd("edit " .. path)

    if member and member ~= "" then move_to_member(member) end
  end)
end

function M.copy_fqcn()
  local fqcn = get_fqcn()
  if fqcn then
    vim.fn.setreg("+", fqcn)
    vim.notify("Copied: " .. fqcn)
    return
  end

  vim.notify("No class found", vim.log.levels.WARN)
end

function M.copy_fqcn_with_near_member()
  local fqcn = get_nearest_member_fqcn()
  if fqcn then
    vim.fn.setreg("+", fqcn)
    vim.notify("Copied: " .. fqcn)
    return
  end

  vim.notify("No class found", vim.log.levels.WARN)
end

return M
