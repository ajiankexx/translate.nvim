local M = {}

local print_var = require("translate.utils").print_var
local Config = require("translate.config").Config
local curl = require("plenary.curl")
local utils = require("translate.utils")

---param opts TranslateConfig
function M.setup(opts)
    Config.model = opts.model
    Config.api_base = opts.api_base
    Config.api_key = opts.api_key
end

function M.test(word)
    local word = vim.fn.expand("<cword>")
    print_var({word=word})
end

vim.api.nvim_create_user_command("Llm", function()
    local word = vim.fn.expand("<cword>")
    M.test(word)
end, {})

vim.api.nvim_create_user_command("LlmWord", function()
  local word = vim.fn.expand("<cword>")
  utils.send_request(word)
end, {})

vim.api.nvim_create_user_command("LlmModel", function()
  local model = utils.get_models()
end, {})

vim.api.nvim_create_user_command("LlmShow", function()
    print_var(Config)
end, {})

vim.api.nvim_create_user_command("LlmConfig", function(opts)
  local args = opts.fargs
  local arg_str = table.concat(args, " ")

  -- 提取每个参数值
  local api_base = string.match(arg_str, "%-%-api_base%s+([^%s]+)")
  local model    = string.match(arg_str, "%-%-model%s+([^%s]+)")
  local api_token    = string.match(arg_str, "%-%-api_token%s+([^%s]+)")

  if not api_base or not model or not api_token then
    vim.notify([[
Usage: :LlmConfig --endpoint <url> --model <name> --token <key>
Example: :LlmConfig --endpoint http://localhost:8200 --model Qwen3 --token sk-xxx
]], vim.log.levels.WARN)
    return
  end

  -- 设置到你的共享配置表中
  Config.api_base = api_base
  Config.model = model
  Config.api_key = api_token

  vim.notify("LlmConfig updated:\n" ..
    "Endpoint: " .. api_base .. "\n" ..
    "Model: " .. model .. "\n" ..
    "Token: " .. string.sub(api_token, 1, 6) .. "... (hidden)")
end, {
  nargs = "*",
  desc = "Set LLM config: --endpoint <url> --model <name> --token <sk-xxx>"
})

return M
