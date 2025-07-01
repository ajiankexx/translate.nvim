---@class TranslateConfig
---@fields tgt string?
---@fields src string?
---@fields token string?
---@fields provider string?

local M = {}
M.Config = {}
M.Config.api_base = "htts://api.siliconflow.cn/v1/chat/completions"
M.Config.model = "Qwen/Qwen2.5-7B-Instruct"
M.Config.api_key = ""
M.Config.src = "en"
M.Config.tgt = "zh"
return M
