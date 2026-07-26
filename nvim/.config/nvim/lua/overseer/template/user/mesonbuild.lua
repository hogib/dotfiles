return {
  condition = {
    callback = function() return vim.fn.filereadable 'meson.build' == 1 end,
  },

  generator = function(opts, cb)
    local tasks = {}

    -- Define your build configurations and their corresponding directories
    local build_configs = {
      { name = 'Debug', dir = 'build-dbg', type = 'debug' },
      { name = 'Release', dir = 'build-rel', type = 'release' },
      { name = 'RelWithDebInfo', dir = 'build-rd', type = 'debugoptimized' },
      { name = 'MinSizeRel', dir = 'build-min', type = 'minsize' },
    }

    for _, cfg in ipairs(build_configs) do
      -- 1. Setup Task (always available so you can initialize the directory)
      table.insert(tasks, {
        name = string.format('Meson Setup: %s', cfg.name),
        builder = function()
          return {
            cmd = { 'meson', 'setup', cfg.dir, '--buildtype=' .. cfg.type },
            components = { 'default' },
          }
        end,
      })

      -- 2. Compile, Test, and Dynamic Targets (only if the directory has been set up)
      if vim.fn.isdirectory(cfg.dir) == 1 then
        table.insert(tasks, {
          name = string.format('Meson Compile All [%s]', cfg.name),
          builder = function() return { cmd = { 'meson', 'compile', '-C', cfg.dir }, components = { 'default' } } end,
        })

        table.insert(tasks, {
          name = string.format('Meson Test [%s]', cfg.name),
          builder = function() return { cmd = { 'meson', 'test', '-C', cfg.dir }, components = { 'default' } } end,
        })

        -- Dynamically extract targets for this specific build directory
        local output = vim.fn.system { 'meson', 'introspect', '--targets', cfg.dir }

        if vim.v.shell_error == 0 and output ~= '' then
          local ok, parsed_targets = pcall(vim.json.decode, output)

          if ok and type(parsed_targets) == 'table' then
            for _, target in ipairs(parsed_targets) do
              if target.name then
                table.insert(tasks, {
                  name = string.format('Meson Compile %s: %s', cfg.name, target.name),
                  builder = function()
                    return {
                      cmd = { 'meson', 'compile', '-C', cfg.dir, target.name },
                      components = { 'default' },
                    }
                  end,
                })
              end
            end
          end
        end
      end
    end

    -- 3. Return the combined list of static and dynamic tasks to Overseer
    cb(tasks)
  end,
}
