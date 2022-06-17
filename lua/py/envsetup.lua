local Job = require("plenary.job")
local config = require("py.config").config

local M = {}
--- get all python versions on your system that you can create an env with
---@return  table : a list of all python versions on your system
local getPythonVersions = function()
    local python_versions_list = {}
    for line in io.popen("ls /usr/bin/python3.*"):read("*a"):gmatch("[^\r\n]+") do
        if not line:find("-config") then
            local python = line:gsub("/usr/bin/", "")
            table.insert(python_versions_list, python)
        end
    end
    return python_versions_list
end

--- Create an .envrc or add specified information to envrc from setup.
--  1. If .envrc does not exist, create it.
--  2. If .envrc exists, and the information from setup is not there append it to the end of the file.
--  3. If .envrc exists and is empty add information from setup to file.
M.dirEnvSetup = function()
    -- avoid running direnv allow multiple times
    local direnv_activation = false
    local envrc = config.envrc
    local env_dir, env_file = require("py.utils").pathFinder(
        true,
        ".envrc",
        ".envrc is not found, dir env will be created."
    )

    local dir, _ = require("py.poetry").findPoetry()
    if dir == nil then
        vim.notify("Please be in the root of the project")
    end

    if env_dir == nil then
        env_dir = dir .. "/.envrc"
        vim.fn.writefile(envrc, env_dir)
        vim.notify(".envrc has been created", "info", { title = "py.nvim" })
        direnv_activation = true
    else
        vim.notify(".envrc already exists - checking contents.", "info", { title = "py.nvim" })
        local file = vim.fn.readfile(env_file)
        if vim.tbl_isempty(file) then
            vim.notify(".envrc is empty - updating data", "info", { title = "py.nvim" })
            vim.fn.writefile(envrc, env_file)
            direnv_activation = true
        else
            for _, line in ipairs(envrc) do
                if not vim.tbl_contains(file, line) then
                    if line:find("layout_poetry") then
                        direnv_activation = true
                    end
                    vim.fn.writefile({ line }, env_file, "a")
                end
            end
        end
    end

    if direnv_activation and config.use_direnv then
        vim.notify("direnv will be activated", "info", { title = "py.nvim" })
        vim.defer_fn(function()
            vim.cmd("lcd" .. dir)
            vim.cmd([[silent !direnv allow]])
        end, 1000)
    end
end

--- Create env for poetry directories
M.createEnv = function()
    local all_python_versions = getPythonVersions()
    vim.ui.select(all_python_versions, { prompt = "python version :" }, function(version)
        local poetry_dir, _ = require("py.poetry").findPoetry()
        Job
            :new({
                command = "poetry",
                args = { "env", "use", version },
                cwd = poetry_dir,
                on_exit = function(_, _)
                    vim.notify("Env Has been created", "info", { title = "py.nvim" })
                end,
            })
            :start()
    end)
end

return M
