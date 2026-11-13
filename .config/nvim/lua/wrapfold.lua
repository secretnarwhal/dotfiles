-- Collapsible soft-wrapped lines.
-- Wraps the treesitter foldexpr so that any line that wraps onto more than one
-- screen row also becomes its own one-line fold. It gets the normal caret in the
-- fold column; click it or press `za` to collapse the line to a single row.
-- (A one-line fold can close because 'foldminlines' counts screen rows.)

local M = {}

-- Text width per window, cached briefly since foldexpr runs once per line.
local cache = {}
local function text_width(win)
    local now = vim.uv.now()
    local c = cache[win]
    if not c or now - c.t > 200 then
        local info = vim.fn.getwininfo(win)[1]
        c = { t = now, w = info and (info.width - info.textoff) or math.huge }
        cache[win] = c
    end
    return c.w
end

function M.foldexpr(lnum)
    local ts = vim.treesitter.foldexpr(lnum)
    local win = vim.api.nvim_get_current_win()
    if not vim.wo[win].wrap or vim.bo.buftype ~= "" then return ts end

    local s = tostring(ts)
    if s:sub(1, 1) == ">" then return ts end -- line already starts a fold (e.g. a heading)

    local line = vim.fn.getline(lnum)
    if #line == 0 or vim.fn.strdisplaywidth(line) <= text_width(win) then return ts end

    local level = tonumber(s:match("%d+")) or 0
    return ">" .. (level + 1)
end

-- Recompute folds after a resize (wrapping changes with window width).
local function recompute(win)
    if vim.api.nvim_win_is_valid(win) and vim.wo[win].foldmethod == "expr" then
        cache[win] = nil
        vim.api.nvim_win_call(win, function() vim.wo.foldexpr = vim.wo.foldexpr end)
    end
end

function M.setup()
    local group = vim.api.nvim_create_augroup("wrapfold", { clear = true })
    vim.api.nvim_create_autocmd("WinResized", {
        group = group,
        callback = function()
            for _, w in ipairs(vim.v.event.windows or {}) do recompute(w) end
        end,
    })
    vim.api.nvim_create_autocmd("WinClosed", {
        group = group,
        callback = function(ev) cache[tonumber(ev.match)] = nil end,
    })
end

return M
