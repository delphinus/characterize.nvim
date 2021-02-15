local M = {}

local digraphs = {}
function M.digraphs(nr)
  if #digraphs == 0 then
    local out = vim.api.nvim_exec('digraphs', true)
    for line in vim.gsplit(out, '\n') do
      for digraph, n in line:gmatch'(..).-(%d+)%s*' do
        n = tonumber(n)
        if n == 10 and #digraphs == 0 then n = 0 end
        if not digraphs[n] then digraphs[n] = {} end
        table.insert(digraphs[n], digraph)
      end
    end
  end
  if nr then
    return digraphs[nr] or {}
  end
  return digraphs
end

local html_entities
function M.html_entity(nr)
  if not html_entities then
    html_entities = require'characterize.html_entities'
  end
  return html_entities[nr] and '&'..html_entities[nr]..';' or ''
end

local emojis
function M.emojis(code)
  if not emojis then emojis = require'characterize.emojis' end
  return code and emojis[code] or emojis
end

local desc
function M.description(nr, default)
  if not desc then desc = require'characterize.desc' end
  for _, t in ipairs(desc.ranges) do
    if nr > t[1] and nr < t[2] then return t[3] end
  end
  return desc.chars[nr] or default or ''
end

function M.info(chars)
  local results = M.info_table(chars)
  if #results == 0 then return 'NUL' end
  return table.concat(
    vim.tbl_map(function(r)
      local text = '<'..r.char..'>'..r.nr
      if r.nr < 256 then
        text = text..(', \\%03o'):format(r.nr)
      end
      text = text..', '..r.codepoint..' '..r.description
      for _, d in ipairs(r.digraphs) do
        text = text..', \\<C-K>'..d
      end
      for _, e in ipairs(r.emojis) do
        text = text..', '..e
      end
      if r.html_entity:len() > 0 then
        text = text..', '..r.html_entity
      end
      return text
    end, results),
    ' '
  )
end

local _n = string.char(10)
local _r = string.char(13)
function M.info_table(chars)
  if not chars or type(chars) ~= 'string' or chars:len() == 0 then
    return {}
  end
  local results = {}
  local is_old_mac = vim.bo.fileformat == 'mac'
  local c = chars
  while c:len() > 0 do
    local nr
    if c == _n then
      nr = 0
    elseif c == _r and is_old_mac then
      nr = 10
    else
      nr = vim.fn.char2nr(c)
    end
    local nr_char = vim.fn.nr2char(nr)
    local char = nr < 32 and '^'..vim.fn.nr2char(64 + nr) or nr_char
    c = vim.fn.strpart(c, nr == 0 and 1 or nr_char:len())
    table.insert(results, {
      char = char,
      nr = nr,
      codepoint = ('U+%04X'):format(nr),
      description = M.description(nr, '<unknown>'),
      digraphs = M.digraphs(nr),
      emojis = M.emojis(nr),
      html_entity = M.html_entity(nr)
    })
  end
  return results
end

function M.cursor_char()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)
  -- TODO: use api-fast way?
  return vim.fn.matchstr(line:sub(cursor[2] + 1), '.')
end

function M.cursor_info()
  return M.info(M.cursor_char())
end

local mapped_key
function M.setup(opts)
  opts = vim.tbl_extend('force', {
    map_key = 'ga',
  }, opts or {})

  if mapped_key then
    vim.api.nvim_del_keymap('n', mapped_key)
  end
  if opts.map_key and opts.map_key:len() then
    function _G.__characterize_cursor_info()
      -- TODO: Use floating windows
      print(M.cursor_info())
    end
    mapped_key = opts.map_key
    vim.api.nvim_set_keymap(
      'n',
      mapped_key,
      '<Cmd>lua _G.__characterize_cursor_info()<CR>',
      {noremap = true}
    )
  end
end

return M
