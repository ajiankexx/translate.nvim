local curl = require("plenary.curl")

if curl ~= nil then
    vim.notify("successfule")
else 
    vim.notify("fail")
end
