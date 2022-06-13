local poetry = require("py.poetry")
local Job = require("plenary.job")

local M = {}

M.pytest = {
    status = nil,
    failed = nil,
    result = nil,
}

function M.showPytestResult()
    if M.pytest.status == "running" then
        vim.notify("Running tests...", "info", { title = "py.nvim" })
    elseif M.pytest.status == "complete" then
        if M.pytest.failed == 1 then
            vim.notify(M.pytest.result, "error", { title = "py.nvim" })
        else
            vim.notify(M.pytest.result, "info", { title = "py.nvim" })
        end
    else
        vim.notify(M.pytest.result, "info", { title = "py.nvim" })
    end
end

function M.launchPytest()
    local poetry_dir = poetry.findPoetry()

    if poetry_dir == nil then
        return nil
    end

    -- notify
    if M.pytest.status == "running" then
        M.showPytestResult()
    else
        vim.notify("Launching pytest...", "info", { title = "py.nvim" })

        Job
            :new({
                command = "poetry",
                args = { "run", "pytest" },
                cwd = poetry_dir,
                on_start = function()
                    M.pytest.status = "running"
                end,
                on_exit = function(j, return_val)
                    local res = {}
                    for _, val in pairs(j:result()) do
                        table.insert(res, val)
                    end

                    M.pytest.status = "complete"
                    M.pytest.failed = return_val
                    M.pytest.result = res

                    M.showPytestResult()
                end,
            })
            :start()
    end
end

-- function M.launchPytest(opts)
--
--   local cwd = vim.fn.getcwd()
--   local current_path = vim.api.nvim_exec(":echo @%", 1)
--
--   local poetry_dir = poetry.findPoetry(current_path, cwd)
--
--   -- Launch Pytests
--   vim.notify("Running pytests...", "info", {title="py.nvim"} )
--
--   Job:new({
--     --command = 'poetry run pytest',
--     command = 'poetry',
--     args = {'run', 'pytest'},
--     cwd = poetry_dir,
--     on_exit = function(j, return_val)
--
--       if return_val == 1 then
--
--         local err = {}
--         for k, val in pairs(j:result()) do
--           table.insert(err, val)
--         end
--         vim.notify(err, "error", {
--           title="py.nvim",
--           keep=function() return false end})
--
--       else
--         vim.notify("Tests Passed Successfully!", "info", {title="py.nvim"})
--
--       end
--
--     end,
--   }):start()
--
--
--   -- local test_term = vim.fn.termopen('cd '..poetry_dir..' && poetry run pytest', {
--   --   on_stdout = function(message)
--   --     vim.notify(message)
--   --   end
--   -- })
--
-- end

return M
