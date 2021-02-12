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

local _n = string.char(10)
local _r = string.char(13)
function M.info(chars)
  if not chars or chars:len() == 0 then return 'NUL' end
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
    local result = '<'..char..'> '..nr
    if nr < 256 then
      result = result..(', \\%03o'):format(nr)
    end
    result = result..(', U+%04X %s'):format(nr, M.description(nr, '<unknown>'))
    for _, d in ipairs(M.digraphs(nr)) do
      result = result..', \\<C-K>'..d
    end
    for _, e in ipairs(M.emojis(nr)) do
      result = result..', '..e
    end
    local entity = M.html_entity(nr)
    if entity:len() > 0 then
      result = result..', '..entity
    end
    table.insert(results, result)
  end
  return table.concat(results, ' ')
end

function M.setup(opts)

end

return M
