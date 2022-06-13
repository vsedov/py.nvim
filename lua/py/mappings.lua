local config = require("py.config")

local keymap = {}

function keymap.map(mode, key, rhs)
    local lhs = string.format("%s%s", config.leader(), key)
    vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true })
end

function keymap.set_mappings()
    -- IPython Mappings
    keymap.map("n", "p", "<cmd>lua require('py.ipython').toggleIPython()<CR>")
    keymap.map("n", "c", "<cmd>lua require('py.ipython').sendObjectsToIPython()<CR>")
    keymap.map("v", "c", '"zy:lua require("py.ipython").sendHighlightsToIPython()<CR>')
    keymap.map("v", "s", '"zy:lua require("py.ipython").sendIPythonToBuffer()<CR>')

    -- Pytest Mappings
    keymap.map("n", "t", "<cmd>lua require('py.pytest').launchPytest()<CR>")
    keymap.map("n", "r", "<cmd>lua require('py.pytest').showPytestResult()<CR>")

    -- Poetry Mappings
    keymap.map("n", "a", "<cmd>lua require('py.poetry').inputDependency()<CR>")
    keymap.map("n", "d", "<cmd>lua require('py.poetry').showPackage()<CR>")
end

return keymap
