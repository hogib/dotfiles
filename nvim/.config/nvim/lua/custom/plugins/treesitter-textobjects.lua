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
      vim.keymap.set({ 'x', 'o' }, 'af', function() select.select_textobject('@function.outer', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'if', function() select.select_textobject('@function.inner', 'textobjects') end)

      -- Classes
      vim.keymap.set({ 'x', 'o' }, 'ac', function() select.select_textobject('@class.outer', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'ic', function() select.select_textobject('@class.inner', 'textobjects') end)

      -- Scope
      vim.keymap.set({ 'x', 'o' }, 'as', function() select.select_textobject('@local.scope', 'locals') end)

      -- Conditionals (if statements, switch cases)
      vim.keymap.set({ 'x', 'o' }, 'ai', function() select.select_textobject('@conditional.outer', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'ii', function() select.select_textobject('@conditional.inner', 'textobjects') end)

      -- Loops (for, while)
      vim.keymap.set({ 'x', 'o' }, 'al', function() select.select_textobject('@loop.outer', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'il', function() select.select_textobject('@loop.inner', 'textobjects') end)

      -- Blocks / {} Scopes
      vim.keymap.set({ 'x', 'o' }, 'ab', function() select.select_textobject('@block.outer', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'ib', function() select.select_textobject('@block.inner', 'textobjects') end)

      -- Comments
      vim.keymap.set({ 'x', 'o' }, 'a/', function() select.select_textobject('@comment.outer', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'i/', function() select.select_textobject('@comment.inner', 'textobjects') end)
    end,
  },
}
