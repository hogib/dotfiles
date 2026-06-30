return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      local ok_blink, blink = pcall(require, 'blink.cmp')
      if ok_blink then capabilities = blink.get_lsp_capabilities(capabilities) end

      local servers = {
        clangd = {
          cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--header-insertion=iwyu',
          },
          init_options = {},
        },
        pyright = {},
        rust_analyzer = {},
        gopls = {},
        bashls = {},
        cmake = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              diagnostics = {
                globals = { 'vim' },
              },
            },
          },
        },
        ts_ls = {},
      }

      require('mason-tool-installer').setup {
        ensure_installed = {
          'clangd',
          'pyright',
          'rust-analyzer',
          'gopls',
          'bash-language-server',
          'cmake-language-server',
          'lua-language-server',
          'typescript-language-server',
          'stylua',
          'black',
          'isort',
          'goimports',
          'shfmt',
          'clang-format',
          'prettierd',
          'prettier',
        },
      }

      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
      }

      for name, config in pairs(servers) do
        config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, config.capabilities or {})
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
      end
    end,
  },

  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function() require('conform').format { async = true, lsp_format = 'fallback' } end,
        mode = '',
        desc = 'Format buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        if ft == 'c' or ft == 'cpp' then return nil end

        return {
          timeout_ms = 500,
          lsp_format = 'fallback',
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        go = { 'gofmt', 'goimports' },
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        bash = { 'shfmt' },
      },
      formatters = {
        ['clang-format'] = {
          prepend_args = { '--style=file', '--fallback-style=LLVM' },
        },
      },
    },
  },

  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function() require('luasnip.loaders.from_vscode').lazy_load() end,
          },
        },
      },
    },
    opts = {
      keymap = { preset = 'default' },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
        ghost_text = {
          enabled = true,
        },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      snippets = {
        preset = 'luasnip',
      },
      signature = {
        enabled = true,
      },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
  },
}
