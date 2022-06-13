-- local Path = require("plenary.path")
-- local Job = require("plenary.job")
-- local scan = require("plenary.scandir")
local config = require("py.config")

local M = {}

do
    function M.setup(user_config)
        config.setup(user_config)

        if config.mappings() == true then
            require("py.mappings").set_mappings()
        end
    end
end

return M
