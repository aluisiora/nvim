local phpnamespace = require("php.namespace")

local function snippet_for(entity_type, suffix)
  local class_name = vim.fn.expand("%:t:r")
  local namespace = phpnamespace.generate()
  local snippet = "<?php\n\n"
  if namespace ~= "" then
    snippet = snippet .. "namespace " .. namespace .. ";\n\n"
  end
  snippet = snippet .. entity_type .. " "
  local position = 0
  if class_name ~= "" then
    snippet = snippet .. class_name
  else
    snippet = snippet .. "$" .. position
    position = position + 1
  end
  if suffix ~= nil then
    snippet = snippet .. " " .. suffix .. " $" .. position
    position = position + 1
  end
  return snippet .. "\n{\n\t$" .. position .. "\n}\n"
end

return {
  {
    prefix = "prif",
    desc = "Create a private method",
    body = {
      "private function ${1}(${2}): ${3:void}",
      "{",
      "    ${0}",
      "}",
      "",
    },
  },
  {
    prefix = "pubf",
    desc = "Create a public method",
    body = {
      "public function ${1}(${2}): ${3:void}",
      "{",
      "    ${0}",
      "}",
      "",
    },
  },
  {
    prefix = "prof",
    desc = "Create a protected method",
    body = {
      "protected function ${1}(${2}): ${3:void}",
      "{",
      "    ${0}",
      "}",
      "",
    },
  },
  {
    prefix = "pubsf",
    desc = "Create a public static method",
    body = {
      "public static function ${1}(${2}): ${3:void}",
      "{",
      "    ${0}",
      "}",
      "",
    },
  },
  {
    prefix = "prisf",
    desc = "Create a private static method",
    body = {
      "private static function ${1}(${2}): ${3:void}",
      "{",
      "    ${0}",
      "}",
      "",
    },
  },
  {
    prefix = "prosf",
    desc = "Create a protected static method",
    body = {
      "protected static function ${1}(${2}): ${3:void}",
      "{",
      "    ${0}",
      "}",
      "",
    },
  },
  {
    prefix = "con",
    desc = "Create PHP __construct method",
    body = {
      "public function __construct(${1})",
      "{",
      "    ${2}",
      "}",
      "",
    },
  },
  {
    prefix = "inv",
    desc = "Create PHP __invoke method",
    body = {
      "public function __invoke(${1}): ${2:void}",
      "{",
      "    ${3}",
      "}",
      "",
    },
  },
  {
    prefix = "foe",
    desc = "Foreach loop",
    body = {
      "foreach(\\$${1} as \\$${2}) {",
      "    ${0}",
      "}",
      "",
    },
  },
  {
    prefix = "foek",
    description = "Foreach key value loop",
    body = {
      "foreach(\\$${1} as \\$${2:key} => \\$${3:value}) {",
      "    ${0}",
      "}",
      "",
    },
  },
  function()
    return {
      prefix = "!pc",
      body = snippet_for("class"),
      desc = "Generate PSR-4 PHP Class",
    }
  end,
  function()
    return {
      prefix = "!pce",
      body = snippet_for("class", "extends"),
      desc = "Generate PSR-4 PHP Class with extends",
    }
  end,
  function()
    return {
      prefix = "!pci",
      body = snippet_for("class", "implements"),
      desc = "Generate PSR-4 PHP Class with implements",
    }
  end,
  function()
    return {
      prefix = "!pac",
      body = snippet_for("abstract class"),
      desc = "Generate PSR-4 PHP Abstract Class",
    }
  end,
  function()
    return {
      prefix = "!pace",
      body = snippet_for("abstract class", "extends"),
      desc = "Generate PSR-4 PHP Abstract Class with extends",
    }
  end,
  function()
    return {
      prefix = "!paci",
      body = snippet_for("class", "implements"),
      desc = "Generate PSR-4 PHP Abstract Class with implements",
    }
  end,
  function()
    return {
      prefix = "!pfc",
      body = snippet_for("final class"),
      desc = "Generate PSR-4 PHP Final Class",
    }
  end,
  function()
    return {
      prefix = "!pfce",
      body = snippet_for("final class", "extends"),
      desc = "Generate PSR-4 PHP Final Class with extends",
    }
  end,
  function()
    return {
      prefix = "!pfci",
      body = snippet_for("final class", "implements"),
      desc = "Generate PSR-4 PHP Final Class with implements",
    }
  end,
  function()
    return {
      prefix = "!pi",
      body = snippet_for("interface"),
      desc = "Generate PSR-4 PHP Interface",
    }
  end,
  function()
    return {
      prefix = "!pie",
      body = snippet_for("interface", "extends"),
      desc = "Generate PSR-4 PHP Interface with extends",
    }
  end,
  function()
    return {
      prefix = "!pe",
      body = snippet_for("enum"),
      desc = "Generate PSR-4 PHP Enum",
    }
  end,
}
