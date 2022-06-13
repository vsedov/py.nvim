local M = {}
local py_config = require("py.config")

local command_list = {
    -- Ipython commands
    ["toggleIpython"] = function()
        require("py.ipython").toggleIPython()
    end,
    ["sendBuffer"] = function()
        require("py.ipython").sendIPythonToBuffer()
    end,

    ["sendObj"] = function()
        require("py.ipython").sendObjectsToIPython()
    end,

    ["sendHighlight"] = function()
        require("py.ipython").sendHighlightsToIPython()
    end,

    -- Pytest Commands
    ["testStart"] = function()
        require("py.pytest").launchPytest()
    end,
    ["testResult"] = function()
        require("py.pytest").showPytestResult()
    end,

    -- poetry mapping
    ["addDep"] = function()
        require("py.poetry").inputDependency()
    end,
    ["showPackage"] = function()
        require("py.poetry").showPackage()
    end,
}

local execute_command = function(args)
    command_list[args.fargs[1]]()
end

local function create_command()
    vim.api.nvim_create_user_command("Py", function(args)
        execute_command(args)
    end, {
        desc = "poetry commands",
        complete = function()
            return vim.tbl_keys(command_list)
        end,
        nargs = "*",
        bang = true,
        force = true,
        range = true,
    })
end

function M.setup(user_config)
    local default_config = py_config.default_config
    if vim.fn.executable("poetry") == 0 then
        error("poetry is not executable")
    end

    user_config = user_config or {}

    py_config.config = vim.tbl_extend("keep", user_config, default_config)
    if py_config.mappings() then
        require("py.mappings").set_mappings()
    end

    if py_config.taskipy() then
        local taskipy_commands = {
            ["taskList"] = function()
                require("py.taskipy").runTasks()
            end,
            ["tasks"] = function()
                require("py.taskipy").runTaskInput()
            end,
        }

        vim.tbl_extend("keep", command_list, taskipy_commands)
    end

    create_command()
end

return M
