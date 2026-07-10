return {
  'stevearc/overseer.nvim',
  config = function()
    require('overseer').setup {
      -- Strategy used for running tasks
      strategy = 'terminal',

      -- Template modules to load
      templates = { 'builtin', 'user' },

      -- Configure the task list UI
      task_list = {
        direction = 'bottom',
        min_height = 10,
        max_height = 20,
        default_detail = 1,
      },

      -- Aliases for component lists
      component_aliases = {
        -- Most tasks are initialized with the default components
        default = {
          'on_exit_set_status',
          'on_complete_notify',
          { 'on_complete_dispose', require_view = { 'SUCCESS', 'FAILURE' } },
        },
      },
    }

    -- Set up useful keymaps
    vim.keymap.set('n', '<leader>rr', '<cmd>OverseerRun<CR>', { desc = 'Run task' })
    vim.keymap.set('n', '<leader>rt', '<cmd>OverseerToggle<CR>', { desc = 'Toggle task list' })
    vim.keymap.set('n', '<leader>rc', '<cmd>OverseerRunCmd<CR>', { desc = 'Run shell command' })
    vim.keymap.set('n', '<leader>ra', '<cmd>OverseerTaskAction<CR>', { desc = 'Task action' })
    vim.keymap.set('n', '<leader>ri', '<cmd>OverseerInfo<CR>', { desc = 'Overseer Info' })
  end,
}
