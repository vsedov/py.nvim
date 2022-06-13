local Job = require("plenary.job")
local M = {}
-- ╭────────────────────────────────────────────────────────────────────╮
-- │                                                                    │
-- │                       General Functionality                        │
-- │                                                                    │
-- ╰────────────────────────────────────────────────────────────────────╯

--- Find Poetry exists with the project spec.
-- Returns parent and file of pyproject.
function M.findPoetry()
    return require("py.utils").pathFinder(false, "pyproject.toml", "Poetry Environment Not Found")
end

--- show package details : gets information from poetry to get information from a package.
---@param package string : Name of package you want information from.
function M.showPackageDetails(package)
    local poetry_dir, _ = M.findPoetry()
    if poetry_dir ~= nil then
        Job
            :new({
                command = "poetry",
                args = { "show", package },
                cwd = poetry_dir,
                on_exit = function(j, return_val)
                    if return_val == 0 then
                        local res = {}
                        for _, val in pairs(j:result()) do
                            table.insert(res, val)
                        end
                        vim.notify(res, "info", { title = "py.nvim" })
                    end
                end,
            })
            :start()
    end
end

--- get package information - calls showPackageDetails ; takes user input
function M.showPackage()
    local poetry_dir, _ = M.findPoetry()

    if poetry_dir ~= nil then
        vim.ui.input({ prompt = "Show Package: " }, function(package)
            M.showPackageDetails(package)
        end)
    end
end

--- Install poetry components on the basis that poetry_dir is not nill
function M.installPoetry()
    local poetry_dir, _ = M.findPoetry()

    if poetry_dir ~= nil then
        Job:new({
            command = "poetry",
            args = { "install" },
            cwd = poetry_dir,
        })
    end
end

-- ╭────────────────────────────────────────────────────────────────────╮
-- │                      Dependency Functionality                      │
-- │                                                                    │
-- ╰────────────────────────────────────────────────────────────────────╯

--- Parser for dependencies, formats them correctly.
---@param package string: package name that you want to parse / format.
---@return table : arguments of data that is formated.
function M.parseDependency(package)
    local args = { "add" }
    local sep = " "
    for str in string.gmatch(package, "([^" .. sep .. "]+)") do
        table.insert(args, str)
    end

    return args
end

--- Add Dependency to poetry pyproject
---@param package string : name of package you want to add
---@param opts string : optional parameters to package i.e version
function M.addDependency(package, opts)
    opts = opts or { silent = false }

    local poetry_dir, _ = M.findPoetry()

    if poetry_dir == nil then
        return nil
    end

    if opts.silent ~= true then
        vim.notify("Adding " .. package .. " to Poetry Environment", "info", { title = "py.nvim" })
    end

    Job
        :new({
            command = "poetry",
            args = M.parseDependency(package),
            cwd = poetry_dir,
            on_exit = function(j, return_val)
                if return_val == 1 then
                    local res = {}
                    for _, val in pairs(j:result()) do
                        table.insert(res, val)
                    end

                    if opts.silent ~= true then
                        vim.notify(res, "error", { title = "py.nvim" })
                    end
                else
                    if opts.silent ~= true then
                        vim.notify("Added Successfully: " .. package, "info", { title = "py.nvim" })
                    end
                end
            end,
        })
        :start()
end

--- User input ; add a dependency from  nuser input
function M.inputDependency()
    vim.ui.input({ prompt = "Add Package: " }, function(package)
        M.addDependency(package, { silent = false })
    end)
end

return M
