return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      local parsers = { 'c', 'cpp', 'lua', 'vim', 'vimdoc' }
      local installed = require('nvim-treesitter.config').get_installed()

      local missing = vim.iter(parsers):filter(function(p) return not vim.tbl_contains(installed, p) end):totable()

      if #missing > 0 then require('nvim-treesitter').install(missing) end

      vim.api.nvim_create_autocmd('FileType', {
        desc = 'Enable native Tree-sitter syntax highlighting',
        callback = function() pcall(vim.treesitter.start) end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = {
          lookahead = true, -- Automatically jump forward to matching object
        },
      }

      local ts_select = require 'nvim-treesitter-textobjects.select'

      local function map(keys, query, desc)
        vim.keymap.set({ 'x', 'o' }, keys, function() ts_select.select_textobject(query, 'textobjects') end, { desc = desc })
      end

      -- Functions
      map('af', '@function.outer', 'Select outer function')
      map('if', '@function.inner', 'Select inner function')

      -- C Structs / Enums / Classes
      map('ac', '@class.outer', 'Select outer struct/enum')
      map('ic', '@class.inner', 'Select inner struct/enum')

      -- Parameters
      map('aa', '@parameter.outer', 'Select outer parameter')
      map('ia', '@parameter.inner', 'Select inner parameter')

      local ts_move = require 'nvim-treesitter-textobjects.move'

      -- Helper function to map movement keys
      local function map_move(keys, func, query, desc)
        vim.keymap.set({ 'n', 'x', 'o' }, keys, function() func(query, 'textobjects') end, { desc = desc })
      end

      -- Jump forward
      map_move(']f', ts_move.goto_next_start, '@function.outer', 'Next function start')
      map_move(']c', ts_move.goto_next_start, '@class.outer', 'Next struct/enum start')
      map_move(']a', ts_move.goto_next_start, '@parameter.inner', 'Next parameter start')

      -- Jump backward
      map_move('[f', ts_move.goto_previous_start, '@function.outer', 'Previous function start')
      map_move('[c', ts_move.goto_previous_start, '@class.outer', 'Previous struct/enum start')
      map_move('[a', ts_move.goto_previous_start, '@parameter.inner', 'Previous parameter start')

      -- Jump to the END of a text object
      map_move(']F', ts_move.goto_next_end, '@function.outer', 'Next function end')
      map_move(']C', ts_move.goto_next_end, '@class.outer', 'Next struct/enum end')

      map_move('[F', ts_move.goto_previous_end, '@function.outer', 'Previous function end')
      map_move('[C', ts_move.goto_previous_end, '@class.outer', 'Previous struct/enum end')
    end,
  },
}
