# How to Install
for example:
```lua
config = function() 
    require("translate").setup({
        model = "Qwen/Qwen2.5-7B-Instruct",
        api_base = "https://api.siliconflow.cn/v1/chat/completions",
        api_key = "<your-api-key>"
    })
end,
```
