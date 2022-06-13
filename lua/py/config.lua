local M = {}

local default_config = {

    mappings = false,

    leader = "<space>p",

    poetry_install_every = 1,

    ipython_in_vsplit = 1,
    ipython_auto_install = 1,
    ipython_auto_reload = 1,
    ipython_send_imports = 1,
}

function M.setup(user_config)
    if vim.fn.executable("poetry") == 0 then
        error("poetry is not executable")
    end

    user_config = user_config or {}
    M.config = vim.tbl_extend("keep", user_config, default_config)
end

function M.mappings()
    return M.config.mappings
end

function M.leader()
    return M.config.leader
end

function M.poetry_install_every()
    return M.config.poetry_install_every
end

function M.ipython_in_vsplit()
    return M.config.ipython_in_vsplit
end

function M.ipython_auto_install()
    return M.config.ipython_auto_install
end

function M.ipython_auto_reload()
    return M.config.ipython_auto_reload
end

function M.ipython_send_imports()
    return M.config.ipython_send_imports
end

return M
