return {
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    init = function() vim.g.no_plugin_maps = true end,
    config = function()
      -- Setup the plugin options
      require('nvim-treesitter-textobjects').setup {
        lookahead = true,
        selection_modes = {
          ['@parameter.outer'] = 'v', -- charwise
          ['@function.outer'] = 'v', -- linewise
          ['@class.outer'] = '<c-v>', -- blockwise
        },
      }

      -- Define the keymaps
      local select = require 'nvim-treesitter-textobjects.select'

      -- Functions
      vim.keymap.set({ 'x', 'o' }, 'af', function() select.select_textobject('@function.outer', 'textobjects') end, { desc = 'function' })
      vim.keymap.set({ 'x', 'o' }, 'if', function() select.select_textobject('@function.inner', 'textobjects') end, { desc = 'function' })

      -- Classes
      vim.keymap.set({ 'x', 'o' }, 'ac', function() select.select_textobject('@class.outer', 'textobjects') end, { desc = 'class' })
      vim.keymap.set({ 'x', 'o' }, 'ic', function() select.select_textobject('@class.inner', 'textobjects') end, { desc = 'class' })

      -- Scope
      vim.keymap.set({ 'x', 'o' }, 'ao', function() select.select_textobject('@local.scope', 'locals') end, { desc = 'scope' })

      -- Conditionals (if statements, switch cases)
      vim.keymap.set({ 'x', 'o' }, 'ai', function() select.select_textobject('@conditional.outer', 'textobjects') end, { desc = 'conditional' })
      vim.keymap.set({ 'x', 'o' }, 'ii', function() select.select_textobject('@conditional.inner', 'textobjects') end, { desc = 'conditional' })

      -- Loops (for, while)
      vim.keymap.set({ 'x', 'o' }, 'al', function() select.select_textobject('@loop.outer', 'textobjects') end, { desc = 'loop' })
      vim.keymap.set({ 'x', 'o' }, 'il', function() select.select_textobject('@loop.inner', 'textobjects') end, { desc = 'loop' })

      -- Blocks / {} Scopes
      vim.keymap.set({ 'x', 'o' }, 'ab', function() select.select_textobject('@block.outer', 'textobjects') end, { desc = 'block' })
      vim.keymap.set({ 'x', 'o' }, 'ib', function() select.select_textobject('@block.inner', 'textobjects') end, { desc = 'block' })

      -- Comments
      vim.keymap.set({ 'x', 'o' }, 'a/', function() select.select_textobject('@comment.outer', 'textobjects') end, { desc = 'comment block' })
      vim.keymap.set({ 'x', 'o' }, 'i/', function() select.select_textobject('@comment.inner', 'textobjects') end, { desc = 'comment block' })

      vim.keymap.set({ 'x', 'o' }, 'at', function() select.select_textobject('@struct.outer', 'textobjects') end, { desc = 'struct' })
      vim.keymap.set({ 'x', 'o' }, 'it', function() select.select_textobject('@struct.inner', 'textobjects') end, { desc = 'struct' })

      vim.keymap.set('n', '<leader>I', function() require('nvim-treesitter-textobjects.swap').swap_next '@parameter.inner' end)
      vim.keymap.set('n', '<leader>A', function() require('nvim-treesitter-textobjects.swap').swap_next '@parameter.outer' end)
    end,
  },
}
