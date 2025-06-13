local lib = require("neotest.lib")
local logger = require("neotest.logging")
local types = require("neotest.types")
local Path = require("plenary.path")

local NeotestAdapter = { name = "neotest-codeception" }

-- Detect Codeception test files
function NeotestAdapter.is_test_file(file_path) return file_path:match("Test%.php$") or file_path:match("Cest%.php$") end

-- Determine project root
function NeotestAdapter.root(dir)
  return lib.files.match_root_pattern("codeception.yml", "codeception.dist.yml", "composer.json")(dir)
end

-- Filter directories to ignore non-test folders
function NeotestAdapter.filter_dir(name, rel_path, root)
  if name == "tests" or name == "test" then return true end

  return rel_path:match("^tests?/")
end

function NeotestAdapter.make_test_id(position)
  local class = vim.fn.fnamemodify(vim.fn.fnamemodify(position.path, ":r"), ":t")
  return class .. ":" .. position.name
end

-- Discover test positions (Fixed Neotest hierarchy issue)
function NeotestAdapter.discover_positions(file_path)
  if not NeotestAdapter.is_test_file(file_path) then return nil end

  local query = [[
    ((class_declaration
      name: (name) @namespace.name
    )) @namespace.definition

    (method_declaration
      (visibility_modifier) @visibility
      name: (name) @test.name
      (#eq? @visibility "public")
      (#not-match? @test.name "^_")
    ) @test.definition
  ]]

  return lib.treesitter.parse_positions(file_path, query, {
    position_id = "require('neotest-codeception').make_test_id",
  })
end

-- Relative path from project root
local function relative_project_path(filepath)
  local root = NeotestAdapter.root(vim.fn.getcwd())
  return Path:new(filepath):make_relative(root)
end

-- Build command to execute tests
function NeotestAdapter.build_spec(args)
  local xml_output_file = vim.fn.tempname() .. ".xml"
  local command = {
    "php",
    "vendor/bin/codecept",
    "run",
    "--no-interaction",
    "--phpunit-xml",
    xml_output_file,
  }

  local position = args.tree:data()
  local relpath = relative_project_path(position.path)

  if position.type == "test" then
    table.insert(command, string.format("%s:%s", relpath, position.name))
  else
    table.insert(command, relpath)
  end

  return {
    command = command,
    context = position,
    output_file = xml_output_file,
  }
end

local function generate_result(value, result, xml_content)
  if value.type == "file" then
    local status = types.ResultStatus.passed
    if xml_content:match("<failure") then status = types.ResultStatus.failed end

    return {
      status = status,
      output = result.output,
    }
  end

  if value.type == "test" then
    if xml_content:match('<testcase[^>]-name="' .. value.name .. '"[^>]-/>') then
      return {
        status = types.ResultStatus.passed,
      }
    end

    local error = xml_content:match('<testcase[^>]-name="' .. value.name .. '".-<failure[^>]->([^<]-)</failure>')
    if error then
      return {
        status = types.ResultStatus.failed,
        short = error,
        output = result.output,
      }
    end

    return {
      status = types.ResultStatus.failed,
      output = result.output,
    }
  end

  return {}
end

-- Process test results
function NeotestAdapter.results(spec, result, tree)
  local output_file = spec.output_file
  if not output_file or vim.fn.filereadable(output_file) == 0 then
    logger.error("xml file not found")
    return {} -- Ensure fallback if no result file is found
  end

  -- Read the XML file as a raw string
  local xml_content = table.concat(vim.fn.readfile(output_file), "\n")

  local results = {}

  for _, node in tree:iter_nodes() do
    local value = node:data()
    results[value.id] = generate_result(value, result, xml_content)
  end

  return results
end

return NeotestAdapter
