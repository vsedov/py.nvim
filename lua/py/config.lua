local M = {}

M.default_config = {
    mappings = false,
    taskipy = true,
    leader = "<space>p",
    poetry_install_every = 1,
    ipython_in_vsplit = 1,
    ipython_auto_install = 1,
    ipython_auto_reload = 1,
    ipython_send_imports = 1,
    envrc = {
        "export PYTHONPATH=$(pwd)",
    },
    use_direnv = true,
}

M.config = {}

return M
