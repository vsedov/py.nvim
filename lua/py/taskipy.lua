local poetry = require("py.poetry")
local Job = require("plenary.job")

local M = {}

-- ╭────────────────────────────────────────────────────────────────────╮
-- │ taskipy config                                                     │
-- ╰────────────────────────────────────────────────────────────────────╯

--- Show taskipy tasks if it exists
function M.getTasks()
    local poetry_dir, _ = poetry.findPoetry()
    if poetry_dir ~= nil then
        local job = Job:new({
            command = "poetry",
            args = { "run", "task", "-l" },
            cwd = poetry_dir,
            on_exit = function(j, return_val)
                if return_val == 0 then
                    local result = j:result()
                    return result
                end
            end,
        })
        job:sync()
        return job:result()
    end
end

--- Show results of taskipy in vim.notify
function M.show_result(task, res)
    vim.notify(res, task, { title = "py.nvim", timeout = 10000 })
end

--- TaskiPyRunner, runs taskipy tasks
---@param task_name string : name of task
function M.taskipyRunner(task_name)
    local poetry_dir, _ = poetry.findPoetry()

    Job
        :new({
            command = "poetry",
            args = { "run", "task", task_name },
            cwd = poetry_dir,
            on_exit = function(j, _)
                local res = {}
                for _, val in pairs(j:result()) do
                    table.insert(res, val)
                end
                M.show_result(task_name, res)
            end,
        })
        :start()
end

--- Run Task for taskipy, gives a ui propmt to select a task.
function M.runTasks()
    local task_list = M.getTasks()
    local tasks = {}
    for _, task in pairs(task_list) do
        local task_name = string.match(task, "([^%s]+)")
        table.insert(tasks, task_name)
    end
    vim.ui.select(tasks, {
        prompt = "Run Task: ",
    }, function(task_name)
        M.taskipyRunner(task_name)
    end)
end

--- Run task through input instead - for ease of use.
function M.runTaskInput()
    vim.ui.input({ prompt = "Run Task: " }, function(task_name)
        local task_list = M.getTasks()
        local tasks = {}
        for _, task in pairs(task_list) do
            local task_name_check = string.match(task, "([^%s]+)")
            table.insert(tasks, task_name_check)
        end
        if vim.tbl_contains(tasks, task_name) then
            M.taskipyRunner(task_name)
        else
            vim.notify("Task does not exist", "error", { title = "py.nvim" })
        end
    end)
end

return M
