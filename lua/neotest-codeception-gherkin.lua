local lib = require("neotest.lib")
local logger = require("neotest.logging")
local types = require("neotest.types")
local Path = require("plenary.path")

local NeotestAdapter = { name = "neotest-codeception-gherkin" }

-- Detect cucumber feature files
function NeotestAdapter.is_test_file(file_path) return file_path:match("%.feature$") end

-- Determine project root
function NeotestAdapter.root(dir)
  return lib.files.match_root_pattern(
    "behat.yml",
    "behat.yml.dist",
    "codeception.yml",
    "codeception.dist.yml",
    "composer.json"
  )(dir)
end

-- Filter directories to ignore non-test folders
function NeotestAdapter.filter_dir(name, rel_path, root)
  if name == "tests" or name == "test" then return true end

  return rel_path:match("^tests?/")
end

-- Discover test positions (Fixed Neotest hierarchy issue)
function NeotestAdapter.discover_positions(file_path)
  if not NeotestAdapter.is_test_file(file_path) then return nil end

  local results = {}
  local lines = lib.files.read_lines(file_path)
  results[1] = {
    type = "file",
    path = file_path,
    name = vim.fn.fnamemodify(file_path, ":t"),
    id = file_path,
    range = { 0, 0, #lines, 0 },
  }

  local line_no = 1
  while line_no <= #lines do
    local line = lines[line_no]
    local feature = line:match("^Feature:%s*(.+)")
    if feature then results[1].name = feature end

    local scenario = line:match("^%s*Scenario:%s*(.+)")
    if scenario then
      table.insert(results, {
        type = "test",
        name = scenario,
        id = file_path .. "::" .. scenario .. "::" .. line_no,
        path = file_path,
        range = { line_no - 1, 0, line_no - 1, #line },
      })
    end

    line_no = line_no + 1
  end

  -- return results
  return types.Tree.from_list(results, function(pos) return pos.id end)
end

-- Relative path from project root
local function relative_project_path(filepath)
  local root = NeotestAdapter.root(vim.fn.getcwd())
  return Path:new(filepath):make_relative(root)
end

-- Build command to execute tests
function NeotestAdapter.build_spec(args)
  local position = args.tree:data()
  local relpath = relative_project_path(position.path)
  local xml_output_file = vim.fn.tempname() .. ".xml"
  local command = {
    "php",
    "vendor/bin/codecept",
    "run",
    "--no-interaction",
    "--phpunit-xml",
    xml_output_file,
    relpath,
  }

  if position.type == "test" then
    table.insert(command, "--filter")
    table.insert(command, position.name .. "$")
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
    if xml_content:match('<testcase[^>]-name=".+: ' .. value.name .. '"[^>]-/>') then
      return {
        status = types.ResultStatus.passed,
      }
    end

    local error = xml_content:match('<testcase[^>]-name=".+: ' .. value.name .. '".-<failure[^>]->([^<]-)</failure>')
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
