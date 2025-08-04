local function log_error(mes)
    vim.notify("[snipe-marks]: " .. mes, vim.log.levels.ERROR)
end

local success, Menu = pcall(require, "snipe.menu")
if not success then
    log_error("could not load snipe.menu, make sure it's installed")
end
local M = {}

local function isUpper(char)
    return #char == 1 and (65 <= char:byte() and char:byte() <= 90)
end

local function isLower(char)
    return #char == 1 and (97 <= char:byte() and char:byte() <= 122)
end

local function parseMarks(items, list, cb)
    for _, markInfo in pairs(list) do
        local mark = markInfo.mark:gsub("'", "")
        local filePath
        if markInfo.file ~= nil then
            filePath = markInfo.file
        else
            filePath = vim.api.nvim_buf_get_name(0)
        end
        local path = vim.fn.fnamemodify(filePath, ":h")
        local file = vim.fn.fnamemodify(filePath, ":t")
        if cb(mark) then
            table.insert(items, {
                mark = mark,
                path = path,
                file = file,
                text = "Mark: " .. mark .. " File: " .. file,
            })
        end
    end
end

local function getMarks()
    local items = {}
    parseMarks(items, vim.fn.getmarklist(), isUpper)
    parseMarks(items, vim.fn.getmarklist(vim.api.nvim_get_current_buf()), isLower)

    return items
end

local function openMark(mark)
    vim.cmd("normal! '" .. mark)
    vim.cmd("normal! zz")
end

local menu = Menu:new()

local function setKeymaps(m)
    vim.keymap.set("n", "q", function()
        m:close()
    end, { nowait = true, buffer = m.buf })

    vim.keymap.set("n", "<C-j>", function()
        local hovered = m:hovered()
        m:close()
        openMark(m.items[hovered].mark)
    end, { nowait = true, buffer = m.buf })
end
menu:add_new_buffer_callback(setKeymaps)

function M.open()
    menu:open(getMarks(), function(m, i)
        print("Opening mark: " .. m.items[i].file)
        m:close()

        vim.print(m.items[i].mark)
        openMark(m.items[i].mark)
    end, function(item)
        local text = item.mark .. " : " .. item.file .. " " .. item.path
        local hl = {}

        -- Highlight mark
        table.insert(hl, { first = 0, last = #item.mark, hlgroup = "String" })
        -- Highlight " : "
        table.insert(hl, {
            first = 1 + #item.mark,
            last = 1 + #item.mark + 3,
            hlgroup = "comment",
        })
        -- Highlight file
        table.insert(hl, {
            first = 1 + #item.mark + 3,
            last = 1 + #item.mark + 3 + #item.file + 1,
            hlgroup = "Directory",
        })
        -- Highlight path
        table.insert(hl, {
            first = 1 + #item.mark + 3 + #item.file + 1,
            last = 1 + #item.mark + 3 + #item.file + 1 + #item.path,
            hlgroup = "comment",
        })

        return text, hl
    end, 10)
end

function M.delAll()
    vim.cmd("delmarks a-z A-Z")
end
return M
