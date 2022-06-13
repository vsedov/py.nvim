local config = require("py.config")

local M = {}

function M.map(mode, key, rhs)
    local lhs = string.format("%s%s", config.leader(), key)
    vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true })
end

function M.set_mappings()
    -- IPython Mappings
    M.map("n", "p", "<cmd>lua require('py.ipython').toggleIPython()<CR>")
    M.map("n", "c", "<cmd>lua require('py.ipython').sendObjectsToIPython()<CR>")
    M.map("v", "c", '"zy:lua require("py.ipython").sendHighlightsToIPython()<CR>')
    M.map("v", "s", '"zy:lua require("py.ipython").sendIPythonToBuffer()<CR>')

    -- Pytest Mappings
    M.map("n", "t", "<cmd>lua require('py.pytest').launchPytest()<CR>")
    M.map("n", "r", "<cmd>lua require('py.pytest').showPytestResult()<CR>")

    -- Poetry Mappings
    M.map("n", "a", "<cmd>lua require('py.poetry').inputDependency()<CR>")
    M.map("n", "d", "<cmd>lua require('py.poetry').showPackage()<CR>")
end

return M
