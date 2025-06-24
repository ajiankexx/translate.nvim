local M = {}

local print_var = require("utils").print_var
local Config = require("types").Config
local curl = require("plenary.curl")

---param opts TranslateConfig
function M.setup(opts)
    M.opts = opts
    Config.tgt = opts.tgt or Config.tgt
    Config.src = opts.src or Config.src
    Config.token = opts.token
    Config.provider_endpoint = opts.provider or Config.provider
end

function M.translate(word)
    -- curl.post(Config.provider_endpoint, {
    --     body = '{"key":"value"}',
    --     headers = {
    --         ['Content-Type'] = 'application/json',
    --         ['Authorization'] = string.format("Bearer %s", Config.token)
    --     },
    --     callback = function(response)
    --         Utils.print_var(response)
    --     end
    -- })
    return "result"
end

vim.api.nvim_create_user_command("Trans", function()
    local word = vim.fn.expand("<cword>")
    local result = M.translate(word)
    print_var({result = result})
end, {})
