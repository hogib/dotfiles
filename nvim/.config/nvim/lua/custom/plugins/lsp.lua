return {
  {
    -- Completion and types for `vim.*` and plugin APIs when editing this config
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    lazy = false,
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

      local nproc = vim.uv.available_parallelism()
      local jnproc = '--j=' .. math.max(1, nproc - 1)

      local servers = {
        clangd = {
          cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--header-insertion=iwyu',
            '--completion-style=detailed',
            '--function-arg-placeholders',
            '--fallback-style=llvm',
            jnproc,
          },
          init_options = {},
        },
        gopls = {},
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = 'standard',
                diagnosticMode = 'openFilesOnly',
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        bashls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
        mesonlsp = {},
        ts_ls = {},
        just = {},
        texlab = {
          settings = {
            texlab = {
              -- vimtex does the building and forward search; chktex runs via nvim-lint
              build = { onSave = false },
              chktex = { onOpenAndSave = false, onEdit = false },
            },
          },
        },
      }

      require('mason-tool-installer').setup {
        run_on_start = false,
        ensure_installed = {
          'gopls',
          'just',
          'bash-language-server',
          'basedpyright',
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
          'mesonlsp',
          'texlab',
          'tex-fmt',
          -- linters
          'ruff',
          'shellcheck',
          'golangci-lint',
        },
      }

      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers),
        automatic_enable = false,
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
        -- isort sorts imports, then black formats; both need to run
        python = { 'isort', 'black' },
        -- goimports is gofmt plus import fixing; gofmt is the fallback
        go = { 'goimports', 'gofmt', stop_after_first = true },
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        zsh = { 'shfmt' },
        meson = { 'meson_format' },
        markdown = { 'prettier' },
        tex = { 'tex-fmt' },
      },
      formatters = {
        ['clang-format'] = {
          prepend_args = { '--style=file', '--fallback-style=LLVM' },
        },
        -- shfmt guesses the dialect from the file extension, which misses
        -- ~/.zshrc and friends
        shfmt = {
          prepend_args = function(_, ctx)
            if vim.bo[ctx.buf].filetype == 'zsh' then return { '-ln', 'zsh' } end
            return {}
          end,
        },
        -- Keep line breaks as written instead of hard-wrapping at 80 columns
        ['tex-fmt'] = { prepend_args = { '--nowrap' } },
        ['meson_format'] = {
          command = 'meson',
          args = { 'format', '-' },
          stdin = true,
        },
      },
    },
  },

  {
    'saghen/blink.cmp',
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
      keymap = { preset = 'super-tab' },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
        ghost_text = {
          enabled = true,
        },
        trigger = {
          show_in_snippet = false,
        },
      },
      sources = {
        default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
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
