# snipe-marks

Neovim snipe marks UI

## Install

Using `lazy`:

```lua
{
    "phdah/snipe-marks",
    dependencies = { "leath-dub/snipe.nvim" },
    keys = {
        {
            "<leader>fm",
            mode = "n",
            function()
                require("snipe_marks").open()
            end,
            desc = "(f)ind all (m)arks",
            silent = true,
        },
        {
            "<leader>dm",
            mode = "n",
            function()
                require("snipe_marks").delAll()
            end,
            desc = "(d)elete all (m)arks",
            silent = true,
        },
    },
}
```
