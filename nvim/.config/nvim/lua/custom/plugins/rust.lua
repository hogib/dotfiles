return {
  'mrcjkb/rustaceanvim',
  version = '^9',
  lazy = false,
  init = function()
    vim.g.rustaceanvim = {
      server = {
        default_settings = {
          ['rust-analyzer'] = {
            check = { command = 'clippy' },
          },
        },
      },
    }
  end,
}
