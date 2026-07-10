local files = vim.fn.globpath(vim.fn.stdpath 'config' .. '/lua/overseer/template/user', '*.lua', false, true)
local templates = {}

for _, file in ipairs(files) do
  local filename = vim.fn.fnamemodify(file, ':t')
  if filename ~= 'init.lua' then
    -- Strip the .lua extension and format it as a module path
    local module_name = filename:gsub('%.lua$', '')
    table.insert(templates, 'user.' .. module_name)
  end
end

return templates
