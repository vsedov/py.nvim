# py.nvim
Simple Neovim Plugin for interactive development in Python with Poetry.

Integrates primarily with Poetry Environments to manage Interactive REPLs, Dependency Management and Testing.

## To Install:

**Via Packer:**
  ```lua
  use {
       "KCaverly/py.nvim", | 'vsedov/py.nvim'
        ft = {"python"},
        config = function()
			require("py").setup()
		end
	}
```


## Setup
Defaults
  ```lua
 {
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
```


## Features:

### Interactive REPL
* Launch a IPython REPL from the poetry environment you are working in.
* Send imports, classes and functions from .py to REPL.
* Send & Replace functions/classes from IPython REPL to .py file with Treesitter.

### Poetry Environment Manager
* Add Dependencies for both Dev & Prod environments.

### Pytest Manager
* Launch pytest from Poetry environment, with notifications provided on test resolution to user.

### Taskipy Tasks
* Control your tasks that you have set within your pyproject.


### Command List
Main command is `:Py [ListShown Bellow] `
#### Ipython
- toggleIpython : toggle ipython shell.
- sendBuffer : send information to ipython shell.
- sendObj : send object / replace items in ipython shell.
- SendHighlight : send selected object using visual mode.
#### PyTest
- testStart : start any test cases you have.
- testResult : view test results of file.
#### Poetry mappings
- addDep : add dependencies to pyproject , use -D for dev depdencies.
- showPackage : show package information.
#### env mappings
- envCreate : create an env based on all python version you have on your system, env for poetry.
- dirEnvCreate : activate all direnv commands that you have set in your envrc : this will activate a direnv for you.
#### Taskipy
- taskList : provides a list of all commands in your pyproject.toml and will let you choose which one you want to run.
- tasks :  direct input for a specific task

#### default mappings :
```lua
    keymap.map("n", "p", "<cmd>lua require('py.ipython').toggleIPython()<CR>")
    keymap.map("n", "c", "<cmd>lua require('py.ipython').sendObjectsToIPython()<CR>")
    keymap.map("v", "c", '"zy:lua require("py.ipython").sendHighlightsToIPython()<CR>')
    keymap.map("v", "s", '"zy:lua require("py.ipython").sendIPythonToBuffer()<CR>')

    -- Pytest Mappings
    keymap.map("n", "t", "<cmd>lua require('py.pytest').launchPytest()<CR>")
    keymap.map("n", "r", "<cmd>lua require('py.pytest').showPytestResult()<CR>")

    -- Poetry Mappings
    keymap.map("n", "a", "<cmd>lua require('py.poetry').inputDependency()<CR>")
    keymap.map("n", "d", "<cmd>lua require('py.poetry').showPackage()<CR>")

    if config.taskipy() then
        keymap.map("n", "li", "<cmd>lua require('py.taskipy').runTasks()<cr>")
        keymap.map("n", "ll", "<cmd>lua require('py.taskipy').runTaskInput()<cr>")
    end
```
## Note
This is still wip and may change in the near future.
