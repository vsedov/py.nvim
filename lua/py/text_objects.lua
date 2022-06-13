local ts_utils = require("nvim-treesitter.ts_utils")
local utils = require("py.utils")

local M = {}

function M.getStatementDefinition()
    local node = ts_utils.get_node_at_cursor()
    if node:named() == false then
        error("Node not recognized. Check to ensure treesitter parser is installed.")
    end

    while string.match(node:sexpr(), "statement") == nil and string.match(node:sexpr(), "definition") == nil do
        node = node:parent()
    end

    return node
end

function M.getObject(bufn)
    local node = M.getStatementDefinition()

    if node == nil then
        return nil
    end

    local bufn = bufn or vim.api.nvim_get_current_buf()
    local text = ts_utils.get_node_text(node, bufn)
    local _, start_column, _, _ = node:range()
    local message = table.concat(text, "\r")
    while start_column ~= 0 do
        message = string.gsub(message, "\r%s%s%s%s", "\r")
        start_column = start_column - 4
    end
    return message
end

function M.getImports()
    root = ts_utils.get_root_for_position(1, 1, nil)

    if root == nil then
        return nil
    end

    local import_nodes = {}
    for k, v in pairs(ts_utils.get_named_children(root)) do
        if v:type() == "import_statement" then
            table.insert(import_nodes, v)
        end

        if v:type() == "import_from_statement" then
            table.insert(import_nodes, v)
        end
    end

    local import_text = ""
    for k, v in pairs(import_nodes) do
        local node_text = ts_utils.get_node_text(v)

        for j, v in pairs(node_text) do
            if import_text ~= "" then
                import_text = import_text .. "\r" .. v
            else
                import_text = v
            end
        end
    end

    return import_text
end

function M.parsePythonObject(object_text)
    if string.find(object_text, "class ") ~= nil then
        txt = string.gsub(object_text, "class ", "")
        txt = string.gsub(txt, "%(.*%):.*", "")
        txt = string.gsub(txt, ":.*", "")
        return { "class", txt }
    elseif string.find(object_text, "def ") ~= nil then
        txt = string.gsub(object_text, "def ", "")
        txt = string.gsub(txt, "%(.*%):.*", "")
        return { "function", txt }
    end
end

function M.getPythonObject(object, search_name)
    local root = ts_utils.get_root_for_position(1, 1, nil)
    if root == nil then
        return nil
    end

    local objects = {}
    for k, v in pairs(ts_utils.get_named_children(root)) do
        if v:type() == "function_definition" and object == "function" then
            parsed = M.parsePythonObject(ts_utils.get_node_text(v)[1])

            if search_name == parsed[2] then
                return v
            end
        elseif v:type() == "class_definition" and object == "class" then
            parsed = M.parsePythonObject(ts_utils.get_node_text(v)[1])

            if search_name == parsed[2] then
                return v
            end
        end
    end

    return nil
end

function M.getHighlighted()
    return vim.fn.getreg("z")
end

function M.getIPythonHighlighted()
    local text = M.getHighlighted()

    local lines = utils.split(text, "\n")

    new_lines = {}
    for _, line in pairs(lines) do
        line = string.gsub(line, "In .%d.%p%s", "")
        line = string.gsub(line, "%s%s%s%p%p%p%p%s", "")
        line = string.gsub(line, "%s%s%s%p%p%p%p", "")
        table.insert(new_lines, line)
    end

    return new_lines
end

function M.highlightNode(node, bufn)
    local ns = vim.api.nvim_create_namespace("py.nvim")
    ts_utils.goto_node(node)
    ts_utils.highlight_node(node, bufn, ns, "TODO")
end

function M.replaceText(bufn, node, new_text)
    local rng, rng2, rng3, rng4 = ts_utils.get_node_range(node)
    print(rng)
    print(rng2)
    print(rng3)
    print(rng4)

    -- Delete text
    vim.api.nvim_buf_set_lines(bufn, rng, rng3 + 1, {}, new_text)
end

return M
