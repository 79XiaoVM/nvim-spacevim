--=============================================================================
-- prompt.lua --- prompt api for spacevim
-- Copyright (c) 2016-2019 Wang Shidong & Contributors
-- Author: Wang Shidong < wsdjeg@outlook.com >
-- URL: https://spacevim.org
-- License: GPLv3
--=============================================================================

local Key = require('spacevim.api').import('vim.keys')

local M = {}

M.__cmp = require('spacevim.api').import('vim.compatible')
M.__vim = require('spacevim.api').import('vim')


M._keys = {
    close = Key.t('<Esc>')
}

M._prompt = {
    mpt = '==>',
    cursor_begin = '',
    cursor_char = '',
    cursor_end = '',
}

M._function_key = {}

M._quit = true

M._handle_fly = ''

M._onclose = ''

M._oninputpro = ''

function M.open()
    M._quit = false
    M._build_prompt()
    if M.__cmp.fn.empty(M._prompt.cursor_begin) == 0 then
        M._handle_input(M._prompt.cursor_begin)
    else
        M._handle_input()
    end
end

function M._c_r_mode_off(timer)
    M._c_r_mode = false
end

function M._handle_input(...)
    local argv = {...}
    local begin = argv[1] or ''
    if begin ~= '' then
        if type(M._oninputpro) == 'function' then
            M._oninputpro()
        end
        if type(M._handle_fly) == 'function' then
            M._handle_fly(M._prompt.cursor_begin
            .. M._prompt.cursor_char
            .. M._prompt.cursor_end)
        end
        M._build_prompt()
    end
    M._c_r_mode = false
    while not M._quit do
        local char = M.__vim.getchar()
        if M._function_key[char] ~= nil then
            pcall(M._function_key[char])
            goto continue
        end
        if M._c_r_mode == 1 then
        elseif char == Key.t('<c-r>') then
        elseif char == Key.t('<right>') then
            M._prompt.cursor_begin = M._prompt.cursor_begin .. M._prompt.cursor_char
            M._prompt.cursor_char = M.__cmp.fn.matchstr(M._prompt.cursor_begin, '^.')
            M._prompt.cursor_end = M.__cmp.fn.substitute(M._prompt.cursor_end, '^.', '', 'g')
            M._build_prompt()
            goto continue
        elseif char == Key.t('<left>') then
        elseif char == Key.t('<C-w>') then
        elseif char == Key.t('<C-a>')  or char == Key.t('<Home>') then
        elseif char == Key.t('<C-e>')  or char == Key.t('<End>') then
        elseif char == Key.t('<C-u>') then
        elseif char == Key.t('<C-k>') then
        elseif char == Key.t('<bs>') then
        elseif (type(M._keys.close) == 'string' and char == M._keys.close)
            or (type(M._keys.close) == 'table' and vim.fn.index(M._keys.close, char) > -1 ) then
            M.close()
            break
        elseif char == Key.t('<FocusLost>') or char == Key.t('<FocusGained>') or vim.fn.char2nr(char) == 128 then
        else
        end
        if type(M._oninputpro) == 'function' then
            M._oninputpro()
        end
        if type(M._handle_fly) == 'function' then
            M._handle_fly(M._prompt.cursor_begin
            .. M._prompt.cursor_char
            .. M._prompt.cursor_end)
        end
        ::continue::
    end
end


function M._build_prompt()
    local ident = M.__cmp.fn['repeat'](' ', M.__cmp.win_screenpos(0)[2] - 1)
end

function M._clear_prompt()
    M._prompt = {
        mpt = M._prompt.mpt,
        cursor_begin = '',
        cursor_char = '',
        cursor_end = ''
    }
end

function M.close()
    if type(M._onclose) == 'function' then
        M._onclose()
    end
    M._clear_prompt()
    M._quit = true
end


return M
