return {
  'stevearc/overseer.nvim',
  dependencies = { 'stevearc/dressing.nvim' },

  cmd = {
    'OverseerRun',
    'OverseerOpen',
    'OverseerInfo',
    'OverseerToggle',
    'OverseerShell',
    'OverseerTaskAction',
  },

  keys = {
    { '<leader>rr', '<cmd>OverseerRun<CR>', desc = 'Run task' },
    { '<leader>rt', '<cmd>OverseerToggle<CR>', desc = 'Toggle task list' },
    { '<leader>rc', '<cmd>OverseerShell<CR>', desc = 'Run shell command' },
    { '<leader>ra', '<cmd>OverseerTaskAction<CR>', desc = 'Task action' },
  },

  opts = {
    strategy = 'terminal',
    templates = { 'builtin', 'user.mesonbuild' },
    task_list = {
      direction = 'bottom',
      min_height = 10,
      max_height = 20,
      default_detail = 1,
    },
    component_aliases = {
      default = {
        'on_exit_set_status',
        'on_complete_notify',
        { 'on_complete_dispose', require_view = { 'SUCCESS', 'FAILURE' } },
      },
    },
  },
}
