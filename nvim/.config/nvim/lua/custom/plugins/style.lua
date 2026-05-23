return {
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- Disable italics in comments
        },
        transparent = true,
        on_highlights = function(hl, c)
          hl.TelescopeNormal = {
            fg = c.fg_dark,
          }
          hl.TelescopeBorder = {
            fg = c.bg_dark,
          }
          hl.NeoTreeNormal = {
            fg = c.bg_light,
          }
          hl.NeoTreeNormalNC = {
            fg = c.bg_light,
          }
        end,
      }

      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'tokyonight-night'
      vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
    end,
  },
}
