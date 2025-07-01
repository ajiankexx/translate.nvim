local Config = require("translate.config").Config
local M = {}

---@param config table<string, string>
M.print_var = function(config)
    local lines = {}
    for k,v in pairs(config) do
        table.insert(lines, k..": "..v)
    end
    local msg = table.concat(lines, "\n")
    vim.notify(msg)
end

M.get_visual_selection = function()
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")

  local start_row = start_pos[2]
  local start_col = start_pos[3]
  local end_row = end_pos[2]
  local end_col = end_pos[3]

  if start_row > end_row or (start_row == end_row and start_col > end_col) then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)

  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_col, end_col)
  else
    lines[1] = string.sub(lines[1], start_col)
    lines[#lines] = string.sub(lines[#lines], 1, end_col)
  end

  return table.concat(lines, "\n")
end

M.get_models = function()
  local cmd = {
    "curl", "-s", "-X", "GET",
    Config.api_base.."models",
    "-H", "Content-Type: application/json",
  }

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data then return end
      local response = table.concat(data, "\n")
      local ok, result = pcall(vim.fn.json_decode, response)
      if ok and result and result.data then
        local models = {}
        for _, model in ipairs(result.data) do
          table.insert(models, model.id)
        end
        vim.notify("Models:\n" .. table.concat(models, "\n"), vim.log.levels.INFO)
      else
        vim.notify("JSON decode error or invalid response", vim.log.levels.ERROR)
      end
    end,
    -- on_stderr = function(_, err)
    --   if err and #err > 0 then
    --     vim.notify("Error:\n" .. table.concat(err, "\n"), vim.log.levels.ERROR)
    --   end
    -- end,
    on_exit = function(_, code)
      if code ~= 0 then
        vim.notify("Command exited with code: " .. code, vim.log.levels.WARN)
      end
    end,
  })
end

M.build_request_data = function(content)
  local data = {
    -- model = "Qwen/Qwen3-32B-FP8",
    model = Config.model,
    messages = {
      { role = "system", content = "simply translate the word or paragraph to chinese" },
      { role = "user", content = content }
    }
  }
  return vim.fn.json_encode(data)
end

M.send_request = function(prompt, callback)
  local json_data = M.build_request_data(prompt)

  local cmd = {
    "curl", "-s", "-X", "POST",
    Config.api_base.."chat/completions",
    -- "https://api.siliconflow.cn/v1/chat/completions",
    -- "http://localhost:8200/v1/chat/completions",
    "-H", "Content-Type: application/json",
    "-H", "Authorization: Bearer "..Config.api_key,
    "-d", json_data
  }

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data then return end
      local response = table.concat(data, "\n")

      local ok, decoded = pcall(vim.fn.json_decode, response)
      if not ok or not decoded or not decoded.choices or not decoded.choices[1] then
        vim.notify("LLM response decode error", vim.log.levels.ERROR)
        if callback then callback(nil) end
        return
      end

      local content = decoded.choices[1].message.content
      vim.notify("LLM response:\n" .. content, vim.log.levels.INFO)

      if callback then
        callback(content)
      end
    end,
    -- on_stderr = function(_, err)
    --   if err and #err > 0 then
    --     vim.notify("Error:\n" .. table.concat(err, "\n"), vim.log.levels.ERROR)
    --   end
    -- end,
    on_exit = function(_, code)
      if code ~= 0 then
        vim.notify("Request exited with code " .. code, vim.log.levels.WARN)
      end
    end
  })
end

return M
