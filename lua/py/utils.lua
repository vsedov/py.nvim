local Path = require("plenary.path")
local scan = require("plenary.scandir")

local M = {}

function M.getOutput(result_in)
    local res = {}
    for _, val in pairs(result_in:result()) do
        table.insert(res, val)
    end

    return res
end

function M.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end

    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end

    return t
end
function M.pathFinder(hidden_file, filename, error)
    hidden_file = hidden_file or false

    local cwd = vim.fn.getcwd()
    local current_path = vim.api.nvim_exec(":echo @%", 1)

    local parents = Path:new(current_path):parents()
    for _, parent in pairs(parents) do
        local files = scan.scan_dir(parent, { hidden = hidden_file, depth = 1 })
        for _, file in pairs(files) do
            if file == parent .. "/" .. filename then
                return parent, file
            end
        end

        if parent == cwd then
            break
        end
    end

    vim.notify(error, "error", { title = "py.nvim" })
end
return M
