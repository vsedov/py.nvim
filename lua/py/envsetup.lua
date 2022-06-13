local M = {}

local env_commands = { "info", "list", "remove", "use" }

M.getPythonVersions = function()
    local python_versions_list = {}
    for line in io.popen("ls /usr/bin/python3.*"):read("*a"):gmatch("[^\r\n]+") do
        if not line:find("-config") then
            local python = line:gsub("/usr/bin/", "")
            table.insert(python_versions_list, python)
        end
    end
    return python_versions_list
end

M.dirEnvSetup = function()
    -- TODO(vsedov) (19:43:59 - 13/06/22): refactor this, not viable code.
    local envrc = [[
layout_poetry
export PYTHONPATH=$(pwd)
#eval "$(register-python-argcomplete cz)"
    ]]

    local env_dir, env_file = require("py.utils").pathFinder(
        true,
        ".envrc",
        ".envrc is not found, dir env will be created."
    )

    local dir, _ = require("py.poetry").findPoetry()
    if env_dir == nil then
        if dir == nil then
            return nil
        end
        env_dir = dir .. "/.envrc"
        local file = io.open(env_dir, "w")
        if file == nil then
            return
        end
        file:write(envrc)
        file:close()
        vim.notify(".envrc is created.")
    else
        vim.notify(".envrc is already exists.")
        local file = io.open(env_file, "r")
        if file == nil then
            return
        end
        local envrc_content = file:read("*a")
        file:close()

        if envrc_content:find("layout_poetry") == nil then
            file = io.open(env_file, "a")
            file:write(envrc)
            file:close()
            vim.notify(".envrc is updated.")
        end
    end
    vim.defer_fn(function()
        -- cd to env_dir
        vim.cmd("lcd" .. dir)

        vim.cmd([[!direnv allow]])
    end, 1000)
end

return M
