return {
  'coder/claudecode.nvim',
  dependencies = { 'folke/snacks.nvim' },
  config = true,

  keys = {
    { '<leader>w', nil, desc = 'AI/Claude Code' },
    { '<leader>wc', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude' },
    { '<leader>wf', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
    { '<leader>wr', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume Claude' },
    { '<leader>wC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
    { '<leader>wm', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select Claude model' },
    { '<leader>wb', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
    { '<leader>ws', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
    {
      '<leader>as',
      '<cmd>ClaudeCodeTreeAdd<cr>',
      desc = 'Add file',
      ft = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw', 'snacks_picker_list' },
    },
  },
}
