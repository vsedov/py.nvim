local poetry = require("py.poetry")
local config = require("py.config")
local text_objects = require("py.text_objects")

local M = {}

M.ipython = {
    opened = 0,
    win_id = nil,
    buf_id = nil,
    chan_id = nil,
    launch_buf = nil,
    launch_win = nil,
}

function M.launchIPython()
    -- Get Current Details
    local launch_buf = vim.api.nvim_get_current_buf()
    local launch_win = vim.api.nvim_get_current_win()
    local current_path = vim.api.nvim_exec(":echo @%", 1)

    -- Ensure Current File is .py
    require("plenary.filetype").detect(current_path)

    -- Get Poetry File in Parent
    local poetry_dir, _ = poetry.findPoetry()

    if poetry_dir == nil then
        return nil
    end

    -- Install IPython Automatically
    if config.ipython_auto_install() == 1 then
        poetry.addDependency("--dev ipython", { silent = true })
    end

    -- Run Poetry Install Automatically
    if config.poetry_install_every() == 1 then
        poetry.installPoetry()
    end

    -- Navigate to the IPython
    local ipython_str = "cd " .. poetry_dir .. " && clear && clear && poetry run ipython"

    -- Run AutoReload on Launch
    if config.ipython_auto_reload() == 1 then
        ipython_str = ipython_str .. " --ext=autoreload --InteractiveShellApp.exec_lines='autoreload 2'"
    end

    -- Launch Terminal
    if config.ipython_in_vsplit() == 1 then
        vim.api.nvim_exec(":vsplit", 0)
    end

    local bufn = vim.api.nvim_create_buf(true, true)
    local current_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(current_win, bufn)

    local chan = vim.fn.termopen(ipython_str, {
        on_exit = function()
            -- local chan = vim.api.nvim_get_current_buf()
            M.ipython.opened = 0
            M.ipython.win_id = current_win
            M.ipython.buf_id = bufn
            M.ipython.chan_id = chan
            M.ipython.launch_buf = launch_buf
            M.ipython.launch_win = launch_win
        end,
    })

    M.ipython.opened = 1
    M.ipython.win_id = current_win
    M.ipython.buf_id = bufn
    M.ipython.chan_id = chan
    M.ipython.launch_buf = launch_buf
    M.ipython.launch_win = launch_win

    if config.ipython_send_imports() == 1 then
        vim.api.nvim_set_current_win(launch_win)
        M.sendImportsToIPython()
    else
        vim.api.nvim_set_current_win(M.ipython_win_id)
    end
end

function M.killIPython()
    if M.ipython.opened == 1 then
        vim.api.nvim_set_current_win(M.ipython.win_id)
        vim.api.nvim_input("<ESC>")
        vim.api.nvim_input(":bd!<CR>")
    end
end

function M.toggleIPython()
    if M.ipython.opened == 1 then
        M.killIPython()
    else
        M.launchIPython()
    end
end

function M.sendToIPython(message)
    message = vim.api.nvim_replace_termcodes("<esc>[200~" .. message .. "<esc>[201~", true, false, true)

    if M.ipython.chan_id ~= nil then
        vim.api.nvim_chan_send(M.ipython.chan_id, message)
        vim.api.nvim_set_current_win(M.ipython.win_id)
        vim.api.nvim_exec(":startinsert", 0)
    end
end

function M.sendImportsToIPython()
    local message = text_objects.getImports()
    if message ~= nil then
        M.sendToIPython(message)
    end
end

function M.sendObjectsToIPython()
    local message = text_objects.getObject()
    if message ~= nil then
        M.sendToIPython(message)
    end
end

function M.sendHighlightsToIPython()
    local message = text_objects.getHighlighted()
    if message ~= nil then
        M.sendToIPython(message)
    end
end

function M.sendIPythonToBuffer()
    local message = text_objects.getIPythonHighlighted()
    local parsed = text_objects.parsePythonObject(message[1])
    vim.api.nvim_set_current_win(M.ipython.launch_win)
    local node = text_objects.getPythonObject(parsed[1], parsed[2])

    -- Highlight Node
    text_objects.highlightNode(node, M.ipython.launch_buf)

    -- Replace Text
    text_objects.replaceText(M.ipython.launch_buf, node, message)
end

return M
