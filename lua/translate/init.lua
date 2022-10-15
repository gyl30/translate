local M = {}
local title = "translate"
local notify = require("notify")
local job = require('plenary.job')

local function getVisualSelection()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cline, ccol = cursor[1], cursor[2]
    local vline, vcol = vim.fn.line('v'), vim.fn.col('v')

    local sline, scol
    local eline, ecol
    if cline == vline then
        if ccol <= vcol then
            sline, scol = cline, ccol
            eline, ecol = vline, vcol
            scol = scol + 1
        else
            sline, scol = vline, vcol
            eline, ecol = cline, ccol
            ecol = ecol + 1
        end
    elseif cline < vline then
        sline, scol = cline, ccol
        eline, ecol = vline, vcol
        scol = scol + 1
    else
        sline, scol = vline, vcol
        eline, ecol = cline, ccol
        ecol = ecol + 1
    end

    local mode = vim.api.nvim_get_mode().mode

    if mode == "V" or mode == "CTRL-V" or mode == "\22" then
        scol = 1
        ecol = nil
    end

    local lines = vim.api.nvim_buf_get_lines(0, sline - 1, eline, 0)
    if #lines == 0 then return end

    local startText, endText
    if #lines == 1 then
        startText = string.sub(lines[1], scol, ecol)
    else
        startText = string.sub(lines[1], scol)
        endText = string.sub(lines[#lines], 1, ecol)
    end

    local selection = {startText}
    if #lines > 2 then
        vim.list_extend(selection, vim.list_slice(lines, 2, #lines - 1))
    end
    table.insert(selection, endText)
    return  table.concat(selection, "\n")
end

function M.translate(content)
    local args = ' -X socks5://127.0.0.1:1080 https://google.com'
    local title = "translate"

    job:new({
        command = "trans",
        args = {content, '-x',"127.0.0.1:8889", "-show-prompt-message=N","-no-ansi","-show-languages=N", "-show-translation-phonetics=N","-show-alternatives=N",":zh" },
        on_exit = function(j, exit_code)
            local res = table.concat(j:result(), "\n")
            local notify_type = "info"

            if exit_code ~=0 then
                notify_type = "error"
            end
            notify(res, notify_type,{title = title, render = "minimal", stages = "fade"})
        end,
    }):start()

end
function M.translateN()
    M.translate(vim.call('expand','<cword>'))
end
function M.translateV()
    M.translate(getVisualSelection())
end

return M
