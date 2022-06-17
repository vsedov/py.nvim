local M = {}
local py_config = require("py.config")

local command_list = {
    -- ╭────────────────────────────────────────────────────────────────────╮
    -- │      Ipython commands                                              │
    -- ╰────────────────────────────────────────────────────────────────────╯
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

    -- ╭────────────────────────────────────────────────────────────────────╮
    -- │      Pytest Commands                                               │
    -- ╰────────────────────────────────────────────────────────────────────╯
    ["testStart"] = function()
        require("py.pytest").launchPytest()
    end,
    ["testResult"] = function()
        require("py.pytest").showPytestResult()
    end,

    -- ╭────────────────────────────────────────────────────────────────────╮
    -- │     poetry mapping                                                 │
    -- ╰────────────────────────────────────────────────────────────────────╯
    ["addDep"] = function()
        require("py.poetry").inputDependency()
    end,
    ["showPackage"] = function()
        require("py.poetry").showPackage()
    end,

    -- ╭────────────────────────────────────────────────────────────────────╮
    -- │     env mapping                                                    │
    -- ╰────────────────────────────────────────────────────────────────────╯

    ["envCreate"] = function()
        require("py.envsetup").createEnv()
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

local table_merge = function(itemList)
    command_list = vim.tbl_deep_extend("force", command_list, itemList)
end

function M.setup(user_config)
    if vim.fn.executable("poetry") == 0 then
        error("poetry is not executable")
    end

    user_config = user_config or {}

    py_config.config = vim.tbl_extend("keep", user_config, py_config.default_config)
    if py_config.config.mappings then
        require("py.mappings").set_mappings()
    end

    if py_config.config.use_direnv then
        local direnv_command = {
            ["dirEnvCreate"] = function()
                require("py.envsetup").dirEnvSetup()
            end,
        }
        table_merge(direnv_command)
    end

    if py_config.config.taskipy then
        local taskipy_commands = {
            ["taskList"] = function()
                require("py.taskipy").runTasks()
            end,
            ["tasks"] = function()
                require("py.taskipy").runTaskInput()
            end,
        }

        table_merge(taskipy_commands)
    end

    create_command()
end

return M
