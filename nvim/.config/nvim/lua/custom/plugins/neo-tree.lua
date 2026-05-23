-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

---@module 'lazy'
---@type LazySpec
return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    filesystem = {
      hijack_netrw_behavior = 'open_default',
      bind_to_cwd = true, -- true creates a 2-way binding between vim's cwd and neo-tree's root
      filtered_items = {
        always_show = {
          '.gitignore',
          '.config',
        },
        always_show_by_pattern = {
          '.env*',
        },
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['P'] = {
            'toggle_preview',
            config = {
              use_float = false,
              use_snacks_image = true,
              use_image_nvim = true,
            },
          },

          ['l'] = 'focus_preview',
          ['<C-b>'] = { 'scroll_preview', config = { direction = 10 } },
          ['<C-f>'] = { 'scroll_preview', config = { direction = -10 } },
        },

        ['<F5>'] = 'refresh',
      },
    },
  },
}
