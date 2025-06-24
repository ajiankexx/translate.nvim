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
  -- 获取起始和结束位置（[1]-行，[2]-列）
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")

  -- 解包
  local start_row = start_pos[2]
  local start_col = start_pos[3]
  local end_row = end_pos[2]
  local end_col = end_pos[3]

  -- 如果用户反选了，交换位置
  if start_row > end_row or (start_row == end_row and start_col > end_col) then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end

  -- 获取行内容
  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)

  -- 修剪首行和末行
  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_col, end_col)
  else
    lines[1] = string.sub(lines[1], start_col)
    lines[#lines] = string.sub(lines[#lines], 1, end_col)
  end

  return table.concat(lines, "\n")
end
return M
