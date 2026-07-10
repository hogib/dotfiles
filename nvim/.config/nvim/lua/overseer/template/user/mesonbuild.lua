return {
  condition = {
    callback = function() return vim.fn.filereadable 'meson.build' == 1 end,
  },

  generator = function(opts, cb)
    local tasks = {
      {
        name = 'Meson: Setup',
        builder = function() return { cmd = { 'meson', 'setup', 'builddir' }, components = { 'default' } } end,
      },
      {
        name = 'Meson: Compile All',
        builder = function() return { cmd = { 'meson', 'compile', '-C', 'builddir' }, components = { 'default' } } end,
      },
      {
        name = 'Meson: Test',
        builder = function() return { cmd = { 'meson', 'test', '-C', 'builddir' }, components = { 'default' } } end,
      },
    }

    -- dynamicccc didnt write this btw
    if vim.fn.isdirectory 'builddir' == 1 then
      local output = vim.fn.system { 'meson', 'introspect', '--targets', 'builddir' }

      if vim.v.shell_error == 0 and output ~= '' then
        local ok, parsed_targets = pcall(vim.json.decode, output)

        if ok and type(parsed_targets) == 'table' then
          for _, target in ipairs(parsed_targets) do
            if target.name then
              table.insert(tasks, {
                name = 'Meson Compile: ' .. target.name,
                builder = function()
                  return {
                    cmd = { 'meson', 'compile', '-C', 'builddir', target.name },
                    components = { 'default' },
                  }
                end,
              })
            end
          end
        end
      end
    end

    -- 3. Return the combined list of static and dynamic tasks to Overseer
    cb(tasks)
  end,
}
