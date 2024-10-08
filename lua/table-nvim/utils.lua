local tbl_node = 'pipe_table'
local tbl_cell = 'pipe_table_cell'
local tbl_delimiter_cell = 'pipe_table_delimiter_cell'
local tbl_align_left = 'pipe_table_align_left'
local tbl_align_right = 'pipe_table_align_right'
local tbl_node_len = #tbl_node

local conf = require('table-nvim.config')

---Returns `true` if the node is the root of a markdown table and `false` otherwise.
---@param node TSNode The node to check.
local is_tbl_root = function(node)
  return node:type() == tbl_node
end

---Returns `true` if the node belongs to a markdown table and `false` otherwise.
---@param node TSNode The node to check.
local is_tbl_node = function(node)
  return string.sub(node:type(), 1, tbl_node_len) == tbl_node
end

---@param node TSNode? A node within a markdown table
---@return TSNode? tbl_root Root node of a markdown table, if the `node` does not belong to a markdown table, then `nil` is returned
local get_tbl_root = function(node)
  if node == nil then return nil end
  if string.sub(node:type(), 1, tbl_node_len) ~= tbl_node then return nil end

  if is_tbl_root(node) then return node end

  while true do
    node = node:parent()
    if node == nil then return nil end
    if is_tbl_root(node) then return node end
  end
end

---Returns `true` if the provided node is a table cell, and `false` otherwise.
local is_tbl_cell = function(node)
  local type = node:type()
  return type == tbl_cell or type == tbl_delimiter_cell
end

---Returns `true` if the provided node is an alignment node, and `false` otherwise.
local is_tbl_align = function(node)
  local type = node:type()
  return type == tbl_align_left or type == tbl_align_right
end

---Returns rows for a new table that is not surrounded by pipes.
---@return string[]
local gen_table_alt = function()
  local padd             = conf.get_config().padd_column_separators
  local column_separator = padd and ' | ' or '|'

  local header_row       = { 'Column1', column_separator, 'Column2' }
  local delimiter_row    = { '-------', column_separator, '-------' }
  local row              = { 'x      ', column_separator, 'x' }

  return {
    table.concat(header_row),
    table.concat(delimiter_row),
    table.concat(row),
  }
end

---Returns rows for a new table.
---@return string[]
local gen_table = function()
  local padd            = conf.get_config().padd_column_separators
  local first_separator = padd and '| ' or '|'
  local last_separator  = padd and ' |' or '|'
  local separator       = padd and ' | ' or '|'

  local header_row      = { first_separator, 'Column1', separator, 'Column2', last_separator }
  local delimiter_row   = { first_separator, '-------', separator, '-------', last_separator }
  local row             = { first_separator, 'x      ', separator, 'x      ', last_separator }

  return {
    table.concat(header_row),
    table.concat(delimiter_row),
    table.concat(row),
  }
end

---Iterate of all children of a treesitter node.
---@param node TSNode
---@return fun(): integer?, TSNode?
local iter_children = function(node)
  local n = node:child_count()
  local i = -1
  return function()
    i = i + 1
    if i < n then return i + 1, node:child(i) end
  end
end

---Iterate of all named children of a treesitter node.
---@param node TSNode
---@return fun(): integer?, TSNode?
local iter_named_children = function(node)
  local n = node:named_child_count()
  local i = -1
  return function()
    i = i + 1
    if i < n then return i + 1, node:named_child(i) end
  end
end

return {
  get_tbl_root = get_tbl_root,
  is_tbl_root = is_tbl_root,
  is_tbl_node = is_tbl_node,
  is_tbl_cell = is_tbl_cell,
  is_tbl_align = is_tbl_align,
  gen_table = gen_table,
  gen_table_alt = gen_table_alt,
  iter_children = iter_children,
  iter_named_children = iter_named_children,
}
