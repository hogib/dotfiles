local is_meson_project = {
  callback = function(search) return vim.fn.filereadable 'meson.build' == 1 end,
}

return {
  {
    name = 'Meson Compile',
    builder = function()
      return {
        cmd = { 'meson' },
        args = { 'compile', '-C', 'builddir' },
        components = { 'default', { 'on_output_quickfix', open = true } },
      }
    end,
    condition = is_meson_project,
  },
  {
    name = 'Meson Test',
    builder = function()
      return {
        cmd = { 'meson' },
        args = { 'test', '-C', 'builddir' },
        components = { 'default', { 'on_output_quickfix', open = true } },
      }
    end,
    condition = is_meson_project,
  },
  {
    name = 'Meson Clean',
    builder = function()
      return {
        cmd = { 'ninja' },
        args = { '-C', 'builddir', 'clean' },
        components = { 'default' },
      }
    end,
    condition = is_meson_project,
  },
}
